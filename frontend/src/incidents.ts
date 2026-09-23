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

export const specimenDrafts: IncidentDraft[] = [
  {
    title: 'The database did not become sentient during Tuesday’s deployment',
    prevention: 'A sternly worded maintenance window and one decaf coffee.',
    severity: 'existential',
    confidence: 12,
    date: '2026-09-22',
  },
  {
    title: 'The load balancer resisted choosing a favourite user',
    prevention: 'Traffic was distributed without making eye contact.',
    severity: 'moderate',
    confidence: 64,
    date: '2026-09-20',
  },
]
