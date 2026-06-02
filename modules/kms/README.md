# kms module

A reusable Terraform module that provisions a KMS Customer Managed Key with rotation enabled, an alias, and regulatory traceability tags.

## NIS2 & ISO 27001 mapping

| Resource | NIS2 Article 21(2) | ISO 27001:2022 Annex A |
|---|---|---|
| KMS CMK with rotation | (h) cryptography | A.8.24 use of cryptography |

## Example

```hcl
module "kms_logs" {
  source = "../../modules/kms"

  key_alias   = "nis2-logs"
  description = "CMK for log buckets"
}
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->