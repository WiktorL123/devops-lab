# Stage 2 Continuous Integration Review

## Review metadata

- Date: 2026-08-29
- Role: DevOps Reviewer
- Scope: frontend and backend GitHub Actions CI definitions, path filters, permissions, dependency installation, quality gates, documentation, and readiness for pull request verification
- Result: no actionable local findings; GitHub-hosted execution remains pending

This review does not approve or implement CD, container image publishing,
Terraform, Azure resources, database migration delivery, or deployment.

## Verification evidence

- `frontend-ci` and `backend-ci` are separate and path-scoped.
- Both workflows run for relevant pull requests and relevant pushes to `main`.
- Both workflows use Node.js from `.nvmrc`, deterministic `npm ci` installs, npm caching, minimal read-only repository permissions, timeouts, and concurrency cancellation.
- Both workflows execute `lint -> test -> build`; backend CI explicitly generates Prisma Client before those checks.
- GitHub Actions are pinned to full commit SHAs with version comments.
- `actionlint` 1.7.12 reported no workflow findings.
- The exact frontend CI command chain passed in an isolated Node.js 24.19.0 container.
- The exact backend CI command chain, including Prisma Client generation, passed in an isolated Node.js 24.19.0 container.
- Both dependency installations reported zero known vulnerabilities.
- `git diff --check` passed.
- The workflows have not yet run on GitHub-hosted runners because the branch has not been pushed.

## Findings

```yaml
findings: []
summary: "No actionable DevOps/infrastructure findings in the local Stage 2 CI implementation. GitHub-hosted PR execution remains to be verified."
```

## Cost review

The CI definitions do not create Azure resources or select paid Azure SKUs.
Local verification consumed no Azure credit. GitHub-hosted usage must be observed
under the repository owner's applicable GitHub Actions allowance after push.

## Retrospective

### What worked

- The atomic approval gate kept Stage 2 limited to CI and its documentation.
- Independent path-scoped workflows preserve separate frontend and backend delivery boundaries.
- Repeating CI after merge establishes the quality gate required by the future deployment flow.
- Reproducing the complete command chains in clean containers reduced dependence on the developer workstation state.
- Explicit Prisma Client generation documents and verifies the backend build prerequisite without connecting to or mutating a database.
- Full-SHA action pinning and minimal permissions provide a sound supply-chain baseline.
- CD, Azure, Terraform, migrations, image publishing, commits, and merge remained outside the approved implementation scope.

### What should improve

- Local workflow linting and command reproduction cannot fully emulate GitHub event payloads, hosted-runner behavior, cache restoration, or repository permission settings.
- Stage completion must therefore require successful `frontend-ci` and `backend-ci` runs in the pull request.
- Branch protection and required status checks should be considered only in a later, separately approved change-set after the actual check names are visible on GitHub.
- Future CD must independently confirm runtime-impacting paths; a successful CI run caused only by a workflow or shared toolchain change must not automatically publish an application image.

## CI/CD provider decision

GitHub Actions is the sole provider for the active CI and future CD delivery path.
Azure Pipelines is not part of the current implementation.

The planned CD behavior remains future work:

1. A relevant component change is merged to `main`.
2. The corresponding post-merge CI workflow succeeds.
3. The component image is built and pushed to ACR; pull requests do not publish images.
4. The image receives a `<semver>-<short-sha>` tag and its immutable digest is recorded.
5. The deployment selects the exact digest rather than `latest`.
6. Backend deployment runs an explicit migration job before updating the application revision.

This decision records direction only and does not authorize CD implementation.

## Next-stage assessment

Stage 2 is locally ready for pull request verification but is not complete.

Remaining handoff sequence:

1. The user commits and pushes `devops/ci`.
2. The user opens the Stage 2 pull request.
3. Both GitHub-hosted CI workflows pass and their path-scoping behavior is checked.
4. The user reviews and merges the pull request.
5. Confirm Stage 2 completion before proposing the next atomic change-set.

Do not start CD, Terraform, Azure infrastructure, or image publishing as part of
this handoff.
