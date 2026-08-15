import { useState, useRef, useEffect } from 'react'
import { 
  Bot, 
  Send, 
  Paperclip, 
  X, 
  CheckCircle2, 
  AlertTriangle, 
  FileText, 
  Bell, 
  Tag, 
  Trash2, 
  Edit3,
  FileSpreadsheet,
  Plus
} from 'lucide-react'
import { supabase } from '../config/supabase'
import { useAuth } from '../contexts/AuthContext'
import { parseUniversalAdminCommand } from '../lib/groq'
import type { 
  UniversalAdminResponse, 
  ExtractedDocMetadata, 
  ExtractedAlertMetadata
} from '../lib/groq'

interface ChatMessage {
  id: string
  sender: 'admin' | 'ai'
  text: string
  timestamp: string
  attachedFile?: { name: string; size: number }
  fileBlob?: File
  actionResponse?: UniversalAdminResponse
  confirmationStatus?: 'pending' | 'confirmed' | 'cancelled'
  dbResult?: { id: string; type: 'document' | 'alert' | 'scores' }
}

export default function AiCommandCenterPage() {
  const { user, institution } = useAuth()
  const [messages, setMessages] = useState<ChatMessage[]>([
    {
      id: 'welcome',
      sender: 'ai',
      text: `Hello ${institution?.short_name || institution?.name || 'Administrator'}! I am Eduai Intelligent Copilot for this campus.\n\nType natural prompts like *"this is AIPD Assignment for Sem 5 IT"* and attach documents. I will automatically extract metadata, infer the full subject title, and generate 14+ multilingual search tags for students and parents.`,
      timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
    }
  ])
  
  const [inputPrompt, setInputPrompt] = useState('')
  const [selectedFile, setSelectedFile] = useState<File | null>(null)
  const [isProcessing, setIsProcessing] = useState(false)
  const [executingMessageId, setExecutingMessageId] = useState<string | null>(null)
  
  // Inline editing state for confirmation cards
  const [editingCardId, setEditingCardId] = useState<string | null>(null)
  const [editedDoc, setEditedDoc] = useState<ExtractedDocMetadata | null>(null)
  const [editedAlert, setEditedAlert] = useState<ExtractedAlertMetadata | null>(null)
  const [newTagInput, setNewTagInput] = useState('')

  const fileInputRef = useRef<HTMLInputElement>(null)
  const chatEndRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    chatEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [messages, isProcessing])

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      setSelectedFile(e.target.files[0])
    }
  }

  const handleSendMessage = async (promptOverride?: string) => {
    const textToSend = promptOverride || inputPrompt.trim()
    if (!textToSend && !selectedFile) return

    const currentFile = selectedFile
    const fileMetadata = currentFile ? { name: currentFile.name, size: currentFile.size } : undefined

    let fileSnippetText: string | null = null
    if (currentFile) {
      if (currentFile.type.includes('text') || currentFile.name.endsWith('.txt') || currentFile.name.endsWith('.csv') || currentFile.name.endsWith('.json')) {
        try {
          const raw = await currentFile.text()
          fileSnippetText = raw.length > 2000 ? raw.substring(0, 2000) + '...' : raw
        } catch (_) {}
      }
    }

    const userMessage: ChatMessage = {
      id: `admin_${Date.now()}`,
      sender: 'admin',
      text: textToSend || `Uploaded file: ${currentFile?.name}`,
      timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
      attachedFile: fileMetadata,
      fileBlob: currentFile || undefined
    }

    setMessages(prev => [...prev, userMessage])
    setInputPrompt('')
    setSelectedFile(null)
    setIsProcessing(true)

    try {
      const response = await parseUniversalAdminCommand(textToSend, fileMetadata, fileSnippetText)

      const aiMessage: ChatMessage = {
        id: `ai_${Date.now()}`,
        sender: 'ai',
        text: response.message,
        timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
        actionResponse: response,
        confirmationStatus: response.requiresConfirmation ? 'pending' : undefined,
        fileBlob: currentFile || undefined
      }

      setMessages(prev => [...prev, aiMessage])
    } catch (err: any) {
      setMessages(prev => [
        ...prev,
        {
          id: `ai_err_${Date.now()}`,
          sender: 'ai',
          text: `⚠️ Error processing command: ${err.message || 'Something went wrong.'}`,
          timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
        }
      ])
    } finally {
      setIsProcessing(false)
    }
  }

  // CONFIRM & EXECUTE DATABASE INSERTION / SYNC
  const handleConfirmAction = async (msg: ChatMessage) => {
    if (!msg.actionResponse) return
    setExecutingMessageId(msg.id)

    try {
      if (msg.actionResponse.actionType === 'INSERT_DOCUMENT') {
        const docData = (editingCardId === msg.id && editedDoc) ? editedDoc : msg.actionResponse.documentData!

        let fileUrl = 'https://ifframkwyjegmxubscnk.supabase.co/storage/v1/object/public/documents/sample.pdf'
        let fileName = msg.attachedFile?.name || `${docData.title}.pdf`
        let fileSize = msg.attachedFile?.size || 1024 * 150

        // Find file blob
        const fileToUpload = msg.fileBlob || messages.find(m => m.sender === 'admin' && m.fileBlob)?.fileBlob
        if (fileToUpload) {
          const cleanName = fileToUpload.name.replace(/[^a-zA-Z0-9._-]/g, '_')
          const path = `admin_${Date.now()}_${cleanName}`
          const { data: uploadData, error: uploadErr } = await supabase.storage
            .from('documents')
            .upload(path, fileToUpload)

          if (!uploadErr && uploadData) {
            const { data: pubData } = supabase.storage.from('documents').getPublicUrl(uploadData.path)
            fileUrl = pubData.publicUrl
            fileName = fileToUpload.name
            fileSize = fileToUpload.size
          }
        }

        // Insert into Supabase documents table with full tags array
        const currentInstId = institution?.id || '6c6e9b83-cabf-4b13-855b-97d2e1461177'
        const { data: insertRes, error: insertErr } = await supabase
          .from('documents')
          .insert({
            title: docData.title,
            description: docData.content_summary,
            category: docData.category,
            department: docData.department,
            semester: docData.semester,
            division: docData.division,
            subject_name: docData.subject_name || docData.title,
            tags: docData.tags,
            content_summary: docData.content_summary,
            file_url: fileUrl,
            file_name: fileName,
            file_size: fileSize,
            uploaded_by: user?.id || 'admin',
            institution_id: currentInstId
          })
          .select()
          .single()

        if (insertErr) throw insertErr

        setMessages(prev =>
          prev.map(m =>
            m.id === msg.id
              ? {
                  ...m,
                  confirmationStatus: 'confirmed',
                  dbResult: { id: insertRes.id, type: 'document' }
                }
              : m
          )
        )
      } else if (msg.actionResponse.actionType === 'BROADCAST_ALERT') {
        const alertData = (editingCardId === msg.id && editedAlert) ? editedAlert : msg.actionResponse.alertData!
        const currentInstId = institution?.id || '6c6e9b83-cabf-4b13-855b-97d2e1461177'

        const { data: insertRes, error: insertErr } = await supabase
          .from('campus_alerts')
          .insert({
            title: alertData.title,
            message: alertData.message,
            category: alertData.category,
            department: alertData.department,
            semester: alertData.semester,
            priority: alertData.priority,
            created_by: user?.id || 'admin',
            institution_id: currentInstId
          })
          .select()
          .single()

        if (insertErr) throw insertErr

        setMessages(prev =>
          prev.map(m =>
            m.id === msg.id
              ? {
                  ...m,
                  confirmationStatus: 'confirmed',
                  dbResult: { id: insertRes.id, type: 'alert' }
                }
              : m
          )
        )
      } else if (msg.actionResponse.actionType === 'UPDATE_ATTENDANCE_MARKS') {
        const scores = msg.actionResponse.scoresData || []
        for (const s of scores) {
          if (!s.enrollment_no) continue

          const updatePayload: any = {}
          if (s.overall_attendance !== undefined) {
            updatePayload.overall_attendance = s.overall_attendance
          }

          if (s.subject && (s.mid_sem_marks !== undefined || s.practical_marks !== undefined)) {
            const { data: existingStudent } = await supabase
              .from('students')
              .select('marks_data')
              .eq('enrollment_no', s.enrollment_no)
              .maybeSingle()

            const currentMarks = (existingStudent?.marks_data as any) || {}
            currentMarks[s.subject] = {
              ...(currentMarks[s.subject] || {}),
              ...(s.mid_sem_marks !== undefined ? { mid_sem: s.mid_sem_marks } : {}),
              ...(s.practical_marks !== undefined ? { practical: s.practical_marks } : {}),
            }
            updatePayload.marks_data = currentMarks
          }

          await supabase
            .from('students')
            .update(updatePayload)
            .eq('enrollment_no', s.enrollment_no)
        }

        setMessages(prev =>
          prev.map(m =>
            m.id === msg.id
              ? {
                  ...m,
                  confirmationStatus: 'confirmed',
                  dbResult: { id: 'bulk_scores', type: 'scores' }
                }
              : m
          )
        )
      }
      setEditingCardId(null)
    } catch (err: any) {
      alert(`Database Action Failed: ${err.message}`)
    } finally {
      setExecutingMessageId(null)
    }
  }

  const handleCancelAction = (msgId: string) => {
    setMessages(prev =>
      prev.map(m =>
        m.id === msgId ? { ...m, confirmationStatus: 'cancelled' } : m
      )
    )
    setEditingCardId(null)
  }

  const startEditCard = (msg: ChatMessage) => {
    if (!msg.actionResponse) return
    setEditingCardId(msg.id)
    if (msg.actionResponse.documentData) {
      setEditedDoc({ ...msg.actionResponse.documentData })
    }
    if (msg.actionResponse.alertData) {
      setEditedAlert({ ...msg.actionResponse.alertData })
    }
  }

  const handleAddTagToEditedDoc = () => {
    if (!newTagInput.trim() || !editedDoc) return
    const tagClean = newTagInput.trim().toLowerCase()
    if (!editedDoc.tags.includes(tagClean)) {
      setEditedDoc({
        ...editedDoc,
        tags: [...editedDoc.tags, tagClean]
      })
    }
    setNewTagInput('')
  }

  const handleRemoveTagFromEditedDoc = (tagToRemove: string) => {
    if (!editedDoc) return
    setEditedDoc({
      ...editedDoc,
      tags: editedDoc.tags.filter(t => t !== tagToRemove)
    })
  }

  return (
    <div className="flex flex-col h-[calc(100vh-2rem)] max-w-5xl mx-auto">
      {/* Top Header */}
      <div className="flex items-center justify-between pb-4 border-b border-card-border">
        <div>
          <h1 className="text-2xl font-extrabold text-text-primary tracking-tight flex items-center gap-2">
            <Bot className="text-primary" size={26} />
            AI Command Center
          </h1>
          <p className="text-xs text-text-secondary mt-0.5">
            Single prompt ingestion for academic documents, attendance & marks sync, and campus alerts
          </p>
        </div>
        <div className="flex items-center gap-2">
          <span className="text-[11px] bg-primary/10 text-primary font-bold px-3 py-1 rounded-full border border-primary/30">
            Powered by GPT OSS 120B
          </span>
        </div>
      </div>

      {/* Messages List Area */}
      <div className="flex-1 overflow-y-auto py-6 space-y-6 pr-2">
        {messages.map((msg) => {
          const isAdmin = msg.sender === 'admin'

          return (
            <div
              key={msg.id}
              className={`flex flex-col ${isAdmin ? 'items-end' : 'items-start'} space-y-2`}
            >
              {/* Message Bubble */}
              <div
                className={`max-w-2xl rounded-2xl px-5 py-3.5 text-sm leading-relaxed shadow-sm ${
                  isAdmin
                    ? 'bg-primary text-background font-medium rounded-tr-none'
                    : 'bg-surface border border-card-border text-text-primary rounded-tl-none'
                }`}
              >
                {/* Attached file chip in user message */}
                {msg.attachedFile && (
                  <div className="mb-2 flex items-center gap-2 p-2 bg-background/20 rounded-lg text-xs font-semibold">
                    <FileText size={14} />
                    <span className="truncate">{msg.attachedFile.name}</span>
                    <span className="opacity-70 text-[10px]">
                      ({(msg.attachedFile.size / 1024).toFixed(1)} KB)
                    </span>
                  </div>
                )}

                <div className="whitespace-pre-wrap">{msg.text}</div>

                <div
                  className={`text-[10px] mt-1.5 ${
                    isAdmin ? 'text-background/70 text-right' : 'text-text-muted text-left'
                  }`}
                >
                  {msg.timestamp}
                </div>
              </div>

              {/* ACTION CONFIRMATION CARD (Before Database Insert) */}
              {msg.actionResponse?.requiresConfirmation && (
                <div className="w-full max-w-2xl bg-surface/95 backdrop-blur-md border border-card-border rounded-2xl p-5 shadow-2xl space-y-4">
                  {/* Card Status Header */}
                  <div className="flex items-center justify-between pb-3 border-b border-card-border">
                    <div className="flex items-center gap-2">
                      {msg.confirmationStatus === 'confirmed' ? (
                        <span className="flex items-center gap-1.5 text-xs font-bold text-primary bg-primary/15 px-2.5 py-1 rounded-full border border-primary/30">
                          <CheckCircle2 size={14} /> Synced to Database
                        </span>
                      ) : msg.confirmationStatus === 'cancelled' ? (
                        <span className="flex items-center gap-1.5 text-xs font-bold text-error bg-error/15 px-2.5 py-1 rounded-full border border-error/30">
                          <X size={14} /> Discarded
                        </span>
                      ) : (
                        <span className="flex items-center gap-1.5 text-xs font-bold text-warning bg-warning/15 px-2.5 py-1 rounded-full border border-warning/30 animate-pulse">
                          <AlertTriangle size={14} /> Confirmation Required
                        </span>
                      )}

                      <span className="text-xs font-semibold text-text-secondary">
                        {msg.actionResponse.actionType === 'INSERT_DOCUMENT' 
                          ? 'Academic Document & Tags' 
                          : msg.actionResponse.actionType === 'UPDATE_ATTENDANCE_MARKS'
                            ? 'Attendance & Marks Sync'
                            : 'Campus Broadcast Alert'}
                      </span>
                    </div>

                    {msg.confirmationStatus === 'pending' && (
                      <button
                        onClick={() => editingCardId === msg.id ? setEditingCardId(null) : startEditCard(msg)}
                        className="text-xs text-text-muted hover:text-primary flex items-center gap-1 transition-colors"
                      >
                        <Edit3 size={13} />
                        {editingCardId === msg.id ? 'Done Editing' : 'Edit Tags & Info'}
                      </button>
                    )}
                  </div>

                  {/* 1. DOCUMENT PREVIEW CONTENT */}
                  {msg.actionResponse.actionType === 'INSERT_DOCUMENT' && msg.actionResponse.documentData && (
                    <div className="space-y-3">
                      {editingCardId === msg.id && editedDoc ? (
                        <div className="space-y-3 p-3 bg-surface-light rounded-xl border border-card-border text-xs">
                          <div>
                            <label className="text-text-muted block mb-1">Title</label>
                            <input
                              type="text"
                              value={editedDoc.title}
                              onChange={e => setEditedDoc({ ...editedDoc, title: e.target.value })}
                              className="w-full bg-surface border border-card-border rounded-lg p-2 text-text-primary"
                            />
                          </div>
                          <div className="grid grid-cols-3 gap-2">
                            <div>
                              <label className="text-text-muted block mb-1">Category</label>
                              <select
                                value={editedDoc.category}
                                onChange={e => setEditedDoc({ ...editedDoc, category: e.target.value as any })}
                                className="w-full bg-surface border border-card-border rounded-lg p-2 text-text-primary"
                              >
                                <option value="assignment">Assignment</option>
                                <option value="timetable">Timetable</option>
                                <option value="lab_manual">Lab Manual</option>
                                <option value="syllabus">Syllabus</option>
                                <option value="notes">Lecture Notes</option>
                                <option value="pyq">PYQ Exam Paper</option>
                                <option value="circular">Circular</option>
                              </select>
                            </div>
                            <div>
                              <label className="text-text-muted block mb-1">Department</label>
                              <input
                                type="text"
                                value={editedDoc.department}
                                onChange={e => setEditedDoc({ ...editedDoc, department: e.target.value })}
                                className="w-full bg-surface border border-card-border rounded-lg p-2 text-text-primary"
                              />
                            </div>
                            <div>
                              <label className="text-text-muted block mb-1">Semester</label>
                              <input
                                type="text"
                                value={editedDoc.semester}
                                onChange={e => setEditedDoc({ ...editedDoc, semester: e.target.value })}
                                className="w-full bg-surface border border-card-border rounded-lg p-2 text-text-primary"
                              />
                            </div>
                          </div>

                          {/* Editable Tags Section */}
                          <div>
                            <label className="text-text-muted block mb-1">Search & Voice Match Tags</label>
                            <div className="flex flex-wrap gap-1.5 mb-2">
                              {editedDoc.tags.map((tag, i) => (
                                <span
                                  key={i}
                                  className="text-[11px] bg-primary/10 text-primary px-2 py-0.5 rounded-md border border-primary/30 flex items-center gap-1"
                                >
                                  {tag}
                                  <button
                                    type="button"
                                    onClick={() => handleRemoveTagFromEditedDoc(tag)}
                                    className="hover:text-error"
                                  >
                                    ×
                                  </button>
                                </span>
                              ))}
                            </div>
                            <div className="flex gap-2">
                              <input
                                type="text"
                                placeholder="Add custom tag (e.g. practical 1, unit 2)..."
                                value={newTagInput}
                                onChange={e => setNewTagInput(e.target.value)}
                                onKeyDown={e => {
                                  if (e.key === 'Enter') {
                                    e.preventDefault()
                                    handleAddTagToEditedDoc()
                                  }
                                }}
                                className="flex-1 bg-surface border border-card-border rounded-lg p-1.5 text-xs text-text-primary"
                              />
                              <button
                                type="button"
                                onClick={handleAddTagToEditedDoc}
                                className="bg-primary/20 text-primary border border-primary/30 px-3 py-1 rounded-lg text-xs font-bold flex items-center gap-1"
                              >
                                <Plus size={13} /> Add
                              </button>
                            </div>
                          </div>
                        </div>
                      ) : (
                        <div>
                          <h4 className="text-base font-bold text-text-primary flex items-center gap-2">
                            <FileText size={18} className="text-primary" />
                            {msg.actionResponse.documentData.title}
                          </h4>
                          <div className="grid grid-cols-3 gap-2 mt-3 text-xs">
                            <div className="bg-surface-light p-2.5 rounded-lg border border-card-border">
                              <span className="text-text-muted block">Category</span>
                              <span className="font-semibold text-primary capitalize">
                                {msg.actionResponse.documentData.category.replace('_', ' ')}
                              </span>
                            </div>
                            <div className="bg-surface-light p-2.5 rounded-lg border border-card-border">
                              <span className="text-text-muted block">Department</span>
                              <span className="font-semibold text-text-primary">
                                {msg.actionResponse.documentData.department}
                              </span>
                            </div>
                            <div className="bg-surface-light p-2.5 rounded-lg border border-card-border">
                              <span className="text-text-muted block">Semester / Class</span>
                              <span className="font-semibold text-cyan-accent">
                                Sem {msg.actionResponse.documentData.semester} (Div {msg.actionResponse.documentData.division})
                              </span>
                            </div>
                          </div>

                          {/* Multi-lingual Search Tags Preview */}
                          <div className="mt-3">
                            <span className="text-xs text-text-muted flex items-center gap-1 mb-1.5 font-bold">
                              <Tag size={12} className="text-primary" /> Auto-Generated Search & Voice Tags ({msg.actionResponse.documentData.tags.length}):
                            </span>
                            <div className="flex flex-wrap gap-1.5">
                              {msg.actionResponse.documentData.tags.map((tag, i) => (
                                <span
                                  key={i}
                                  className="text-[11px] bg-primary/10 text-primary px-2.5 py-0.5 rounded-md border border-primary/20 font-mono font-medium"
                                >
                                  #{tag}
                                </span>
                              ))}
                            </div>
                          </div>

                          {/* Content Summary */}
                          {msg.actionResponse.documentData.content_summary && (
                            <div className="mt-3 p-2.5 bg-surface-light/50 rounded-lg border border-card-border text-xs text-text-secondary">
                              <span className="font-bold text-text-primary block mb-0.5">Content Summary:</span>
                              {msg.actionResponse.documentData.content_summary}
                            </div>
                          )}
                        </div>
                      )}
                    </div>
                  )}

                  {/* 2. ATTENDANCE & MARKS PREVIEW TABLE */}
                  {msg.actionResponse.actionType === 'UPDATE_ATTENDANCE_MARKS' && msg.actionResponse.scoresData && (
                    <div className="space-y-3">
                      <div className="flex items-center gap-2">
                        <FileSpreadsheet size={18} className="text-cyan-accent" />
                        <h4 className="text-sm font-bold text-text-primary">
                          Parsed Student Scores ({msg.actionResponse.scoresData.length} Students)
                        </h4>
                      </div>

                      <div className="overflow-x-auto max-h-48 border border-card-border rounded-xl">
                        <table className="w-full text-left text-xs">
                          <thead className="bg-surface-light text-text-muted uppercase font-bold sticky top-0">
                            <tr>
                              <th className="p-2">Enrollment</th>
                              <th className="p-2">Name</th>
                              <th className="p-2">Attendance %</th>
                              <th className="p-2">Subject</th>
                              <th className="p-2">Mid-Sem</th>
                              <th className="p-2">Practical</th>
                            </tr>
                          </thead>
                          <tbody className="divide-y divide-card-border text-text-primary">
                            {msg.actionResponse.scoresData.map((s, idx) => (
                              <tr key={idx} className="hover:bg-surface-light/40">
                                <td className="p-2 font-mono text-cyan-accent font-bold">{s.enrollment_no}</td>
                                <td className="p-2">{s.student_name || '—'}</td>
                                <td className="p-2 font-bold">{s.overall_attendance ? `${s.overall_attendance}%` : '—'}</td>
                                <td className="p-2 text-text-secondary">{s.subject || 'General'}</td>
                                <td className="p-2 font-mono">{s.mid_sem_marks ? `${s.mid_sem_marks}/30` : '—'}</td>
                                <td className="p-2 font-mono">{s.practical_marks ? `${s.practical_marks}/30` : '—'}</td>
                              </tr>
                            ))}
                          </tbody>
                        </table>
                      </div>
                    </div>
                  )}

                  {/* 3. ALERT PREVIEW CONTENT */}
                  {msg.actionResponse.actionType === 'BROADCAST_ALERT' && msg.actionResponse.alertData && (
                    <div className="space-y-3">
                      {editingCardId === msg.id && editedAlert ? (
                        <div className="space-y-3 p-3 bg-surface-light rounded-xl border border-card-border text-xs">
                          <div>
                            <label className="text-text-muted block mb-1">Alert Title</label>
                            <input
                              type="text"
                              value={editedAlert.title}
                              onChange={e => setEditedAlert({ ...editedAlert, title: e.target.value })}
                              className="w-full bg-surface border border-card-border rounded-lg p-2 text-text-primary"
                            />
                          </div>
                          <div>
                            <label className="text-text-muted block mb-1">Message Body</label>
                            <textarea
                              rows={3}
                              value={editedAlert.message}
                              onChange={e => setEditedAlert({ ...editedAlert, message: e.target.value })}
                              className="w-full bg-surface border border-card-border rounded-lg p-2 text-text-primary"
                            />
                          </div>
                        </div>
                      ) : (
                        <div>
                          <h4 className="text-base font-bold text-text-primary flex items-center gap-2">
                            <Bell size={18} className="text-warning" />
                            {msg.actionResponse.alertData.title}
                          </h4>
                          <p className="text-xs text-text-secondary mt-2 bg-surface-light p-3 rounded-lg border border-card-border">
                            {msg.actionResponse.alertData.message}
                          </p>
                          <div className="flex items-center gap-2 mt-3 text-xs">
                            <span className="bg-surface-light px-2.5 py-1 rounded-md border border-card-border text-text-muted">
                              Target: <strong className="text-text-primary">{msg.actionResponse.alertData.department} (Sem {msg.actionResponse.alertData.semester})</strong>
                            </span>
                            <span className="bg-surface-light px-2.5 py-1 rounded-md border border-card-border text-text-muted">
                              Priority: <strong className="text-warning uppercase">{msg.actionResponse.alertData.priority}</strong>
                            </span>
                          </div>
                        </div>
                      )}
                    </div>
                  )}

                  {/* ACTION CONFIRMATION BUTTONS */}
                  {msg.confirmationStatus === 'pending' && (
                    <div className="flex items-center gap-3 pt-3 border-t border-card-border">
                      <button
                        onClick={() => handleConfirmAction(msg)}
                        disabled={executingMessageId === msg.id}
                        className="flex-1 bg-primary text-background font-bold py-2.5 px-4 rounded-xl hover:opacity-90 transition-all flex items-center justify-center gap-2 text-xs shadow-lg shadow-primary/20 cursor-pointer"
                      >
                        {executingMessageId === msg.id ? (
                          <div className="w-4 h-4 border-2 border-background border-t-transparent rounded-full animate-spin" />
                        ) : (
                          <>
                            <CheckCircle2 size={16} />
                            Confirm & Ingest to Database
                          </>
                        )}
                      </button>

                      <button
                        onClick={() => handleCancelAction(msg.id)}
                        className="px-4 py-2.5 rounded-xl border border-card-border text-text-muted hover:text-error hover:border-error/40 transition-colors text-xs font-semibold flex items-center gap-1.5"
                      >
                        <Trash2 size={14} /> Discard
                      </button>
                    </div>
                  )}
                </div>
              )}
            </div>
          )
        })}

        {isProcessing && (
          <div className="flex items-center gap-3 text-xs text-text-muted bg-surface/60 border border-card-border p-3.5 rounded-2xl w-fit animate-pulse">
            <Bot size={16} className="text-primary animate-spin" />
            Analyzing document content & generating multi-lingual tags with GPT OSS 120B...
          </div>
        )}

        <div ref={chatEndRef} />
      </div>

      {/* Attached file indicator before sending */}
      {selectedFile && (
        <div className="mb-2 p-2.5 bg-surface border border-primary/40 rounded-xl flex items-center justify-between text-xs">
          <div className="flex items-center gap-2 text-text-primary">
            <FileText size={16} className="text-primary" />
            <span className="font-semibold">{selectedFile.name}</span>
            <span className="text-text-muted">({(selectedFile.size / 1024).toFixed(1)} KB)</span>
          </div>
          <button
            onClick={() => setSelectedFile(null)}
            className="text-text-muted hover:text-error transition-colors p-1"
          >
            <X size={14} />
          </button>
        </div>
      )}

      {/* Bottom Prompt Bar */}
      <div className="pt-3 border-t border-card-border">
        <form
          onSubmit={(e) => {
            e.preventDefault()
            handleSendMessage()
          }}
          className="flex items-center gap-2 bg-surface p-2 rounded-2xl border border-card-border focus-within:border-primary/60 transition-all shadow-lg"
        >
          <input
            type="file"
            ref={fileInputRef}
            onChange={handleFileSelect}
            className="hidden"
            accept=".pdf,.png,.jpg,.jpeg,.csv,.xlsx,.xls,.docx,.txt"
          />

          <button
            type="button"
            onClick={() => fileInputRef.current?.click()}
            className={`p-2.5 rounded-xl border transition-all ${
              selectedFile
                ? 'bg-primary text-background border-primary'
                : 'bg-surface-light border-card-border text-text-secondary hover:text-primary hover:border-primary/40'
            }`}
            title="Attach Document or Spreadsheet"
          >
            <Paperclip size={18} />
          </button>

          <input
            type="text"
            value={inputPrompt}
            onChange={(e) => setInputPrompt(e.target.value)}
            placeholder='e.g. "this is aipd assignment of sem 5" or "Holiday notice for tomorrow"...'
            className="flex-1 bg-transparent border-none px-3 text-sm text-text-primary placeholder:text-text-muted focus:outline-none"
            disabled={isProcessing}
          />

          <button
            type="submit"
            disabled={isProcessing || (!inputPrompt.trim() && !selectedFile)}
            className="bg-primary text-background p-2.5 rounded-xl font-bold hover:opacity-90 transition-all disabled:opacity-40 disabled:cursor-not-allowed flex items-center justify-center"
          >
            <Send size={18} />
          </button>
        </form>
      </div>
    </div>
  )
}
