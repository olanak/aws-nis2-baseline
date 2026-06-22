# Learning Log — aws-nis2-baseline

A curated record of the engineering decisions and lessons from building this baseline. The full week-by-week build journal lives in the blog series; this is the distilled set of things worth remembering.

## Decisions that shaped the project

- **Managed risk over zero-findings theater.** Scanner findings are triaged in a decision matrix (Fixed / Deferred / Accepted / Suppressed-with-reason) rather than chased to a misleading green. A documented, reasoned disposition is the GRC signal — not an empty findings list.
- **Apply-mode vs plan-mode honesty.** Where LocalStack fully supports a service, the module is applied and asserted. Where it doesn't, the module is kept correct but marked plan-mode and proven on real AWS. Two distinct reasons emerged: a *partial gap* (Identity Center — creates resources but 501s on a provisioning-status poll, ADR-021) and *total non-coverage* (GuardDuty, Security Hub — not implemented at all, ADR-022). Naming which is which is part of the work.
- **Provider-agnostic composition.** Module wiring lives once in `environments/_composition`; `dev` and `prod` are thin provider wrappers. Environments can't drift, so "same code on LocalStack and real AWS" is structural, not maintained by hand.
- **Dependency injection over override.** The s3-baseline bucket exposes an `additional_policy_statements` hook so callers (CloudTrail, Config) add their delivery permissions without ever weakening the module's baseline guarantees.
- **Sharp focus over breadth.** NIS2 + ISO only (not NIST/CIS as well); FSBP only (not FSBP + CIS); single-region MVP. Each documented as a deliberate, extensible choice.

## Lessons worth keeping

- **`for_each` keys must be known at plan time.** Keying SCP attachments on apply-time OU IDs failed in the integration test (passed in isolation with static IDs). Fix: keys from static names, apply-time IDs in the values. General rule — if `for_each` errors "known only after apply," move the dynamic part out of the keys.
- **Probe the full resource graph, not just `create`.** Identity Center's `create` calls all succeeded; the failure was a post-create provisioning-status poll only the full apply reached. Probing creates alone gave false confidence.
- **Test conventions matter.** The provider block goes *inside* the `.tftest.hcl` file. Non-ASCII characters in suppression comments break Checkov. Every consumer of a shared composition needs the full provider endpoint set (the integration test is a separate consumer from `dev`).
- **A green test can prove less than it looks.** LocalStack doesn't enforce KMS key policies, so the KMS↔SNS↔EventBridge permission chain applies cleanly locally whether or not it's correct. Documented as correct-but-unverifiable-locally; real AWS is where it's confirmed.
- **Close findings by intent, not mechanically.** The deferred CloudTrail-SNS finding closed because centralized EventBridge alerting supersedes a per-trail topic — a better outcome than bolting on exactly what the scanner named.
- **`grep` each `data`/`var` before pushing.** tflint's unused-declaration rule caught leftover scaffolding twice; a ten-second self-check prevents it.

## Cross-references
- Architecture: [architecture.md](architecture.md)
- NIS2 mapping: [nis2-control-mapping.md](nis2-control-mapping.md)
- ISO crosswalk: [iso27001-crosswalk.md](iso27001-crosswalk.md)
- Supply chain (measure d): [supply-chain.md](supply-chain.md)
