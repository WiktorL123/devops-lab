# Lab Progress

## Current stage

**Stage 3 - Platform architecture alternatives and decision**

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

## In progress

- [ ] Gather the required platform-design inputs and explicit assumptions
- [ ] Compare complete platform architecture alternatives before selecting an implementation
- [ ] Confirm the owned domain and intended frontend hostname before domain implementation

## Next

After the user merges the Platform Architect activation, use that role to gather
the current Azure budget, region, domain/DNS constraints, and workload goals.
Then compare multiple complete platform alternatives, including cost and
operational trade-offs, before recommending an architecture. Terraform
implementation remains blocked until the user approves one alternative.

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

Do not start Terraform or deployment work until the platform alternatives have
been compared and the user approves the selected architecture.

## Planned agent evolution

- Platform Architect is active for the current platform-design phase.
- It must compare multiple complete platform alternatives before recommending one.

## Later planned stages

High-level only. The Tutor must still reveal/execute one learning task at a time.

- local application/container baseline
- CI
- platform architecture alternatives and decision (current)
- initial Terraform with local state
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
