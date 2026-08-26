# Repository Workflow

## Pull requests

Agents do not merge pull requests.

The user owns:
- review,
- approval,
- merge.

## Atomic approval gate

Every approval applies only to the explicitly described atomic change-set.

Before requesting approval, the agent must state:
- objective,
- files/resources expected to change,
- behavior being introduced or changed,
- what is explicitly out of scope.

Approval for one change-set must never be interpreted as approval for adjacent or subsequent work.

If implementation reveals that additional scope is required, the agent must stop and request a new approval.

## Agent-generated changes

For repository mutations:

1. agent inspects the current state,
2. agent presents one atomic change-set,
3. agent states objective, expected files/resources, behavior, and out-of-scope items,
4. user approves,
5. agent implements only that approved change-set,
6. agent summarizes the result,
7. relevant docs are updated in the same change where appropriate,
8. changes go through PR review.

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
