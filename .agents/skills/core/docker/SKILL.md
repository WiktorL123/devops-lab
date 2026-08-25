# Docker skill

Frontend and backend are separate images.

Both Dockerfiles must be multi-stage.

Optimize for:
- reproducible builds,
- small runtime stages,
- no build toolchain in runtime unless required,
- no embedded runtime secrets.

Local development may use Docker Compose with PostgreSQL.

Do not collapse frontend and backend into one runtime container.
