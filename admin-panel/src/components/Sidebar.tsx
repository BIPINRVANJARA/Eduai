import { Link, useLocation } from 'react-router-dom'
import { 
  LayoutDashboard, 
  Bot, 
  UserCheck, 
  Users, 
  FileSpreadsheet, 
  FileText, 
  Upload, 
  Bell, 
  Building2,
  Settings, 
  LogOut,
  ShieldAlert
} from 'lucide-react'
import { useAuth } from '../contexts/AuthContext'

export default function Sidebar() {
  const location = useLocation()
  const { signOut, institution, assignedDepartment, isDeptAdmin } = useAuth()

  const navItems = [
    { icon: Bot, label: 'AI Command Center', path: '/ai-copilot', highlight: true },
    { icon: Building2, label: 'Department Manager', path: '/departments', badge: 'Admin', hiddenForDeptAdmin: true },
    { icon: UserCheck, label: 'Student Approvals', path: '/approvals', badge: 'New' },
    { icon: FileSpreadsheet, label: 'Attendance & Marks', path: '/attendance-marks' },
    { icon: LayoutDashboard, label: 'Dashboard', path: '/dashboard' },
    { icon: Users, label: 'Enrolled Students', path: '/students' },
    { icon: FileText, label: 'Documents Repository', path: '/documents' },
    { icon: Upload, label: 'Manual Upload', path: '/upload' },
    { icon: Bell, label: 'Campus Alerts', path: '/alerts' },
    { icon: Settings, label: 'Settings', path: '/settings' },
  ]

  const visibleNavItems = navItems.filter(item => !(item.hiddenForDeptAdmin && isDeptAdmin))

  return (
    <div className="w-64 bg-surface border-r border-card-border flex flex-col h-full">
      <div className="p-6 pb-4 border-b border-card-border/60">
        <div className="flex items-center gap-3">
          <img 
            src="/app_icon.png" 
            alt="Eduai Logo" 
            className="w-9 h-9 rounded-xl border border-primary/30 object-cover shadow-sm"
          />
          <div className="min-w-0 flex-1">
            <h1 className="text-xl font-extrabold text-text-primary tracking-tight">Eduai</h1>
            <span className="text-[10px] text-primary uppercase font-bold tracking-wider block truncate">
              {institution?.short_name || institution?.name || 'Institution Admin'}
            </span>
          </div>
        </div>

        {/* Role & Scope Badge */}
        <div className="mt-3 bg-surface-light p-2 rounded-xl border border-card-border/80 text-[11px] space-y-1">
          <div className="flex items-center justify-between">
            <span className="text-text-muted font-medium">Role:</span>
            <span className={`text-[10px] font-bold px-2 py-0.5 rounded ${
              isDeptAdmin 
                ? 'bg-cyan-500/15 text-cyan-400 border border-cyan-500/30' 
                : 'bg-primary/15 text-primary border border-primary/30'
            }`}>
              {isDeptAdmin ? 'Dept Admin' : 'Institute Admin'}
            </span>
          </div>
          {isDeptAdmin && assignedDepartment && (
            <div className="flex items-center gap-1.5 text-text-primary font-semibold text-[10px] pt-1 border-t border-card-border/50 truncate">
              <ShieldAlert size={12} className="text-cyan-400 shrink-0" />
              <span className="truncate">{assignedDepartment}</span>
            </div>
          )}
        </div>
      </div>
      
      <nav className="flex-1 px-4 space-y-1.5 mt-2 overflow-y-auto">
        {visibleNavItems.map((item) => {
          const isActive = location.pathname === item.path
          return (
            <Link
              key={item.path}
              to={item.path}
              className={`flex items-center gap-3 px-3.5 py-2.5 rounded-xl transition-all ${
                item.highlight && !isActive
                  ? 'bg-primary/10 border border-primary/30 text-primary hover:bg-primary/15'
                  : isActive 
                    ? 'bg-primary text-background font-bold shadow-md shadow-primary/20' 
                    : 'text-text-secondary hover:bg-surface-light hover:text-text-primary'
              }`}
            >
              <item.icon size={18} className={isActive ? 'text-background' : item.highlight ? 'text-primary' : 'text-text-secondary'} />
              <span className="font-semibold text-xs">{item.label}</span>
              {item.badge && !isActive && (
                <span className="ml-auto text-[9px] bg-warning/20 text-warning px-1.5 py-0.5 rounded-full font-bold uppercase border border-warning/30">
                  {item.badge}
                </span>
              )}
              {item.highlight && !isActive && (
                <span className="ml-auto text-[9px] bg-primary text-background px-1.5 py-0.5 rounded-full font-bold uppercase">
                  Universal
                </span>
              )}
            </Link>
          )
        })}
      </nav>

      <div className="p-4 border-t border-card-border">
        <button
          onClick={signOut}
          className="flex items-center gap-3 px-4 py-3 w-full rounded-xl text-text-secondary hover:bg-surface-light hover:text-error transition-colors text-xs font-semibold"
        >
          <LogOut size={18} />
          <span>Logout</span>
        </button>
      </div>
    </div>
  )
}
