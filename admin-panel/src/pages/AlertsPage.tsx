import React, { useEffect, useState } from 'react'
import { Bell, Bot, FileText, Sparkles, CheckCircle2, AlertCircle, RefreshCw, Trash2, Megaphone } from 'lucide-react'
import { supabase } from '../config/supabase'
import { useAuth } from '../contexts/AuthContext'
import { parseAdminAlertPrompt, type ExtractedAlertMetadata } from '../lib/groq'
import type { Alert } from '../lib/types'

const CATEGORIES = [
  { value: 'attendance', label: 'Attendance Warning' },
  { value: 'marks', label: 'Marks & Results' },
  { value: 'fees', label: 'Fee & Payment' },
  { value: 'timetable', label: 'Exam & Timetable' },
  { value: 'holiday', label: 'Holiday & Vacation' },
  { value: 'general', label: 'General Announcement' },
  { value: 'emergency', label: 'Emergency Notice' },
]

const DEPARTMENTS = [
  'All',
  'Information Technology',
  'Computer Science & Engineering',
  'Electronics & Communication',
  'Mechanical Engineering',
  'Civil Engineering',
]

const QUICK_PROMPTS = [
  'Post holiday notice that campus will be closed on August 15 for Independence Day',
  'Send high priority attendance warning for students having attendance below 75%',
  'Announce that Semester 5 Mid-Sem Exam Timetable is released',
  'Reminder: Last date for tuition fee payment is 25th of this month',
]

export default function AlertsPage() {
  const { user, institution } = useAuth()
  const currentInstId = institution?.id || '6c6e9b83-cabf-4b13-855b-97d2e1461177'
  const [activeTab, setActiveTab] = useState<'ai' | 'manual'>('ai')

  // Live Alerts State
  const [alerts, setAlerts] = useState<Alert[]>([])
  const [loadingAlerts, setLoadingAlerts] = useState(true)

  // Form & Action states
  const [loading, setLoading] = useState(false)
  const [success, setSuccess] = useState('')
  const [error, setError] = useState('')

  // AI Agent Mode States
  const [adminPrompt, setAdminPrompt] = useState('')
  const [isAnalyzing, setIsAnalyzing] = useState(false)
  const [extractedAlert, setExtractedAlert] = useState<ExtractedAlertMetadata | null>(null)

  // Manual Mode States
  const [formData, setFormData] = useState({
    title: '',
    message: '',
    category: 'general' as Alert['category'],
    department: 'All',
    semester: 'All',
    priority: 'normal' as Alert['priority'],
  })

  // Fetch Live Alerts
  const fetchAlerts = async () => {
    try {
      setLoadingAlerts(true)
      let query = supabase.from('campus_alerts').select('*')
      if (currentInstId) {
        query = query.eq('created_by', currentInstId)
      }
      const { data, error } = await query.order('created_at', { ascending: false })

      if (error) throw error
      setAlerts(data || [])
    } catch (err: any) {
      console.error('Error fetching alerts:', err)
    } finally {
      setLoadingAlerts(false)
    }
  }

  useEffect(() => {
    fetchAlerts()
  }, [currentInstId])

  // AI Analysis
  const handleAnalyzeAlert = async (text?: string) => {
    const promptToUse = text || adminPrompt
    if (!promptToUse.trim()) {
      setError('Please type an announcement prompt.')
      return
    }

    setIsAnalyzing(true)
    setError('')
    try {
      const result = await parseAdminAlertPrompt(promptToUse)
      setExtractedAlert(result)
    } catch (err: any) {
      setError('Failed to analyze prompt: ' + (err.message || err))
    } finally {
      setIsAnalyzing(false)
    }
  }

  // Publish AI Alert
  const handlePublishAiAlert = async () => {
    if (!extractedAlert) return
    setLoading(true)
    setError('')
    setSuccess('')

    try {
      const { error: dbError } = await supabase.from('campus_alerts').insert([
        {
          title: extractedAlert.title,
          message: extractedAlert.message,
          category: extractedAlert.category,
          department: extractedAlert.department,
          semester: extractedAlert.semester,
          priority: extractedAlert.priority,
          created_by: currentInstId,
        },
      ])

      if (dbError) throw dbError

      setSuccess('✅ Campus Alert published live to Student and Parent apps!')
      setAdminPrompt('')
      setExtractedAlert(null)
      fetchAlerts()
    } catch (err: any) {
      setError(err.message || 'Failed to publish alert.')
    } finally {
      setLoading(false)
    }
  }

  // Publish Manual Alert
  const handleManualSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError('')
    setSuccess('')

    try {
      const { error: dbError } = await supabase.from('campus_alerts').insert([
        {
          title: formData.title,
          message: formData.message,
          category: formData.category,
          department: formData.department,
          semester: formData.semester,
          priority: formData.priority,
          created_by: currentInstId,
        },
      ])

      if (dbError) throw dbError

      setSuccess('✅ Alert published successfully!')
      setFormData({
        title: '',
        message: '',
        category: 'general',
        department: 'All',
        semester: 'All',
        priority: 'normal',
      })
      fetchAlerts()
    } catch (err: any) {
      setError(err.message || 'Failed to publish alert.')
    } finally {
      setLoading(false)
    }
  }

  // Delete Alert
  const handleDeleteAlert = async (id: string) => {
    if (!confirm('Are you sure you want to delete this campus alert?')) return
    try {
      const { error } = await supabase.from('campus_alerts').delete().eq('id', id)
      if (error) throw error
      setAlerts(prev => prev.filter(a => a.id !== id))
    } catch (err: any) {
      alert('Failed to delete alert: ' + err.message)
    }
  }

  return (
    <div className="max-w-5xl mx-auto space-y-8">
      {/* Header */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 border-b border-card-border pb-6">
        <div>
          <h1 className="text-2xl font-bold text-text-primary tracking-tight flex items-center gap-2.5">
            <Megaphone className="w-6 h-6 text-primary" />
            Campus Alerts & Broadcasts
          </h1>
          <p className="text-text-secondary text-sm mt-1">
            Broadcast real-time announcements, attendance warnings, exam updates & holiday notices
          </p>
        </div>

        {/* Mode Toggle Switch */}
        <div className="flex items-center bg-surface-light p-1 rounded-xl border border-card-border">
          <button
            onClick={() => { setActiveTab('ai'); setError(''); setSuccess(''); }}
            className={`flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-semibold transition-all ${
              activeTab === 'ai'
                ? 'bg-primary text-background shadow-md'
                : 'text-text-secondary hover:text-text-primary'
            }`}
          >
            <Bot className="w-4 h-4" />
            🤖 AI Generator
          </button>
          <button
            onClick={() => { setActiveTab('manual'); setError(''); setSuccess(''); }}
            className={`flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-semibold transition-all ${
              activeTab === 'manual'
                ? 'bg-primary text-background shadow-md'
                : 'text-text-secondary hover:text-text-primary'
            }`}
          >
            <FileText className="w-4 h-4" />
            📝 Manual Form
          </button>
        </div>
      </div>

      {/* Status Banners */}
      {error && (
        <div className="p-4 bg-error/10 border border-error/20 rounded-xl text-error text-sm flex items-center gap-3">
          <AlertCircle className="w-5 h-5 shrink-0" />
          <span>{error}</span>
        </div>
      )}

      {success && (
        <div className="p-4 bg-primary/10 border border-primary/20 rounded-xl text-primary text-sm flex items-center gap-3">
          <CheckCircle2 className="w-5 h-5 shrink-0" />
          <span>{success}</span>
        </div>
      )}

      {/* Mode 1: AI Generator */}
      {activeTab === 'ai' && (
        <div className="bg-surface p-6 rounded-2xl border border-card-border space-y-6">
          <div>
            <h2 className="text-base font-semibold text-text-primary mb-1 flex items-center gap-2">
              <Sparkles className="w-4 h-4 text-primary" />
              Prompt AI to Create Campus Alert
            </h2>
            <p className="text-xs text-text-secondary">
              Describe the announcement in plain English. The AI will format the title, body, audience, and priority.
            </p>
          </div>

          {/* Quick Prompts */}
          <div className="flex flex-wrap gap-2">
            {QUICK_PROMPTS.map((qp, idx) => (
              <button
                key={idx}
                type="button"
                onClick={() => {
                  setAdminPrompt(qp)
                  handleAnalyzeAlert(qp)
                }}
                className="text-xs bg-surface-light hover:bg-primary/10 hover:border-primary/40 border border-card-border px-3 py-1.5 rounded-full text-text-secondary hover:text-primary transition-colors text-left flex items-center gap-1.5"
              >
                <Sparkles className="w-3 h-3 text-primary shrink-0" />
                {qp}
              </button>
            ))}
          </div>

          <div className="relative">
            <textarea
              value={adminPrompt}
              onChange={(e) => setAdminPrompt(e.target.value)}
              placeholder="e.g. 'Publish an urgent alert for IT Sem 5 that mid-sem examination begins from 20th August'..."
              rows={3}
              className="w-full bg-surface-light border border-card-border rounded-xl px-4 py-3 text-text-primary text-sm focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all resize-none"
            />
            <button
              type="button"
              onClick={() => handleAnalyzeAlert()}
              disabled={isAnalyzing || !adminPrompt.trim()}
              className="absolute right-3 bottom-4 bg-primary hover:bg-primary/90 text-background font-semibold px-4 py-2 rounded-lg text-xs flex items-center gap-2 transition-all disabled:opacity-50"
            >
              {isAnalyzing ? (
                <>
                  <RefreshCw className="w-3.5 h-3.5 animate-spin" />
                  Generating...
                </>
              ) : (
                <>
                  <Sparkles className="w-3.5 h-3.5" />
                  Format with AI
                </>
              )}
            </button>
          </div>

          {/* AI Extracted Alert Preview */}
          {extractedAlert && (
            <div className="p-6 rounded-2xl bg-surface-light border border-primary/40 space-y-4 shadow-lg shadow-primary/5">
              <div className="flex items-center justify-between border-b border-card-border pb-3">
                <div className="flex items-center gap-2">
                  <Bell className="w-4 h-4 text-primary" />
                  <span className="text-xs font-bold text-text-primary uppercase tracking-wider">
                    Alert Preview ({extractedAlert.category})
                  </span>
                </div>
                <span className={`text-[10px] font-bold uppercase px-2.5 py-1 rounded-full border ${
                  extractedAlert.priority === 'urgent'
                    ? 'bg-error/15 text-error border-error/30'
                    : extractedAlert.priority === 'high'
                    ? 'bg-warning/15 text-warning border-warning/30'
                    : 'bg-primary/15 text-primary border-primary/30'
                }`}>
                  {extractedAlert.priority} priority
                </span>
              </div>

              <div>
                <input
                  type="text"
                  value={extractedAlert.title}
                  onChange={(e) => setExtractedAlert({ ...extractedAlert, title: e.target.value })}
                  className="w-full bg-transparent text-base font-bold text-text-primary focus:outline-none"
                />
                <textarea
                  rows={3}
                  value={extractedAlert.message}
                  onChange={(e) => setExtractedAlert({ ...extractedAlert, message: e.target.value })}
                  className="w-full bg-surface border border-card-border rounded-lg p-3 text-xs text-text-secondary focus:outline-none mt-2"
                />
              </div>

              <div className="flex flex-wrap items-center gap-4 text-xs text-text-secondary pt-2">
                <span>Target: <strong className="text-text-primary">{extractedAlert.department}</strong></span>
                <span>•</span>
                <span>Semester: <strong className="text-text-primary">{extractedAlert.semester}</strong></span>
              </div>

              <button
                type="button"
                onClick={handlePublishAiAlert}
                disabled={loading}
                className="w-full bg-primary hover:bg-primary/90 text-background font-bold py-3 rounded-xl transition-all flex items-center justify-center gap-2 text-sm shadow-md shadow-primary/20"
              >
                {loading ? <RefreshCw className="w-4 h-4 animate-spin" /> : <CheckCircle2 className="w-4 h-4" />}
                Publish Alert to Mobile Apps
              </button>
            </div>
          )}
        </div>
      )}

      {/* Mode 2: Manual Form */}
      {activeTab === 'manual' && (
        <form onSubmit={handleManualSubmit} className="bg-surface p-6 sm:p-8 rounded-2xl border border-card-border space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-text-secondary mb-2">
                Alert Title *
              </label>
              <input
                type="text"
                required
                value={formData.title}
                onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                placeholder="e.g. ⚠️ Attendance Defaulter List Published"
                className="w-full bg-surface-light border border-card-border rounded-lg px-4 py-2.5 text-text-primary text-sm focus:outline-none focus:border-primary"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-text-secondary mb-2">
                Category *
              </label>
              <select
                value={formData.category}
                onChange={(e) => setFormData({ ...formData, category: e.target.value as any })}
                className="w-full bg-surface-light border border-card-border rounded-lg px-4 py-2.5 text-text-primary text-sm focus:outline-none focus:border-primary"
              >
                {CATEGORIES.map((c) => (
                  <option key={c.value} value={c.value}>{c.label}</option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-text-secondary mb-2">
                Priority Level *
              </label>
              <select
                value={formData.priority}
                onChange={(e) => setFormData({ ...formData, priority: e.target.value as any })}
                className="w-full bg-surface-light border border-card-border rounded-lg px-4 py-2.5 text-text-primary text-sm focus:outline-none focus:border-primary"
              >
                <option value="normal">Normal Priority</option>
                <option value="high">High Priority</option>
                <option value="urgent">Urgent / Critical</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-text-secondary mb-2">
                Target Department
              </label>
              <select
                value={formData.department}
                onChange={(e) => setFormData({ ...formData, department: e.target.value })}
                className="w-full bg-surface-light border border-card-border rounded-lg px-4 py-2.5 text-text-primary text-sm focus:outline-none focus:border-primary"
              >
                {DEPARTMENTS.map((d) => (
                  <option key={d} value={d}>{d}</option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-text-secondary mb-2">
                Target Semester
              </label>
              <input
                type="text"
                value={formData.semester}
                onChange={(e) => setFormData({ ...formData, semester: e.target.value })}
                placeholder="e.g. 5, 1, 3, 5 or All"
                className="w-full bg-surface-light border border-card-border rounded-lg px-4 py-2.5 text-text-primary text-sm focus:outline-none focus:border-primary"
              />
            </div>

            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-text-secondary mb-2">
                Alert Message Details *
              </label>
              <textarea
                required
                rows={4}
                value={formData.message}
                onChange={(e) => setFormData({ ...formData, message: e.target.value })}
                placeholder="Write detailed notification message here..."
                className="w-full bg-surface-light border border-card-border rounded-lg px-4 py-2.5 text-text-primary text-sm focus:outline-none focus:border-primary"
              />
            </div>
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full bg-primary hover:bg-primary/90 text-background font-semibold py-3 px-4 rounded-lg transition-colors disabled:opacity-50 text-sm"
          >
            {loading ? 'Publishing...' : 'Broadcast Alert to All Users'}
          </button>
        </form>
      )}

      {/* Live Active Alerts List */}
      <div className="space-y-4 pt-4">
        <div className="flex items-center justify-between">
          <h2 className="text-lg font-bold text-text-primary flex items-center gap-2">
            <Bell className="w-5 h-5 text-primary" />
            Live Broadcasted Alerts ({alerts.length})
          </h2>
          <button
            onClick={fetchAlerts}
            className="text-xs text-primary hover:underline flex items-center gap-1"
          >
            <RefreshCw className={`w-3.5 h-3.5 ${loadingAlerts ? 'animate-spin' : ''}`} />
            Refresh
          </button>
        </div>

        {loadingAlerts ? (
          <div className="text-center py-12 text-text-secondary text-sm">Loading active broadcasts...</div>
        ) : alerts.length === 0 ? (
          <div className="p-8 text-center bg-surface rounded-2xl border border-card-border text-text-muted text-sm">
            No campus alerts broadcasted yet. Create one above to notify all students & parents.
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {alerts.map((alert) => (
              <div
                key={alert.id}
                className="bg-surface p-5 rounded-2xl border border-card-border space-y-3 relative hover:border-card-border/80 transition-colors"
              >
                <div className="flex items-start justify-between gap-3">
                  <div className="space-y-1">
                    <span className="text-[10px] font-bold uppercase tracking-wider text-primary bg-primary/10 border border-primary/20 px-2 py-0.5 rounded-full">
                      {alert.category}
                    </span>
                    <h3 className="font-bold text-text-primary text-sm pt-1">{alert.title}</h3>
                  </div>

                  <button
                    onClick={() => handleDeleteAlert(alert.id)}
                    className="text-text-muted hover:text-error p-1.5 rounded-lg hover:bg-surface-light transition-colors"
                    title="Delete Alert"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>

                <p className="text-xs text-text-secondary line-clamp-3 leading-relaxed">
                  {alert.message}
                </p>

                <div className="flex items-center justify-between text-[11px] text-text-muted border-t border-card-border pt-2.5">
                  <span>Target: <strong>{alert.department} (Sem {alert.semester})</strong></span>
                  <span>{new Date(alert.created_at).toLocaleDateString()}</span>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}
