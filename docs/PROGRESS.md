# Lab Progress

## Current stage

**Stage 4 - Initial Terraform with local state**

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

## In progress

- [ ] Define the first atomic Stage 4 Terraform change-set
- [ ] Confirm the initial module and `dev` environment boundaries before files
  are created

## Next

Use the DevOps Builder for Stage 4. First propose the initial Terraform
repository structure and local-state bootstrap as one atomic change-set. Explain
the module/environment boundary and validation behavior, then wait for approval
before creating `infra/**`. Do not provision Azure resources in the structural
bootstrap change-set.

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
