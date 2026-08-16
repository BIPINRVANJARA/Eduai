import { createContext, useContext, useEffect, useState } from 'react'
import type { Session, User } from '@supabase/supabase-js'
import { supabase } from '../config/supabase'
import type { Department } from '../lib/types'

export interface InstitutionSession {
  id: string
  code: string
  name: string
  short_name: string
  admin_email: string
  city?: string
  state?: string
  address?: string
  contact_email?: string
}

export type AdminRole = 'institute_admin' | 'dept_admin' | 'super_admin'

interface AuthContextType {
  session: Session | { user: { id: string; email: string; user_metadata: any } } | null
  user: User | { id: string; email: string; user_metadata: any } | null
  institution: InstitutionSession | null
  departments: Department[]
  selectedDepartment: string // 'all' or department name like 'Information Technology'
  adminRole: AdminRole
  isDeptAdmin: boolean
  assignedDepartment: string | null
  loading: boolean
  setSelectedDepartment: (dept: string) => void
  refreshDepartments: () => Promise<void>
  saveDepartmentUpdate: (updatedDept: Department) => void
  setInstitutionSession: (inst: InstitutionSession, role?: AdminRole, dept?: string) => void
  switchToDepartmentAdmin: (deptName: string, email?: string) => void
  switchToInstituteAdmin: () => void
  signOut: () => Promise<void>
}

const DEFAULT_DEPARTMENTS: Department[] = [
  { id: '1', institution_id: '6c6e9b83-cabf-4b13-855b-97d2e1461177', name: 'Information Technology', code: 'IT', hod_name: 'Prof. H. R. Patel', hod_email: 'hod.it@gph.edu.in', hod_mobile: '9876543210', status: 'active', created_at: new Date().toISOString() },
  { id: '2', institution_id: '6c6e9b83-cabf-4b13-855b-97d2e1461177', name: 'Computer Engineering', code: 'CE', hod_name: 'Prof. S. M. Shah', hod_email: 'hod.ce@gph.edu.in', hod_mobile: '9876543211', status: 'active', created_at: new Date().toISOString() },
  { id: '3', institution_id: '6c6e9b83-cabf-4b13-855b-97d2e1461177', name: 'Electronics & Communication', code: 'EC', hod_name: 'Prof. V. K. Joshi', hod_email: 'hod.ec@gph.edu.in', hod_mobile: '9876543212', status: 'active', created_at: new Date().toISOString() },
  { id: '4', institution_id: '6c6e9b83-cabf-4b13-855b-97d2e1461177', name: 'Mechanical Engineering', code: 'ME', hod_name: 'Prof. P. B. Dave', hod_email: 'hod.me@gph.edu.in', hod_mobile: '9876543213', status: 'active', created_at: new Date().toISOString() },
  { id: '5', institution_id: '6c6e9b83-cabf-4b13-855b-97d2e1461177', name: 'Civil Engineering', code: 'CL', hod_name: 'Prof. R. N. Mehta', hod_email: 'hod.cl@gph.edu.in', hod_mobile: '9876543214', status: 'active', created_at: new Date().toISOString() },
  { id: '6', institution_id: '6c6e9b83-cabf-4b13-855b-97d2e1461177', name: 'General / Applied Sciences', code: 'GEN', hod_name: 'Dr. A. K. Trivedi', hod_email: 'hod.gen@gph.edu.in', hod_mobile: '9876543215', status: 'active', created_at: new Date().toISOString() },
]

const AuthContext = createContext<AuthContextType>({
  session: null,
  user: null,
  institution: null,
  departments: [],
  selectedDepartment: 'all',
  adminRole: 'institute_admin',
  isDeptAdmin: false,
  assignedDepartment: null,
  loading: true,
  setSelectedDepartment: () => {},
  refreshDepartments: async () => {},
  saveDepartmentUpdate: () => {},
  setInstitutionSession: () => {},
  switchToDepartmentAdmin: () => {},
  switchToInstituteAdmin: () => {},
  signOut: async () => {},
})

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [session, setSession] = useState<any | null>(null)
  const [user, setUser] = useState<any | null>(null)
  const [institution, setInstitution] = useState<InstitutionSession | null>(null)
  const [departments, setDepartments] = useState<Department[]>(DEFAULT_DEPARTMENTS)
  const [selectedDepartment, setSelectedDepartment] = useState<string>('all')
  const [adminRole, setAdminRole] = useState<AdminRole>('institute_admin')
  const [assignedDepartment, setAssignedDepartment] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)

  const isDeptAdmin = adminRole === 'dept_admin' || Boolean(assignedDepartment)

  const fetchDepartments = async (instId: string) => {
    try {
      // 1. Check local cache first for custom configured departments & HOD emails
      const cached = localStorage.getItem('eduai_departments_cache')
      let initialList = DEFAULT_DEPARTMENTS
      if (cached) {
        try {
          const parsed = JSON.parse(cached)
          if (Array.isArray(parsed) && parsed.length > 0) {
            initialList = parsed
          }
        } catch (_) {}
      }

      const { data, error } = await supabase
        .from('departments')
        .select('*')
        .eq('institution_id', instId)
        .order('name', { ascending: true })

      if (!error && data && data.length > 0) {
        setDepartments(data)
        localStorage.setItem('eduai_departments_cache', JSON.stringify(data))
      } else {
        setDepartments(initialList)
      }
    } catch {
      const cached = localStorage.getItem('eduai_departments_cache')
      if (cached) {
        try {
          setDepartments(JSON.parse(cached))
          return
        } catch (_) {}
      }
      setDepartments(DEFAULT_DEPARTMENTS)
    }
  }

  const saveDepartmentUpdate = (updatedDept: Department) => {
    setDepartments(prev => {
      const next = prev.map(d => d.id === updatedDept.id ? updatedDept : d)
      localStorage.setItem('eduai_departments_cache', JSON.stringify(next))
      return next
    })
  }

  const refreshDepartments = async () => {
    const instId = institution?.id || '6c6e9b83-cabf-4b13-855b-97d2e1461177'
    await fetchDepartments(instId)
  }

  const syncInstitutionFromEmail = async (email: string) => {
    try {
      const { data } = await supabase
        .from('institutions')
        .select('*')
        .ilike('admin_email', email)
        .maybeSingle()

      if (data) {
        const instObj: InstitutionSession = {
          id: data.id,
          code: data.code,
          name: data.name,
          short_name: data.short_name,
          admin_email: data.admin_email,
          city: data.city,
          state: data.state,
          address: data.address,
          contact_email: data.contact_email,
        }
        setInstitution(instObj)
        sessionStorage.setItem('eduai_inst_session', JSON.stringify(instObj))
        await fetchDepartments(data.id)
      }
    } catch (err) {
      console.error('Error syncing institution:', err)
    }
  }

  useEffect(() => {
    // 1. Check if an institution session is active in storage
    const storedInst = sessionStorage.getItem('eduai_inst_session')
    const storedRole = sessionStorage.getItem('eduai_admin_role') as AdminRole || 'institute_admin'
    const storedDept = sessionStorage.getItem('eduai_assigned_dept')

    if (storedRole) setAdminRole(storedRole)
    if (storedDept) {
      setAssignedDepartment(storedDept)
      setSelectedDepartment(storedDept)
    }

    if (storedInst) {
      try {
        const parsed: InstitutionSession = JSON.parse(storedInst)
        setInstitution(parsed)
        fetchDepartments(parsed.id)
        const mockUser = {
          id: parsed.id || 'admin',
          email: parsed.admin_email,
          user_metadata: {
            role: storedRole || 'admin',
            department: storedDept,
            institution_id: parsed.id,
            institution_code: parsed.code,
            full_name: storedDept ? `${storedDept} HOD / Admin` : `${parsed.short_name || parsed.name} Administrator`
          }
        }
        setUser(mockUser)
        setSession({ user: mockUser })
        setLoading(false)
        return
      } catch (_) {}
    }

    // 2. Otherwise check Supabase Auth Session
    supabase.auth.getSession().then(async ({ data: { session } }) => {
      if (session?.user) {
        setSession(session)
        setUser(session.user)
        const isDept = session.user.user_metadata?.is_dept_admin || session.user.user_metadata?.role === 'dept_admin'
        const uRole: AdminRole = isDept ? 'dept_admin' : ((session.user.user_metadata?.role as AdminRole) || 'institute_admin')
        const uDept = session.user.user_metadata?.department || null
        setAdminRole(uRole)
        if (uDept) {
          setAssignedDepartment(uDept)
          setSelectedDepartment(uDept)
        }
        if (session.user.email) {
          await syncInstitutionFromEmail(session.user.email)
        }
      }
      setLoading(false)
    })

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange(async (_event, session) => {
      if (session?.user) {
        setSession(session)
        setUser(session.user)
        const isDept = session.user.user_metadata?.is_dept_admin || session.user.user_metadata?.role === 'dept_admin'
        const uRole: AdminRole = isDept ? 'dept_admin' : ((session.user.user_metadata?.role as AdminRole) || 'institute_admin')
        const uDept = session.user.user_metadata?.department || null
        setAdminRole(uRole)
        if (uDept) {
          setAssignedDepartment(uDept)
          setSelectedDepartment(uDept)
        }
        if (session.user.email) {
          await syncInstitutionFromEmail(session.user.email)
        }
      }
      setLoading(false)
    })

    return () => subscription.unsubscribe()
  }, [])

  const setInstitutionSession = (inst: InstitutionSession, role: AdminRole = 'institute_admin', dept?: string) => {
    sessionStorage.setItem('eduai_inst_session', JSON.stringify(inst))
    sessionStorage.setItem('eduai_admin_role', role)
    if (dept) {
      sessionStorage.setItem('eduai_assigned_dept', dept)
      setAssignedDepartment(dept)
      setSelectedDepartment(dept)
    } else {
      sessionStorage.removeItem('eduai_assigned_dept')
      setAssignedDepartment(null)
      setSelectedDepartment('all')
    }

    setAdminRole(role)
    setInstitution(inst)
    fetchDepartments(inst.id)

    const mockUser = {
      id: inst.id || 'admin',
      email: inst.admin_email,
      user_metadata: {
        role: role,
        department: dept,
        institution_id: inst.id,
        institution_code: inst.code,
        full_name: dept ? `${dept} HOD / Admin` : `${inst.short_name || inst.name} Administrator`
      }
    }
    setUser(mockUser)
    setSession({ user: mockUser })
  }

  const switchToDepartmentAdmin = (deptName: string, email?: string) => {
    if (!institution) return
    const instObj = { ...institution }
    if (email) instObj.admin_email = email
    setInstitutionSession(instObj, 'dept_admin', deptName)
  }

  const switchToInstituteAdmin = () => {
    if (!institution) return
    setInstitutionSession(institution, 'institute_admin')
  }

  const signOut = async () => {
    sessionStorage.removeItem('eduai_inst_session')
    sessionStorage.removeItem('eduai_admin_role')
    sessionStorage.removeItem('eduai_assigned_dept')
    setInstitution(null)
    setSession(null)
    setUser(null)
    setAdminRole('institute_admin')
    setAssignedDepartment(null)
    setSelectedDepartment('all')
    await supabase.auth.signOut().catch(() => {})
  }

  return (
    <AuthContext.Provider value={{
      session,
      user,
      institution,
      departments,
      selectedDepartment,
      adminRole,
      isDeptAdmin,
      assignedDepartment,
      loading,
      setSelectedDepartment,
      refreshDepartments,
      saveDepartmentUpdate,
      setInstitutionSession,
      switchToDepartmentAdmin,
      switchToInstituteAdmin,
      signOut
    }}>
      {children}
    </AuthContext.Provider>
  )
}

export const useAuth = () => {
  return useContext(AuthContext)
}
