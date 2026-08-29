# Lab Progress

## Current stage

**Stage 2 - Continuous integration**

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

## In progress

- [ ] Verify `frontend-ci` and `backend-ci` in the Stage 2 pull request
- [ ] Review and merge the Stage 2 CI pull request

## Next

Push the `devops/ci` branch and open a pull request to verify both path-scoped CI workflows on GitHub Actions. After successful CI review and user-controlled merge, confirm Stage 2 completion before opening a new approval gate for later work.

The local Stage 2 review found no actionable DevOps findings. Hosted execution
is still unverified, so Stage 2 remains in progress until both workflows pass in
the pull request. See `docs/reviews/STAGE_2_CI_REVIEW.md`.

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
