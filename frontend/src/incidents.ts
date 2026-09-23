export type Severity = 'minor' | 'moderate' | 'major' | 'existential'

export type Incident = {
  id: string
  title: string
  prevention: string
  severity: Severity
  confidence: number
  date: string
}

export type IncidentDraft = Omit<Incident, 'id'>

export const initialIncidents: Incident[] = [
  {
    id: 'quiet-database',
    title: 'The database did not become sentient during Tuesday’s deployment',
    prevention: 'A sternly worded maintenance window and one decaf coffee.',
    severity: 'existential',
    confidence: 12,
    date: '2026-09-22',
  },
  {
    id: 'patient-load-balancer',
    title: 'The load balancer resisted choosing a favourite user',
    prevention: 'Traffic was distributed without making eye contact.',
    severity: 'moderate',
    confidence: 64,
    date: '2026-09-20',
  },
  {
    id: 'unreleased-friday',
    title: 'Friday’s unplanned release remained safely imaginary',
    prevention: 'The deploy button was covered with a tasteful linen napkin.',
    severity: 'major',
    confidence: 91,
    date: '2026-09-18',
  },
]

export function addIncident(incidents: Incident[], draft: IncidentDraft, id: string): Incident[] {
  return [{ ...draft, id }, ...incidents]
}

export function updateIncident(
  incidents: Incident[],
  id: string,
  draft: IncidentDraft,
): Incident[] {
  return incidents.map((incident) => (incident.id === id ? { ...draft, id } : incident))
}

export function removeIncident(incidents: Incident[], id: string): Incident[] {
  return incidents.filter((incident) => incident.id !== id)
}

export function parseIncidents(value: string | null): Incident[] {
  if (!value) return initialIncidents

  try {
    const parsed: unknown = JSON.parse(value)
    if (!Array.isArray(parsed)) return initialIncidents
    return parsed.filter(isIncident)
  } catch {
    return initialIncidents
  }
}

function isIncident(value: unknown): value is Incident {
  if (!value || typeof value !== 'object') return false

  const incident = value as Record<string, unknown>
  return (
    typeof incident.id === 'string' &&
    typeof incident.title === 'string' &&
    typeof incident.prevention === 'string' &&
    ['minor', 'moderate', 'major', 'existential'].includes(String(incident.severity)) &&
    typeof incident.confidence === 'number' &&
    typeof incident.date === 'string'
  )
}
