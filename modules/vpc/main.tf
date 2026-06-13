locals {
  base_tags = merge(var.tags, {
    ManagedBy        = "Terraform"
    Module           = "modules/vpc"
    NIS2Controls     = "Art21-2-b"
    ISO27001Controls = "A8.16_A8.22"
  })
}

# ---------------------------------------------------------------------------
# VPC
# ---------------------------------------------------------------------------
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.base_tags, { Name = var.vpc_name })
}

# ---------------------------------------------------------------------------
# Internet Gateway (for public subnets)
# ---------------------------------------------------------------------------
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = merge(local.base_tags, { Name = "${var.vpc_name}-igw" })
}

# ---------------------------------------------------------------------------
# Subnets — public + private, one each per AZ
# ---------------------------------------------------------------------------
resource "aws_subnet" "public" {
  for_each = { for idx, az in var.availability_zones : az => idx }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[each.value]
  availability_zone       = each.key
  map_public_ip_on_launch = false # NIS2: no automatic public IPs

  tags = merge(local.base_tags, {
    Name = "${var.vpc_name}-public-${each.key}"
    Tier = "public"
  })
}

resource "aws_subnet" "private" {
  for_each = { for idx, az in var.availability_zones : az => idx }

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[each.value]
  availability_zone = each.key

  tags = merge(local.base_tags, {
    Name = "${var.vpc_name}-private-${each.key}"
    Tier = "private"
  })
}

# ---------------------------------------------------------------------------
# NAT Gateway (private subnet egress)
# ---------------------------------------------------------------------------
resource "aws_eip" "nat" {
  # checkov:skip=CKV2_AWS_19:This EIP is attached to a NAT gateway (aws_nat_gateway.this), not an EC2 instance. NAT gateways consume an EIP by design; the check does not recognize this valid attachment.
  count  = var.enable_nat_gateway ? 1 : 0
  domain = "vpc"
  tags   = merge(local.base_tags, { Name = "${var.vpc_name}-nat-eip" })
}

resource "aws_nat_gateway" "this" {
  count         = var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[var.availability_zones[0]].id

  tags       = merge(local.base_tags, { Name = "${var.vpc_name}-nat" })
  depends_on = [aws_internet_gateway.this]
}

# ---------------------------------------------------------------------------
# Route tables
# ---------------------------------------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = merge(local.base_tags, { Name = "${var.vpc_name}-public-rt" })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags   = merge(local.base_tags, { Name = "${var.vpc_name}-private-rt" })
}

resource "aws_route" "private_nat" {
  count                  = var.enable_nat_gateway ? 1 : 0
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

# ---------------------------------------------------------------------------
# Flow Logs — the NIS2 network audit layer
# ---------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "flow_logs" {
  name              = "/aws/vpc/${var.vpc_name}/flow-logs"
  retention_in_days = var.flow_logs_retention_days
  kms_key_id        = var.kms_key_arn

  tags = merge(local.base_tags, { Name = "${var.vpc_name}-flow-logs" })
}

data "aws_iam_policy_document" "flow_logs_trust" {
  statement {
    sid     = "AllowFlowLogsAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "flow_logs" {
  name               = "${var.vpc_name}-flow-logs"
  assume_role_policy = data.aws_iam_policy_document.flow_logs_trust.json
  tags               = merge(local.base_tags, { Name = "${var.vpc_name}-flow-logs" })
}

data "aws_iam_policy_document" "flow_logs_permissions" {
  statement {
    sid    = "AllowWriteToFlowLogGroup"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]
    resources = ["${aws_cloudwatch_log_group.flow_logs.arn}:*"]
  }
}

# Lock the auto-created default security group to deny-all.
# NIS2 Art.21(2)(b) network security; ISO 27001 A.8.22.
resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id

  # No ingress, no egress blocks = deny all traffic.

  tags = merge(local.base_tags, {
    Name = "${var.vpc_name}-default-sg-locked"
  })
}

resource "aws_iam_role_policy" "flow_logs" {
  name   = "${var.vpc_name}-flow-logs"
  role   = aws_iam_role.flow_logs.id
  policy = data.aws_iam_policy_document.flow_logs_permissions.json
}

resource "aws_flow_log" "this" {
  vpc_id          = aws_vpc.this.id
  traffic_type    = "ALL"
  iam_role_arn    = aws_iam_role.flow_logs.arn
  log_destination = aws_cloudwatch_log_group.flow_logs.arn

  # Custom format with NIS2-relevant fields (who/when/action + bytes)
  log_format = "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status}"

  tags = merge(local.base_tags, { Name = "${var.vpc_name}-flow-log" })

  depends_on = [aws_iam_role_policy.flow_logs]
}