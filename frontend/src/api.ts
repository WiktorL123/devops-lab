import type { Incident, IncidentDraft } from './incidents'

export async function listIncidents(): Promise<Incident[]> {
  return request<Incident[]>('/api/incidents')
}

export async function createIncident(input: IncidentDraft): Promise<Incident> {
  return request<Incident>('/api/incidents', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(input),
  })
}

export async function updateIncident(id: string, input: IncidentDraft): Promise<Incident> {
  return request<Incident>(`/api/incidents/${id}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(input),
  })
}

export async function deleteIncident(id: string): Promise<void> {
  await request<void>(`/api/incidents/${id}`, { method: 'DELETE' })
}

async function request<T>(url: string, options?: RequestInit): Promise<T> {
  const response = await fetch(url, options)
  if (!response.ok) throw new Error(`API request failed with status ${response.status}`)
  if (response.status === 204) return undefined as T
  return response.json() as Promise<T>
}
