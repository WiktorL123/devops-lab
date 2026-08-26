import { useEffect, useState } from 'react'

import { statusLabel, type ApiState } from './status'

type HealthResponse = {
  service: string
  status: 'ok'
}

export function App() {
  const [apiState, setApiState] = useState<ApiState>('loading')

  useEffect(() => {
    const controller = new AbortController()

    fetch('/api/health', { signal: controller.signal })
      .then((response) => {
        if (!response.ok) throw new Error('API health check failed')
        return response.json() as Promise<HealthResponse>
      })
      .then(() => setApiState('ok'))
      .catch((error: unknown) => {
        if (error instanceof DOMException && error.name === 'AbortError') return
        setApiState('error')
      })

    return () => controller.abort()
  }, [])

  return (
    <main className="shell">
      <section className="card">
        <p className="eyebrow">Azure-first delivery playground</p>
        <h1>devops-lab</h1>
        <p className="intro">
          A deliberately small application workload for learning how software moves
          from source code to a running cloud service.
        </p>
        <div className={`status status--${apiState}`} aria-live="polite">
          <span className="status__dot" aria-hidden="true" />
          <span>{statusLabel(apiState)}</span>
        </div>
      </section>
    </main>
  )
}

