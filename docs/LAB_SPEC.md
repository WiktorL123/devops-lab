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
- public frontend ingress with a custom domain
- free Azure Container Apps managed TLS certificate for the frontend domain
- internal backend ingress without a public custom domain
- customer VNet integration with dedicated Container Apps and delegated
  PostgreSQL subnets
- private PostgreSQL networking and private DNS
- Azure Log Analytics workspace for initial platform troubleshooting

Optional:
- Azure DNS
- advanced TLS exercises using an uploaded or Key Vault-backed certificate
- production environment
- AKS
- monitoring/observability beyond the baseline Log Analytics workspace

The custom frontend domain is required for the accepted platform outcome. Azure
still assigns a generated `*.azurecontainerapps.io` FQDN, but that address is a
technical platform endpoint rather than the documented public application URL.

The intended low-cost baseline is a subdomain such as `app.<owned-domain>`, a
direct DNS CNAME to the generated frontend Container App hostname, the required
TXT ownership-validation record, and a free managed certificate. An apex domain
may instead use an A record to the Container Apps environment IP. The exact
hostname must be supplied before implementation.

Domain registration and DNS control are external prerequisites. Existing
external DNS hosting may be used; selecting Azure DNS requires a separate
cost-aware decision. Future infrastructure and delivery work must account for
the Azure-side hostname binding, DNS validation dependency, certificate
issuance/renewal conditions, and an HTTPS smoke test against the custom domain.

The selected Azure architecture is Option B, the balanced private-data-plane
design recorded in `docs/architecture/ADR-001-platform-architecture.md`. The
frontend is the only public application ingress. Its Nginx proxies relative
`/api/*` requests to the internally exposed backend Container App. Consequently,
API routes remain reachable through the frontend origin and require application
authentication/authorization where appropriate; the backend has no separate
public ingress. Container Apps supplies the platform edge proxy, so the initial
design does not add Front Door or Application Gateway.

The dev platform uses `polandcentral`, a lifecycle-based resource-group split,
Consumption Container Apps, private PostgreSQL Flexible Server `B1ms` with
32 GiB storage and no HA, ACR Basic, Key Vault Standard, and Log Analytics
pay-as-you-go with 30-day retention and a daily cap. These are approved planning
assumptions, not authorization to provision paid resources. Availability and
current prices must be rechecked before provisioning.

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

The selected CI/CD provider for the active lab implementation is GitHub Actions.
Azure Pipelines is not part of the current delivery path.

Deployment workflows run only after the corresponding post-merge CI workflow
has succeeded on `main` and the component has runtime-impacting changes. Pull
request workflows do not publish or deploy container images.

Frontend:
- successful post-merge frontend CI
- build container
- push to ACR
- tag the image as `<semver>-<short-sha>`
- capture the immutable image digest
- deploy/update frontend Container App

Backend:
- successful post-merge backend CI
- build container
- push to ACR
- tag the image as `<semver>-<short-sha>`
- capture the immutable image digest
- explicit Prisma migration job/stage
- deploy/update backend Container App

Deployments identify the selected image by its immutable registry digest. The
semantic-version and short-SHA tag remains a human-readable release identifier.
Do not publish or deploy `latest`.

The first real deployment happens through CI/CD.

## Terraform

Start with local state.

Later migrate state deliberately to Azure Blob Storage as a learning exercise.

The remote-state target is a dedicated StorageV2 `Standard_LRS` account in
`rg-devopslab-tfstate-polandcentral`, separate from the resources controlled by
that state. It uses a private `tfstate` container and a key such as
`dev/terraform.tfstate`, with blob versioning and 14-day blob/container soft
delete. Shared Key authorization is disabled. GitHub-hosted runners authenticate
through OIDC and Entra ID and receive `Storage Blob Data Contributor` at the
smallest practical state-container scope. The public blob service endpoint is
retained initially for runner reachability; the container is not public.

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

## Approval policy

All repository mutations use atomic approval gates.

Every requested approval must state:
- objective,
- files/resources expected to change,
- behavior being introduced or changed,
- explicit out-of-scope items.

If additional work becomes necessary during implementation, stop and request a new approval.

## Platform architecture decision

The Platform Architect compared three complete alternatives. Option B was
selected on 2026-08-29. The ADR is the implementation handoff to the DevOps
Builder. Any departure from its topology, paid SKU assumptions, identity model,
or explicit deferrals requires a new atomic approval gate.

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
