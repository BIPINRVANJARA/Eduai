import React, { useState } from 'react'
import { useNavigate, Link } from 'react-router-dom'
import { supabase } from '../config/supabase'
import { ShieldCheck, Building2, Layers } from 'lucide-react'
import { useAuth, type InstitutionSession } from '../contexts/AuthContext'

export default function LoginPage() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const navigate = useNavigate()
  const { setInstitutionSession } = useAuth()

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError('')

    const cleanEmail = email.trim()
    const cleanPassword = password.trim()

    try {
      // 1. Direct Institution Verification from institutions table (Institute Admin)
      const { data: instData, error: instError } = await supabase
        .from('institutions')
        .select('*')
        .ilike('admin_email', cleanEmail)
        .eq('admin_password', cleanPassword)
        .maybeSingle()

      if (!instError && instData) {
        // Log in as Full Institute Admin
        setInstitutionSession({
          id: instData.id,
          code: instData.code,
          name: instData.name,
          short_name: instData.short_name,
          admin_email: instData.admin_email
        }, 'institute_admin')
        navigate('/ai-copilot')
        return
      }

      // 2. Department Admin Verification from Local Credential Store
      try {
        const deptAdmins: any[] = JSON.parse(localStorage.getItem('eduai_dept_admins') || '[]')
        const matchedDeptAdmin = deptAdmins.find(
          (a) => a.email.toLowerCase() === cleanEmail.toLowerCase() && a.password === cleanPassword
        )
        if (matchedDeptAdmin) {
          const instObj: InstitutionSession = {
            id: matchedDeptAdmin.institution_id || '6c6e9b83-cabf-4b13-855b-97d2e1461177',
            code: '624',
            name: 'Government Polytechnic Himmatnagar',
            short_name: 'GPH',
            admin_email: cleanEmail
          }
          setInstitutionSession(instObj, 'dept_admin', matchedDeptAdmin.department)
          navigate('/ai-copilot')
          return
        }
      } catch (_) {}

      // 3. Department Admin Verification from Supabase departments table
      try {
        const { data: deptData } = await supabase
          .from('departments')
          .select('*')
          .ilike('hod_email', cleanEmail)
          .eq('admin_password', cleanPassword)
          .maybeSingle()

        if (deptData) {
          const instObj: InstitutionSession = {
            id: deptData.institution_id || '6c6e9b83-cabf-4b13-855b-97d2e1461177',
            code: '624',
            name: 'Government Polytechnic Himmatnagar',
            short_name: 'GPH',
            admin_email: cleanEmail
          }
          setInstitutionSession(instObj, 'dept_admin', deptData.name)
          navigate('/ai-copilot')
          return
        }
      } catch (_) {}

      // 4. Supabase Auth Verification (supports both Institute Admin and Department Admin)
      const { data: authData, error: signInError } = await supabase.auth.signInWithPassword({
        email: cleanEmail,
        password: cleanPassword,
      })

      if (!signInError && authData?.user) {
        const userMeta = authData.user.user_metadata || {}
        const isDeptAdmin = Boolean(userMeta.is_dept_admin || userMeta.department)
        const assignedDept = userMeta.department || null
        const instId = userMeta.institution_id || '6c6e9b83-cabf-4b13-855b-97d2e1461177'

        // Fetch institution details
        const { data: matchedInst } = await supabase
          .from('institutions')
          .select('*')
          .eq('id', instId)
          .maybeSingle()

        const instObj: InstitutionSession = matchedInst ? {
          id: matchedInst.id,
          code: matchedInst.code,
          name: matchedInst.name,
          short_name: matchedInst.short_name,
          admin_email: matchedInst.admin_email
        } : {
          id: instId,
          code: '624',
          name: 'Government Polytechnic Himmatnagar',
          short_name: 'GPH',
          admin_email: cleanEmail
        }

        if (isDeptAdmin && assignedDept) {
          // Department Admin Mode
          setInstitutionSession(instObj, 'dept_admin', assignedDept)
        } else {
          // Institute Admin Mode
          setInstitutionSession(instObj, 'institute_admin')
        }

        navigate('/ai-copilot')
        return
      }

      setError('Invalid login credentials. Please check your admin/HOD email and password.')
    } catch (err: any) {
      setError(`Login failed: ${err.message || 'Server error'}`)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-background p-4 text-text-primary">
      <div className="w-full max-w-md bg-surface p-8 rounded-3xl border border-card-border shadow-2xl">
        <div className="text-center mb-8">
          <div className="flex justify-center mb-4">
            <img 
              src="/app_icon.png" 
              alt="Eduai" 
              className="w-16 h-16 rounded-2xl border border-primary/40 shadow-lg object-cover"
            />
          </div>
          <h1 className="text-3xl font-extrabold text-text-primary tracking-tight mb-1">Eduai</h1>
          <p className="text-primary text-xs font-bold uppercase tracking-wider">
            Unified Academic Admin Portal
          </p>
          <span className="text-[11px] text-text-muted mt-1 block">
            Single login for Institute Admins & Department Coordinators
          </span>
        </div>

        {/* Unified Role Badges */}
        <div className="grid grid-cols-2 gap-2 mb-6 bg-surface-light p-1.5 rounded-2xl border border-card-border">
          <div className="flex items-center justify-center gap-1.5 py-1.5 text-[11px] font-semibold text-primary">
            <Building2 size={13} />
            <span>Institute Admin</span>
          </div>
          <div className="flex items-center justify-center gap-1.5 py-1.5 text-[11px] font-semibold text-cyan-400">
            <Layers size={13} />
            <span>Department Admin</span>
          </div>
        </div>

        {error && (
          <div className="mb-6 p-4 bg-error/10 border border-error/20 rounded-xl text-error text-xs font-medium">
            {error}
          </div>
        )}

        <form onSubmit={handleLogin} className="space-y-5">
          <div>
            <label className="block text-xs font-semibold text-text-secondary mb-2">
              Email Address / Admin ID
            </label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full bg-surface-light border border-card-border rounded-xl px-4 py-3 text-text-primary text-sm focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all font-mono"
              required
              placeholder="admin@college.ac.in or hod.it@gph.edu.in"
            />
          </div>
          
          <div>
            <div className="flex justify-between items-center mb-2">
              <label className="text-xs font-semibold text-text-secondary">
                Password
              </label>
              <a 
                href="#forgot" 
                onClick={(e) => { e.preventDefault(); alert("Please contact your College Administrator or Super Admin to reset credentials."); }}
                className="text-xs text-primary hover:underline"
              >
                Forgot password?
              </a>
            </div>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full bg-surface-light border border-card-border rounded-xl px-4 py-3 text-text-primary text-sm focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all"
              required
              placeholder="••••••••"
            />
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full bg-primary hover:bg-primary/90 text-background font-bold py-3.5 px-4 rounded-xl transition-all shadow-lg shadow-primary/20 flex items-center justify-center gap-2 text-sm disabled:opacity-50 disabled:cursor-not-allowed mt-2 cursor-pointer"
          >
            <ShieldCheck size={18} />
            {loading ? 'Verifying Credentials...' : 'Sign In to Admin Portal'}
          </button>
        </form>

        <div className="mt-8 pt-6 border-t border-card-border flex items-center justify-between text-xs text-text-muted">
          <Link to="/" className="hover:text-text-primary transition-colors">
            ← Back to Home
          </Link>
          <Link to="/super-admin" className="text-primary hover:underline font-medium">
            Super Admin Portal →
          </Link>
        </div>
      </div>
    </div>
  )
}
