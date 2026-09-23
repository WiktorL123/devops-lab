import { describe, expect, it } from 'vitest'

import {
  addIncident,
  initialIncidents,
  parseIncidents,
  removeIncident,
  updateIncident,
  type IncidentDraft,
} from './incidents'

const draft: IncidentDraft = {
  title: 'Nothing happened in a highly controlled manner',
  prevention: 'A clipboard was present.',
  severity: 'minor',
  confidence: 48,
  date: '2026-09-23',
}

describe('counterfactual incident operations', () => {
  it('adds, updates, and removes an incident', () => {
    const added = addIncident(initialIncidents, draft, 'new-id')
    const updated = updateIncident(added, 'new-id', { ...draft, confidence: 73 })
    const removed = removeIncident(updated, 'new-id')

    expect(added[0].id).toBe('new-id')
    expect(updated[0].confidence).toBe(73)
    expect(removed).toEqual(initialIncidents)
  })

  it('falls back to the curated archive for invalid stored data', () => {
    expect(parseIncidents('{not-json')).toEqual(initialIncidents)
    expect(parseIncidents(JSON.stringify({ unexpected: true }))).toEqual(initialIncidents)
  })
})
