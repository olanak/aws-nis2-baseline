# alerting module

Centralized detection alerting: a KMS-encrypted SNS topic fed by EventBridge rules that match GuardDuty and Security Hub findings. All detection sources route through this single channel rather than each wiring its own notifications — the deferred per-trail SNS notification (CloudTrail) resolves here.

Rules match on event **pattern** (`source`, `detail-type`), not on the detection modules' resource ARNs, so this apply-mode module stays decoupled from the plan-mode GuardDuty/Security Hub modules.

## The KMS<->SNS<->EventBridge permission chain
An encrypted SNS topic that EventBridge publishes to needs two grants, both included here: the SNS topic policy allows `events.amazonaws.com` to `sns:Publish`, and the KMS key policy allows that principal `kms:GenerateDataKey*` + `kms:Decrypt`. LocalStack does not enforce KMS key policies, so this is correct-but-unverified locally; the Week 6 real-AWS run confirms it.

## NIS2 & ISO 27001 mapping

| Resource | NIS2 Article 21(2) | ISO 27001:2022 |
|---|---|---|
| Encrypted SNS topic | (b) incident handling | A.5.24 incident planning, A.8.24 crypto |
| EventBridge GuardDuty rule | (b) incident handling | A.5.25 assessment of events |
| EventBridge Security Hub rule | (b) incident handling | A.5.25, A.5.26 response |

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->