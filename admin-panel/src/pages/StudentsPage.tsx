import { useEffect, useState } from 'react'
import { Search } from 'lucide-react'
import DataTable from '../components/DataTable'
import { supabase } from '../config/supabase'
import type { Student } from '../lib/types'
import { useAuth } from '../contexts/AuthContext'

export default function StudentsPage() {
  const { institution } = useAuth()
  const [students, setStudents] = useState<Student[]>([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')

  useEffect(() => {
    async function fetchStudents() {
      try {
        let query = supabase.from('students').select('*').order('created_at', { ascending: false })
        
        if (institution?.id) {
          query = query.eq('institution_id', institution.id)
        }

        if (search) {
          query = query.or(`full_name.ilike.%${search}%,enrollment_no.ilike.%${search}%`)
        }

        const { data, error } = await query
        if (error) throw error
        setStudents(data || [])
      } catch (error) {
        console.error('Error fetching students:', error)
      } finally {
        setLoading(false)
      }
    }

    const timer = setTimeout(() => {
      fetchStudents()
    }, 300)

    return () => clearTimeout(timer)
  }, [search, institution?.id])

  const columns = [
    { key: 'enrollment_no', header: 'Enrollment #' },
    { 
      key: 'full_name', 
      header: 'Name',
      render: (s: Student) => s.full_name || (s.email ? s.email.split('@')[0] : 'Student')
    },
    { key: 'department', header: 'Department' },
    { key: 'semester', header: 'Semester', render: (s: Student) => `Sem ${s.semester || '5'}` },
    { key: 'division', header: 'Division', render: (s: Student) => s.division || 'A' },
    { key: 'email', header: 'Email', render: (s: Student) => s.email || '—' },
    { key: 'mobile', header: 'Mobile', render: (s: Student) => s.mobile || '—' },
    { 
      key: 'overall_attendance', 
      header: 'Attendance %',
      render: (s: Student) => {
        const att = s.overall_attendance ?? 0
        return (
          <span className={`font-bold ${att < 75 ? 'text-error' : 'text-primary'}`}>
            {att}%
          </span>
        )
      }
    }
  ]

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-2xl font-bold text-text-primary mb-1">Students Directory</h1>
          <p className="text-text-secondary text-sm">Manage all registered students.</p>
        </div>
        
        <div className="relative w-full sm:w-64">
          <input
            type="text"
            placeholder="Search name or enrollment..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full bg-surface border border-card-border rounded-lg pl-10 pr-4 py-2 text-text-primary text-sm focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all"
          />
          <Search className="absolute left-3 top-2.5 text-text-secondary" size={18} />
        </div>
      </div>

      <DataTable
        columns={columns}
        data={students}
        isLoading={loading}
        emptyMessage="No students found."
      />
    </div>
  )
}
