import request from 'supertest'
import { describe, expect, it, vi } from 'vitest'

import { createApp } from './app.js'

describe('GET /api/health', () => {
  it('reports a healthy service when PostgreSQL responds', async () => {
    const checkDatabase = vi.fn().mockResolvedValue(undefined)
    const response = await request(createApp(checkDatabase)).get('/api/health')

    expect(response.status).toBe(200)
    expect(response.body).toEqual({ service: 'backend', status: 'ok' })
  })

  it('reports an unavailable service when PostgreSQL fails', async () => {
    const checkDatabase = vi.fn().mockRejectedValue(new Error('unavailable'))
    const response = await request(createApp(checkDatabase)).get('/api/health')

    expect(response.status).toBe(503)
    expect(response.body).toEqual({ service: 'backend', status: 'error' })
  })
})

