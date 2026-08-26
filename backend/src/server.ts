import { PrismaClient } from '@prisma/client'

import { createApp } from './app.js'

const prisma = new PrismaClient()
const port = Number.parseInt(process.env.PORT ?? '3000', 10)
const app = createApp(() => prisma.$queryRaw`SELECT 1`)

const server = app.listen(port, () => {
  console.log(`Backend listening on port ${port}`)
})

async function shutdown(signal: string) {
  console.log(`Received ${signal}; shutting down`)
  server.close(async () => {
    await prisma.$disconnect()
    process.exit(0)
  })
}

process.on('SIGTERM', () => void shutdown('SIGTERM'))
process.on('SIGINT', () => void shutdown('SIGINT'))

