# Stage 1 Application Bootstrap Review

## Review metadata

- Date: 2026-08-26
- Role: DevOps Reviewer
- Scope: local application bootstrap, container images, Docker Compose wiring, Prisma migration readiness, secrets boundaries, and readiness for the CI stage
- Result: remediation implemented and verified; no actionable findings remain

This review does not approve or implement Terraform, Azure infrastructure, CI/CD, deployment, or production platform decisions.

## Verification evidence

- Frontend lint, test, and production build passed.
- Backend lint, two tests, and TypeScript build passed.
- Prisma Client generation passed.
- `npm audit` reported zero known vulnerabilities for both components.
- Both multi-stage container images built successfully.
- PostgreSQL started healthy under Docker Compose.
- The frontend, direct backend health endpoint, and Nginx-proxied health endpoint returned successful responses.
- `docker compose config --quiet` and `git diff --check` passed.
- Node.js 24 is an active LTS line; the repository uses 24.19.0 because that exact version was available for both the local toolchain and the official Alpine container image during verification.
- PostgreSQL 16 remains supported through November 2028.
- Agent-controlled visual browser inspection was unavailable; HTTP responses, generated assets, container status, and runtime logs were verified instead.

## Findings

```yaml
- category: Deployment
  severity: Medium
  title: Missing initial Prisma migration
  description: >
    The Prisma schema defines the LabEvent model, but the repository contains no
    prisma/migrations history. A new Compose database therefore has no table for
    the model, and the future explicit migration pipeline has no versioned baseline.
  proposed_solution: >
    Generate and commit the initial Prisma migration and keep migration execution
    explicit. Do not add migrations to container startup.
  related_files:
    - backend/prisma/schema.prisma
    - backend/prisma/migrations/
  notes: >
    The current health endpoint only runs SELECT 1, so it does not detect the
    missing application table.

- category: Deployment
  severity: Medium
  title: Frontend proxy is coupled to the Docker Compose backend name
  description: >
    Nginx always proxies /api to backend:3000. That address is valid for local
    Compose but is not a portable runtime configuration for separate Azure
    Container Apps or future cloud profiles.
  proposed_solution: >
    Use a runtime-rendered Nginx template with BACKEND_UPSTREAM. Compose should
    provide backend:3000 while future environments provide their own endpoint
    without rebuilding the frontend image.
  related_files:
    - frontend/nginx.conf
    - frontend/Dockerfile
    - compose.yaml
  notes: >
    The browser can continue using the relative /api path.

- category: Maintainability
  severity: Low
  title: Frontend runtime uses the old Nginx 1.27 line
  description: >
    The verified image runs Nginx 1.27.5. At review time, the official stable
    release is 1.30.4 and the 1.27 line is no longer listed among legacy releases.
  proposed_solution: >
    Pin the runtime to the available multi-architecture nginx:1.30.4-alpine image,
    then rebuild and retest the frontend and proxy.
  related_files:
    - frontend/Dockerfile
  notes: >
    Source: https://nginx.org/en/download.html

- category: Security
  severity: Low
  title: Container images need baseline hardening
  description: >
    Both image configurations have no runtime User, so they default to root.
    The frontend Docker build context also does not exclude .env files, allowing
    local configuration or secrets to enter build layers or cache.
  proposed_solution: >
    Run the backend as the node user, use an unprivileged Nginx runtime, and exclude
    .env files from Docker build contexts while retaining a safe .env.example when needed.
  related_files:
    - backend/Dockerfile
    - frontend/Dockerfile
    - backend/.dockerignore
    - frontend/.dockerignore
  notes: >
    The local example PostgreSQL password is not a cloud runtime secret. Future
    runtime secrets still belong in Azure Key Vault.

- category: Reliability
  severity: Low
  title: Compose does not check backend and frontend readiness
  description: >
    PostgreSQL has a healthcheck, but the backend and frontend do not. The frontend
    waits only for the backend container to start, leaving a startup race.
  proposed_solution: >
    Add backend and frontend healthchecks and make frontend startup depend on a
    healthy backend.
  related_files:
    - compose.yaml
  notes: >
    The existing /api/health endpoint can support the backend readiness check.
```

## Cost review

No Azure resources, paid SKUs, or cloud workloads were introduced. The current stack consumes only local Docker resources, so there is no Azure credit impact from this change-set.

## Retrospective

### What worked

- The atomic approval gate kept the bootstrap limited to the local application workload.
- Frontend and backend remain independently buildable and deployable containers.
- Both Dockerfiles use multiple stages.
- Prisma migrations are not hidden in container startup.
- Dependency auditing was performed before accepting the lockfiles.
- Local behavior was verified through component checks and a running Compose stack.
- Documentation was updated when the learning stage changed.

### What should improve

- Inspect tracked hidden files with `git ls-files` or an equivalent check before adding them. The existing `.gitignore` was temporarily overwritten during bootstrap, then restored after the final diff check detected the problem.
- Verify the availability and support status of base-image tags before the first build.
- Treat a versioned initial database migration as part of a usable Prisma baseline.
- Give local configuration an explicit runtime extension point for later cloud environments.
- Include container user and Docker build-context checks in the bootstrap review checklist.

## Next-stage assessment

Stage 1 remediation has been implemented and verified. No application or container remediation remains before merge.

Remaining handoff sequence:

1. The user reviews and merges the bootstrap pull request.
2. Confirm that the merged `main` contains the Stage 1 baseline.
3. Open a new atomic approval gate for Stage 2 CI.

The intended Stage 2 scope is limited to separate `frontend-ci` and `backend-ci` GitHub Actions workflows with `lint -> test -> build`, relevant path filters, and runs on pull requests and post-merge changes to `main`. Deployment, Terraform, and Azure remain out of scope for that stage.

The DevOps Builder is the appropriate implementation role for Stage 2. The DevOps Tutor should be used instead when the user wants to build the workflows one learning task at a time.

## Remediation outcome

Remediation was completed on 2026-08-26 under atomic change-set #3.

- The initial `20260826210000_init` Prisma migration was added, applied explicitly, and verified against PostgreSQL. A second execution reported no pending migrations.
- A dedicated Compose `migrate` tool service and Dockerfile migration target now support explicit migration delivery without coupling migrations to backend startup.
- The frontend Nginx configuration is rendered at runtime from `BACKEND_UPSTREAM`; the browser continues to use the relative `/api` path.
- The frontend runtime was updated to Nginx 1.30.4 and now listens on the unprivileged port 8080.
- The backend runs as the `node` user (UID 1000), and the frontend runs as the `nginx` user (UID 101).
- Frontend and backend Docker build contexts exclude `.env` files.
- PostgreSQL, backend, and frontend all report healthy under Docker Compose, and frontend startup waits for a healthy backend.

Post-remediation verification:

- frontend: dependency install, lint, one test, and production build passed under Node.js 24.19.0;
- backend: dependency install, Prisma Client generation, lint, two tests, and TypeScript build passed under Node.js 24.19.0;
- both dependency installations reported zero known vulnerabilities;
- the initial migration created the expected `LabEvent` table and was idempotent;
- both runtime containers were verified as non-root;
- Nginx configuration syntax and runtime environment substitution were verified;
- direct backend and Nginx-proxied health endpoints returned successful responses;
- `docker compose up --wait`, `docker compose config --quiet`, and `git diff --check` passed.

Follow-up review result:

```yaml
findings: []
summary: "No actionable DevOps/infrastructure findings remain from the Stage 1 bootstrap review."
```

## Reference sources

- Node.js release status: https://nodejs.org/en/about/previous-releases
- Nginx release status: https://nginx.org/en/download.html
- PostgreSQL support policy: https://www.postgresql.org/support/versioning/
