# Prompt for a fresh Codex session

Copy the prompt below into a fresh Codex session after the `terraform-init`
branch has been committed, pushed, fetched, and checked out on the new computer.

```text
Kontynuujemy pracę nad repozytorium devops-lab na innym komputerze.

Najpierw przeczytaj w całości, w tej kolejności:

1. AGENTS.md
2. docs/AGENT_INDEX.md
3. docs/LAB_SPEC.md
4. docs/WORKFLOW.md
5. docs/PROGRESS.md
6. docs/architecture/ADR-001-platform-architecture.md
7. docs/architecture/PLATFORM_OPTIONS.md
8. infra/README.md
9. infra/modules/README.md
10. docs/handoffs/STAGE_4_TERRAFORM_HANDOFF.md

Następnie wykonaj wyłącznie odczytowe sprawdzenie:

- aktualnego brancha i git status,
- wersji Terraform,
- obecności bootstrapu infra/environments/dev,
- zgodności bieżącego stanu z PROGRESS i handoffem.

Ustal aktualny etap projektu i wybierz właściwą rolę. Oczekiwany etap to
Stage 4 — Initial Terraform with local state, a oczekiwana rola to DevOps
Builder. Jeśli stan repozytorium wskazuje inaczej, zgłoś rozbieżność zamiast ją
samodzielnie naprawiać.

Change-set #11 utworzył i zwalidował wyłącznie lokalny bootstrap Terraform.
Nie istnieje jeszcze zgoda na zasoby Azure, principale, OIDC, RBAC, plan ani
apply.

Następna praca ma rozpocząć się od read-only preflightu lokalnych narzędzi i
subskrypcji Azure, a następnie od zaprojektowania osobnego bootstrapu
principali/OIDC/RBAC. Nie łącz tego automatycznie z implementacją pierwszych
modułów, terraform plan ani terraform apply.

Przestrzegaj atomic approval gate. Przed każdą zmianą opisz cel, pliki lub
zasoby, zachowanie oraz zakres wyłączony i poczekaj na moją wyraźną zgodę.
Nie twórz ani nie zmieniaj plików, Azure, GitHub, DNS lub certyfikatów podczas
pierwszej odpowiedzi.

Nie wykonuj commit, push ani merge. Nie rozszerzaj zakresu bez nowej zgody.
```
