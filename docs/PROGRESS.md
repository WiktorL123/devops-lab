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

## In progress

- [ ] Merge initial agent system into `main`

## Next

After the agent-system PR is merged:

**Stage 1 - Application bootstrap decision**

The Implementation agent should present the smallest useful application setup and ask the user to select/approve the frontend approach.

Expected baseline:
- backend: Node.js + TypeScript + Prisma
- PostgreSQL
- separate frontend
- multi-stage Dockerfiles
- local Docker Compose
- if Nunjucks is selected: GOV.UK Frontend components/macros with a custom `devops-lab` visual layer

Do not start Terraform or deployment work until the application workload exists and the user confirms progression.

## Later planned stages

High-level only. The Tutor must still reveal/execute one learning task at a time.

- local application/container baseline
- CI
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
