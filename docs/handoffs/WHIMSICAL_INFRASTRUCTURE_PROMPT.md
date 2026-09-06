# Whimsical infrastructure diagram handoff

## Purpose

Use this document as the complete source prompt for an AI that will recreate the
target `devops-lab` infrastructure as an architecture diagram in Whimsical. The
diagram describes the platform being built, not an inventory or completion
report of resources that happen to exist today.

Create one readable, left-to-right architecture diagram. Show trust boundaries,
network boundaries, delivery paths, runtime traffic, identities, secret access,
and Terraform state separately enough that their purposes are not confused.

## Diagram title and scope

Title the diagram:

`devops-lab — Azure dev environment and GitHub Actions delivery architecture`

The scope is one Azure-first `dev` environment in `polandcentral`. The source
repository is a GitHub monorepo containing independent frontend and backend
applications plus Terraform. GitHub Actions is the only active CI/CD provider.

The platform is deliberately cost-aware:

- Azure Container Apps uses the Consumption model;
- frontend and backend can scale to zero;
- PostgreSQL Flexible Server uses Burstable `B1ms`, 32 GiB storage, and no HA;
- Azure Container Registry uses Basic;
- Key Vault uses Standard with Azure RBAC;
- Log Analytics uses pay-as-you-go, 30-day retention, and a conservative daily
  cap;
- no Front Door, Application Gateway, WAF, NAT Gateway, static public IP, AKS,
  Azure DNS, or private endpoints for ACR and Key Vault are present initially.

## Recommended Whimsical layout

Divide the canvas into five main vertical areas, from left to right:

1. external users and external DNS;
2. GitHub repository and GitHub Actions;
3. Azure identity and authorization;
4. Azure application resource group and its VNet-integrated runtime;
5. Azure Terraform-state resource group.

Place the application data plane in the center and make it visually dominant.
Place CI/CD above it and Terraform state below or to the far right. Do not draw
the Storage Account inside the application VNet. Do not draw the GitHub-hosted
runner as a permanent Azure resource.

Use solid arrows for runtime traffic, dashed arrows for CI/CD or management
operations, dotted arrows for identity/authorization, and a distinct colour for
secret access. Add a legend that explains these conventions.

## External boundary

Draw these external components outside Azure:

- an end-user browser;
- the existing external DNS provider `home.pl`;
- the public hostname `app.devopslab.com.pl`;
- the GitHub repository `WiktorL123/devops-lab`.

Show the DNS provider publishing the records needed for the Container Apps
custom-domain binding and ownership validation. The public hostname resolves to
the Azure Container Apps frontend ingress. Azure issues and renews the free
Container Apps managed TLS certificate after DNS validation.

The Azure-generated frontend `*.azurecontainerapps.io` hostname still exists as
a technical platform endpoint, but label `app.devopslab.com.pl` as the intended
public application address. Do not add an Azure DNS zone.

## GitHub repository and automation boundary

Inside the GitHub boundary, show these source areas:

- `frontend/` — independently versioned frontend container;
- `backend/` — independently versioned backend container;
- `infra/` — Terraform modules, the `dev` composition root, and the independent
  Terraform-state bootstrap;
- `.github/workflows/` — CI, infrastructure, and deployment workflows.

Show the GitHub Environment named `dev`. It stores non-secret Azure identifiers
as environment variables and scopes the OIDC jobs. Long-lived Azure client
secrets are not used.

Show the following workflow paths:

### Frontend CI and deployment

1. A pull request affecting the frontend runs `lint -> test -> build`.
2. After merge to `main`, frontend CI runs again.
3. A successful relevant post-merge CI run builds the multi-stage frontend
   image.
4. The image is tagged `<semver>-<short-sha>`; `latest` is never used.
5. The workflow pushes the image to Azure Container Registry, captures its
   immutable digest, and deploys that exact digest to the frontend Container
   App.

### Backend CI and deployment

1. A pull request affecting the backend runs `lint -> test -> build`.
2. After merge to `main`, backend CI runs again.
3. A successful relevant post-merge CI run builds the multi-stage backend
   image.
4. The image is tagged `<semver>-<short-sha>`; `latest` is never used.
5. The workflow pushes the image to Azure Container Registry and captures its
   immutable digest.
6. The workflow runs Prisma migrations as an explicit Container Apps Job or
   equivalent explicit deployment stage.
7. A successful migration allows deployment of that exact image digest to the
   backend Container App. A failed migration blocks the backend rollout.

Frontend and backend release and roll back independently by immutable image
digest or Container Apps revision.

### Terraform workflow

For pull requests affecting `infra/**`, show:

`terraform fmt -check -> terraform validate -> terraform plan`

For changes merged to `main`, show:

`terraform fmt -check -> terraform validate -> terraform plan -> save plan artifact -> apply exactly that saved plan`

The plan path uses the Terraform plan identity. The apply path uses the
Terraform apply identity. Both use the same Azure Blob backend and authenticate
without a client secret through GitHub OIDC.

## Azure identity and authorization boundary

Show GitHub Actions requesting short-lived OIDC tokens from GitHub's token
issuer. Azure validates each token against a federated credential whose trust
condition is:

```text
issuer:   https://token.actions.githubusercontent.com
subject:  repo:WiktorL123@123184089/devops-lab@1346681774:environment:dev
audience: api://AzureADTokenExchange
```

The numeric suffixes are immutable GitHub owner and repository IDs. They bind
Azure trust to this specific repository even if a repository name is later
renamed or reused.

Show four separate user-assigned managed identities used by GitHub Actions:

- `id-gh-tf-plan-dev` — reads Azure resources and reads/writes the Terraform
  state blob as required for backend operation, but does not mutate application
  resources;
- `id-gh-tf-apply-dev` — changes infrastructure in the application resource
  group and creates only approved, constrained role assignments;
- `id-gh-frontend-deploy-dev` — pushes frontend images and updates only the
  frontend application resources;
- `id-gh-backend-deploy-dev` — pushes backend images, runs the migration job,
  and updates only the backend application resources.

Make this relationship explicit:

`federated credential = which GitHub workload may assume an identity`

`Azure RBAC assignment = what that identity may do and at what scope`

Also show two separate Terraform-managed runtime identities:

- `id-app-frontend-dev` — lets the frontend runtime pull its image from ACR;
- `id-app-backend-dev` — lets the backend and migration runtime pull images and
  read only the required PostgreSQL secret from Key Vault.

Application identities do not receive permissions to query Log Analytics merely
to emit platform logs.

## Azure subscription and resource-group boundaries

Draw one Azure subscription containing two lifecycle-separated resource groups.

### Application resource group

Name:

`rg-devopslab-dev-polandcentral`

This group contains the lifecycle-managed application platform:

- customer virtual network;
- delegated Container Apps and PostgreSQL subnets;
- PostgreSQL private DNS zone and VNet link;
- Log Analytics workspace;
- Container Apps Environment;
- frontend and backend Container Apps;
- explicit database migration job;
- Azure Container Registry;
- Azure Key Vault;
- PostgreSQL Flexible Server;
- runtime managed identities and scoped RBAC assignments.

Azure may create a separate platform-managed infrastructure resource group for
the Container Apps Environment. Draw it as Azure-managed and label it `do not
edit manually`; do not treat it as an application-owned deployment target.

### Terraform-state resource group

Name:

`rg-devopslab-tfstate-polandcentral`

This group has an independent lifecycle and must outlive infrastructure managed
by the application state. It contains:

- StorageV2 account `stdevopslabtfstate190c1f` using `Standard_LRS`;
- private blob container `tfstate`;
- state object `dev/terraform.tfstate`;
- blob versioning;
- 14-day blob and container soft delete;
- HTTPS-only access with TLS 1.2 minimum;
- Shared Key authorization disabled;
- Entra ID/OIDC data-plane authorization;
- native Azure Blob lease-based Terraform state locking.

The blob service endpoint remains network-reachable from GitHub-hosted runners,
but the container does not allow anonymous public access. Access is authorized
through Azure RBAC. The plan and apply identities receive `Storage Blob Data
Contributor` at the smallest practical container scope.

Show `infra/bootstrap/tfstate` as an independent Terraform root that creates the
state resource group, Storage Account, container, and state RBAC. It deliberately
keeps its own local Terraform state to avoid the backend depending on itself.

## Application VNet and private data plane

Inside the application resource group, draw a VNet with address space:

`10.20.0.0/16`

Draw two non-overlapping subnets:

### Container Apps infrastructure subnet

- address range: `10.20.0.0/23`;
- delegated to `Microsoft.App/environments`;
- contains or is attached to the VNet-integrated Container Apps Environment;
- hosts the network integration for the frontend, backend, and migration job.

### PostgreSQL subnet

- address range: `10.20.2.0/28`;
- delegated to `Microsoft.DBforPostgreSQL/flexibleServers`;
- contains the privately reachable PostgreSQL Flexible Server;
- is dedicated to PostgreSQL Flexible Server.

Show a Private DNS zone named:

`devopslab-dev.private.postgres.database.azure.com`

Draw a Private DNS VNet link between this zone and the VNet. Label it as DNS
resolution for PostgreSQL private addresses, not as an application-to-database
network connection. The backend and migration job resolve the database hostname
through this linked zone and connect through the VNet to the delegated
PostgreSQL subnet.

## Container runtime

Draw one VNet-integrated Azure Container Apps Environment using the Consumption
workload profile. Connect it to Log Analytics for platform logs.

Inside the environment, draw:

### Frontend Container App

- separate deployable container and revision history;
- external ingress enabled;
- free managed TLS certificate for `app.devopslab.com.pl`;
- only public application entry point;
- can scale to zero;
- Nginx/application proxy forwards relative `/api/*` requests to the backend's
  internal Container Apps endpoint;
- pulls its image from ACR by runtime managed identity.

### Backend Container App

- separate deployable container and revision history;
- internal ingress only;
- no separate public custom domain;
- can scale to zero;
- receives API traffic only through the frontend proxy within the Container
  Apps environment;
- connects privately to PostgreSQL;
- obtains its database credential from Key Vault by managed identity;
- pulls its image from ACR by managed identity.

### Database migration job

- runs explicitly during backend deployment before a backend revision update;
- uses the backend image or a migration-specific invocation of that image;
- has the same required private database connectivity and narrowly scoped Key
  Vault secret access as the backend;
- is not a container-startup side effect.

Make clear that internal backend ingress removes a separate public backend
origin but does not make `/api/*` private to browser users: those routes are
intentionally exposed through the public frontend origin and still require
normal application authentication and authorization.

## Shared Azure services

### Azure Container Registry

Draw one ACR Basic registry with admin credentials disabled. It stores frontend
and backend image repositories. Deployment identities push images. Runtime
identities pull only the images required by their applications. Deployments use
immutable digests while `<semver>-<short-sha>` remains the human-readable tag.

The initial design keeps the ACR service endpoint public but protected by Entra
ID and scoped RBAC; no ACR Private Endpoint is present.

### Azure Key Vault

Draw one Key Vault Standard using Azure RBAC. It stores runtime secrets,
including the initial PostgreSQL credential. Only the backend/migration runtime
identity can read the required database secret. The frontend does not receive
that permission. Build-time secrets, if any, stay in GitHub rather than Key
Vault.

The initial design keeps the Key Vault service endpoint public but protected by
identity and RBAC; no Key Vault Private Endpoint is present.

### PostgreSQL Flexible Server

Draw one Azure Database for PostgreSQL Flexible Server:

- Burstable `B1ms`;
- 32 GiB storage;
- TLS-enabled;
- no high availability;
- private access through the delegated PostgreSQL subnet;
- private DNS resolution through the linked zone;
- not exposed through a public database endpoint.

### Log Analytics

Draw one Log Analytics workspace receiving Container Apps Environment platform
and application logs. Label it `pay-as-you-go, 30-day retention, conservative
daily cap, no Microsoft Sentinel`.

## Required arrows and labels

At minimum, include these arrows:

1. `Browser -> home.pl DNS` — resolve `app.devopslab.com.pl`.
2. `Browser -> frontend external ingress` — HTTPS.
3. `Frontend -> backend internal ingress` — proxied `/api/*` traffic.
4. `Backend -> PostgreSQL` — private TLS database connection.
5. `Migration job -> PostgreSQL` — explicit Prisma migrations.
6. `Backend/migration identity -> Key Vault` — read PostgreSQL secret.
7. `Frontend/backend runtime identities -> ACR` — pull by immutable digest.
8. `Frontend/backend deployment workflows -> ACR` — push versioned images.
9. `Deployment workflows -> corresponding Container Apps resources` — deploy
   exact image digest.
10. `Terraform plan/apply workflows -> state blob` — Entra ID data-plane access
    and state locking.
11. `Terraform plan identity -> application resource group` — read-only
    infrastructure inspection.
12. `Terraform apply identity -> application resource group` — infrastructure
    changes and constrained RBAC administration.
13. `GitHub OIDC issuer -> four GitHub managed identities` — short-lived
    federated authentication.
14. `Container Apps Environment -> Log Analytics` — logs.
15. `Private DNS zone <-> VNet` — VNet link for PostgreSQL name resolution.

Avoid drawing a direct public-browser connection to the backend or PostgreSQL.
Avoid drawing the Private DNS VNet link as if it were a backend-to-database
application connection.

## Trust and ownership annotations

Add concise annotations showing:

- GitHub owns workflow execution and issues OIDC tokens;
- Azure validates federation and enforces RBAC;
- Terraform owns declared application infrastructure and runtime identities;
- the identity bootstrap owns the initial GitHub identities, federated
  credentials, application resource group, and bootstrap role assignments;
- the independent state bootstrap owns the state resource group and backend;
- Azure owns the Container Apps platform-managed infrastructure resource group;
- home.pl remains the authoritative external DNS provider;
- users own PR review and merge; workflows never merge pull requests.

## Deferred production-oriented components

Place the following in a small grey `Not in initial dev platform` box rather
than in the active architecture:

- Front Door, Application Gateway, and WAF;
- PostgreSQL HA or zone redundancy;
- NAT Gateway and fixed outbound IP;
- private endpoints for ACR, Key Vault, and Terraform state;
- self-hosted GitHub runner;
- Azure DNS;
- AKS;
- broader monitoring or Microsoft Sentinel;
- separate test, UAT, and production environments.

These are deliberate dev-lab trade-offs, not missing connections in the
diagram.
