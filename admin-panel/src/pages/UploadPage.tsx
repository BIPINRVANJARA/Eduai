import React, { useState } from 'react'
import { Bot, FileText, Sparkles, CheckCircle2, AlertCircle, RefreshCw, Plus, X, Tag } from 'lucide-react'
import FileUploader from '../components/FileUploader'
import { supabase } from '../config/supabase'
import { useAuth } from '../contexts/AuthContext'
import { parseAdminUploadPrompt, type ExtractedDocMetadata } from '../lib/groq'

const CATEGORIES = [
  { value: 'timetable', label: 'Timetable' },
  { value: 'lab_manual', label: 'Lab Manual' },
  { value: 'assignment', label: 'Assignment' },
  { value: 'notes', label: 'Lecture Notes / Study Material' },
  { value: 'pyq', label: 'Previous Year Papers (PYQ)' },
  { value: 'syllabus', label: 'Syllabus & Curriculum' },
  { value: 'circular', label: 'Circular & Notice' },
  { value: 'fee_structure', label: 'Fee Structure & Receipts' },
  { value: 'placement', label: 'Placement & Internship' },
  { value: 'project', label: 'Capstone Projects & Templates' },
  { value: 'attendance_report', label: 'Attendance Report' },
  { value: 'other', label: 'Other Academic File' },
]

const DEPARTMENTS = [
  'Information Technology',
  'Computer Science & Engineering',
  'Electronics & Communication',
  'Mechanical Engineering',
  'Civil Engineering',
  'General',
]

const QUICK_PROMPTS = [
  'This is timetable pdf for IT Sem 5 add it to the database',
  'Upload AIPE Lab Manual for IT Department Sem 5',
  'Add assignment for Web Development Semester 4',
  'Upload circular regarding mid-semester examination schedule',
]

export default function UploadPage() {
  const { user, institution } = useAuth()
  const [activeTab, setActiveTab] = useState<'ai' | 'manual'>('ai')

  // Shared file state
  const [file, setFile] = useState<File | null>(null)
  const [loading, setLoading] = useState(false)
  const [success, setSuccess] = useState('')
  const [error, setError] = useState('')

  // AI Agent Mode States
  const [adminPrompt, setAdminPrompt] = useState('')
  const [isAnalyzing, setIsAnalyzing] = useState(false)
  const [extractedData, setExtractedData] = useState<ExtractedDocMetadata | null>(null)
  const [customTagInput, setCustomTagInput] = useState('')

  // Manual Mode States
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    category: 'timetable',
    department: 'Information Technology',
    semester: '1',
    division: 'A',
    subject_name: '',
    tags: [] as string[],
  })
  const [manualTagInput, setManualTagInput] = useState('')

  // Handle AI Analysis
  const handleAnalyzeWithAI = async (promptText?: string) => {
    const textToUse = promptText || adminPrompt
    if (!textToUse.trim()) {
      setError('Please enter a description or prompt for the AI to analyze.')
      return
    }

    setIsAnalyzing(true)
    setError('')
    try {
      const extracted = await parseAdminUploadPrompt(textToUse, file?.name || 'document.pdf')
      setExtractedData(extracted)
    } catch (err: any) {
      setError('Failed to analyze with AI: ' + (err.message || err))
    } finally {
      setIsAnalyzing(false)
    }
  }

  // Handle AI Upload Confirmation
  const handleConfirmAiUpload = async () => {
    if (!file) {
      setError('Please select a file to upload.')
      return
    }
    if (!extractedData) {
      setError('Please analyze the document first before uploading.')
      return
    }

    setLoading(true)
    setError('')
    setSuccess('')

    try {
      // 1. Upload to Supabase Storage
      const fileExt = file.name.split('.').pop()
      const fileName = `${crypto.randomUUID()}.${fileExt}`
      const filePath = `${extractedData.category}/${fileName}`
      
      const currentInstId = institution?.id || '6c6e9b83-cabf-4b13-855b-97d2e1461177'

      const { error: uploadError } = await supabase.storage
        .from('documents')
        .upload(filePath, file)

      if (uploadError) throw uploadError

      // 2. Insert metadata + tags into Supabase DB
      let insertPayload: any = {
        title: extractedData.title,
        description: extractedData.content_summary,
        category: extractedData.category,
        department: extractedData.department,
        semester: extractedData.semester,
        division: extractedData.division,
        subject_name: extractedData.subject_name,
        tags: extractedData.tags,
        content_summary: extractedData.content_summary,
        file_url: filePath,
        file_name: file.name,
        file_size: file.size,
        uploaded_by: user?.id,
        institution_id: currentInstId,
      }

      let { error: dbError } = await supabase.from('documents').insert([insertPayload])

      // Fallback if semester column is integer in Postgres
      if (dbError && dbError.message?.includes('invalid input syntax for type integer')) {
        const firstInt = parseInt(extractedData.semester) || 1
        insertPayload.semester = firstInt
        const retry = await supabase.from('documents').insert([insertPayload])
        dbError = retry.error
      }

      if (dbError) throw dbError

      setSuccess(`✅ Successfully uploaded "${extractedData.title}" with ${extractedData.tags.length} search tags! Students and parents can now query it directly through AI.`)
      setFile(null)
      setAdminPrompt('')
      setExtractedData(null)
    } catch (err: any) {
      console.error('Upload error:', err)
      setError(err.message || 'An error occurred during upload.')
    } finally {
      setLoading(false)
    }
  }

  // Handle Manual Form Submission
  const handleManualSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!file) {
      setError('Please select a file to upload.')
      return
    }

    setLoading(true)
    setError('')
    setSuccess('')

    try {
      const fileExt = file.name.split('.').pop()
      const fileName = `${crypto.randomUUID()}.${fileExt}`
      const filePath = `${formData.category}/${fileName}`
      
      const currentInstId = institution?.id || '6c6e9b83-cabf-4b13-855b-97d2e1461177'

      const { error: uploadError } = await supabase.storage
        .from('documents')
        .upload(filePath, file)

      if (uploadError) throw uploadError

      const { error: dbError } = await supabase.from('documents').insert([
        {
          title: formData.title,
          description: formData.description,
          category: formData.category,
          department: formData.department,
          semester: formData.semester,
          division: formData.division,
          subject_name: formData.subject_name,
          tags: formData.tags,
          file_url: filePath,
          file_name: file.name,
          file_size: file.size,
          uploaded_by: user?.id,
          institution_id: currentInstId,
        },
      ])

      if (dbError) throw dbError

      setSuccess('✅ Document uploaded successfully!')
      setFile(null)
      setFormData({
        title: '',
        description: '',
        category: 'timetable',
        department: 'Information Technology',
        semester: '1',
        division: 'A',
        subject_name: '',
        tags: [],
      })
    } catch (err: any) {
      console.error('Upload error:', err)
      setError(err.message || 'An error occurred during upload.')
    } finally {
      setLoading(false)
    }
  }

  // Tag helpers for AI mode
  const addCustomTag = () => {
    if (!customTagInput.trim() || !extractedData) return
    if (!extractedData.tags.includes(customTagInput.trim())) {
      setExtractedData({
        ...extractedData,
        tags: [...extractedData.tags, customTagInput.trim()],
      })
    }
    setCustomTagInput('')
  }

  const removeCustomTag = (tagToRemove: string) => {
    if (!extractedData) return
    setExtractedData({
      ...extractedData,
      tags: extractedData.tags.filter(t => t !== tagToRemove),
    })
  }

  return (
    <div className="max-w-4xl mx-auto space-y-8">
      {/* Header & Mode Switcher */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 border-b border-card-border pb-6">
        <div>
          <h1 className="text-2xl font-bold text-text-primary tracking-tight">
            Academic Document Management
          </h1>
          <p className="text-text-secondary text-sm mt-1">
            Upload timetables, lab manuals, and assignments for student & parent RAG queries
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
            🤖 AI Agent Upload
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

      {/* Notifications */}
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

      {/* Mode 1: AI Assistant Upload */}
      {activeTab === 'ai' && (
        <div className="space-y-6">
          {/* Step 1: File Selection */}
          <div className="bg-surface p-6 rounded-2xl border border-card-border space-y-4">
            <h2 className="text-base font-semibold text-text-primary flex items-center gap-2">
              <span className="flex items-center justify-center w-6 h-6 rounded-full bg-primary/20 text-primary text-xs font-bold">1</span>
              Select Document File (PDF / DOC)
            </h2>
            <FileUploader
              selectedFile={file}
              onFileSelect={(f) => {
                setFile(f)
                if (f && adminPrompt) {
                  handleAnalyzeWithAI()
                }
              }}
            />
          </div>

          {/* Step 2: AI Command / Prompt Input */}
          <div className="bg-surface p-6 rounded-2xl border border-card-border space-y-4">
            <h2 className="text-base font-semibold text-text-primary flex items-center gap-2">
              <span className="flex items-center justify-center w-6 h-6 rounded-full bg-primary/20 text-primary text-xs font-bold">2</span>
              Give Natural Language Instruction to AI
            </h2>

            {/* Quick Prompts */}
            <div className="flex flex-wrap gap-2">
              {QUICK_PROMPTS.map((qp, idx) => (
                <button
                  key={idx}
                  type="button"
                  onClick={() => {
                    setAdminPrompt(qp)
                    handleAnalyzeWithAI(qp)
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
                placeholder="e.g., 'This is timetable pdf of IT department Sem 5 add it to the database with all search tags'..."
                rows={3}
                className="w-full bg-surface-light border border-card-border rounded-xl px-4 py-3 text-text-primary text-sm focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all resize-none"
              />
              <button
                type="button"
                onClick={() => handleAnalyzeWithAI()}
                disabled={isAnalyzing || !adminPrompt.trim()}
                className="absolute right-3 bottom-4 bg-primary hover:bg-primary/90 text-background font-semibold px-4 py-2 rounded-lg text-xs flex items-center gap-2 transition-all disabled:opacity-50"
              >
                {isAnalyzing ? (
                  <>
                    <RefreshCw className="w-3.5 h-3.5 animate-spin" />
                    Analyzing with LLM...
                  </>
                ) : (
                  <>
                    <Sparkles className="w-3.5 h-3.5" />
                    Process with AI
                  </>
                )}
              </button>
            </div>
          </div>

          {/* Step 3: Extracted Metadata & Auto-Generated Tags Preview */}
          {extractedData && (
            <div className="bg-surface p-6 rounded-2xl border border-primary/40 space-y-6 shadow-lg shadow-primary/5">
              <div className="flex items-center justify-between border-b border-card-border pb-4">
                <div className="flex items-center gap-2">
                  <span className="flex items-center justify-center w-6 h-6 rounded-full bg-primary text-background text-xs font-bold">3</span>
                  <h3 className="font-bold text-text-primary">AI Extracted Metadata & Search Tags</h3>
                </div>
                <span className="text-xs uppercase font-bold tracking-wider px-3 py-1 rounded-full bg-primary/10 text-primary border border-primary/30">
                  {extractedData.category.replace('_', ' ')}
                </span>
              </div>

              {/* Grid of Extracted Details */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div className="bg-surface-light p-3.5 rounded-xl border border-card-border">
                  <label className="text-xs text-text-muted font-medium block">Document Title</label>
                  <input
                    type="text"
                    value={extractedData.title}
                    onChange={(e) => setExtractedData({ ...extractedData, title: e.target.value })}
                    className="w-full bg-transparent text-sm font-semibold text-text-primary focus:outline-none mt-1"
                  />
                </div>

                <div className="bg-surface-light p-3.5 rounded-xl border border-card-border">
                  <label className="text-xs text-text-muted font-medium block">Department</label>
                  <input
                    type="text"
                    value={extractedData.department}
                    onChange={(e) => setExtractedData({ ...extractedData, department: e.target.value })}
                    className="w-full bg-transparent text-sm font-semibold text-text-primary focus:outline-none mt-1"
                  />
                </div>

                <div className="bg-surface-light p-3.5 rounded-xl border border-card-border">
                  <label className="text-xs text-text-muted font-medium block">Semester & Division</label>
                  <div className="flex items-center gap-2 mt-1">
                    <input
                      type="text"
                      value={extractedData.semester}
                      onChange={(e) => setExtractedData({ ...extractedData, semester: e.target.value })}
                      placeholder="e.g. 1, 3, 5 or 5"
                      className="bg-transparent text-sm font-semibold text-text-primary focus:outline-none w-28"
                    />
                    <span className="text-card-border">|</span>
                    <input
                      type="text"
                      value={extractedData.division || 'All'}
                      onChange={(e) => setExtractedData({ ...extractedData, division: e.target.value })}
                      placeholder="e.g. A, B, C or All"
                      className="bg-transparent text-sm font-semibold text-text-primary focus:outline-none w-28"
                    />
                  </div>
                </div>

                <div className="bg-surface-light p-3.5 rounded-xl border border-card-border">
                  <label className="text-xs text-text-muted font-medium block">Subject Name</label>
                  <input
                    type="text"
                    value={extractedData.subject_name || 'General / Class Schedule'}
                    onChange={(e) => setExtractedData({ ...extractedData, subject_name: e.target.value })}
                    className="w-full bg-transparent text-sm font-semibold text-text-primary focus:outline-none mt-1"
                  />
                </div>
              </div>

              {/* Multi-Language Search Tags */}
              <div className="space-y-3">
                <div className="flex items-center justify-between">
                  <label className="text-xs font-semibold text-text-secondary flex items-center gap-1.5">
                    <Tag className="w-3.5 h-3.5 text-primary" />
                    Auto-Generated Search Synonyms & Multilingual Tags ({extractedData.tags.length})
                  </label>
                  <span className="text-[11px] text-text-muted">Students can ask using any of these terms</span>
                </div>

                <div className="flex flex-wrap gap-2 p-3 bg-surface-light rounded-xl border border-card-border">
                  {extractedData.tags.map((tag, idx) => (
                    <span
                      key={idx}
                      className="inline-flex items-center gap-1.5 bg-surface border border-card-border hover:border-primary/40 px-2.5 py-1 rounded-lg text-xs text-text-primary transition-colors"
                    >
                      <span>{tag}</span>
                      <button
                        type="button"
                        onClick={() => removeCustomTag(tag)}
                        className="text-text-muted hover:text-error"
                      >
                        <X className="w-3 h-3" />
                      </button>
                    </span>
                  ))}

                  {/* Add Tag Input */}
                  <div className="inline-flex items-center gap-1">
                    <input
                      type="text"
                      value={customTagInput}
                      onChange={(e) => setCustomTagInput(e.target.value)}
                      onKeyDown={(e) => { if (e.key === 'Enter') { e.preventDefault(); addCustomTag(); } }}
                      placeholder="+ add tag..."
                      className="bg-transparent text-xs text-text-primary px-2 py-1 focus:outline-none w-24"
                    />
                    {customTagInput && (
                      <button
                        type="button"
                        onClick={addCustomTag}
                        className="text-primary hover:text-primary/80"
                      >
                        <Plus className="w-3.5 h-3.5" />
                      </button>
                    )}
                  </div>
                </div>
              </div>

              {/* Upload Confirmation Button */}
              <button
                type="button"
                onClick={handleConfirmAiUpload}
                disabled={loading || !file}
                className="w-full bg-primary hover:bg-primary/90 text-background font-bold py-3.5 px-6 rounded-xl transition-all shadow-lg shadow-primary/20 flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed text-sm"
              >
                {loading ? (
                  <>
                    <RefreshCw className="w-4 h-4 animate-spin" />
                    Uploading to Supabase Storage & Recording Tags...
                  </>
                ) : (
                  <>
                    <CheckCircle2 className="w-4 h-4" />
                    Confirm & Add to Database for Student AI Retrieval
                  </>
                )}
              </button>
            </div>
          )}
        </div>
      )}

      {/* Mode 2: Manual Form Upload */}
      {activeTab === 'manual' && (
        <form onSubmit={handleManualSubmit} className="bg-surface p-6 sm:p-8 rounded-2xl border border-card-border space-y-6">
          <div>
            <label className="block text-sm font-medium text-text-secondary mb-2">
              Select Document File *
            </label>
            <FileUploader selectedFile={file} onFileSelect={setFile} />
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-text-secondary mb-2">
                Document Title *
              </label>
              <input
                type="text"
                required
                value={formData.title}
                onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                placeholder="e.g. IT Sem 5 Class Timetable"
                className="w-full bg-surface-light border border-card-border rounded-lg px-4 py-2.5 text-text-primary text-sm focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-text-secondary mb-2">
                Category *
              </label>
              <select
                value={formData.category}
                onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                className="w-full bg-surface-light border border-card-border rounded-lg px-4 py-2.5 text-text-primary text-sm focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all"
              >
                {CATEGORIES.map((c) => (
                  <option key={c.value} value={c.value}>
                    {c.label}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-text-secondary mb-2">
                Department *
              </label>
              <select
                value={formData.department}
                onChange={(e) => setFormData({ ...formData, department: e.target.value })}
                className="w-full bg-surface-light border border-card-border rounded-lg px-4 py-2.5 text-text-primary text-sm focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all"
              >
                {DEPARTMENTS.map((d) => (
                  <option key={d} value={d}>
                    {d}
                  </option>
                ))}
              </select>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-text-secondary mb-2">
                  Semester *
                </label>
                <select
                  value={formData.semester}
                  onChange={(e) => setFormData({ ...formData, semester: e.target.value })}
                  className="w-full bg-surface-light border border-card-border rounded-lg px-4 py-2.5 text-text-primary text-sm focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all"
                >
                  {[1, 2, 3, 4, 5, 6, 7, 8].map((s) => (
                    <option key={s} value={String(s)}>
                      Semester {s}
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-text-secondary mb-2">
                  Division
                </label>
                <input
                  type="text"
                  value={formData.division}
                  onChange={(e) => setFormData({ ...formData, division: e.target.value })}
                  placeholder="e.g. A"
                  className="w-full bg-surface-light border border-card-border rounded-lg px-4 py-2.5 text-text-primary text-sm focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all"
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-text-secondary mb-2">
                Subject Name
              </label>
              <input
                type="text"
                value={formData.subject_name}
                onChange={(e) => setFormData({ ...formData, subject_name: e.target.value })}
                placeholder="e.g. Artificial Intelligence"
                className="w-full bg-surface-light border border-card-border rounded-lg px-4 py-2.5 text-text-primary text-sm focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-text-secondary mb-2">
                Search Tags (comma separated)
              </label>
              <input
                type="text"
                value={manualTagInput}
                onChange={(e) => {
                  setManualTagInput(e.target.value)
                  setFormData({
                    ...formData,
                    tags: e.target.value.split(',').map((t) => t.trim()).filter(Boolean),
                  })
                }}
                placeholder="TT, Timetable, time table, schedule"
                className="w-full bg-surface-light border border-card-border rounded-lg px-4 py-2.5 text-text-primary text-sm focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all"
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-text-secondary mb-2">
              Description / RAG Notes
            </label>
            <textarea
              rows={3}
              value={formData.description}
              onChange={(e) => setFormData({ ...formData, description: e.target.value })}
              placeholder="Short description or instructions for AI assistant..."
              className="w-full bg-surface-light border border-card-border rounded-lg px-4 py-2.5 text-text-primary text-sm focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all"
            />
          </div>

          <button
            type="submit"
            disabled={loading || !file}
            className="w-full bg-primary hover:bg-primary/90 text-background font-semibold py-3 px-4 rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed text-sm"
          >
            {loading ? 'Uploading...' : 'Save & Upload Document'}
          </button>
        </form>
      )}
    </div>
  )
}
