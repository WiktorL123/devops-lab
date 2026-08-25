# Database migrations skill

Prisma migrations are an explicit deployment concern.

Do not run migrations implicitly as normal container startup behavior.

For the lab, use a distinct pipeline job/stage for migration execution.

When discussing production, explain:
- backward compatibility,
- expand/contract,
- zero-downtime concerns,
- rollback limitations of destructive schema changes.

Keep the initial dev flow simpler than a full production platform.
