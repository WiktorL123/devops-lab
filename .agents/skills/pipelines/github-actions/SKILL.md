# GitHub Actions skill

GitHub Actions is the default CI/CD provider for this lab.

Expected workflows:
- frontend-ci
- backend-ci
- frontend-deploy
- backend-deploy
- infra

Use path filters so unrelated components are not rebuilt or redeployed.

PR:
- relevant CI
- Terraform validation/plan for infra changes

After merge:
- rerun relevant CI
- deploy only after successful corresponding CI

Keep workflows understandable and teachable.
When the user is learning, prefer building one job at a time.
