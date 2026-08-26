# Lab Progress

## Current stage

**Stage 0 - Agent system initialization**

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

## In progress

- [ ] Merge agent-system refinement into `main`

## Next

After the agent-system refinement is merged:

**Stage 1 - Application bootstrap decision**

The Implementator should present the smallest useful application setup and ask the user to select/approve the frontend approach.

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
