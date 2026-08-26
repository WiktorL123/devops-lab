import express, { type Express } from 'express'

export type DatabaseCheck = () => Promise<unknown>

export function createApp(checkDatabase: DatabaseCheck): Express {
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

  return app
}

