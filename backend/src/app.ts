import express, { type Express } from 'express'

export type Severity = 'minor' | 'moderate' | 'major' | 'existential'
export type IncidentInput = {
  title: string
  prevention: string
  severity: Severity
  confidence: number
  date: string
}
export type Incident = IncidentInput & { id: string }
export type IncidentRepository = {
  list: () => Promise<Incident[]>
  create: (input: IncidentInput) => Promise<Incident>
  update: (id: string, input: IncidentInput) => Promise<Incident | null>
  remove: (id: string) => Promise<boolean>
}
export type DatabaseCheck = () => Promise<unknown>

export function createApp(checkDatabase: DatabaseCheck, incidents: IncidentRepository): Express {
  const app = express()
  app.disable('x-powered-by')
  app.use(express.json())

  app.get('/api/health', async (_request, response) => {
    try {
      await checkDatabase()
      response.json({ service: 'backend', status: 'ok' })
    } catch {
      response.status(503).json({ service: 'backend', status: 'error' })
    }
  })

  app.get('/api/incidents', async (_request, response) => {
    try {
      response.json(await incidents.list())
    } catch {
      response.status(500).json({ error: 'Unable to read the incident registry' })
    }
  })

  app.post('/api/incidents', async (request, response) => {
    const input = parseIncidentInput(request.body)
    if (!input) {
      response.status(400).json({ error: 'Invalid counterfactual incident' })
      return
    }
    try {
      response.status(201).json(await incidents.create(input))
    } catch {
      response.status(500).json({ error: 'Unable to archive the incident' })
    }
  })

  app.put('/api/incidents/:id', async (request, response) => {
    const input = parseIncidentInput(request.body)
    if (!input) {
      response.status(400).json({ error: 'Invalid counterfactual incident' })
      return
    }
    try {
      const incident = await incidents.update(request.params.id, input)
      if (!incident) {
        response.status(404).json({ error: 'Counterfactual incident not found' })
        return
      }
      response.json(incident)
    } catch {
      response.status(500).json({ error: 'Unable to amend the incident' })
    }
  })

  app.delete('/api/incidents/:id', async (request, response) => {
    try {
      if (!(await incidents.remove(request.params.id))) {
        response.status(404).json({ error: 'Counterfactual incident not found' })
        return
      }
      response.status(204).send()
    } catch {
      response.status(500).json({ error: 'Unable to remove the incident' })
    }
  })

  return app
}

function parseIncidentInput(value: unknown): IncidentInput | null {
  if (!value || typeof value !== 'object') return null
  const input = value as Record<string, unknown>
  const severities = ['minor', 'moderate', 'major', 'existential']

  if (
    typeof input.title !== 'string' || input.title.trim().length === 0 || input.title.length > 100 ||
    typeof input.prevention !== 'string' || input.prevention.trim().length === 0 || input.prevention.length > 220 ||
    typeof input.severity !== 'string' || !severities.includes(input.severity) ||
    typeof input.confidence !== 'number' || !Number.isInteger(input.confidence) || input.confidence < 0 || input.confidence > 100 ||
    typeof input.date !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(input.date) || Number.isNaN(Date.parse(`${input.date}T00:00:00.000Z`))
  ) return null

  return {
    title: input.title.trim(),
    prevention: input.prevention.trim(),
    severity: input.severity as Severity,
    confidence: input.confidence,
    date: input.date,
  }
}
