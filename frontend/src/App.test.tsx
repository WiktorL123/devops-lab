import { describe, expect, it } from 'vitest'

import { statusLabel } from './status'

describe('statusLabel', () => {
  it('describes a healthy API', () => {
    expect(statusLabel('ok')).toBe('API and PostgreSQL are reachable')
  })
})

