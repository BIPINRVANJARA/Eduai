import { useEffect, useState } from 'react'
import { 
  Download, 
  Search, 
  Tag, 
  Edit3, 
  Trash2, 
  X, 
  Plus, 
  CheckCircle2, 
  AlertTriangle, 
  FileText,
  Save
} from 'lucide-react'
import DataTable from '../components/DataTable'
import { supabase } from '../config/supabase'
import type { Document } from '../lib/types'
import { useAuth } from '../contexts/AuthContext'

const CATEGORIES = [
  { value: '', label: 'All Categories' },
  { value: 'timetable', label: 'Timetable' },
  { value: 'lab_manual', label: 'Lab Manual' },
  { value: 'assignment', label: 'Assignment' },
  { value: 'notes', label: 'Lecture Notes / Study Material' },
  { value: 'pyq', label: 'Previous Year Papers (PYQ)' },
  { value: 'syllabus', label: 'Syllabus & Curriculum' },
  { value: 'circular', label: 'Circular & Notice' },
  { value: 'fee_structure', label: 'Fee Structure & Receipts' },
  { value: 'placement', label: 'Placement & Internship' },
  { value: 'project', label: 'Capstone Projects' },
  { value: 'attendance_report', label: 'Attendance Report' },
  { value: 'other', label: 'Other' },
]

const DEPARTMENTS = [
  'Information Technology',
  'Computer Science & Engineering',
  'Electronics & Communication',
  'Mechanical Engineering',
  'Civil Engineering',
  'General',
]

export default function DocumentsPage() {
  const { institution, selectedDepartment } = useAuth()
  const [documents, setDocuments] = useState<Document[]>([])
  const [loading, setLoading] = useState(true)
  const [category, setCategory] = useState('')
  const [search, setSearch] = useState('')

  // Edit State
  const [editingDoc, setEditingDoc] = useState<Document | null>(null)
  const [isUpdating, setIsUpdating] = useState(false)
  const [newTagInput, setNewTagInput] = useState('')

  // Delete State
  const [deletingDoc, setDeletingDoc] = useState<Document | null>(null)
  const [isDeleting, setIsDeleting] = useState(false)

  // Toast / Status message
  const [statusMessage, setStatusMessage] = useState<{ text: string; type: 'success' | 'error' } | null>(null)

  const showToast = (text: string, type: 'success' | 'error' = 'success') => {
    setStatusMessage({ text, type })
    setTimeout(() => setStatusMessage(null), 4000)
  }

  const fetchDocuments = async () => {
    try {
      setLoading(true)
      let query = supabase.from('documents').select('*').order('created_at', { ascending: false })
      
      if (institution?.id) {
        query = query.eq('institution_id', institution.id)
      }

      if (selectedDepartment && selectedDepartment !== 'all') {
        query = query.or(`department.eq.${selectedDepartment},department.eq.General,department.eq.All`)
      }

      if (category) {
        query = query.eq('category', category)
      }

      const { data, error } = await query
      if (error) throw error
      setDocuments(data || [])
    } catch (error: any) {
      console.error('Error fetching documents:', error)
      showToast(error.message || 'Failed to load documents', 'error')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchDocuments()
  }, [category, institution?.id, selectedDepartment])

  const handleDownload = async (fileUrl: string, fileName: string) => {
    try {
      if (!fileUrl) {
        showToast('No downloadable URL found for this document.', 'error')
        return
      }

      // If it's already an absolute URL (e.g. AWS S3 link or Supabase Public URL)
      if (fileUrl.startsWith('http://') || fileUrl.startsWith('https://')) {
        window.open(fileUrl, '_blank')
        return
      }

      // Otherwise download from Supabase Storage path
      const { data, error } = await supabase.storage.from('documents').download(fileUrl)
      if (error) {
        const publicUrl = supabase.storage.from('documents').getPublicUrl(fileUrl).data.publicUrl
        window.open(publicUrl, '_blank')
        return
      }
      
      const url = URL.createObjectURL(data)
      const a = document.createElement('a')
      a.href = url
      a.download = fileName || 'document.pdf'
      a.click()
      URL.revokeObjectURL(url)
    } catch (error: any) {
      console.error('Error downloading file:', error)
      showToast('Error opening file: ' + error.message, 'error')
    }
  }

  // Handle Edit Actions
  const handleOpenEdit = (doc: Document) => {
    setEditingDoc({
      ...doc,
      tags: doc.tags ? [...doc.tags] : []
    })
    setNewTagInput('')
  }

  const handleAddTag = () => {
    if (!newTagInput.trim() || !editingDoc) return
    const cleanTag = newTagInput.trim().toLowerCase()
    const currentTags = editingDoc.tags || []
    if (!currentTags.includes(cleanTag)) {
      setEditingDoc({
        ...editingDoc,
        tags: [...currentTags, cleanTag]
      })
    }
    setNewTagInput('')
  }

  const handleRemoveTag = (tagToRemove: string) => {
    if (!editingDoc) return
    setEditingDoc({
      ...editingDoc,
      tags: (editingDoc.tags || []).filter(t => t !== tagToRemove)
    })
  }

  const handleSaveEdit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!editingDoc) return

    setIsUpdating(true)
    try {
      const { error } = await supabase
        .from('documents')
        .update({
          title: editingDoc.title,
          category: editingDoc.category,
          department: editingDoc.department,
          semester: editingDoc.semester,
          division: editingDoc.division,
          subject_name: editingDoc.subject_name,
          description: editingDoc.description,
          tags: editingDoc.tags,
          file_url: editingDoc.file_url,
          content_summary: editingDoc.description || editingDoc.content_summary
        })
        .eq('id', editingDoc.id)

      if (error) throw error

      setDocuments(prev =>
        prev.map(d => (d.id === editingDoc.id ? { ...editingDoc } : d))
      )
      setEditingDoc(null)
      showToast('Document updated successfully!')
    } catch (error: any) {
      console.error('Error updating document:', error)
      showToast(error.message || 'Failed to update document', 'error')
    } finally {
      setIsUpdating(false)
    }
  }

  // Handle Delete Actions
  const handleConfirmDelete = async () => {
    if (!deletingDoc) return

    setIsDeleting(true)
    try {
      const { error } = await supabase
        .from('documents')
        .delete()
        .eq('id', deletingDoc.id)

      if (error) throw error

      setDocuments(prev => prev.filter(d => d.id !== deletingDoc.id))
      setDeletingDoc(null)
      showToast('Document deleted successfully!')
    } catch (error: any) {
      console.error('Error deleting document:', error)
      showToast(error.message || 'Failed to delete document', 'error')
    } finally {
      setIsDeleting(false)
    }
  }

  const filteredDocs = documents.filter((doc) => {
    const q = search.toLowerCase()
    if (!q) return true
    const title = (doc.title || '').toLowerCase()
    const subject = (doc.subject_name || '').toLowerCase()
    const dept = (doc.department || '').toLowerCase()
    const tags = Array.isArray(doc.tags) ? doc.tags.join(' ').toLowerCase() : ''
    return title.includes(q) || subject.includes(q) || dept.includes(q) || tags.includes(q)
  })

  const columns = [
    { 
      key: 'title', 
      header: 'Title & Search Tags',
      render: (d: Document) => (
        <div className="space-y-1.5 py-1 max-w-md">
          <div className="font-semibold text-text-primary text-sm flex items-center gap-2">
            <FileText size={15} className="text-primary shrink-0" />
            <span className="truncate">{d.title}</span>
          </div>
          {d.tags && d.tags.length > 0 && (
            <div className="flex flex-wrap gap-1 items-center">
              <Tag className="w-3 h-3 text-primary shrink-0" />
              {d.tags.slice(0, 4).map((t, idx) => (
                <span key={idx} className="px-1.5 py-0.5 bg-surface-light border border-card-border rounded text-[10px] text-text-muted">
                  #{t}
                </span>
              ))}
              {d.tags.length > 4 && (
                <span className="text-[10px] text-text-muted">+{d.tags.length - 4} more</span>
              )}
            </div>
          )}
        </div>
      )
    },
    { 
      key: 'category', 
      header: 'Category',
      render: (d: Document) => (
        <span className="px-2.5 py-1 bg-surface-light border border-card-border rounded-full text-xs capitalize text-primary font-medium">
          {d.category.replace('_', ' ')}
        </span>
      )
    },
    { key: 'department', header: 'Department' },
    { key: 'semester', header: 'Semester', render: (d: Document) => `Sem ${d.semester}` },
    { key: 'subject_name', header: 'Subject', render: (d: Document) => d.subject_name || 'General' },
    { 
      key: 'created_at', 
      header: 'Upload Date',
      render: (d: Document) => new Date(d.created_at).toLocaleDateString()
    },
    {
      key: 'actions',
      header: 'Actions',
      render: (d: Document) => (
        <div className="flex items-center gap-1.5">
          {/* Download File */}
          <button
            onClick={() => handleDownload(d.file_url, d.file_name)}
            className="p-2 text-text-secondary hover:text-primary transition-colors bg-surface-light hover:bg-surface border border-card-border rounded-lg"
            title="Download File"
          >
            <Download size={15} />
          </button>

          {/* Edit Document */}
          <button
            onClick={() => handleOpenEdit(d)}
            className="p-2 text-text-secondary hover:text-accent transition-colors bg-surface-light hover:bg-surface border border-card-border rounded-lg"
            title="Edit Document Info & Tags"
          >
            <Edit3 size={15} />
          </button>

          {/* Delete Document */}
          <button
            onClick={() => setDeletingDoc(d)}
            className="p-2 text-text-secondary hover:text-error transition-colors bg-surface-light hover:bg-surface border border-card-border rounded-lg"
            title="Delete Document"
          >
            <Trash2 size={15} />
          </button>
        </div>
      )
    }
  ]

  return (
    <div className="space-y-6">
      {/* Toast Notification */}
      {statusMessage && (
        <div 
          className={`fixed top-5 right-5 z-50 px-4 py-3 rounded-xl shadow-2xl border flex items-center gap-2 text-xs font-bold animate-fade-in ${
            statusMessage.type === 'success'
              ? 'bg-surface border-primary text-primary'
              : 'bg-surface border-error text-error'
          }`}
        >
          {statusMessage.type === 'success' ? <CheckCircle2 size={16} /> : <AlertTriangle size={16} />}
          <span>{statusMessage.text}</span>
        </div>
      )}

      {/* Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-2xl font-bold text-text-primary mb-1">Document Repository</h1>
          <p className="text-text-secondary text-sm">View, search, edit, and manage all academic documents & RAG search tags.</p>
        </div>
        
        <div className="flex flex-col sm:flex-row items-center gap-3 w-full sm:w-auto">
          {/* Search Box */}
          <div className="relative w-full sm:w-64">
            <Search className="w-4 h-4 text-text-muted absolute left-3 top-1/2 -translate-y-1/2" />
            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Search title, tag, subject..."
              className="w-full bg-surface border border-card-border rounded-lg pl-9 pr-4 py-2 text-text-primary text-xs focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary"
            />
          </div>

          <select
            value={category}
            onChange={(e) => setCategory(e.target.value)}
            className="w-full sm:w-auto bg-surface border border-card-border rounded-lg px-4 py-2 text-text-primary text-xs focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary"
          >
            {CATEGORIES.map(c => (
              <option key={c.value} value={c.value}>{c.label}</option>
            ))}
          </select>
        </div>
      </div>

      {/* Data Table */}
      <DataTable
        columns={columns}
        data={filteredDocs}
        isLoading={loading}
        emptyMessage="No documents found matching your filter or search."
      />

      {/* ========================================================= */}
      {/* EDIT DOCUMENT MODAL                                       */}
      {/* ========================================================= */}
      {editingDoc && (
        <div className="fixed inset-0 z-50 bg-background/80 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-surface border border-card-border rounded-2xl w-full max-w-2xl p-6 shadow-2xl space-y-5 animate-fade-in">
            {/* Modal Header */}
            <div className="flex items-center justify-between border-b border-card-border pb-3">
              <div className="flex items-center gap-2">
                <div className="p-2 bg-primary/10 rounded-lg text-primary">
                  <Edit3 size={18} />
                </div>
                <div>
                  <h3 className="text-base font-bold text-white">Edit Academic Document</h3>
                  <p className="text-xs text-text-secondary">Update document title, subject mapping, and RAG search tags</p>
                </div>
              </div>
              <button
                onClick={() => setEditingDoc(null)}
                className="text-text-muted hover:text-white p-1 rounded-lg hover:bg-surface-light transition-colors"
              >
                <X size={18} />
              </button>
            </div>

            {/* Form */}
            <form onSubmit={handleSaveEdit} className="space-y-4 text-xs">
              {/* Document Title */}
              <div>
                <label className="block text-text-secondary font-semibold mb-1">Document Title *</label>
                <input
                  type="text"
                  required
                  value={editingDoc.title}
                  onChange={e => setEditingDoc({ ...editingDoc, title: e.target.value })}
                  className="w-full bg-surface-light border border-card-border rounded-xl px-3.5 py-2.5 text-white focus:outline-none focus:border-primary"
                  placeholder="e.g. AIPD Assignment 1 - Unit 1"
                />
              </div>

              {/* Subject Name & Category */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label className="block text-text-secondary font-semibold mb-1">Subject Name *</label>
                  <input
                    type="text"
                    required
                    value={editingDoc.subject_name}
                    onChange={e => setEditingDoc({ ...editingDoc, subject_name: e.target.value })}
                    className="w-full bg-surface-light border border-card-border rounded-xl px-3.5 py-2.5 text-white focus:outline-none focus:border-primary"
                    placeholder="e.g. Artificial Intelligence and Product Development"
                  />
                </div>

                <div>
                  <label className="block text-text-secondary font-semibold mb-1">Category *</label>
                  <select
                    value={editingDoc.category}
                    onChange={e => setEditingDoc({ ...editingDoc, category: e.target.value })}
                    className="w-full bg-surface-light border border-card-border rounded-xl px-3.5 py-2.5 text-white focus:outline-none focus:border-primary capitalize"
                  >
                    {CATEGORIES.filter(c => c.value !== '').map(c => (
                      <option key={c.value} value={c.value}>{c.label}</option>
                    ))}
                  </select>
                </div>
              </div>

              {/* Department, Semester & Division */}
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                <div>
                  <label className="block text-text-secondary font-semibold mb-1">Department</label>
                  <select
                    value={editingDoc.department}
                    onChange={e => setEditingDoc({ ...editingDoc, department: e.target.value })}
                    className="w-full bg-surface-light border border-card-border rounded-xl px-3.5 py-2.5 text-white focus:outline-none focus:border-primary"
                  >
                    {DEPARTMENTS.map(d => (
                      <option key={d} value={d}>{d}</option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="block text-text-secondary font-semibold mb-1">Semester</label>
                  <select
                    value={editingDoc.semester}
                    onChange={e => setEditingDoc({ ...editingDoc, semester: e.target.value })}
                    className="w-full bg-surface-light border border-card-border rounded-xl px-3.5 py-2.5 text-white focus:outline-none focus:border-primary"
                  >
                    {['1', '2', '3', '4', '5', '6', '7', '8', 'All'].map(s => (
                      <option key={s} value={s}>Semester {s}</option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="block text-text-secondary font-semibold mb-1">Division / Class</label>
                  <select
                    value={editingDoc.division || 'All'}
                    onChange={e => setEditingDoc({ ...editingDoc, division: e.target.value })}
                    className="w-full bg-surface-light border border-card-border rounded-xl px-3.5 py-2.5 text-white focus:outline-none focus:border-primary"
                  >
                    {['A', 'B', 'C', 'D', 'All'].map(div => (
                      <option key={div} value={div}>Division {div}</option>
                    ))}
                  </select>
                </div>
              </div>

              {/* Direct Download URL */}
              <div>
                <label className="block text-text-secondary font-semibold mb-1">Direct Download URL (Cloud / Web Link)</label>
                <input
                  type="text"
                  value={editingDoc.file_url || ''}
                  onChange={e => setEditingDoc({ ...editingDoc, file_url: e.target.value })}
                  className="w-full bg-surface-light border border-card-border rounded-xl px-3.5 py-2.5 text-cyan font-mono text-xs focus:outline-none focus:border-primary"
                  placeholder="https://..."
                />
              </div>

              {/* Description / Summary */}
              <div>
                <label className="block text-text-secondary font-semibold mb-1">Description / Summary</label>
                <textarea
                  rows={2}
                  value={editingDoc.description || ''}
                  onChange={e => setEditingDoc({ ...editingDoc, description: e.target.value })}
                  className="w-full bg-surface-light border border-card-border rounded-xl px-3.5 py-2 text-white focus:outline-none focus:border-primary"
                  placeholder="Summary for AI semantic search..."
                />
              </div>

              {/* Search & Voice Tags */}
              <div>
                <label className="block text-text-secondary font-semibold mb-1.5 flex items-center justify-between">
                  <span className="flex items-center gap-1.5">
                    <Tag size={13} className="text-primary" /> Multi-Lingual Search & Voice Tags ({editingDoc.tags?.length || 0})
                  </span>
                  <span className="text-[10px] text-text-muted">Used by Student AI Chatbot</span>
                </label>

                <div className="flex flex-wrap gap-1.5 mb-2.5 max-h-24 overflow-y-auto p-2 bg-surface-light/40 border border-card-border rounded-xl">
                  {editingDoc.tags && editingDoc.tags.map((tag, i) => (
                    <span
                      key={i}
                      className="px-2 py-0.5 bg-surface-light border border-primary/30 rounded-lg text-primary text-[11px] font-mono flex items-center gap-1"
                    >
                      #{tag}
                      <button
                        type="button"
                        onClick={() => handleRemoveTag(tag)}
                        className="hover:text-error transition-colors p-0.5"
                      >
                        ×
                      </button>
                    </span>
                  ))}
                  {(!editingDoc.tags || editingDoc.tags.length === 0) && (
                    <span className="text-text-muted text-[11px]">No tags yet. Add tags below.</span>
                  )}
                </div>

                <div className="flex gap-2">
                  <input
                    type="text"
                    value={newTagInput}
                    onChange={e => setNewTagInput(e.target.value)}
                    onKeyDown={e => {
                      if (e.key === 'Enter') {
                        e.preventDefault()
                        handleAddTag()
                      }
                    }}
                    placeholder="Type new tag and press Enter (e.g. #aipd, #practical 1, gu: એસાઇનમેન્ટ)..."
                    className="flex-1 bg-surface-light border border-card-border rounded-xl px-3 py-2 text-white text-xs focus:outline-none focus:border-primary"
                  />
                  <button
                    type="button"
                    onClick={handleAddTag}
                    className="px-4 py-2 bg-primary/15 text-primary border border-primary/30 rounded-xl hover:bg-primary/25 transition-colors font-bold flex items-center gap-1 cursor-pointer"
                  >
                    <Plus size={14} /> Add
                  </button>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="flex items-center justify-end gap-3 pt-4 border-t border-card-border">
                <button
                  type="button"
                  onClick={() => setEditingDoc(null)}
                  className="px-4 py-2.5 rounded-xl border border-card-border text-text-secondary hover:text-white transition-colors font-semibold"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={isUpdating}
                  className="px-5 py-2.5 rounded-xl bg-primary text-background font-extrabold text-xs hover:bg-[#c4f85e] transition-all shadow-lg flex items-center gap-1.5 cursor-pointer disabled:opacity-50"
                >
                  {isUpdating ? (
                    <div className="w-4 h-4 border-2 border-background border-t-transparent rounded-full animate-spin" />
                  ) : (
                    <>
                      <Save size={15} /> Save & Update Document
                    </>
                  )}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ========================================================= */}
      {/* DELETE CONFIRMATION MODAL                                 */}
      {/* ========================================================= */}
      {deletingDoc && (
        <div className="fixed inset-0 z-50 bg-background/80 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-surface border border-card-border rounded-2xl w-full max-w-md p-6 shadow-2xl space-y-4 animate-fade-in">
            <div className="flex items-center gap-3 text-error">
              <div className="p-3 bg-error/10 border border-error/20 rounded-xl">
                <Trash2 size={24} />
              </div>
              <div>
                <h3 className="text-base font-bold text-white">Delete Academic Document?</h3>
                <p className="text-xs text-text-secondary">This action cannot be undone.</p>
              </div>
            </div>

            <div className="bg-surface-light p-3 rounded-xl border border-card-border text-xs text-text-primary space-y-1">
              <p className="font-bold text-white">{deletingDoc.title}</p>
              <p className="text-text-secondary">{deletingDoc.department} · Sem {deletingDoc.semester}</p>
              <p className="text-text-muted font-mono text-[11px]">{deletingDoc.file_name}</p>
            </div>

            <p className="text-xs text-text-secondary">
              Students and parents will no longer be able to access, download, or search this document via the AI Copilot.
            </p>

            <div className="flex items-center justify-end gap-3 pt-3 border-t border-card-border">
              <button
                type="button"
                onClick={() => setDeletingDoc(null)}
                disabled={isDeleting}
                className="px-4 py-2.5 rounded-xl border border-card-border text-text-secondary hover:text-white transition-colors text-xs font-semibold"
              >
                Cancel
              </button>
              <button
                type="button"
                onClick={handleConfirmDelete}
                disabled={isDeleting}
                className="px-5 py-2.5 rounded-xl bg-error text-white font-extrabold text-xs hover:bg-red-600 transition-all shadow-lg flex items-center gap-1.5 cursor-pointer disabled:opacity-50"
              >
                {isDeleting ? (
                  <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
                ) : (
                  <>
                    <Trash2 size={15} /> Yes, Delete Document
                  </>
                )}
              </button>
            </div>
          </div>
        </div>
      )}

    </div>
  )
}
