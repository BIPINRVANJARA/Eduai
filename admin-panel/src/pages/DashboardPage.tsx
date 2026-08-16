import { useEffect, useState } from 'react'
import { Users, UserSquare2, FileText, Activity } from 'lucide-react'
import StatsCard from '../components/StatsCard'
import { supabase } from '../config/supabase'
import type { Document } from '../lib/types'
import DataTable from '../components/DataTable'
import { useAuth } from '../contexts/AuthContext'

export default function DashboardPage() {
  const { institution, selectedDepartment, isDeptAdmin, assignedDepartment } = useAuth()
  const [stats, setStats] = useState({
    students: 0,
    parents: 0,
    documents: 0,
    activeSessions: 0
  })
  const [recentDocs, setRecentDocs] = useState<Document[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    async function fetchDashboardData() {
      try {
        setLoading(true)
        const instId = institution?.id
        let studentsQ = supabase.from('students').select('*', { count: 'exact', head: true })
        let docsCountQ = supabase.from('documents').select('*', { count: 'exact', head: true })
        let docsListQ = supabase.from('documents').select('*').order('created_at', { ascending: false }).limit(8)

        if (instId) {
          studentsQ = studentsQ.eq('institution_id', instId)
          docsCountQ = docsCountQ.eq('institution_id', instId)
          docsListQ = docsListQ.eq('institution_id', instId)
        }

        if (selectedDepartment && selectedDepartment !== 'all') {
          studentsQ = studentsQ.eq('department', selectedDepartment)
          docsCountQ = docsCountQ.or(`department.eq.${selectedDepartment},department.eq.General,department.eq.All`)
          docsListQ = docsListQ.or(`department.eq.${selectedDepartment},department.eq.General,department.eq.All`)
        }

        const [
          { count: studentsCount },
          { count: docsCount },
          { data: docs }
        ] = await Promise.all([
          studentsQ,
          docsCountQ,
          docsListQ
        ])

        setStats({
          students: studentsCount || 0,
          parents: studentsCount || 0,
          documents: docsCount || 0,
          activeSessions: 1
        })
        
        setRecentDocs(docs || [])
      } catch (error) {
        console.error('Error fetching dashboard data:', error)
      } finally {
        setLoading(false)
      }
    }

    fetchDashboardData()
  }, [institution?.id, selectedDepartment])

  const docColumns = [
    { key: 'title', header: 'Title' },
    { key: 'category', header: 'Category' },
    { key: 'department', header: 'Department' },
    { 
      key: 'created_at', 
      header: 'Upload Date',
      render: (doc: Document) => new Date(doc.created_at).toLocaleDateString()
    }
  ]

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-2xl font-bold text-text-primary mb-1">
          {isDeptAdmin && assignedDepartment 
            ? `${assignedDepartment} Department Dashboard` 
            : selectedDepartment !== 'all'
              ? `${selectedDepartment} Overview`
              : 'College-Wide Dashboard Overview'}
        </h1>
        <p className="text-text-secondary text-xs">
          {isDeptAdmin && assignedDepartment
            ? `Viewing academic records, student roster, and syllabus repository strictly for ${assignedDepartment}.`
            : selectedDepartment !== 'all'
              ? `Filtered view for ${selectedDepartment}. Switch Active Scope in the top bar to view other branches or College-Wide.`
              : 'Comprehensive overview across all academic departments and students.'}
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatsCard
          title="Total Students"
          value={loading ? '-' : stats.students}
          icon={<Users size={24} />}
        />
        <StatsCard
          title="Total Parents"
          value={loading ? '-' : stats.parents}
          icon={<UserSquare2 size={24} />}
        />
        <StatsCard
          title="Documents"
          value={loading ? '-' : stats.documents}
          icon={<FileText size={24} />}
        />
        <StatsCard
          title="Active Sessions"
          value={loading ? '-' : stats.activeSessions}
          icon={<Activity size={24} />}
          trend="Live"
        />
      </div>

      <div className="bg-surface rounded-xl border border-card-border shadow-sm p-6">
        <div className="flex justify-between items-center mb-6">
          <h2 className="text-lg font-bold text-text-primary">Recent Documents</h2>
        </div>
        <DataTable
          columns={docColumns}
          data={recentDocs}
          isLoading={loading}
          emptyMessage="No documents uploaded yet."
        />
      </div>
    </div>
  )
}
