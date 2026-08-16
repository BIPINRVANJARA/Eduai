import { Navigate, Outlet } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'
import Sidebar from './Sidebar'
import { Building2, Filter, ShieldCheck } from 'lucide-react'

export default function Layout() {
  const { session, loading, institution, departments, selectedDepartment, setSelectedDepartment, isDeptAdmin, assignedDepartment } = useAuth()

  if (loading) {
    return <div className="min-h-screen flex items-center justify-center bg-background text-text-primary">Loading...</div>
  }

  if (!session) {
    return <Navigate to="/login" replace />
  }

  return (
    <div className="flex h-screen bg-background text-text-primary overflow-hidden">
      <Sidebar />
      <div className="flex-1 flex flex-col min-w-0 overflow-hidden">
        {/* Top Bar with Department Scope Control */}
        <header className="h-14 border-b border-card-border bg-surface/80 backdrop-blur-md px-8 flex items-center justify-between shrink-0 z-10">
          <div className="flex items-center gap-3">
            <span className="text-xs font-semibold text-text-muted flex items-center gap-1.5">
              <Building2 size={14} className="text-primary" />
              {institution?.name || 'Institution Portal'}
            </span>
          </div>

          {/* Department Filter Selector */}
          <div className="flex items-center gap-2.5">
            <div className="flex items-center gap-2 bg-surface-light border border-card-border px-3 py-1.5 rounded-xl shadow-inner">
              <Filter size={13} className="text-primary shrink-0" />
              <span className="text-[11px] font-semibold text-text-muted">Active Scope:</span>
              
              {isDeptAdmin ? (
                <div className="flex items-center gap-1.5 text-xs font-bold text-cyan-400">
                  <ShieldCheck size={14} />
                  <span>{assignedDepartment || 'Department'}</span>
                </div>
              ) : (
                <select
                  value={selectedDepartment}
                  onChange={(e) => setSelectedDepartment(e.target.value)}
                  className="bg-transparent text-xs font-bold text-text-primary focus:outline-none cursor-pointer pr-2"
                >
                  <option value="all" className="bg-surface text-text-primary">
                    🏛️ All Departments (College-Wide)
                  </option>
                  {departments.map((d) => (
                    <option key={d.id} value={d.name} className="bg-surface text-text-primary">
                      💻 {d.name} ({d.code})
                    </option>
                  ))}
                </select>
              )}
            </div>
          </div>
        </header>

        {/* Main Content Area */}
        <main className="flex-1 overflow-y-auto p-8">
          <Outlet />
        </main>
      </div>
    </div>
  )
}
