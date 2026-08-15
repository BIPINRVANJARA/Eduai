import { useEffect, useState } from 'react'
import { Download, Search, Tag } from 'lucide-react'
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

export default function DocumentsPage() {
  const { institution } = useAuth()
  const [documents, setDocuments] = useState<Document[]>([])
  const [loading, setLoading] = useState(true)
  const [category, setCategory] = useState('')
  const [search, setSearch] = useState('')

  useEffect(() => {
    async function fetchDocuments() {
      try {
        setLoading(true)
        let query = supabase.from('documents').select('*').order('created_at', { ascending: false })
        
        if (institution?.id) {
          query = query.eq('institution_id', institution.id)
        }

        if (category) {
          query = query.eq('category', category)
        }

        const { data, error } = await query
        if (error) throw error
        setDocuments(data || [])
      } catch (error) {
        console.error('Error fetching documents:', error)
      } finally {
        setLoading(false)
      }
    }

    fetchDocuments()
  }, [category, institution?.id])

  const handleDownload = async (fileUrl: string, fileName: string) => {
    try {
      const { data, error } = await supabase.storage.from('documents').download(fileUrl)
      if (error) {
        // Fallback to direct public URL
        const publicUrl = supabase.storage.from('documents').getPublicUrl(fileUrl).data.publicUrl
        window.open(publicUrl, '_blank')
        return
      }
      
      const url = URL.createObjectURL(data)
      const a = document.createElement('a')
      a.href = url
      a.download = fileName
      a.click()
      URL.revokeObjectURL(url)
    } catch (error) {
      console.error('Error downloading file:', error)
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
        <div className="space-y-1.5 py-1">
          <div className="font-semibold text-text-primary text-sm">{d.title}</div>
          {d.tags && d.tags.length > 0 && (
            <div className="flex flex-wrap gap-1 items-center">
              <Tag className="w-3 h-3 text-primary shrink-0" />
              {d.tags.slice(0, 4).map((t, idx) => (
                <span key={idx} className="px-1.5 py-0.5 bg-surface-light border border-card-border rounded text-[10px] text-text-muted">
                  {t}
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
      header: 'File',
      render: (d: Document) => (
        <button
          onClick={() => handleDownload(d.file_url, d.file_name)}
          className="p-2 text-text-secondary hover:text-primary transition-colors bg-surface-light hover:bg-surface border border-card-border rounded-lg"
          title="Download File"
        >
          <Download size={16} />
        </button>
      )
    }
  ]

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-2xl font-bold text-text-primary mb-1">Document Repository</h1>
          <p className="text-text-secondary text-sm">View, search, and manage all academic documents & RAG search tags.</p>
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

      <DataTable
        columns={columns}
        data={filteredDocs}
        isLoading={loading}
        emptyMessage="No documents found matching your filter or search."
      />
    </div>
  )
}
