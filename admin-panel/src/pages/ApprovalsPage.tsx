import { useState, useEffect } from 'react'
import { 
  UserCheck, 
  UserX, 
  Clock, 
  CheckCircle2, 
  XCircle, 
  Search, 
  RefreshCw,
  Phone,
  Mail,
  Calendar,
  Layers,
  GraduationCap
} from 'lucide-react'
import { supabase } from '../config/supabase'
import { useAuth } from '../contexts/AuthContext'

interface StudentApprovalRequest {
  id: string
  profile_id?: string
  enrollment_no: string
  full_name: string
  email: string
  mobile: string
  parent_email: string
  parent_mobile: string
  department: string
  semester: string
  division: string
  birthdate?: string
  status: 'pending_approval' | 'approved' | 'rejected'
  institution_id?: string
  created_at: string
}

export default function ApprovalsPage() {
  const { institution } = useAuth()
  const [students, setStudents] = useState<StudentApprovalRequest[]>([])
  const [loading, setLoading] = useState(true)
  const [activeTab, setActiveTab] = useState<'pending_approval' | 'approved' | 'rejected'>('pending_approval')
  const [searchQuery, setSearchQuery] = useState('')
  const [actionProcessingId, setActionProcessingId] = useState<string | null>(null)

  useEffect(() => {
    fetchStudentRequests()
  }, [institution?.id])

  const fetchStudentRequests = async () => {
    setLoading(true)
    try {
      let query = supabase
        .from('students')
        .select('*')
        .order('created_at', { ascending: false })

      if (institution?.id) {
        query = query.eq('institution_id', institution.id)
      }

      const { data, error } = await query

      if (error) throw error
      setStudents(data || [])
    } catch (err: any) {
      console.error('Error fetching student requests:', err)
    } finally {
      setLoading(false)
    }
  }

  const handleUpdateStatus = async (student: StudentApprovalRequest, newStatus: 'approved' | 'rejected') => {
    setActionProcessingId(student.id)
    try {
      // 1. Update Student Table
      const { error: studentErr } = await supabase
        .from('students')
        .update({ status: newStatus })
        .eq('id', student.id)

      if (studentErr) throw studentErr

      // 2. Also update linked parent status if approving
      if (student.parent_email) {
        await supabase
          .from('parents')
          .update({ status: newStatus })
          .eq('email', student.parent_email)
      }

      setStudents(prev =>
        prev.map(s => (s.id === student.id ? { ...s, status: newStatus } : s))
      )
    } catch (err: any) {
      alert(`Failed to update status: ${err.message}`)
    } finally {
      setActionProcessingId(null)
    }
  }

  const pendingCount = students.filter(s => s.status === 'pending_approval' || !s.status).length
  const approvedCount = students.filter(s => s.status === 'approved').length
  const rejectedCount = students.filter(s => s.status === 'rejected').length

  const filtered = students.filter(s => {
    const matchesTab = activeTab === 'pending_approval'
      ? (s.status === 'pending_approval' || !s.status)
      : s.status === activeTab

    if (!matchesTab) return false
    if (!searchQuery.trim()) return true

    const q = searchQuery.toLowerCase()
    return (
      s.full_name?.toLowerCase().includes(q) ||
      s.enrollment_no?.toLowerCase().includes(q) ||
      s.department?.toLowerCase().includes(q) ||
      s.email?.toLowerCase().includes(q) ||
      s.parent_mobile?.includes(q)
    )
  })

  return (
    <div className="space-y-6 max-w-6xl mx-auto">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-4 border-b border-card-border">
        <div>
          <div className="flex items-center gap-2">
            <h1 className="text-2xl font-black text-text-primary tracking-tight">Student Registration Approvals</h1>
            {pendingCount > 0 && (
              <span className="bg-warning/20 text-warning px-2.5 py-0.5 rounded-full text-xs font-black border border-warning/30 animate-pulse">
                {pendingCount} PENDING
              </span>
            )}
          </div>
          <p className="text-xs text-text-secondary mt-1">
            Verify student identity with physical college records before approving portal access.
          </p>
        </div>

        <button
          onClick={fetchStudentRequests}
          className="p-2.5 bg-surface border border-card-border hover:bg-surface-light text-text-secondary rounded-xl transition-colors flex items-center gap-2 text-xs font-semibold"
        >
          <RefreshCw size={15} className={loading ? 'animate-spin' : ''} />
          Refresh Requests
        </button>
      </div>

      {/* Status Filter Tabs */}
      <div className="flex items-center gap-2 border-b border-card-border pb-3">
        <button
          onClick={() => setActiveTab('pending_approval')}
          className={`px-4 py-2 rounded-xl text-xs font-bold transition-all flex items-center gap-2 ${
            activeTab === 'pending_approval'
              ? 'bg-warning/15 text-warning border border-warning/30'
              : 'text-text-secondary hover:bg-surface-light'
          }`}
        >
          <Clock size={15} />
          Pending Approvals ({pendingCount})
        </button>

        <button
          onClick={() => setActiveTab('approved')}
          className={`px-4 py-2 rounded-xl text-xs font-bold transition-all flex items-center gap-2 ${
            activeTab === 'approved'
              ? 'bg-accent/15 text-accent border border-accent/30'
              : 'text-text-secondary hover:bg-surface-light'
          }`}
        >
          <CheckCircle2 size={15} />
          Approved Students ({approvedCount})
        </button>

        <button
          onClick={() => setActiveTab('rejected')}
          className={`px-4 py-2 rounded-xl text-xs font-bold transition-all flex items-center gap-2 ${
            activeTab === 'rejected'
              ? 'bg-error/15 text-error border border-error/30'
              : 'text-text-secondary hover:bg-surface-light'
          }`}
        >
          <XCircle size={15} />
          Declined Requests ({rejectedCount})
        </button>
      </div>

      {/* Search Input */}
      <div className="bg-surface border border-card-border rounded-xl p-3 flex items-center gap-3">
        <Search size={18} className="text-text-muted" />
        <input
          type="text"
          value={searchQuery}
          onChange={e => setSearchQuery(e.target.value)}
          placeholder="Search by student name, enrollment no, department, or mobile..."
          className="bg-transparent text-sm text-text-primary placeholder:text-text-muted focus:outline-none w-full"
        />
      </div>

      {/* Requests Grid / Cards */}
      {loading ? (
        <div className="bg-surface border border-card-border rounded-2xl p-12 text-center text-xs text-text-secondary">
          Loading student verification requests...
        </div>
      ) : filtered.length === 0 ? (
        <div className="bg-surface border border-card-border rounded-2xl p-12 text-center text-xs text-text-secondary">
          No student requests found under <strong>{activeTab.replace('_', ' ').toUpperCase()}</strong>.
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {filtered.map(student => (
            <div
              key={student.id}
              className="bg-surface border border-card-border rounded-2xl p-5 shadow-xl hover:border-primary/40 transition-all space-y-4"
            >
              {/* Header Info */}
              <div className="flex items-start justify-between">
                <div>
                  <div className="flex items-center gap-2">
                    <h3 className="text-base font-bold text-text-primary">{student.full_name}</h3>
                    <span className="font-mono text-xs bg-primary/10 text-primary px-2 py-0.5 rounded-md font-bold border border-primary/20">
                      {student.enrollment_no}
                    </span>
                  </div>
                  <div className="text-xs text-text-secondary mt-1 flex items-center gap-1.5">
                    <GraduationCap size={14} className="text-cyan-accent" />
                    <span>{student.department}</span>
                  </div>
                </div>

                {student.status === 'approved' ? (
                  <span className="text-[11px] font-bold text-accent bg-accent/15 px-2.5 py-1 rounded-full border border-accent/30 flex items-center gap-1">
                    <CheckCircle2 size={12} /> Active
                  </span>
                ) : student.status === 'rejected' ? (
                  <span className="text-[11px] font-bold text-error bg-error/15 px-2.5 py-1 rounded-full border border-error/30 flex items-center gap-1">
                    <XCircle size={12} /> Declined
                  </span>
                ) : (
                  <span className="text-[11px] font-bold text-warning bg-warning/15 px-2.5 py-1 rounded-full border border-warning/30 flex items-center gap-1">
                    <Clock size={12} /> Pending Verification
                  </span>
                )}
              </div>

              {/* Academic & Contact Grid */}
              <div className="grid grid-cols-2 gap-2 text-xs bg-surface-light p-3 rounded-xl border border-card-border">
                <div className="space-y-1.5">
                  <div className="flex items-center gap-1.5 text-text-secondary">
                    <Layers size={13} className="text-primary" />
                    <span>Semester {student.semester} (Div {student.division})</span>
                  </div>
                  <div className="flex items-center gap-1.5 text-text-secondary">
                    <Calendar size={13} className="text-primary" />
                    <span>DOB: {student.birthdate || 'N/A'}</span>
                  </div>
                  <div className="flex items-center gap-1.5 text-text-secondary">
                    <Phone size={13} className="text-primary" />
                    <span>Student: {student.mobile}</span>
                  </div>
                </div>

                <div className="space-y-1.5">
                  <div className="flex items-center gap-1.5 text-text-secondary">
                    <Mail size={13} className="text-cyan-accent" />
                    <span className="truncate">{student.email}</span>
                  </div>
                  <div className="flex items-center gap-1.5 text-text-secondary">
                    <Phone size={13} className="text-cyan-accent" />
                    <span>Parent: {student.parent_mobile}</span>
                  </div>
                  <div className="flex items-center gap-1.5 text-text-secondary">
                    <Mail size={13} className="text-cyan-accent" />
                    <span className="truncate">{student.parent_email}</span>
                  </div>
                </div>
              </div>

              {/* Action Buttons */}
              {student.status === 'pending_approval' || !student.status ? (
                <div className="flex items-center gap-3 pt-2">
                  <button
                    onClick={() => handleUpdateStatus(student, 'approved')}
                    disabled={actionProcessingId === student.id}
                    className="flex-1 bg-primary text-background font-bold text-xs py-2.5 px-4 rounded-xl hover:bg-primary-dark transition-all flex items-center justify-center gap-1.5 shadow-md shadow-primary/20"
                  >
                    <UserCheck size={16} />
                    Approve Student
                  </button>

                  <button
                    onClick={() => handleUpdateStatus(student, 'rejected')}
                    disabled={actionProcessingId === student.id}
                    className="px-4 py-2.5 bg-surface-light hover:bg-error/15 text-text-secondary hover:text-error border border-card-border rounded-xl transition-colors text-xs font-semibold flex items-center gap-1.5"
                  >
                    <UserX size={16} />
                    Decline
                  </button>
                </div>
              ) : student.status === 'approved' ? (
                <div className="flex justify-end pt-1">
                  <button
                    onClick={() => handleUpdateStatus(student, 'rejected')}
                    className="text-[11px] text-text-muted hover:text-error transition-colors"
                  >
                    Revoke / Block Access
                  </button>
                </div>
              ) : (
                <div className="flex justify-end pt-1">
                  <button
                    onClick={() => handleUpdateStatus(student, 'approved')}
                    className="text-[11px] text-text-muted hover:text-accent transition-colors"
                  >
                    Re-Approve Access
                  </button>
                </div>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
