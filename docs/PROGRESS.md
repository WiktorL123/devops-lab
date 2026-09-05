# Lab Progress

## Current stage

**Stage 4 - Initial Terraform with local state**

Current Azure Portal balance reported on 2026-08-31: **EUR 175.72**, expiring
2026-09-24. Treat this as dynamic account state.

## Completed

- [x] Lab scope defined
- [x] Azure chosen as first cloud profile
- [x] GitHub Actions chosen as default CI/CD provider
- [x] Agent roles defined
- [x] Cost-first policy defined
- [x] Image versioning strategy defined
- [x] Terraform module strategy defined
- [x] Atomic approval gate defined
- [x] Structured Reviewer finding contract defined
- [x] Agent-system refinement merged into `main`
- [x] React + Vite frontend approach selected
- [x] Local frontend, backend, PostgreSQL, and Docker Compose baseline implemented
- [x] Stage 1 bootstrap review and retrospective completed
- [x] Stage 1 bootstrap review findings remediated and verified
- [x] Stage 1 follow-up review completed with no actionable findings
- [x] Application bootstrap merged into `main`
- [x] Separate frontend and backend CI workflow definitions implemented
- [x] Stage 2 local CI review and retrospective completed with no actionable findings
- [x] GitHub Actions confirmed as the sole provider for the active CI/CD delivery path
- [x] `frontend-ci` and `backend-ci` passed after merge to `main`
- [x] Stage 2 continuous integration completed
- [x] Custom public frontend domain added to the required platform scope
- [x] Platform Architect role introduced and activated for Stage 3
- [x] Stage 3 platform-design inputs gathered and verified
- [x] Three complete platform alternatives documented with cost and RBAC analysis
- [x] Option B balanced private-data-plane architecture selected
- [x] Architecture decision and Builder handoff recorded in ADR-001
- [x] Stage 3 platform architecture completed
- [x] Stage 4 local Terraform bootstrap change-set approved
- [x] Local Terraform 1.16.0 and AzureRM 5.2.0 baseline initialized
- [x] Cross-platform provider lock file generated and bootstrap validated
- [x] Cross-computer Stage 4 handoff and fresh-session prompt documented
- [x] Read-only local-tool and Azure subscription preflight completed
- [x] Required Azure Resource Providers registered
- [x] GitHub OIDC and Azure RBAC bootstrap script prepared for owner execution
- [x] GitHub OIDC and constrained Azure RBAC bootstrap executed and verified
- [x] First meaningful Terraform capability module (`network`) implemented and validated
- [x] Local Terraform network plan reviewed: 5 to add, 0 to change, 0 to destroy
- [x] Network plan applied successfully with local Terraform state
- [x] Dedicated Azure Blob remote-state bootstrap implemented and validated

## In progress

- [x] Commit and push `terraform-init` before continuing on another computer
- [x] Run a read-only local-tool and Azure subscription preflight
- [x] Design the principal, GitHub OIDC, and RBAC bootstrap
- [x] Review and execute the principal, GitHub OIDC, and RBAC bootstrap
- [x] Design and implement the first meaningful Terraform capability module
- [x] Review and apply the local Terraform network plan
- [x] Design and preflight the dedicated Azure Blob remote-state backend
- [ ] Review a saved Terraform plan for the remote-state bootstrap

## Next

For a new computer/session, follow
`docs/handoffs/STAGE_4_TERRAFORM_HANDOFF.md` and use
`docs/handoffs/NEXT_SESSION_PROMPT.md`. After the branch is available remotely,
review a saved Terraform plan for the dedicated Azure Blob remote-state
bootstrap. Backend `plan`, `apply`, and state migration remain separately gated.
Do not provision additional Azure resources without explicit approval.

Stage 2 implementation:

- the application bootstrap was merged to `main` by the user;
- atomic change-set #5 was approved;
- the DevOps Builder implemented the workflow definitions.

Initial Stage 2 scope:

- separate `frontend-ci` and `backend-ci` GitHub Actions workflows;
- `lint -> test -> build` for each component;
- relevant path filters;
- runs on pull requests and again after relevant changes are merged to `main`.

Deployment, Terraform, Azure resources, image publishing, and CD remain explicitly out of scope for Stage 2 CI.

Future CI and CD implementation will remain entirely in GitHub Actions. The
planned CD handoff publishes images to ACR only after successful post-merge CI
for runtime-impacting component changes. Images use `<semver>-<short-sha>` tags,
while deployments select the exact immutable digest. Azure Pipelines is not part
of the active delivery path.

Stage 3 platform requirements now include:

- a custom public domain for the frontend instead of treating the generated
  Azure Container Apps FQDN as the application URL;
- a free managed TLS certificate as the cost-first baseline;
- DNS ownership validation and a direct CNAME for a subdomain, or an A record
  for an apex domain;
- internal backend communication without a separate public custom domain;
- an externally owned domain and controllable DNS records as prerequisites;
- Azure DNS only if a later comparison justifies its additional cost and learning value;
- future infrastructure/CD support for hostname binding, certificate readiness,
  and HTTPS verification against the custom domain.

Expected baseline:
- backend: Node.js + TypeScript + Prisma
- PostgreSQL
- separate frontend
- multi-stage Dockerfiles
- local Docker Compose
- if Nunjucks is selected: GOV.UK Frontend components/macros with a custom `devops-lab` visual layer

The selected architecture is Option B. Terraform implementation may begin only
through a new Stage 4 atomic approval gate. Azure provisioning, remote-state
migration, deployment, and DNS changes remain separately gated.

## Planned agent evolution

- Platform Architect completed the Stage 3 decision.
- DevOps Builder is the next role and must propose the first Stage 4 atomic
  change-set before implementation.

## Later planned stages

High-level only. The Tutor must still reveal/execute one learning task at a time.

- local application/container baseline
- CI
- platform architecture alternatives and decision (completed)
- initial Terraform with local state (current)
- Azure infrastructure
- Terraform state migration to Azure Blob
- ACR/container delivery
- first pipeline-driven deployment
- runtime Key Vault integration
- database migration flow
- image/version gates
- rollback exercise
- custom frontend domain and managed TLS integration
- optional prod comparison
- optional Azure DNS comparison/migration
- cleanup
