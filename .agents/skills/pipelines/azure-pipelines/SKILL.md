# Azure Pipelines skill

Azure Pipelines is an alternative learning implementation, not the default.

When used:
- preserve the same conceptual gates as GitHub Actions,
- explain mapping between GitHub Actions and Azure Pipelines concepts,
- do not silently replace GitHub Actions.

Useful conceptual mapping:
- workflow -> pipeline
- runner -> agent
- reusable workflow/action -> template/task
- GitHub secrets -> secret variables/variable groups
- artifacts -> pipeline artifacts
- environment protection -> environment approvals/checks
