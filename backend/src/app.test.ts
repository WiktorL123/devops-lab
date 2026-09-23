import request from 'supertest'
import { beforeEach, describe, expect, it, vi } from 'vitest'

import { createApp, type Incident, type IncidentRepository } from './app.js'

const example: Incident = {
  id: 'incident-1',
  title: 'The queue remained emotionally available',
  prevention: 'It was thanked for its service.',
  severity: 'moderate',
  confidence: 62,
  date: '2026-09-24',
}

function repository(): IncidentRepository {
  return {
    list: vi.fn().mockResolvedValue([example]),
    create: vi.fn().mockImplementation(async (input) => ({ ...input, id: 'new-id' })),
    update: vi.fn().mockImplementation(async (id, input) => ({ ...input, id })),
    remove: vi.fn().mockResolvedValue(true),
  }
}

describe('backend API', () => {
  const checkDatabase = vi.fn()
  beforeEach(() => checkDatabase.mockResolvedValue(undefined))

  it('reports a healthy service when PostgreSQL responds', async () => {
    const response = await request(createApp(checkDatabase, repository())).get('/api/health')
    expect(response.status).toBe(200)
    expect(response.body).toEqual({ service: 'backend', status: 'ok' })
  })

  it('lists and creates counterfactual incidents', async () => {
    const app = createApp(checkDatabase, repository())
    const input = {
      title: example.title,
      prevention: example.prevention,
      severity: example.severity,
      confidence: example.confidence,
      date: example.date,
    }

    expect((await request(app).get('/api/incidents')).body).toEqual([example])
    const created = await request(app).post('/api/incidents').send(input)
    expect(created.status).toBe(201)
    expect(created.body.id).toBe('new-id')
  })

  it('updates, deletes, and rejects malformed incidents', async () => {
    const app = createApp(checkDatabase, repository())
    const input = {
      title: example.title,
      prevention: example.prevention,
      severity: example.severity,
      confidence: example.confidence,
      date: example.date,
    }

    expect((await request(app).put('/api/incidents/incident-1').send(input)).status).toBe(200)
    expect((await request(app).delete('/api/incidents/incident-1')).status).toBe(204)
    expect((await request(app).post('/api/incidents').send({ title: '' })).status).toBe(400)
  })
})
