# Platform Architecture Options

## Status

- Date: 2026-08-29
- Role: Platform Architect
- Status: decided; Option B selected on 2026-08-29
- Decision owner: repository owner
- Active cloud profile: Azure

This document compares complete platform options. Option B was selected through
an atomic approval gate and is recorded in `ADR-001-platform-architecture.md`.
The decision does not authorize Terraform, Azure resources, role assignments,
DNS changes, or deployment.

## Confirmed inputs

| Input | Value |
|---|---|
| Current remaining Azure credit | User-declared USD 175; dynamic account state, not a permanent constant |
| Environment | One `dev` environment |
| Region | `polandcentral` (Warsaw) |
| Traffic | Low-volume learning workload |
| Scaling | Frontend and backend may scale to zero; cold starts are acceptable |
| Public endpoint | Frontend only |
| Backend endpoint | Internal to the Container Apps environment |
| Public hostname | `app.devopslab.com.pl` |
| DNS provider | home.pl; public NS records resolve to `dns.home.pl`, `dns2.home.pl`, and `dns3.home.pl` |
| DNS capability | home.pl supports A, CNAME, TXT, and CAA records; `app.devopslab.com.pl` currently has no public record |
| CI/CD provider | GitHub Actions only |
| Application units | Separate frontend and backend containers |
| Required platform capabilities | Container Apps environment, managed identities, two Container Apps, PostgreSQL, Key Vault, networking/proxy analysis, Log Analytics, ACR, Terraform state, and RBAC explanation |

### Verification limits

The local workstation does not currently have Azure CLI installed, so this
review could not query subscription-specific provider registrations, quotas, or
SKU restrictions. Poland Central is an Azure region located in Warsaw, and the
official PostgreSQL availability matrix includes Flexible Server there. Before
provisioning, an approved read-only preflight must verify all required resource
types and the selected PostgreSQL SKU against the actual subscription.

Retail prices below are public pay-as-you-go meters, not an invoice quote for
the user's promotional offer. The Azure portal/cost calculator and the remaining
credit must be checked again immediately before a paid SKU is approved.

## Non-negotiable constraints

- The first real application deployment happens through CI/CD.
- Pull requests do not publish or deploy images.
- Runtime secrets are stored in Key Vault.
- GitHub authenticates to Azure with OIDC; no long-lived Azure client secret.
- Images are deployed by immutable digest and retain a
  `<semver>-<short-sha>` tag for human traceability.
- The frontend uses the custom hostname; the generated Container Apps FQDN is a
  technical endpoint.
- The backend has no public ingress.
- PostgreSQL migrations run as an explicit deployment stage, not at backend
  container startup.
- Cost estimates are planning estimates in USD, exclude tax and exchange-rate
  effects, and must be rechecked before provisioning.

## Shared platform building blocks

Every option contains:

- one Azure Container Apps workload-profiles environment using the Consumption
  plan;
- one externally reachable frontend Container App;
- one internally reachable backend Container App;
- one explicit Container Apps Job or equivalent one-shot stage for Prisma
  migrations;
- Azure Database for PostgreSQL Flexible Server;
- Azure Container Registry;
- Azure Key Vault using the Azure RBAC permission model;
- one Log Analytics workspace for Container Apps console and system logs;
- user-assigned managed identities for runtime access and image pulls;
- GitHub Actions workload-identity federation;
- local Terraform state initially, followed by a deliberate migration to Azure
  Blob Storage in a dedicated Storage Account and resource group;
- a free managed TLS certificate whenever TLS terminates directly at Container
  Apps.

### Common request flow without an extra proxy

```text
browser
  -> home.pl DNS: app.devopslab.com.pl
  -> Azure Container Apps edge proxy (TLS termination)
  -> frontend Container App (Nginx)
  -> /api proxy to internal backend app name
  -> Container Apps internal Envoy routing
  -> backend Container App
  -> PostgreSQL
```

Container Apps already supplies an Envoy-based edge proxy for TLS termination,
routing, load balancing, revisions, and internal service discovery. The current
frontend Nginx remains the application-owned reverse proxy that preserves the
browser's relative `/api` path. Adding another proxy is therefore an optional
security or global-routing decision, not a functional requirement.

### Common delivery flow

```text
pull request
  -> component CI: lint -> test -> build

merge to main
  -> component post-merge CI
  -> GitHub OIDC login to Azure
  -> build image once
  -> push image to ACR
  -> capture image digest
  -> frontend: update exact frontend digest
  -> backend: run migration job -> update exact backend digest
  -> HTTPS smoke test through app.devopslab.com.pl
```

## Option A — Lean public PaaS

### Topology

```text
Internet
  -> public Container Apps environment
     -> external frontend
        -> internal backend
           -> public PostgreSQL endpoint over TLS

GitHub OIDC -> public Azure control planes, ACR, and deployment APIs
backend identity -> public Key Vault endpoint with RBAC
```

### Resources and configuration

- Container Apps workload-profiles environment with provider-managed Azure
  networking; no customer VNet.
- Consumption-plan frontend and backend with `minReplicas = 0`.
- Backend ingress set to internal.
- PostgreSQL Flexible Server Burstable `B1ms`, 32 GiB storage, public network
  access, TLS required, no HA.
- ACR Basic with public network access and admin credentials disabled.
- Key Vault Standard with public network access and Azure RBAC.
- Log Analytics pay-as-you-go with 30-day retention and a conservative daily cap.
- Direct custom-domain binding and free managed certificate on the frontend app.
- One user-controlled application resource group; a separate state resource
  group is added during remote-state migration.

### Network and trust boundary

The apps are isolated from each other by ingress configuration, but PostgreSQL,
ACR, and Key Vault expose public service endpoints. Authentication, TLS, firewall
rules, and RBAC protect those endpoints.

The difficult part is PostgreSQL firewall maintenance. Container Apps outbound
addresses are not the same as a dedicated, user-owned static egress address.
Allowing all Azure services simplifies the lab but creates a wider network trust
boundary. Maintaining a changing outbound allowlist is operationally fragile.

### Advantages

- Lowest Terraform and networking complexity.
- Fastest path to the first pipeline deployment.
- No customer VNet, subnet, NAT Gateway, private endpoint, or private DNS cost.
- Direct use of the free Container Apps managed certificate.
- Easy to troubleshoot with public service endpoints.

### Disadvantages and risks

- PostgreSQL is reachable through a public endpoint even though authentication
  and TLS remain required.
- A broad PostgreSQL firewall exception for Azure services would be a real
  security compromise.
- Teaches fewer private-networking concepts.
- A later private-network migration changes the database connectivity model.

### Production compromise

This is acceptable for a disposable, low-risk dev lab but is weaker than a
production design because the database network boundary is public.

## Option B — Balanced private data plane

### Topology

```text
Internet
  -> public Container Apps environment in a customer VNet
     -> external frontend
        -> internal backend
           -> delegated PostgreSQL subnet
              -> private PostgreSQL endpoint

backend identity -> Key Vault over its public endpoint with RBAC
app identities -> ACR Basic over its public endpoint with repository/pull RBAC
```

### Resources and configuration

- Container Apps workload-profiles environment integrated with a customer VNet.
- Suggested VNet: `10.20.0.0/16`.
- Dedicated Container Apps infrastructure subnet: at least `/27`.
- Delegated PostgreSQL subnet: start with `/28`, subject to provider validation.
- Private DNS zone ending in `postgres.database.azure.com`, linked to the VNet.
- External environment address, external frontend ingress, internal backend
  ingress, and built-in Container Apps proxy.
- PostgreSQL Flexible Server Burstable `B1ms`, 32 GiB storage, private network
  access, TLS required, no HA.
- ACR Basic remains public because private endpoints require a more expensive
  registry/network design; managed identity protects image access.
- Key Vault Standard remains public at the network layer but uses Azure RBAC and
  managed identity; it stores the PostgreSQL connection secret.
- Log Analytics pay-as-you-go with 30-day retention and a daily ingestion cap.
- Direct frontend domain binding and free managed certificate.
- One application resource group plus a later separate Terraform-state resource
  group. Azure also creates a managed resource group for VNet-integrated
  Container Apps infrastructure; it must not be edited manually.
- During the planned remote-state migration, one StorageV2 `Standard_LRS`
  account with a private `tfstate` blob container, blob versioning, and 14-day
  blob/container soft delete. Shared Key authorization is disabled; GitHub uses
  OIDC and Azure RBAC. The public blob service endpoint remains reachable by
  GitHub-hosted runners, without making the container anonymously accessible.

### Network and trust boundary

The database is not exposed through a public endpoint. Frontend-to-backend and
backend-to-database traffic remain within the platform/VNet path. ACR and Key
Vault still use public service endpoints, but access is identity-based and no
registry password or Key Vault secret is placed in GitHub.

No NAT Gateway is required because the database is private and this lab has no
external service that allowlists one fixed outbound IP. Adding NAT would create
a fixed monthly cost without solving a current requirement.

### Advantages

- Removes the most important public data-plane exposure: PostgreSQL.
- Teaches VNet integration, subnet delegation, and private DNS.
- Preserves Consumption scale-to-zero and the free managed frontend certificate.
- Cost is close to Option A because VNets do not have a fixed hourly charge.
- Avoids an unnecessary Front Door, Application Gateway, NAT Gateway, or private
  endpoint estate.
- Provides a useful foundation for later production comparison.

### Disadvantages and risks

- More Terraform dependencies and more ways for DNS or subnet delegation to
  fail.
- Container Apps environment networking cannot be changed in place; an incorrect
  initial network choice can require environment replacement.
- ACR and Key Vault endpoints remain publicly reachable at the network layer.
- The Azure-managed Container Apps resource group adds operational noise.

### Production compromise

This does not provide private endpoints for every PaaS service, a WAF, static
egress, zone-redundant compute, or database HA. Those omissions are intentional
to protect the lab budget.

## Option C — Regional proxy and internal app environment

### Topology

```text
Internet
  -> static public IP
  -> Application Gateway
  -> internal Container Apps environment in a customer VNet
     -> internal frontend
        -> internal backend
           -> private PostgreSQL
```

### Resources and configuration

- Customer VNet with separate subnets for Application Gateway, Container Apps,
  and PostgreSQL.
- Internal Container Apps workload-profiles environment.
- Application Gateway Basic v2 as the only public application entry point.
- A static Standard public IP for Application Gateway.
- Custom domain and TLS terminate at Application Gateway rather than directly at
  Container Apps.
- The certificate must be supplied and renewed through a separate certificate
  process, commonly backed by Key Vault; the free Container Apps managed
  certificate no longer solves edge TLS.
- Private PostgreSQL as in Option B.
- ACR Basic, Key Vault Standard, Log Analytics, OIDC, and runtime identities as
  in Option B.

### Network and trust boundary

Both application containers are private. Application Gateway is the controlled
regional ingress boundary. This demonstrates a traditional layered network but
adds another service, subnet, public IP, health probes, TLS lifecycle, and
failure boundary.

### Advantages

- The generated Container Apps application endpoint is not a direct public
  origin.
- Explicit regional reverse-proxy and health-probe learning.
- Clear place for future routing rules or a later WAF upgrade.
- Private PostgreSQL and internal east-west application traffic.

### Disadvantages and risks

- Roughly doubles the expected monthly lab cost.
- Basic v2 is a proxy/load balancer, not a WAF. Upgrading to WAF v2 creates a
  much larger fixed charge.
- Loses the simple free Container Apps managed-certificate path.
- More difficult cold-start behavior because gateway health probes must tolerate
  apps scaling from zero.
- More Terraform, certificate automation, DNS, and troubleshooting work with
  little benefit for a single low-traffic dev service.

### Production compromise

The design looks more enterprise-like but still lacks WAF protection and private
endpoints for ACR and Key Vault. A genuinely hardened version is materially more
expensive than the USD 175 lab budget supports.

## Proxy comparison

| Choice | What it provides | Approximate fixed cost | TLS consequence | Assessment |
|---|---|---:|---|---|
| Container Apps built-in Envoy plus frontend Nginx | TLS termination, revisions, load balancing, internal discovery, `/api` proxy | Included with Container Apps usage | Free Container Apps managed certificate | Recommended |
| Azure Front Door Standard | Global edge, acceleration, rules, optional WAF policy features | About USD 35/month base plus requests and transfer | Certificate terminates at Front Door | Unnecessary for one Warsaw dev workload |
| Application Gateway Basic v2 | Regional reverse proxy, probes, routing | About USD 29/month including one capacity unit and public IP | Separate certificate lifecycle | Educational but poor value here |
| Application Gateway WAF v2 | Regional proxy and managed WAF | Fixed meter alone is roughly USD 376/month before capacity | Separate certificate lifecycle | Exceeds the lab budget |
| Front Door Premium with Private Link | Global WAF/edge with private Container Apps origin | About USD 330/month base before traffic | Front Door certificate | Exceeds the lab budget |

The recommended design uses no additional Azure proxy. This is not the absence
of a proxy: Container Apps already provides the platform edge, and the frontend
container already owns application-level `/api` proxying.

## Resource-group alternatives

### Single user-controlled group

```text
rg-devopslab-dev-polandcentral
```

Simple cleanup, but remote Terraform state must never live in the same group as
resources it controls.

### Lifecycle-based split — recommended

```text
rg-devopslab-dev-polandcentral       # application platform
rg-devopslab-tfstate-polandcentral   # created during remote-state migration
ME_<environment>_<group>_<region>    # Azure-managed Container Apps group
```

The state group has a different deletion lifecycle. The `ME_...` group is
created and maintained by Azure for the VNet-integrated Container Apps
environment and must not be edited or deleted independently.

### Capability-based split

```text
rg-devopslab-network-dev
rg-devopslab-data-dev
rg-devopslab-app-dev
rg-devopslab-ops-dev
rg-devopslab-identities-dev
rg-devopslab-tfstate
```

This improves ownership boundaries for a larger organization but adds RBAC,
Terraform state, dependency, naming, and cleanup complexity with no current team
benefit.

## Identity model

### What authenticates from GitHub

A GitHub-hosted runner is ephemeral and does not receive an Azure role directly.
GitHub issues an OIDC token. Azure validates that token against a federated
identity credential and returns a short-lived Azure token for either:

1. a Microsoft Entra application/service principal, or
2. a user-assigned managed identity.

Both avoid a client secret. The recommended lab implementation uses
user-assigned managed identities so infrastructure, deployment, and runtime
identities use one Azure-native model. GitHub stores only identifiers such as
client ID, tenant ID, and subscription ID; these are configuration values, not
authentication secrets. Workflows require `id-token: write` and should bind the
federated subject to the repository and GitHub `dev` environment.

### Why identities are separated

A single subscription-wide Contributor identity would be simpler, but it would
mix read-only plans, infrastructure mutation, image publication, application
deployment, and runtime secret access. Separate identities limit the impact of a
workflow or application compromise and make the learning goal visible.

Recommended identities:

- `id-gh-tf-plan-dev`: Terraform plan only;
- `id-gh-tf-apply-dev`: approved Terraform apply and controlled RBAC creation;
- `id-gh-frontend-deploy-dev`: frontend image push and frontend update;
- `id-gh-backend-deploy-dev`: backend image push, migration-job execution, and
  backend update;
- `id-app-frontend-dev`: frontend image pull; no Key Vault access;
- `id-app-backend-dev`: backend and migration image pull plus runtime database
  secret read.

Sharing the backend identity with the migration job is acceptable because both
need the same image and database secret. Production could separate them further.

## Recommended RBAC matrix

The exact resource IDs do not exist yet. The table defines the intended role and
smallest practical scope; it is not a role assignment script.

| Principal | Built-in role | Scope | Why | Explicitly not granted |
|---|---|---|---|---|
| Human bootstrap administrator | Existing `Owner` or `Role Based Access Control Administrator` plus resource creation rights | Subscription only for the short bootstrap operation | Create the initial resource groups, OIDC identity, federated credential, and constrained delegation | Not a permanent pipeline credential |
| `id-gh-tf-plan-dev` | `Reader` | Application resource group | Refresh resources and calculate a plan without mutation | No resource writes or role assignments |
| `id-gh-tf-plan-dev` | `Storage Blob Data Contributor` | Terraform state container, after remote-state migration | Read state and acquire/write the state lock; Terraform backends need data-plane access | No storage-account management |
| `id-gh-tf-apply-dev` | `Contributor` | Application resource group | Create, update, and delete approved platform resources | Contributor cannot create role assignments and cannot read Key Vault secret values |
| `id-gh-tf-apply-dev` | `Role Based Access Control Administrator` with an ABAC condition | Application resource group | Create only the required runtime/deployment role assignments | Condition must prevent Owner, User Access Administrator, and unrelated principals/roles |
| `id-gh-tf-apply-dev` | `Storage Blob Data Contributor` | Terraform state container, after migration | Read/write and lock remote state | No broad storage management |
| `id-gh-tf-apply-dev` | `Key Vault Secrets Officer` | Dev Key Vault only, only if Terraform manages secret values | Create/update the PostgreSQL runtime secret | No role-assignment administration through this role; no keys/certificates administration |
| `id-gh-frontend-deploy-dev` | `Container Registry Repository Writer` with repository condition, or legacy `AcrPush` | Frontend repository in ACR, or registry if ABAC is not enabled | Push and read frontend image content | No image deletion; no backend repository access when ABAC is used |
| `id-gh-frontend-deploy-dev` | `Container Apps Contributor` | Frontend Container App | Update the frontend to an exact digest | No Terraform-wide resource management or role assignments |
| `id-gh-backend-deploy-dev` | `Container Registry Repository Writer` with repository condition, or legacy `AcrPush` | Backend repository in ACR, or registry if ABAC is not enabled | Push and read backend image content | No frontend repository access when ABAC is used |
| `id-gh-backend-deploy-dev` | `Container Apps Contributor` | Backend Container App | Update the backend to an exact digest | No infrastructure-wide rights |
| `id-gh-backend-deploy-dev` | `Container Apps Jobs Operator` | Migration Container Apps Job | Start and observe an existing migration execution | No permission to redefine the job or read its runtime secret |
| `id-app-frontend-dev` | `Container Registry Repository Reader` with repository condition, or `AcrPull` | Frontend repository or ACR | Pull the frontend image | No push/delete and no Key Vault access |
| `id-app-backend-dev` | `Container Registry Repository Reader` with repository condition, or `AcrPull` | Backend repository or ACR | Pull backend/migration images | No push/delete |
| `id-app-backend-dev` | `Key Vault Secrets User` | Dev Key Vault | Let Container Apps resolve the PostgreSQL secret reference | Read only; no secret creation, deletion, or RBAC management |

Additional `Reader` access at the application resource-group or Container Apps
environment scope may be required by a deployment action to resolve an existing
environment. This must be verified with the selected actions before granting it;
do not preemptively grant broad Contributor at subscription scope.

### Constrained RBAC administration

Terraform must create role assignments for runtime identities, so `Contributor`
alone is insufficient. Granting unrestricted `Owner` to the apply identity would
be excessive. The preferred bootstrap is:

1. the human creates the application resource group and apply identity;
2. the human grants `Contributor` at that resource group;
3. the human grants `Role Based Access Control Administrator` at the same scope
   with a condition limiting assignable roles and target principals;
4. Terraform creates only the approved `AcrPull`/repository reader,
   repository writer, Container Apps, and Key Vault secret-reader assignments;
5. subscription-wide privileged access is never granted to GitHub.

Role-assignment propagation is eventually consistent. Creating a Key Vault,
granting the apply identity `Key Vault Secrets Officer`, and immediately writing
a secret can require a staged apply or retry. This is an implementation concern,
not a reason to grant broader access.

### Log Analytics identity behavior

The Container Apps environment sends console and system logs to its configured
workspace. Runtime apps do not need a Log Analytics data-reader role merely to
emit those logs. Human troubleshooting access and any future automated querying
should receive separately approved read roles. Do not grant the application
identities permission to query all workspace logs.

### PostgreSQL authentication

The initial lab uses a PostgreSQL credential stored in Key Vault and exposed to
the backend/migration job through a Container Apps Key Vault reference. The
GitHub deploy identity does not read the credential.

Microsoft Entra authentication for PostgreSQL could remove the stored database
password, but Prisma connection pooling and short-lived token refresh add
application complexity. It is a valid later exercise, not the cost-first initial
baseline.

## Secrets and state flow

```text
human bootstrap
  -> creates federated apply identity and constrained RBAC delegation

GitHub Actions
  -> OIDC token
  -> short-lived Azure token
  -> no AZURE_CLIENT_SECRET

Terraform apply
  -> provisions Key Vault and PostgreSQL
  -> stores required runtime secret in Key Vault
  -> sensitive value also exists in Terraform state

backend managed identity
  -> Key Vault Secrets User
  -> Container Apps resolves secret reference
  -> backend receives runtime connection configuration
```

Because Terraform-managed secrets are represented in Terraform state, the state
is sensitive even when it is encrypted in Blob Storage. Access must be limited
to the plan/apply identities and approved administrators. State, `.terraform/`,
and plan files containing sensitive values must never be committed.

## Logging and cost controls

The Log Analytics workspace is required for this lab because troubleshooting is
a core learning goal.

Recommended controls:

- pay-as-you-go Analytics Logs;
- 30-day retention, within the included 31-day Analytics retention window;
- do not enable Microsoft Sentinel;
- begin with Container Apps console and system logs;
- add diagnostic categories deliberately rather than selecting every category;
- configure a daily cap and a budget alert;
- review ingestion after the first deployment.

The first 5 GB/month of Analytics Logs ingestion per billing account is currently
free. Above that allowance, the Poland Central retail meter observed for this
review is USD 2.99/GB. Log volume is therefore a usage-driven cost risk even when
the applications scale to zero.

## Cost comparison

### Pricing facts used

Observed from Microsoft's retail prices and service pricing on 2026-08-29:

- PostgreSQL Flexible Server `B1ms`: USD 0.0199/hour.
- PostgreSQL storage: USD 0.137/GB-month; estimate uses 32 GiB.
- ACR Basic: USD 0.1666/day and includes 10 GB storage.
- Container Apps free monthly grant: 180,000 vCPU-seconds, 360,000 GiB-seconds,
  and 2 million requests per subscription.
- Key Vault Standard operations: USD 0.03 per 10,000 operations.
- Log Analytics: first 5 GB/month free per billing account; observed pay-as-you-go
  ingestion meter USD 2.99/GB after the allowance.
- Application Gateway Basic v2: USD 0.027/hour fixed plus USD 0.008/hour per
  capacity unit; Standard public IPv4 observed at USD 0.005/hour.
- Azure Front Door Standard: USD 35/month base before request and transfer fees.
- Azure Front Door Premium: USD 330/month base before traffic.

### Low-traffic monthly estimate

Assumptions: 730 hours/month, PostgreSQL running continuously, 32 GiB database
storage, ACR under 10 GB, Container Apps inside free grant, Log Analytics at or
below the 5 GB allowance, negligible Key Vault operations, and no material data
egress.

| Cost item | Option A | Option B | Option C |
|---|---:|---:|---:|
| PostgreSQL B1ms compute | USD 14.53 | USD 14.53 | USD 14.53 |
| PostgreSQL 32 GiB storage | USD 4.38 | USD 4.38 | USD 4.38 |
| ACR Basic | USD 5.07 | USD 5.07 | USD 5.07 |
| Container Apps low usage | approximately USD 0 | approximately USD 0 | approximately USD 0 |
| Log Analytics <= 5 GB | approximately USD 0 | approximately USD 0 | approximately USD 0 |
| Key Vault and state storage | less than USD 0.25 | less than USD 0.25 | less than USD 0.25 |
| Private DNS | N/A | approximately USD 0.50 | approximately USD 0.50 |
| Application Gateway + public IP | N/A | N/A | approximately USD 29.20 |
| Estimated total | **USD 24–25/month** | **USD 24.5–26/month** | **USD 53–55/month plus certificate lifecycle** |
| Approximate USD 175 runway | about 7 months | about 6–7 months | about 3 months |

These estimates exclude other workloads in the subscription, taxes, currency
conversion, overage logs, data transfer, backups beyond included allowances, and
future price changes. Promotional-credit expiry may end the runway earlier.

PostgreSQL compute can be stopped to reduce compute charges, but storage remains
billed and Azure automatically starts a stopped Flexible Server after seven
days. Scale-to-zero Container Apps does not make PostgreSQL free.

## Operational and developer comparison

| Driver | Option A | Option B | Option C |
|---|---|---|---|
| Initial Terraform difficulty | Low | Medium | High |
| Network learning value | Low | High | High |
| Database exposure | Public endpoint | Private VNet path | Private VNet path |
| Extra proxy | None | None | Application Gateway |
| Managed frontend certificate | Simple/free at Container Apps | Simple/free at Container Apps | Separate lifecycle at gateway |
| Scale-to-zero behavior | Simple | Simple | Gateway probes add complexity |
| Troubleshooting surface | Small | Moderate: DNS/subnets | Large: proxy/probes/TLS/DNS/subnets |
| Fixed-cost efficiency | Best | Nearly best | Poorer |
| Production similarity | Low | Moderate | Higher topology, but no WAF |
| Migration path | Requires later VNet/database change | Extend with controls as needed | Expensive controls already introduced |

## Failure and rollback boundaries

All options must preserve:

- immutable image digests so a prior revision can be restored without rebuild;
- single-revision deployment initially, with Container Apps revision history
  available for rollback;
- migration failure blocking the backend revision update;
- frontend and backend rollback independence;
- an HTTPS smoke test through the custom hostname;
- a direct health check of the internal backend from the frontend path;
- Terraform plan/apply separation and application of the saved plan after the
  infrastructure workflow is introduced;
- explicit cleanup instructions for paid resources.

Option-specific failures:

- Option A: PostgreSQL firewall drift can break connectivity.
- Option B: private DNS links, subnet delegation, or environment replacement can
  break connectivity.
- Option C: Application Gateway probes, certificate state, public IP, and origin
  routing add new failure points before traffic reaches the frontend.

## Decision drivers

The strongest drivers for this lab are:

1. meaningful Azure networking and identity learning;
2. preservation of the USD 175 credit;
3. custom-domain delivery without certificate-maintenance work;
4. a hidden backend and private database;
5. enough observability to troubleshoot deployments;
6. architecture that remains understandable when Terraform and CD are added.

## Architect recommendation

**Recommend Option B — Balanced private data plane.**

Why it is sufficient:

- It keeps the public boundary at the frontend and makes PostgreSQL private.
- It teaches the VNet, subnet delegation, private DNS, managed identity, RBAC,
  Log Analytics, and Container Apps environment concepts requested for the lab.
- It preserves scale-to-zero and direct free managed TLS for
  `app.devopslab.com.pl`.
- It costs only marginally more than the weakest network option.
- It avoids paying for a proxy when Container Apps and Nginx already provide the
  required proxy layers.

Rejected trade-offs:

- Compared with Option A, it accepts more Terraform and DNS troubleshooting in
  exchange for removing public PostgreSQL exposure.
- Compared with Option C, it leaves the Container Apps frontend origin publicly
  reachable through its generated FQDN and does not introduce a WAF. The custom
  domain remains the documented address, and this is acceptable for dev.
- ACR and Key Vault remain public endpoints protected by identity rather than
  private endpoints. Moving ACR to Premium and adding private endpoints would
  materially reduce the credit runway.

The user selected this recommendation on 2026-08-29 through atomic approval
gate #10.

## Recorded decision

- Option B, including the lifecycle-based resource-group split.
- User-assigned managed identities as the GitHub OIDC targets, with separate
  plan, apply, frontend-deploy, and backend-deploy identities.
- PostgreSQL `B1ms`, 32 GiB, no HA as the future cost-first dev SKU.
- Log Analytics pay-as-you-go, 30-day retention, and a daily cap.
- No Front Door, Application Gateway, NAT Gateway, Azure DNS, private ACR
  endpoint, or private Key Vault endpoint in the initial implementation.
- A dedicated low-cost Storage Account for remote Terraform state, introduced
  only during the planned migration from local state.

The detailed rationale and consequences are in
`ADR-001-platform-architecture.md`. Selecting the architecture does not
authorize Terraform or Azure resource creation. Those require later atomic
change-sets.

## Sources

- Azure regions: https://learn.microsoft.com/en-us/azure/reliability/regions-list
- PostgreSQL regions and capabilities: https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/overview
- PostgreSQL stop/start behavior: https://learn.microsoft.com/en-us/azure/postgresql/configure-maintain/how-to-stop-server
- Container Apps networking: https://learn.microsoft.com/en-us/azure/container-apps/networking
- Container Apps VNet integration: https://learn.microsoft.com/en-us/azure/container-apps/custom-virtual-networks
- Container Apps environments and logging: https://learn.microsoft.com/en-us/azure/container-apps/environment
- Container Apps internal communication: https://learn.microsoft.com/en-us/azure/container-apps/connect-apps
- Container Apps custom domains and managed certificates: https://learn.microsoft.com/en-us/azure/container-apps/custom-domains-managed-certificates
- GitHub Actions OIDC: https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure-openid-connect
- Managed identity ACR pulls: https://learn.microsoft.com/en-us/azure/container-apps/managed-identity-image-pull
- Container Apps Key Vault references: https://learn.microsoft.com/en-us/azure/container-apps/manage-secrets
- Azure container roles: https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/containers
- Key Vault RBAC roles: https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-guide
- Delegated RBAC with conditions: https://learn.microsoft.com/en-us/azure/role-based-access-control/delegate-role-assignments-overview
- Azure Monitor pricing: https://azure.microsoft.com/en-us/pricing/details/monitor/
- Container Apps pricing: https://azure.microsoft.com/en-us/pricing/details/container-apps/
- ACR pricing: https://azure.microsoft.com/en-us/pricing/details/container-registry/
- home.pl DNS record support: https://pomoc.home.pl/baza-wiedzy/rekordy-domeny
- Azure retail price API: https://prices.azure.com/api/retail/prices
- Terraform `azurerm` backend: https://developer.hashicorp.com/terraform/language/backend/azurerm
- Azure Storage security: https://learn.microsoft.com/en-us/azure/storage/common/secure-storage
- Azure Blob soft delete: https://learn.microsoft.com/en-us/azure/storage/blobs/soft-delete-blob-overview
