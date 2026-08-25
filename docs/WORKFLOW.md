# Repository Workflow

## Pull requests

Agents do not merge pull requests.

The user owns:
- review,
- approval,
- merge.

## Agent-generated changes

For repository mutations:

1. agent presents a short plan,
2. user approves,
3. agent implements,
4. agent summarizes,
5. relevant docs are updated in the same change where appropriate,
6. changes go through PR review.

## Documentation updates

Update docs when a commit materially changes:
- infrastructure,
- CI/CD,
- deployment,
- secrets,
- environment layout,
- cloud mapping,
- cost policy,
- current learning stage.

Do not churn docs for trivial presentation-only application changes.

## Platform portability

Initial local platform:
- macOS
- intended path: `/Users/wiktorlemanski/Projects/devops-lab`

Avoid repository automation that unnecessarily depends on that absolute path.

Windows support may be added later by updating scripts/docs rather than redesigning the repository.
