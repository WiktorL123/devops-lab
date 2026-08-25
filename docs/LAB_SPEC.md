# Lab Specification

## Goal

Learn real-world DevOps delivery around a deliberately simple two-service application.

The lab emphasizes how software is built, versioned, deployed, configured, secured, reviewed, troubleshot, and destroyed.

## Application workload

Repository shape:

```text
frontend/
backend/
infra/
scripts/
docs/
```

Backend:
- Node.js
- TypeScript
- Prisma
- PostgreSQL
- intentionally simple MVC or functional organization
- no mandatory Clean/DDD/Hexagonal abstractions

Frontend:
- selected during bootstrap,
- preferred options include React + Vite or Express + Nunjucks SSR,
- the agent may propose a third reasonable option,
- React means Vite,
- if Express + Nunjucks SSR is selected, GOV.UK Frontend components/macros are the component foundation,
- the GOV.UK component layer must be visually customized for `devops-lab` rather than left as an unmodified GOV.UK service,
- customize through an application-owned styling/theme layer; do not fork or manually rewrite the entire GOV.UK Frontend library.

Frontend and backend are independent runtime containers.

Both Dockerfiles are multi-stage.

Local development uses Docker Compose with PostgreSQL.

## Azure core scope

Core:
- 2x Azure Container Apps
- Azure Database for PostgreSQL Flexible Server
- Azure Container Registry
- Azure Key Vault
- Azure Blob Storage for Terraform remote state after migration
- Azure-managed/default Container Apps ingress and DNS

Optional:
- custom domain
- Azure DNS
- TLS/domain exercises beyond default ingress
- production environment
- AKS
- monitoring/observability

## Secrets

Build-time:
- CI/CD platform secrets

Runtime:
- Azure Key Vault
- use managed identity/reference-based access where appropriate

Do not bake runtime secrets into container images.

## CI

Frontend and backend CI are separate.

Each:
- lint
- test
- build

Run on:
- pull request for relevant paths,
- merge to `main` for relevant paths.

The second run after merge is intentional redundancy and acts as a deployment quality gate.

## CD

Frontend:
- successful post-merge frontend CI
- build container
- push to ACR
- deploy/update frontend Container App

Backend:
- successful post-merge backend CI
- build container
- push to ACR
- explicit Prisma migration job/stage
- deploy/update backend Container App

The first real deployment happens through CI/CD.

## Terraform

Start with local state.

Later migrate state deliberately to Azure Blob Storage as a learning exercise.

Use modules from the start.

Prefer capability-oriented reusable modules, for example:
- `container-app`
- `postgres`
- `acr`
- `key-vault`
- `storage`

The same `container-app` module should be reusable for frontend and backend.

Initial environment: dev only.

The structure may be prepared for multiple environments if the Builder first explains why the selected layout is appropriate and receives approval.

## Terraform pipeline

PR:
- fmt check
- validate
- plan

Merge to main:
- fmt check
- validate
- plan
- persist plan artifact
- apply the exact persisted plan

Apply is automatic after successful validation on merge.

Path filter: `infra/**`.

## Image versioning

Frontend and backend version independently.

Source of semantic version:
- corresponding `package.json`

Version bump helper:
- one repo-level script
- user chooses component and `patch|minor|major`
- script changes files only
- no automatic Git commit

Deployment tag:
- `<semver>-<short-sha>`

Do not deploy `latest`.

Version bump gate applies to runtime-impacting changes such as:
- source code,
- runtime/build configuration,
- Dockerfile.

Pure docs/tests do not force a bump.

## Cost policy

Current observed Azure promotional credit: **$175**.

This number can change.

Default behavior:
- cheapest sensible lab SKU,
- explain reasoning,
- explain the production compromise,
- require approval.

Do not treat current credit as an architectural target.
Do not hard-code `$175` into Terraform or application configuration.

## Cleanup

Cleanup is a formal final lab stage.

Expected sequence:
1. `terraform destroy` for Terraform-managed resources,
2. verify leftovers,
3. remove bootstrap resources not managed by the destroyed state, including remote-state storage when appropriate,
4. inspect resource groups,
5. perform a final Cost Management sanity check.

Never destroy the Terraform state backend before Terraform has finished using it.

## Future cloud portability

Keep the lab intent stable when creating future AWS/GCP profiles.

Changing cloud should primarily replace provider-specific implementations, not the learning scope.
