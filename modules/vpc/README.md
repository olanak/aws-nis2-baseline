# vpc module

Provisions a two-AZ VPC (public + private subnets, internet gateway, NAT gateway) with VPC Flow Logs delivered to a KMS-encrypted CloudWatch Log Group — the network audit layer for NIS2.

## NIS2 & ISO 27001 mapping

| Resource | NIS2 Article 21(2) | ISO 27001:2022 |
|---|---|---|
| VPC Flow Logs (ALL traffic) | (b) incident handling | A.8.15 Logging, A.8.16 Monitoring |
| Public/private subnet split | (b) network security | A.8.22 Segregation of networks |
| KMS-encrypted flow-log group | (h) cryptography | A.8.24 |
| Flow-logs IAM service role | (i) access control | A.5.15 |

## Example

```hcl
module "vpc_demo" {
  source = "../../modules/vpc"

  vpc_name    = "nis2-demo-vpc"
  kms_key_arn = module.kms_s3_baseline.key_arn
}
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->