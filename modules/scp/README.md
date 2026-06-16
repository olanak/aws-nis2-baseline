# scp module

Three Service Control Policies attached to OUs (or the org root) as guardrails:

1. **deny-root-user** — denies all actions by the root user
2. **region-lock** — denies operations outside the allowed region (EU data residency), excepting global services
3. **protect-logging-layer** — denies disabling CloudTrail and Config

SCPs are guardrails, not grants: they only restrict what IAM otherwise allows.

## NIS2 & ISO 27001 mapping

| SCP | NIS2 Article 21(2) | ISO 27001:2022 |
|---|---|---|
| deny-root-user | (i) access control | A.5.15, A.8.2 |
| region-lock | (i) access control | A.5.15, A.8.22 |
| protect-logging-layer | (b) incident handling, (f) effectiveness | A.8.15, A.8.34 |

## Example

```hcl
module "scp" {
  source     = "../../modules/scp"
  target_ids = values(module.organizations.ou_ids)
}
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->