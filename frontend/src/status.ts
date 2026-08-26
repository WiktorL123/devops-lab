export type ApiState = 'loading' | 'ok' | 'error'

export function statusLabel(state: ApiState): string {
  const labels: Record<ApiState, string> = {
    loading: 'Checking the application stack…',
    ok: 'API and PostgreSQL are reachable',
    error: 'The application stack is not ready',
  }

  return labels[state]
}

