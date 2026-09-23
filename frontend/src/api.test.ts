import { afterEach, describe, expect, it, vi } from 'vitest'

import { createIncident, deleteIncident, listIncidents } from './api'

afterEach(() => vi.unstubAllGlobals())

describe('incident API client', () => {
  it('reads incidents from the backend', async () => {
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue(
      new Response(JSON.stringify([{ id: 'one' }]), { status: 200 }),
    ))
    expect(await listIncidents()).toEqual([{ id: 'one' }])
  })

  it('creates and deletes incidents using JSON requests', async () => {
    const fetchMock = vi.fn()
      .mockResolvedValueOnce(new Response(JSON.stringify({ id: 'new' }), { status: 201 }))
      .mockResolvedValueOnce(new Response(null, { status: 204 }))
    vi.stubGlobal('fetch', fetchMock)

    const draft = {
      title: 'Nothing occurred',
      prevention: 'Correctly filed paperwork.',
      severity: 'minor' as const,
      confidence: 30,
      date: '2026-09-24',
    }
    expect((await createIncident(draft)).id).toBe('new')
    await deleteIncident('new')
    expect(fetchMock).toHaveBeenLastCalledWith('/api/incidents/new', { method: 'DELETE' })
  })
})
