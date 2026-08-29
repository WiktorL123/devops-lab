# ADR-001: Balanced Private Data Plane on Azure

## Status

Accepted on 2026-08-29 through atomic approval gate #10.

This ADR selects an architecture. It does not authorize Terraform changes,
Azure provisioning, role assignments, DNS changes, certificates, pipelines, or
deployment.

## Context

`devops-lab` needs a realistic but cost-aware Azure platform for one low-traffic
`dev` environment. Its purpose is to teach Terraform, network boundaries,
managed identity, OIDC, container delivery, secrets, migrations, observability,
and troubleshooting. The current promotional credit reported by the user is
USD 175 and must be treated as dynamic account state.

Three complete designs were compared in `PLATFORM_OPTIONS.md`. The decision must
keep the frontend public, avoid a separate public backend endpoint, use the
owned `devopslab.com.pl` domain, and provide materially useful Azure learning
without consuming the budget on an unnecessary proxy or production-grade HA.

## Decision

Select **Option B — Balanced private data plane** in `polandcentral`.

### Topology and request flow

```text
browser
  -> home.pl DNS: app.devopslab.com.pl
  -> Container Apps external ingress and managed TLS
  -> frontend Container App (Nginx)
  -> /api/* proxy
  -> backend Container App with internal ingress
  -> private PostgreSQL Flexible Server
```

The Container Apps environment is integrated with a customer VNet. Start with
`10.20.0.0/16`, a dedicated Container Apps infrastructure subnet of at least
`/27`, and a delegated PostgreSQL subnet of `/28`, subject to provider and
subscription preflight validation. A PostgreSQL private DNS zone is linked to
the VNet.

The frontend is the only public application ingress. “Internal backend” means
that the backend has no separate public ingress or public hostname. It does not
make proxied APIs private: Nginx deliberately forwards `/api/*` to the backend,
so those routes remain reachable at the frontend origin. Sensitive API routes
must use application authentication and authorization. The health route may
remain public for platform checks.

Container Apps already provides the Azure edge proxy, while frontend Nginx owns
the application `/api` proxy. Do not add Front Door, Application Gateway, or a
separate reverse proxy in the initial platform.

### Resource inventory and cost-first SKUs

- lifecycle-managed application resource group:
  `rg-devopslab-dev-polandcentral`;
- Azure-managed Container Apps infrastructure resource group, never edited
  manually;
- one Consumption workload-profiles Container Apps environment;
- separate frontend and backend Container Apps, initially able to scale to zero;
- one Container Apps Job or equivalent explicit stage for Prisma migrations;
- PostgreSQL Flexible Server Burstable `B1ms`, 32 GiB, private access, TLS, no
  HA;
- ACR Basic with admin credentials disabled;
- Key Vault Standard using the Azure RBAC permission model;
- Log Analytics pay-as-you-go, 30-day retention, conservative daily cap, and no
  Microsoft Sentinel;
- direct custom-domain binding for `app.devopslab.com.pl` with a free Container
  Apps managed certificate;
- no Azure DNS, NAT Gateway, ACR private endpoint, Key Vault private endpoint,
  Front Door, Application Gateway, WAF, or static public IP initially.

The estimated low-traffic cost is approximately USD 24.5–26 per month under the
assumptions recorded in `PLATFORM_OPTIONS.md`. PostgreSQL is the main continuous
cost. Prices, available credit, provider registration, quota, and regional SKU
availability must be checked again before provisioning any paid resource.

### Terraform state and resource lifecycle

Stage 4 starts with local Terraform state. A later, explicit learning stage
migrates it to Azure Blob Storage.

The migration target is:

- separate resource group `rg-devopslab-tfstate-polandcentral`;
- one StorageV2 `Standard_LRS` Storage Account;
- private blob container `tfstate`;
- backend key such as `dev/terraform.tfstate`;
- HTTPS only and minimum TLS 1.2;
- Shared Key authorization disabled;
- GitHub OIDC and Entra ID authorization, with `Storage Blob Data Contributor`
  at the smallest practical container scope for plan/apply identities;
- blob versioning and 14-day blob and container soft delete;
- native `azurerm` backend blob-lease state locking.

The blob service endpoint remains network-reachable by GitHub-hosted runners in
the initial implementation. This is not anonymous blob access. Private Endpoint,
NAT, and a self-hosted runner are deferred because they add cost and operational
complexity without serving the current lab goal. Terraform state is sensitive
and must not be committed or exposed. The state resource group has a different
deletion lifecycle and must outlive every resource managed by that state.

### Identity, RBAC, and secrets

GitHub Actions authenticates through workload-identity federation to
user-assigned managed identities. It stores identifiers, not a long-lived Azure
client secret. Use separate identities for Terraform plan, Terraform apply,
frontend deployment, and backend deployment. Runtime frontend and backend
identities are also separate.

The approved role intent and minimum scopes are defined in the RBAC matrix in
`PLATFORM_OPTIONS.md`. Key boundaries are:

- plan can read infrastructure and access the state data plane but cannot mutate
  Azure resources;
- apply receives Contributor only at the application resource group, plus
  constrained role-assignment administration where implementation requires it;
- deploy identities can push only their component images and update only their
  corresponding app/job resources;
- runtime identities can pull only the required images;
- only backend/migration runtime identity reads the PostgreSQL secret from Key
  Vault;
- application identities do not receive Log Analytics query access merely to
  emit logs.

Runtime secrets belong in Key Vault. Build-time secrets belong in GitHub. The
initial PostgreSQL credential is referenced from Key Vault by the backend and
migration job. Prisma migrations remain an explicit deployment stage and never
run implicitly during backend container startup.

### Delivery and rollback

GitHub Actions remains the sole active CI/CD provider. Pull requests run CI and
Terraform checks only. After merge to `main`, a successful path-relevant CI run
may build and push the affected component image, tag it
`<semver>-<short-sha>`, capture its digest, and deploy that exact digest. Backend
deployment runs the migration job before updating the backend revision.

Frontend and backend roll back independently by selecting an earlier immutable
image digest/revision. Migration failure blocks backend rollout. The deployment
flow must eventually verify HTTPS through `app.devopslab.com.pl` and the backend
health route through the frontend `/api` proxy. The first real deployment must
be performed by CI/CD, never by a manual deployment command.

## Consequences

### Positive

- PostgreSQL is removed from the public data plane.
- The lab teaches VNet integration, subnet delegation, private DNS, OIDC,
  scoped RBAC, managed identity, and useful centralized logging.
- Consumption scaling and the free Container Apps managed certificate remain
  available.
- Cost stays close to the simpler public-database option.
- The platform avoids an unnecessary paid proxy and fixed egress component.

### Trade-offs and risks

- VNet, delegation, and private DNS add Terraform ordering and troubleshooting
  complexity.
- The Container Apps environment network design is difficult to change in
  place, so subnet validation is mandatory before provisioning.
- ACR, Key Vault, and the Terraform Storage Account retain public service
  endpoints protected by identity and RBAC.
- There is no WAF, fixed outbound IP, zone redundancy, or database HA.
- Scale-to-zero causes acceptable cold starts, while PostgreSQL continues to
  incur cost unless deliberately stopped or destroyed.
- The generated Container Apps frontend FQDN remains a technical public origin;
  the custom hostname is the documented application address.

These are deliberate dev-lab compromises. A production comparison may later
evaluate HA, private endpoints, static egress, a WAF, and stronger edge-origin
restrictions through a separate approval gate.

## Implementation sequence

1. Bootstrap modular Terraform for one `dev` environment using local state.
2. Provision the approved Azure foundation through the infrastructure workflow.
3. Create the dedicated state Storage Account and migrate state deliberately.
4. Add ACR image delivery and component deployment workflows.
5. Perform the first application deployment through CI/CD.
6. Integrate Key Vault runtime secrets and the explicit migration job.
7. Add version/image gates and exercise rollback.
8. Bind `app.devopslab.com.pl`, complete DNS validation at home.pl, enable the
   managed certificate, and verify HTTPS.

Each numbered stage requires its own atomic approval gate. Terraform modules,
resource definitions, Azure mutations, role assignments, DNS records,
certificates, pipelines, commits, pushes, and merges are outside this ADR
change-set.
