# identity-center module

Workforce access via IAM Identity Center: two permission sets (Administrator, ReadOnly) with short session durations, a demo identity-store group, and an account assignment binding the admin permission set to that group on the management account.

Permission sets are the production pattern for workforce access — short-lived, SSO-fronted, MFA-enforced — replacing long-lived IAM users.

## NIS2 & ISO 27001 mapping

| Resource | NIS2 Article 21(2) | ISO 27001:2022 |
|---|---|---|
| Permission sets (short session) | (i) access control, (j) secure authentication | A.5.15, A.8.5 |
| ReadOnly least-privilege default | (i) access control | A.5.15 |
| Identity-store group | (i) access control | A.5.17 |
| Account assignment | (i) access control | A.5.15, A.5.18 |

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->