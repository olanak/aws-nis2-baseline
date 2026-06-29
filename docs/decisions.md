# Architecture Decision Records — aws-nis2-baseline

A consolidated log of the significant decisions made building this baseline. Each record captures context, decision, and consequences — the reasoning trail behind the code. Lightweight ADR format (Michael Nygard).

---

## ADR-001 — Use LocalStack instead of real AWS
**Date:** 2026-05-27 · **Status:** Accepted
Demonstrate AWS security architecture without ongoing cloud spend during the portfolio-building phase. Use LocalStack for apply-tested modules; plan-only validation for org-level services LocalStack doesn't cover. Zero AWS bill, fully reproducible, faster iteration; org-level services (Organizations, Identity Center, Security Hub) need plan-only treatment, documented transparently as a GRC-mindset signal. *(Community framing later superseded by ADR-011.)*

## ADR-002 — NIS2 + ISO 27001 only (skip NIST CSF, CIS)
**Date:** 2026-05-27 · **Status:** Accepted
Map every control to NIS2 Article 21 + ISO 27001:2022 Annex A only. Cleaner narrative for the EU/German GRC target market, lower maintenance as standards evolve; breadth across NIST/CIS noted as "easily extendable."

## ADR-003 — Native `terraform test` over Terratest (initial)
**Date:** 2026-05-27 · **Status:** Accepted (revisited Week 4)
Use native `terraform test` (HCL) for Weeks 1–3 rather than Go-based Terratest, to avoid learning Terraform and Go simultaneously. Tests live with the code; less expressive for complex assertions — ceiling expected ~Week 4.

## ADR-004 — Full CI ambition (tflint + tfsec + Checkov + terraform-docs + Infracost)
**Date:** 2026-05-27 · **Status:** Accepted
Run the full DevSecOps pipeline from day one rather than minimal fmt+validate. Recruiter-visible production-hygiene signal; Infracost shows cost-awareness; terraform-docs keeps module docs from drifting. More CI to maintain and debug up front.

## ADR-005 — Native `terraform test` Weeks 1–3, Terratest from Week 4
**Date:** Step 5 · **Status:** Accepted
Refines ADR-003 with the migration timing. Native tests now; reassess Terratest at Week 4. *(Week 4 decision: defer — native remained sufficient.)*

## ADR-006 — Dynamic resource names in test runs
**Date:** Step 5 · **Status:** Accepted
Persistent LocalStack state caused `AlreadyExistsException` on re-runs. Use timestamp/random-suffix resource names in tests so runs never collide with orphans and parallel CI can't clash. Requires explicit destroy in teardown.

## ADR-007 — LocalStack S3 endpoint via `s3.localhost.localstack.cloud`
**Date:** Step 5 · **Status:** Accepted
Virtual-hosted-style S3 URLs (`bucket.localhost:4566`) fail WSL2 DNS resolution. Use LocalStack's published resolver `s3.localhost.localstack.cloud:4566` plus `s3_use_path_style = true` in all S3-touching provider configs. Eliminates the DNS-resolution class of failures across Linux/WSL2/macOS.

## ADR-008 — `soft_fail: true` on Checkov in CI
**Date:** Step 6 · **Status:** Accepted
Run Checkov with `soft_fail: true` so findings surface without auto-failing the job; the decision matrix (not the scanner gate) is the authoritative compliance record. No pressure to suppress findings just to ship; requires discipline to actually maintain the matrix.

## ADR-009 — LocalStack as a GitHub Actions service container
**Date:** Step 6 · **Status:** Accepted
Declare LocalStack as a `services:` block on the CI job rather than `docker run` inside a step. Starts before user code with built-in health checks; cleaner logs; standard, transferable pattern.

## ADR-010 — `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24` ahead of Node 20 deprecation
**Date:** Step 6 · **Status:** Accepted
Node 20 leaves GitHub runners Sept 16 2026; major Actions still ship on Node 20. Set `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: "true"` at workflow `env:` level to opt all JS Actions onto Node 24 in one line. Remove once upstream Actions ship Node-24-native versions.

## ADR-011 — LocalStack Pro (Student plan) as the development tier
**Date:** Week 2 Step 1 · **Status:** Accepted — supersedes ADR-001's Community framing
CloudTrail creation hit HTTP 501 (a Pro feature). Rather than engineer tier feature-flags, claim the free LocalStack Student plan (GitHub Student Pack) and run Pro 4.4.0 in both local dev and CI. Tier parity means CI tests what production tests; module code stays clean (no enable/disable gates). Depends on student status — documented in README.

## ADR-012 — Code Scanning auto-required checks removed from branch protection
**Date:** Week 2 Step 1 · **Status:** Accepted
GitHub auto-promotes Code Scanning SARIF entries to required checks, hard-failing on any error-severity finding and bypassing the workflow's `soft_fail`. Remove the `Code scanning results` checks from branch protection; the workflow CI jobs remain the authoritative gate, and Code Scanning findings stay informational in the Security tab.

## ADR-013 — Dependency-injection pattern for module composition
**Date:** Week 2 Step 1 · **Status:** Accepted
`s3-baseline` has multiple consumers needing different policy fragments. The module owns its baseline invariants (TLS-only + SSE-KMS denies) in `locals`; callers extend via `var.additional_policy_statements`, merged with `concat()`. Callers can extend security policy but never remove the baseline. Generalizes to all multi-consumer modules.

## ADR-014 — Pin the LocalStack image to 4.4.0
**Date:** Week 2 Step 1 · **Status:** Accepted
Pin `localstack/localstack-pro:4.4.0` in `docker-compose.yml` and CI, not `:latest` — reproducible emulator behavior, avoiding the March-2026 calendar-versioning/distribution churn. Version bumps are deliberate PRs. A supply-chain control (NIS2 (d)).

## ADR-015 — PR pattern for workflow-initiated commits
**Date:** Week 2 Step 1 · **Status:** Accepted
With branch protection on `main`, the terraform-docs bot can't push directly. It now generates docs, and `peter-evans/create-pull-request` opens a PR from a bot branch that goes through the same CI as a human PR. Mirrors the Dependabot/Renovate pattern.

## ADR-016 — Never close a bot PR without deleting its branch
**Date:** Week 2 Step 1 · **Status:** Accepted (operational rule)
`create-pull-request` is idempotent on the branch but not on PR state: a closed (not merged) bot PR won't reopen on later runs, silently sending updates nowhere. Rule: merge the bot PR, or close it AND delete its branch together.

## ADR-017 — Workspace ownership normalization (chown) step
**Date:** Week 2 Step 1 · **Status:** Accepted
Docker-based Actions run as a non-root UID and leave workspace files they own; the next step (running as the runner user) then can't write `.git/objects`. Add `sudo chown -R $(id -u):$(id -g) "$GITHUB_WORKSPACE"` between a Docker action and any later workspace-writing step.

## ADR-018 — Recursive scan for terraform-docs working-dir
**Date:** Week 2 Step 1 · **Status:** Accepted
The comma-list `working-dir` form silently dropped a module from docs generation. Use recursive scan (`find-dir: modules/` + `recursive: true`) so any new module is auto-included — one less onboarding-checklist item. Modules still need the `<!-- BEGIN_TF_DOCS -->` markers.

## ADR-019 — Personal Access Token for the docs bot PR (so CI triggers)
**Date:** Week 2 Step 2 · **Status:** Accepted
PRs created with the default `GITHUB_TOKEN` don't trigger `pull_request` workflows (recursion guard), so required checks sat "Expected — waiting" forever and the bot PR couldn't merge under branch protection. Use a fine-grained PAT (`DOCS_PAT`, Contents + PRs R/W) for the create-PR step; PAT-created PRs trigger CI normally. Manage/rotate the credential.

## ADR-020 — Keep the Week 6 real-AWS validation run
**Date:** Week 2 Step 3 · **Status:** Accepted
Even with full LocalStack Pro coverage, only real AWS proves IAM authorizes as intended, cross-service delivery handshakes complete, and detection findings are authentic. Keep one bounded run (under €15, budget alarm, immediate destroy) as the credibility artifact that closes "did it ever run on real AWS?"

## ADR-021 — Identity Center is plan-mode (LocalStack provisioning-status gap)
**Date:** Week 3 Step 3 · **Status:** Accepted
LocalStack creates SSO instances, permission sets, and groups, but `aws_ssoadmin_managed_policy_attachment` returns HTTP 501 on `DescribePermissionSetProvisioningStatus` — the endpoint the provider polls after attaching a policy. Keep the correct module but mark it plan-mode (validate + plan-tests, not in the composition or integration test); apply on real AWS in Week 6. *Partial-emulation gap, discovered mid-apply — the project's first plan-mode module.*

## ADR-022 — GuardDuty + Security Hub are plan-mode (LocalStack non-coverage)
**Date:** Week 4 (pre-build) · **Status:** Accepted
Unlike Identity Center's partial gap, LocalStack does not implement GuardDuty or Security Hub at all — confirmed from feature coverage before building. Build both plan-mode from the start (validate + plan-tests, not wired in); build `alerting` (SNS + EventBridge, fully supported) apply-mode. All proven together on real AWS in Week 6. *Total non-coverage vs ADR-021's partial gap — two distinct flavors of "the emulator can't, but the code is correct."*

## ADR-023 — NIS2 measure (d) supply chain addressed as documentation, not a module
**Date:** Week 5 · **Status:** Accepted
Measure (d) doesn't map to a deployable resource — it's about how the project sources, pins, verifies, and trusts dependencies. Address it as documented posture (`docs/supply-chain.md`): provider pinning + lockfile checksums, first-party-modules-only, pinned LocalStack image, CI scanner gates, AWS shared-responsibility + region-lock residency — with the enforced-vs-stance boundary stated honestly (no formal SBOM, no auto-bump bot). Brings coverage to 10/10 without faking.

---

*Resource-level control mapping: [nis2-control-mapping.md](nis2-control-mapping.md) · Framework crosswalk: [iso27001-crosswalk.md](iso27001-crosswalk.md)*
