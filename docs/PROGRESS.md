# Lab Progress

## Current stage

**Stage 1 - Application bootstrap**

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

## In progress

- [ ] Review and merge the local application bootstrap

## Next

The user should review and merge the local application bootstrap. After that user-controlled merge, open a new approval gate for **Stage 2 - CI**.

Stage 2 entry conditions:

- the application bootstrap is merged to `main` by the user;
- a new atomic approval gate is approved;
- the DevOps Builder is selected for implementation, or the DevOps Tutor if the user chooses a one-task-at-a-time learning flow.

Initial Stage 2 scope:

- separate `frontend-ci` and `backend-ci` GitHub Actions workflows;
- `lint -> test -> build` for each component;
- relevant path filters;
- runs on pull requests and again after relevant changes are merged to `main`.

Deployment, Terraform, Azure resources, image publishing, and CD remain explicitly out of scope for Stage 2 CI.

Expected baseline:
- backend: Node.js + TypeScript + Prisma
- PostgreSQL
- separate frontend
- multi-stage Dockerfiles
- local Docker Compose
- if Nunjucks is selected: GOV.UK Frontend components/macros with a custom `devops-lab` visual layer

Do not start Terraform or deployment work until the application workload exists and the user confirms progression.

## Planned agent evolution

- Platform Architect is intentionally deferred until the platform-design phase.
- When added, it must compare multiple complete platform alternatives before recommending one.

## Later planned stages

High-level only. The Tutor must still reveal/execute one learning task at a time.

- local application/container baseline
- CI
- platform architecture alternatives and decision
- initial Terraform with local state
- Azure infrastructure
- Terraform state migration to Azure Blob
- ACR/container delivery
- first pipeline-driven deployment
- runtime Key Vault integration
- database migration flow
- image/version gates
- rollback exercise
- optional prod comparison
- optional custom DNS/domain
- cleanup
