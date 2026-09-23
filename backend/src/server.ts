import { PrismaClient } from '@prisma/client'

import { createApp, type IncidentInput, type IncidentRepository } from './app.js'

const prisma = new PrismaClient()

const incidentRepository: IncidentRepository = {
  async list() {
    const incidents = await prisma.counterfactualIncident.findMany({
      orderBy: [{ occurredOn: 'desc' }, { createdAt: 'desc' }],
    })
    return incidents.map(toApiIncident)
  },
  async create(input) {
    return toApiIncident(await prisma.counterfactualIncident.create({ data: toDatabaseIncident(input) }))
  },
  async update(id, input) {
    const existing = await prisma.counterfactualIncident.findUnique({ where: { id } })
    if (!existing) return null
    return toApiIncident(await prisma.counterfactualIncident.update({
      where: { id },
      data: toDatabaseIncident(input),
    }))
  },
  async remove(id) {
    return (await prisma.counterfactualIncident.deleteMany({ where: { id } })).count > 0
  },
}

const app = createApp(() => prisma.$queryRaw`SELECT 1`, incidentRepository)
const port = Number(process.env.PORT ?? 3000)
const server = app.listen(port, () => console.log(`Backend listening on port ${port}`))

function toDatabaseIncident(input: IncidentInput) {
  return {
    title: input.title,
    prevention: input.prevention,
    severity: input.severity,
    confidence: input.confidence,
    occurredOn: new Date(`${input.date}T00:00:00.000Z`),
  }
}

function toApiIncident(incident: {
  id: string
  title: string
  prevention: string
  severity: string
  confidence: number
  occurredOn: Date
}) {
  return {
    id: incident.id,
    title: incident.title,
    prevention: incident.prevention,
    severity: incident.severity as IncidentInput['severity'],
    confidence: incident.confidence,
    date: incident.occurredOn.toISOString().slice(0, 10),
  }
}

async function shutdown() {
  server.close(async () => {
    await prisma.$disconnect()
    process.exit(0)
  })
}

process.on('SIGTERM', shutdown)
process.on('SIGINT', shutdown)
