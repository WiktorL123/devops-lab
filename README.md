# devops-lab

An Azure-first learning repository built around a deliberately small two-service application.

## Local application

The local workload contains:

- a React + Vite frontend served by Nginx,
- a Node.js + TypeScript backend using Prisma,
- PostgreSQL,
- separate multi-stage container images for frontend and backend.

Local Node.js commands use Node.js 24.19.0 LTS, recorded in `.nvmrc`. With `nvm`, switch to it using `nvm install && nvm use`.

Copy `.env.example` to `.env` if you want to override the development defaults. Apply database migrations explicitly before starting the application containers:

```bash
docker compose up --build --detach postgres
docker compose run --rm --build migrate
docker compose up --build
```

The `migrate` service is an explicitly invoked tool and is not started by the normal Compose stack. Re-running it is safe and reports when no migrations are pending.

For subsequent starts where the schema is already current, start the stack directly:

```bash
docker compose up --build
```

Open <http://localhost:8080>. The status badge confirms whether the frontend can reach both the API and PostgreSQL.

Stop the stack with:

```bash
docker compose down
```

Add `--volumes` only when you deliberately want to remove the local PostgreSQL data volume.

Prisma migrations are not run automatically during container startup. New schema changes must include a versioned migration and be applied through the explicit migration command.

## Component checks

Each component exposes the same basic commands:

```bash
npm run lint
npm test
npm run build
```

Run them inside `frontend/` or `backend/` after installing that component's dependencies.

Azure-first DevOps learning lab focused on CI/CD, Terraform, container delivery, secrets, managed PostgreSQL, troubleshooting, and cost-aware infrastructure.

The application itself is intentionally simple. Its job is to provide a realistic frontend/backend workload for DevOps exercises.

## Planned workload

- separate frontend and backend
- Node.js + TypeScript backend
- Prisma + PostgreSQL
- React + Vite frontend
- multi-stage Dockerfiles for both applications
- local PostgreSQL with Docker Compose
- GitHub Actions CI/CD
- Terraform
- Azure Container Apps
- Azure Database for PostgreSQL Flexible Server
- Azure Container Registry
- Azure Key Vault
- Azure Blob Storage for remote Terraform state

## Agent roles

- **Implementator** - bootstraps and maintains the frontend/backend application workload.
- **DevOps Tutor** - teaches one DevOps step at a time.
- **DevOps Builder** - implements Terraform, CI/CD, and Azure deployment configuration.
- **DevOps Reviewer** - reviews DevOps/infrastructure changes using structured findings.
- **Azure Troubleshooter** - diagnoses Azure, Terraform, deployment, and pipeline failures.
- **Platform Architect** - planned for a later platform-design phase; not active yet.

The current learning stage, completion criteria, and next approved work are tracked in `docs/PROGRESS.md`. Role selection for each new task follows `docs/AGENT_INDEX.md`.

## Agent workflow

See:

- `AGENTS.md`
- `docs/AGENT_INDEX.md`
- `docs/LAB_SPEC.md`
- `docs/PROGRESS.md`

Repository changes use atomic approval gates.
The user owns review, approval, and merge decisions.
Agents may prepare changes and pull requests, but must not merge them.
