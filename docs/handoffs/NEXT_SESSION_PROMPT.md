# Prompt for a fresh Codex session

Copy the prompt below into a fresh Codex session after the current Stage 4
changes have been reviewed, committed, pushed, fetched, and checked out.

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

Przeczytaj również w całości:

11. docs/bootstrap/AZURE_IDENTITY_BOOTSTRAP.md
12. scripts/bootstrap-azure-identity.ps1

Następnie wykonaj wyłącznie odczytowe sprawdzenie:

- aktualnego brancha i git status,
- wersji Terraform,
- obecności bootstrapu infra/environments/dev i skryptu identity bootstrap,
- zgodności bieżącego stanu z PROGRESS i handoffem.

Ustal aktualny etap projektu i wybierz właściwą rolę. Oczekiwany etap to
Stage 4 — Initial Terraform with local state, a oczekiwana rola to DevOps
Builder. Jeśli stan repozytorium wskazuje inaczej, zgłoś rozbieżność zamiast ją
samodzielnie naprawiać.

Change-set #11 utworzył i zwalidował lokalny bootstrap Terraform. Change-sety
#13-#16 zakończyły read-only preflight, rejestrację wymaganych providerów oraz
jednorazowy bootstrap GitHub OIDC/RBAC. Utworzono application resource group,
cztery GitHub managed identities, cztery federated credentials i bazowe role
plan/apply. Nie utworzono płatnych usług ani client secretów.

Aktualny stan kredytu z Azure Portal to 175,72 EUR, ważne do 24 września 2026.
Tenant Kainos jest całkowicie poza zakresem; jedynym tenantem operacyjnym jest
prywatny tenant devops-lab.

Change-set #19 zaimplementował i zwalidował pierwszy znaczący moduł Terraform:
`network`. Następną pracą jest osobno bramkowany, lokalny `terraform plan` dla
sieci. Nie uruchamiaj `terraform plan` ani `terraform apply` bez osobnej zgody.

Przestrzegaj atomic approval gate. Przed każdą zmianą opisz cel, pliki lub
zasoby, zachowanie oraz zakres wyłączony i poczekaj na moją wyraźną zgodę.
Nie twórz ani nie zmieniaj plików, Azure, GitHub, DNS lub certyfikatów podczas
pierwszej odpowiedzi.

Nie wykonuj commit, push ani merge. Nie rozszerzaj zakresu bez nowej zgody.
```
