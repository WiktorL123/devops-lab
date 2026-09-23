import { useEffect, useMemo, useState, type FormEvent } from 'react'

import {
  addIncident,
  initialIncidents,
  parseIncidents,
  removeIncident,
  updateIncident,
  type Incident,
  type IncidentDraft,
  type Severity,
} from './incidents'
import { statusLabel, type ApiState } from './status'

type HealthResponse = { service: string; status: 'ok' }

const storageKey = 'devops-lab.counterfactual-incidents.v1'
const severityLabels: Record<Severity, string> = {
  minor: 'Minor inconvenience',
  moderate: 'Moderately theoretical',
  major: 'Major, had it happened',
  existential: 'Existentially concerning',
}

function emptyDraft(): IncidentDraft {
  return {
    title: '',
    prevention: '',
    severity: 'moderate',
    confidence: 50,
    date: new Date().toISOString().slice(0, 10),
  }
}

export function App() {
  const [apiState, setApiState] = useState<ApiState>('loading')
  const [incidents, setIncidents] = useState<Incident[]>(() =>
    parseIncidents(window.localStorage.getItem(storageKey)),
  )
  const [draft, setDraft] = useState<IncidentDraft>(emptyDraft)
  const [editingId, setEditingId] = useState<string | null>(null)

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

  useEffect(() => {
    window.localStorage.setItem(storageKey, JSON.stringify(incidents))
  }, [incidents])

  const averageConfidence = useMemo(() => {
    if (incidents.length === 0) return 0
    return Math.round(
      incidents.reduce((total, incident) => total + incident.confidence, 0) /
        incidents.length,
    )
  }, [incidents])

  function submitIncident(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setIncidents((current) =>
      editingId
        ? updateIncident(current, editingId, draft)
        : addIncident(current, draft, crypto.randomUUID()),
    )
    setDraft(emptyDraft())
    setEditingId(null)
  }

  function beginEditing(incident: Incident) {
    setEditingId(incident.id)
    setDraft({
      title: incident.title,
      prevention: incident.prevention,
      severity: incident.severity,
      confidence: incident.confidence,
      date: incident.date,
    })
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }

  function cancelEditing() {
    setEditingId(null)
    setDraft(emptyDraft())
  }

  function deleteIncident(incident: Incident) {
    if (!window.confirm(`Remove “${incident.title}” from the record of things that did not happen?`)) return
    setIncidents((current) => removeIncident(current, incident.id))
    if (editingId === incident.id) cancelEditing()
  }

  function resetArchive() {
    if (!window.confirm('Restore the original collection of prevented events?')) return
    setIncidents(initialIncidents)
    cancelEditing()
  }

  return (
    <main className="shell">
      <header className="masthead">
        <div>
          <p className="eyebrow">Office of events that failed to occur</p>
          <h1>Counterfactual Incident Registry</h1>
          <p className="intro">
            A formal archive for operational disasters prevented so thoroughly
            that their existence can no longer be demonstrated.
          </p>
        </div>
        <div className={`status status--${apiState}`} aria-live="polite">
          <span className="status__dot" aria-hidden="true" />
          <span>{statusLabel(apiState)}</span>
        </div>
      </header>

      <section className="summary" aria-label="Registry summary">
        <div><strong>{incidents.length}</strong><span>non-events archived</span></div>
        <div><strong>{averageConfidence}%</strong><span>mean certainty they almost happened</span></div>
        <div><strong>0</strong><span>incidents observed</span></div>
      </section>

      <div className="workspace">
        <section className="panel panel--form">
          <div className="section-heading">
            <p className="section-number">Form 00-N</p>
            <h2>{editingId ? 'Amend a non-event' : 'Register a non-event'}</h2>
          </div>

          <form onSubmit={submitIncident}>
            <label>
              Incident that did not happen
              <input
                required
                maxLength={100}
                value={draft.title}
                onChange={(event) => setDraft({ ...draft, title: event.target.value })}
                placeholder="The cache declined to develop ambitions"
              />
            </label>

            <label>
              Preventative measure allegedly responsible
              <textarea
                required
                maxLength={220}
                rows={4}
                value={draft.prevention}
                onChange={(event) => setDraft({ ...draft, prevention: event.target.value })}
                placeholder="Describe the ritual, process, or tasteful intervention."
              />
            </label>

            <div className="form-grid">
              <label>
                Hypothetical severity
                <select
                  value={draft.severity}
                  onChange={(event) => setDraft({ ...draft, severity: event.target.value as Severity })}
                >
                  {Object.entries(severityLabels).map(([value, label]) => (
                    <option key={value} value={value}>{label}</option>
                  ))}
                </select>
              </label>

              <label>
                Date of non-occurrence
                <input
                  required
                  type="date"
                  value={draft.date}
                  onChange={(event) => setDraft({ ...draft, date: event.target.value })}
                />
              </label>
            </div>

            <label>
              Confidence that danger existed: <strong>{draft.confidence}%</strong>
              <input
                type="range"
                min="0"
                max="100"
                value={draft.confidence}
                onChange={(event) => setDraft({ ...draft, confidence: Number(event.target.value) })}
              />
            </label>

            <div className="form-actions">
              <button className="button button--primary" type="submit">
                {editingId ? 'Save amendment' : 'Archive non-event'}
              </button>
              {editingId && <button className="button" type="button" onClick={cancelEditing}>Cancel</button>}
            </div>
          </form>
        </section>

        <section className="panel panel--registry">
          <div className="section-heading section-heading--row">
            <div>
              <p className="section-number">Permanent provisional record</p>
              <h2>Prevented incidents</h2>
            </div>
            <button className="text-button" type="button" onClick={resetArchive}>Restore specimens</button>
          </div>

          <div className="incident-list">
            {incidents.length === 0 ? (
              <div className="empty-state">
                <p>The absence of records has been recorded.</p>
                <span>Nothing continues to happen as expected.</span>
              </div>
            ) : incidents.map((incident) => (
              <article className="incident" key={incident.id}>
                <div className="incident__meta">
                  <span className={`severity severity--${incident.severity}`}>
                    {severityLabels[incident.severity]}
                  </span>
                  <time dateTime={incident.date}>{incident.date}</time>
                </div>
                <h3>{incident.title}</h3>
                <p>{incident.prevention}</p>
                <div className="incident__footer">
                  <span>{incident.confidence}% plausible in retrospect</span>
                  <div>
                    <button className="text-button" type="button" onClick={() => beginEditing(incident)}>Edit</button>
                    <button className="text-button text-button--danger" type="button" onClick={() => deleteIncident(incident)}>Delete</button>
                  </div>
                </div>
              </article>
            ))}
          </div>
        </section>
      </div>
    </main>
  )
}
