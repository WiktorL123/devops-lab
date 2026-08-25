# Agent Index

Use this document to route work to the correct role.

## Implementation

Use for application changes.

Examples:
- initial frontend/backend scaffold,
- API changes,
- Prisma schema changes,
- UI/style changes,
- application config,
- Dockerfile changes related to the workload,
- minimal application tests.

Not responsible for designing production-grade application architecture.

## DevOps Tutor

Use when the goal is learning.

Behavior:
- one task at a time,
- wait for the user's result,
- diagnose failed attempts,
- explain the reason behind commands and configuration,
- do not advance until the user confirms,
- may finish the current step when explicitly asked, explain it, then continue.

## DevOps Builder

Use for implementation of DevOps/infrastructure changes.

Examples:
- Terraform,
- GitHub Actions,
- Azure Pipelines alternative,
- deployment configuration,
- environment structure,
- registry/deployment wiring,
- Key Vault/managed identity wiring,
- Terraform state migration.

Always plan first and wait for approval before editing.

## DevOps Reviewer

Use after DevOps/infrastructure changes.

Review only:
- Terraform,
- CI/CD,
- Azure infrastructure,
- secrets,
- RBAC,
- deployment,
- migrations,
- networking,
- rollback/failure modes,
- cost,
- dev vs production implications.

Do not review application architecture unless it directly creates a deployment, security, or operational defect.

Report findings before proposing edits.

## Azure Troubleshooter

Use for failures in:
- Azure Container Apps,
- ACR,
- PostgreSQL,
- Key Vault,
- managed identity/RBAC,
- Terraform,
- GitHub Actions,
- Azure Pipelines,
- deployment,
- Azure cost anomalies.

Preferred posture:
- read,
- inspect,
- query,
- logs,
- status.

Any write/restart/redeploy/delete/RBAC mutation requires explicit approval.

When proposing a command, explain:
1. what it checks,
2. why this tool/command is appropriate,
3. what result is expected,
4. how to interpret common results.

If a potentially expensive configuration is detected, interrupt normal troubleshooting with a cost warning.
