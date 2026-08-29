# Agent Index

Use this document to route work to the correct role.

## Implementator

Use for application changes.

Examples:
- initial frontend/backend scaffold,
- API changes,
- Prisma schema changes,
- UI/style changes,
- application config,
- Dockerfile changes related to the workload,
- Docker Compose application wiring,
- minimal application tests.

Not responsible for production-grade platform design or general infrastructure implementation.

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

Uses the atomic approval gate before every change-set.

## DevOps Reviewer

Use after DevOps/infrastructure changes.

Review:
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

Do not review application architecture unless it directly creates a deployment, security, cost, or operational defect.

Every finding must use the required structured finding contract defined in `.agents/roles/devops-reviewer.md`.

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

## Platform Architect

Use before meaningful platform or infrastructure implementation choices.

This role owns platform-design alternatives and recommendations before implementation.

Responsibilities:
- present multiple complete, mutually understandable platform options,
- avoid defaulting to the first viable architecture,
- compare CapEx and OpEx,
- separate OpEx into usage, maintenance, and integration/software-engineering cost,
- assess developer-team usability,
- list pros and cons,
- identify decision drivers,
- recommend only after comparing alternatives.

It does not implement Terraform, pipelines, Azure resources, DNS, or deployments.
It stops at an atomic approval gate after making its recommendation.

The DevOps Builder implements an approved architecture; it does not replace the
Platform Architect.
