# devops-lab agent guide

## Purpose

`devops-lab` is an Azure-first DevOps learning repository.

The application exists primarily as a realistic workload to deploy. Optimize decisions for learning:

- CI/CD
- Terraform
- Azure infrastructure
- container delivery
- secrets
- database migrations
- release/versioning flow
- troubleshooting
- cost awareness
- dev vs production differences

Application architecture is deliberately secondary.

## Non-negotiable working agreement

1. Never merge pull requests. The user reviews, approves, and merges.
2. Repository changes use an atomic approval gate. Approval applies only to the explicitly described atomic change-set.
3. Before requesting approval, state:
   - objective,
   - files/resources expected to change,
   - behavior being introduced or changed,
   - what is explicitly out of scope.
4. Approval for one change-set must never be interpreted as approval for adjacent or subsequent work.
5. If implementation reveals that additional scope is required, stop and request a new approval.
6. Prefer the cheapest sensible Azure option for this lab.
7. Before selecting or changing a paid Azure SKU:
   - propose the cheapest sensible option,
   - explain why it is sufficient,
   - state the main compromise versus a more production-oriented option,
   - ask for approval.
8. Runtime secrets belong in Azure Key Vault.
9. Build-time secrets belong in the CI/CD platform.
10. Frontend and backend remain separate deployable containers.
11. Frontend and backend Dockerfiles must be multi-stage.
12. If the Nunjucks frontend option is selected, use GOV.UK Frontend components/macros as the component foundation, but apply a custom visual layer. Do not ship an unmodified GOV.UK-looking service and do not fork/rewrite the entire GOV.UK Frontend library.
13. Do not introduce DDD, Clean Architecture, Hexagonal Architecture, CQRS, or similar application architecture unless explicitly requested.
14. Infrastructure code is versioned in Git. Terraform state, secrets, and generated Terraform directories are not.
15. Update relevant documentation when a commit materially changes infrastructure, pipelines, deployment flow, secrets, environment structure, cloud mapping, or lab progress.
16. The first real application deployment must happen through CI/CD, not through a manual deployment command.

## Budget

The promotional Azure credit currently observed for this lab is **$175**.

This is contextual information, not a permanent constant.

Agents must:
- treat available credit as dynamic account state,
- never assume `$200`,
- ask for the current balance or read it through approved tooling when a cost-sensitive decision depends on it,
- distinguish current remaining credit from the original promotional grant.

The Reviewer analyzes cost structurally.
The Troubleshooter may interrupt normal troubleshooting with a prominent warning when it detects a configuration that can rapidly consume credit.

## Cloud strategy

The current implementation is **Azure-first**.

Keep the conceptual lab scope cloud-neutral where practical so that a future AWS or GCP profile can implement the same intent without redesigning the lab.

Conceptual capabilities:

- two containerized applications,
- managed PostgreSQL,
- container registry,
- runtime secrets manager,
- Terraform remote state,
- public ingress/default service DNS,
- CI/CD,
- environment-aware infrastructure.

Current Azure mapping:

- Azure Container Apps
- Azure Database for PostgreSQL Flexible Server
- Azure Container Registry
- Azure Key Vault
- Azure Blob Storage for Terraform remote state
- Azure Container Apps ingress with a custom public frontend domain
- a free Azure Container Apps managed TLS certificate for the frontend domain

The platform-generated Azure Container Apps FQDN remains a technical endpoint,
but it is not the intended public application address. The backend does not need
a public custom domain and should use internal Container Apps communication.

The domain registration and control of its DNS records are external
prerequisites. Azure DNS remains optional; prefer the existing DNS provider when
it is sufficient and cheaper for the lab.

Monitoring/observability is not part of the initial core scope.
AKS is optional and should not be introduced unless explicitly requested.

## CI/CD strategy

Default provider: **GitHub Actions**.

Supported alternative for learning/comparison: **Azure Pipelines**.

Frontend CI and backend CI are separate.

Both CI workflows:

`lint -> test -> build`

CI runs:
- on pull requests for relevant paths,
- again after merge to `main`.

Deployment runs only:
- after merge to `main`,
- after successful corresponding post-merge CI,
- when the relevant component path changed.

Target workflows:

- `frontend-ci`
- `backend-ci`
- `frontend-deploy`
- `backend-deploy`
- `infra`

Backend deployment includes database migration as an explicit pipeline job/stage.
Do not run Prisma migrations implicitly as container startup behavior.

## Terraform strategy

Start with local Terraform state.

A planned learning stage migrates state to Azure Blob Storage.

Terraform modules are used from the beginning.
Prefer modules around meaningful capabilities rather than blindly wrapping every individual Azure resource.

Expected direction:

```text
infra/
├── modules/
│   ├── container-app/
│   ├── postgres/
│   ├── acr/
│   ├── key-vault/
│   └── storage/
└── environments/
    └── dev/
```

The exact environment structure is proposed by the agent after explaining the trade-offs and requires user approval.

Infrastructure workflow:

Pull request:
- `terraform fmt -check`
- `terraform validate`
- `terraform plan`

After merge to `main`:
- `terraform fmt -check`
- `terraform validate`
- `terraform plan`
- save plan artifact
- apply exactly that saved plan automatically

Infrastructure workflow is path-scoped to `infra/**`.

## Versioning and image tags

Frontend and backend version independently.

Semantic version lives in the component's `package.json`.

A repository-level version script will support commands conceptually like:

```bash
./scripts/version.sh frontend minor
./scripts/version.sh backend patch
```

The script:
- updates the requested component version,
- does not commit automatically.

Deployment image tag format:

`<semver>-<short-sha>`

Examples:

- `frontend:1.1.0-a1b2c3d`
- `backend:2.0.0-f6e7d8c`

Do not deploy `latest`.

The pipeline must require a version bump when runtime-impacting files for that component change, including:
- application code,
- runtime/build configuration,
- Dockerfile.

Documentation-only and test-only changes do not require a version bump.

## Agent roles

Detailed instructions live under `.agents/roles/`.

- **Implementator**: builds and changes the application workload, including initial bootstrap.
- **DevOps Tutor**: teaches one approved step at a time.
- **DevOps Builder**: implements Terraform, pipelines, and deployment configuration.
- **DevOps Reviewer**: reviews DevOps/infrastructure concerns using a structured finding template.
- **Azure Troubleshooter**: diagnoses Azure, Terraform, deployment, and pipeline failures.
- **Platform Architect**: compares complete platform alternatives and recommends a design before infrastructure implementation.

The Platform Architect is active for the platform-design phase. It must compare
multiple complete platform alternatives before recommending one. The DevOps
Builder implements only an architecture approved by the user.

See `docs/AGENT_INDEX.md` for routing.

## Tutor progression rule

The Tutor gives exactly one task at a time and waits for the user's result.

It does not reveal or start the next task until the user confirms progression.

If the user says they are stuck at step X and asks the Tutor to finish X:
1. complete or propose the minimal completion of X,
2. explain what was done,
3. proceed to X+1 only because the user explicitly requested that transition.

## Initial local environment

The initial development machine is macOS and the intended local repository path is:

`/Users/wiktorlemanski/Projects/devops-lab`

Do not unnecessarily hard-code macOS-specific behavior into repository automation.

The repository should remain portable so Windows support can be added later through documented/scripted updates.
