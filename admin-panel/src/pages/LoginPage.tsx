import React, { useState } from 'react'
import { useNavigate, Link } from 'react-router-dom'
import { supabase } from '../config/supabase'
import { ShieldCheck } from 'lucide-react'
import { useAuth } from '../contexts/AuthContext'

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
      // 1. Direct Institution Verification from institutions table
      const { data: instData, error: instError } = await supabase
        .from('institutions')
        .select('*')
        .ilike('admin_email', cleanEmail)
        .eq('admin_password', cleanPassword)
        .maybeSingle()

      if (!instError && instData) {
        // Log in with verified institution credentials
        setInstitutionSession({
          id: instData.id,
          code: instData.code,
          name: instData.name,
          short_name: instData.short_name,
          admin_email: instData.admin_email
        })
        navigate('/ai-copilot')
        return
      }

      // 2. Fallback to Supabase Auth login
      const { error: signInError } = await supabase.auth.signInWithPassword({
        email: cleanEmail,
        password: cleanPassword,
      })

      if (!signInError) {
        navigate('/ai-copilot')
        return
      }

      setError('Invalid institution login credentials. Please check your admin email and password.')
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
          <p className="text-primary text-xs font-bold uppercase tracking-wider">Institution Admin Portal</p>
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
              placeholder="admin@college.ac.in"
            />
          </div>
          
          <div>
            <label className="block text-xs font-semibold text-text-secondary mb-2">
              Admin Password
            </label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full bg-surface-light border border-card-border rounded-xl px-4 py-3 text-text-primary text-sm focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all font-mono"
              required
              placeholder="••••••••"
            />
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full bg-primary hover:bg-primary/90 text-background font-bold py-3 px-4 rounded-xl transition-all disabled:opacity-50 disabled:cursor-not-allowed shadow-lg shadow-primary/20 cursor-pointer text-sm"
          >
            {loading ? 'Verifying Institution...' : 'Sign In to Institution Portal'}
          </button>
        </form>

        <div className="mt-6 pt-5 border-t border-card-border text-center">
          <Link
            to="/super-admin"
            className="text-xs text-text-muted hover:text-primary inline-flex items-center gap-1.5 transition-colors font-medium"
          >
            <ShieldCheck size={14} className="text-primary" />
            Platform Owner? <strong>Go to Super Admin Portal →</strong>
          </Link>
        </div>
      </div>
    </div>
  )
}
