# Release versioning skill

Frontend and backend version independently.

Semantic version source:
- component `package.json`

User-controlled bump helper:
- repo-level script,
- patch/minor/major,
- no automatic commit.

Deployment image identity:
- `<semver>-<short-sha>`

Never deploy `latest`.

Require version bump for runtime-impacting code/config/Dockerfile changes.
Do not require a bump for documentation-only or test-only changes.
