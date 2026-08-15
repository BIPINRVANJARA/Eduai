import React, { useState, useEffect } from 'react'
import { 
  Building2, 
  Plus, 
  Key, 
  Copy, 
  Check, 
  Trash2, 
  Edit, 
  ShieldCheck, 
  Search, 
  RefreshCw,
  Eye,
  EyeOff,
  Lock,
  ArrowLeft,
  ExternalLink,
  Sparkles
} from 'lucide-react'
import { supabase } from '../config/supabase'
import { Link } from 'react-router-dom'

interface Institution {
  id: string
  code: string
  name: string
  short_name: string
  admin_email: string
  admin_password?: string
  city: string
  state: string
  admissions_open?: boolean
  student_count?: number
  created_at: string
}

export default function SuperAdminPage() {
  // Platform Owner Gate
  const [isAuthenticated, setIsAuthenticated] = useState(false)
  const [passphrase, setPassphrase] = useState('')
  const [authError, setAuthError] = useState('')

  const [institutions, setInstitutions] = useState<Institution[]>([])
  const [loading, setLoading] = useState(true)
  const [searchQuery, setSearchQuery] = useState('')
  const [showAddModal, setShowAddModal] = useState(false)
  const [editingInst, setEditingInst] = useState<Institution | null>(null)
  const [copiedId, setCopiedId] = useState<string | null>(null)
  const [showPasswordMap, setShowPasswordMap] = useState<{ [key: string]: boolean }>({})

  // Success Modal State with Credentials Package
  const [createdCredentials, setCreatedCredentials] = useState<{
    name: string
    code: string
    adminEmail: string
    adminPassword: string
    loginUrl: string
  } | null>(null)

  // Form State
  const [name, setName] = useState('')
  const [shortName, setShortName] = useState('')
  const [code, setCode] = useState('')
  const [city, setCity] = useState('')
  const [stateName, setStateName] = useState('Gujarat')
  const [adminEmail, setAdminEmail] = useState('')
  const [adminPassword, setAdminPassword] = useState('')
  const [formSubmitting, setFormSubmitting] = useState(false)

  useEffect(() => {
    // Check if session storage has super admin flag
    const storedAuth = sessionStorage.getItem('eduai_super_admin_auth')
    if (storedAuth === 'true') {
      setIsAuthenticated(true)
      fetchInstitutions()
    }
  }, [])

  const handleGateLogin = (e: React.FormEvent) => {
    e.preventDefault()
    // Super Admin Passcode / PIN
    if (passphrase === 'Kunjal9016@') {
      setIsAuthenticated(true)
      sessionStorage.setItem('eduai_super_admin_auth', 'true')
      setAuthError('')
      fetchInstitutions()
    } else {
      setAuthError('Invalid Platform Owner Passphrase. Please try again.')
    }
  }

  const fetchInstitutions = async () => {
    setLoading(true)
    try {
      const { data, error } = await supabase
        .from('institutions')
        .select('*')
        .order('created_at', { ascending: false })

      if (error) throw error
      setInstitutions(data || [])
    } catch (err: any) {
      console.error('Error fetching institutions:', err)
    } finally {
      setLoading(false)
    }
  }

  const generateAutoCredentials = () => {
    const cleanShort = (shortName || name || 'college').toLowerCase().replace(/[^a-z0-9]/g, '')
    const randNum = Math.floor(100 + Math.random() * 900)
    const genCode = code || `${randNum}`
    const genEmail = `admin@${cleanShort || 'campus'}.ac.in`
    const genPass = `${(shortName || 'CAMPUS').toUpperCase()}@2026!`
    
    setCode(genCode)
    setAdminEmail(genEmail)
    setAdminPassword(genPass)
  }

  const handleSaveInstitution = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!name || !code || !adminEmail || !adminPassword) {
      alert('Please fill all required fields.')
      return
    }

    setFormSubmitting(true)
    try {
      const payload: any = {
        code,
        name,
        short_name: shortName || name,
        admin_email: adminEmail,
        admin_password: adminPassword,
        city: city || 'Himmatnagar',
        state: stateName || 'Gujarat',
        admissions_open: true,
        student_count: 5000
      }

      if (editingInst) {
        const { error } = await supabase
          .from('institutions')
          .update(payload)
          .eq('id', editingInst.id)
        if (error) throw error
      } else {
        const { error } = await supabase
          .from('institutions')
          .insert(payload)
        if (error) throw error

        // Also create the Supabase Auth login account so the college can login immediately
        try {
          await supabase.auth.signUp({
            email: adminEmail,
            password: adminPassword,
            options: {
              data: {
                role: 'admin',
                full_name: `${name} Administrator`,
              }
            }
          })
        } catch (_) {
          // Account creation error handled gracefully
        }

        // Show credentials modal
        setCreatedCredentials({
          name,
          code,
          adminEmail,
          adminPassword,
          loginUrl: `${window.location.origin}/login`
        })
      }

      setShowAddModal(false)
      setEditingInst(null)
      resetForm()
      fetchInstitutions()
    } catch (err: any) {
      alert(`Failed to save institution: ${err.message}`)
    } finally {
      setFormSubmitting(false)
    }
  }

  const handleDeleteInstitution = async (id: string, instName: string) => {
    if (!confirm(`Are you sure you want to remove ${instName}? All associated college portals and student profiles will be removed.`)) return

    try {
      const { error } = await supabase
        .from('institutions')
        .delete()
        .eq('id', id)

      if (error) throw error
      fetchInstitutions()
    } catch (err: any) {
      alert(`Error deleting institution: ${err.message}`)
    }
  }

  const resetForm = () => {
    setName('')
    setShortName('')
    setCode('')
    setCity('')
    setStateName('Gujarat')
    setAdminEmail('')
    setAdminPassword('')
  }

  const openEditModal = (inst: Institution) => {
    setEditingInst(inst)
    setName(inst.name)
    setShortName(inst.short_name)
    setCode(inst.code)
    setCity(inst.city)
    setStateName(inst.state)
    setAdminEmail(inst.admin_email)
    setAdminPassword(inst.admin_password || '')
    setShowAddModal(true)
  }

  const copyToClipboard = (text: string, id: string) => {
    navigator.clipboard.writeText(text)
    setCopiedId(id)
    setTimeout(() => setCopiedId(null), 2000)
  }

  const togglePasswordVisibility = (id: string) => {
    setShowPasswordMap(prev => ({ ...prev, [id]: !prev[id] }))
  }

  const filteredInstitutions = institutions.filter(inst => 
    inst.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    inst.code.toLowerCase().includes(searchQuery.toLowerCase()) ||
    inst.city.toLowerCase().includes(searchQuery.toLowerCase()) ||
    inst.admin_email.toLowerCase().includes(searchQuery.toLowerCase())
  )

  // 🔒 PLATFORM OWNER ACCESS GATE
  if (!isAuthenticated) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-background p-4 text-text-primary">
        <div className="w-full max-w-md bg-surface p-8 rounded-3xl border border-card-border shadow-2xl space-y-6">
          <div className="text-center space-y-2">
            <div className="w-14 h-14 mx-auto rounded-2xl bg-primary/10 border border-primary/30 flex items-center justify-center shadow-lg">
              <ShieldCheck className="text-primary" size={28} />
            </div>
            <h1 className="text-2xl font-extrabold tracking-tight">Super Admin Portal</h1>
            <p className="text-xs text-text-secondary">
              Enter Platform Owner Passphrase to manage multi-tenant institutions and generate college credentials.
            </p>
          </div>

          {authError && (
            <div className="p-3.5 bg-error/10 border border-error/20 rounded-xl text-error text-xs">
              {authError}
            </div>
          )}

          <form onSubmit={handleGateLogin} className="space-y-4">
            <div>
              <label className="block text-xs font-semibold text-text-secondary mb-1.5">
                Master Passphrase / PIN
              </label>
              <div className="relative">
                <input
                  type="password"
                  value={passphrase}
                  onChange={e => setPassphrase(e.target.value)}
                  placeholder="Enter master passphrase"
                  className="w-full bg-surface-light border border-card-border rounded-xl px-4 py-3 text-text-primary text-sm focus:outline-none focus:border-primary transition-all"
                  autoFocus
                />
                <Lock className="absolute right-3.5 top-3.5 text-text-muted" size={16} />
              </div>
            </div>

            <button
              type="submit"
              className="w-full bg-primary text-background font-extrabold py-3 px-4 rounded-xl hover:opacity-90 transition-all text-sm shadow-lg shadow-primary/20 cursor-pointer"
            >
              Authorize Super Admin Access
            </button>
          </form>

          <div className="pt-2 text-center">
            <Link
              to="/dashboard"
              className="text-xs text-text-muted hover:text-primary flex items-center justify-center gap-1.5 transition-colors"
            >
              <ArrowLeft size={14} /> Back to College Admin Dashboard
            </Link>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="p-8 max-w-7xl mx-auto space-y-6">
      {/* Top Header Bar */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-6 border-b border-card-border">
        <div>
          <div className="flex items-center gap-2.5">
            <h1 className="text-3xl font-extrabold text-text-primary tracking-tight">Super Admin Portal</h1>
            <span className="text-[11px] bg-primary text-background font-extrabold px-2.5 py-0.5 rounded-md uppercase tracking-wider">
              Platform Owner
            </span>
          </div>
          <p className="text-xs text-text-secondary mt-1">
            Manage multi-tenant colleges, generate institution admin credentials, and monitor platform activity.
          </p>
        </div>

        <div className="flex items-center gap-3">
          <Link
            to="/dashboard"
            className="px-4 py-2.5 bg-surface-light border border-card-border hover:border-primary/40 text-text-secondary hover:text-text-primary rounded-xl text-xs font-bold flex items-center gap-1.5 transition-all"
          >
            <ArrowLeft size={15} /> College Portal
          </Link>

          <button
            onClick={() => {
              resetForm()
              setEditingInst(null)
              setShowAddModal(true)
            }}
            className="bg-primary text-background font-extrabold px-5 py-2.5 rounded-xl hover:opacity-90 transition-all text-xs flex items-center gap-2 shadow-lg shadow-primary/20 cursor-pointer"
          >
            <Plus size={16} /> Register New Institution
          </button>
        </div>
      </div>

      {/* Metric Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
        <div className="bg-surface p-6 rounded-2xl border border-card-border shadow-md flex items-center justify-between">
          <div>
            <span className="text-xs font-semibold text-text-muted uppercase tracking-wider block mb-1">
              Total Institutions
            </span>
            <span className="text-3xl font-extrabold text-text-primary">{institutions.length}</span>
            <span className="text-[11px] text-primary block mt-1 font-medium">● 100% Active & Operational</span>
          </div>
          <div className="p-3 bg-primary/10 rounded-xl border border-primary/20">
            <Building2 className="text-primary" size={24} />
          </div>
        </div>

        <div className="bg-surface p-6 rounded-2xl border border-card-border shadow-md flex items-center justify-between">
          <div>
            <span className="text-xs font-semibold text-text-muted uppercase tracking-wider block mb-1">
              Admin Credentials
            </span>
            <span className="text-3xl font-extrabold text-text-primary">{institutions.length}</span>
            <span className="text-[11px] text-cyan-accent block mt-1 font-medium">Dedicated College Portals</span>
          </div>
          <div className="p-3 bg-cyan-accent/10 rounded-xl border border-cyan-accent/20">
            <Key className="text-cyan-accent" size={24} />
          </div>
        </div>

        <div className="bg-surface p-6 rounded-2xl border border-card-border shadow-md flex items-center justify-between">
          <div>
            <span className="text-xs font-semibold text-text-muted uppercase tracking-wider block mb-1">
              Platform Security
            </span>
            <span className="text-2xl font-extrabold text-text-primary">RLS Isolated</span>
            <span className="text-[11px] text-text-secondary block mt-1 font-medium">Multi-tenant student isolation</span>
          </div>
          <div className="p-3 bg-surface-light rounded-xl border border-card-border">
            <ShieldCheck className="text-primary" size={24} />
          </div>
        </div>
      </div>

      {/* Search Bar */}
      <div className="relative">
        <input
          type="text"
          value={searchQuery}
          onChange={e => setSearchQuery(e.target.value)}
          placeholder="Search institutions by name, code, city, or admin email..."
          className="w-full bg-surface border border-card-border rounded-xl pl-11 pr-4 py-3 text-sm text-text-primary placeholder:text-text-muted focus:outline-none focus:border-primary transition-all shadow-sm"
        />
        <Search className="absolute left-4 top-3.5 text-text-muted" size={18} />
      </div>

      {/* Registered Institutions Table */}
      <div className="bg-surface rounded-2xl border border-card-border shadow-md overflow-hidden">
        <div className="p-5 border-b border-card-border flex items-center justify-between">
          <h2 className="text-base font-bold text-text-primary flex items-center gap-2">
            <Building2 size={18} className="text-primary" />
            Registered Institutions & Portals
          </h2>
          <span className="text-xs text-text-muted">
            {filteredInstitutions.length} College(s) Found
          </span>
        </div>

        {loading ? (
          <div className="p-12 text-center text-text-muted flex flex-col items-center gap-2">
            <RefreshCw className="animate-spin text-primary" size={24} />
            <span className="text-xs">Loading institutions...</span>
          </div>
        ) : filteredInstitutions.length === 0 ? (
          <div className="p-12 text-center text-text-muted">
            <Building2 size={32} className="mx-auto mb-2 opacity-40 text-primary" />
            <p className="text-sm font-semibold text-text-primary">No institutions found</p>
            <p className="text-xs text-text-muted mt-1">Click "+ Register New Institution" above to onboard your first college.</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-surface-light text-text-muted uppercase font-bold border-b border-card-border">
                <tr>
                  <th className="p-4">Code</th>
                  <th className="p-4">Institution Name</th>
                  <th className="p-4">Location</th>
                  <th className="p-4">Admin Login ID (Email)</th>
                  <th className="p-4">Admin Password</th>
                  <th className="p-4 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-card-border text-text-primary">
                {filteredInstitutions.map((inst) => {
                  const isPassVisible = showPasswordMap[inst.id] || false
                  return (
                    <tr key={inst.id} className="hover:bg-surface-light/40 transition-colors">
                      <td className="p-4 font-mono font-bold text-primary">{inst.code}</td>
                      <td className="p-4">
                        <div className="font-bold text-text-primary text-sm">{inst.name}</div>
                        <div className="text-[11px] text-text-muted">{inst.short_name}</div>
                      </td>
                      <td className="p-4 text-text-secondary">{inst.city}, {inst.state}</td>
                      <td className="p-4 font-mono">
                        <div className="flex items-center gap-2">
                          <span className="text-cyan-accent font-semibold">{inst.admin_email}</span>
                          <button
                            onClick={() => copyToClipboard(inst.admin_email, `email_${inst.id}`)}
                            className="text-text-muted hover:text-primary transition-colors p-1"
                            title="Copy Admin Email"
                          >
                            {copiedId === `email_${inst.id}` ? <Check size={13} className="text-primary" /> : <Copy size={13} />}
                          </button>
                        </div>
                      </td>
                      <td className="p-4 font-mono">
                        <div className="flex items-center gap-2">
                          <span className="text-text-secondary">
                            {isPassVisible ? (inst.admin_password || '—') : '••••••••••••'}
                          </span>
                          <button
                            onClick={() => togglePasswordVisibility(inst.id)}
                            className="text-text-muted hover:text-text-primary p-1"
                            title={isPassVisible ? 'Hide Password' : 'Show Password'}
                          >
                            {isPassVisible ? <EyeOff size={13} /> : <Eye size={13} />}
                          </button>
                          {inst.admin_password && (
                            <button
                              onClick={() => copyToClipboard(inst.admin_password!, `pass_${inst.id}`)}
                              className="text-text-muted hover:text-primary transition-colors p-1"
                              title="Copy Password"
                            >
                              {copiedId === `pass_${inst.id}` ? <Check size={13} className="text-primary" /> : <Copy size={13} />}
                            </button>
                          )}
                        </div>
                      </td>
                      <td className="p-4 text-right">
                        <div className="flex items-center justify-end gap-2">
                          <button
                            onClick={() => openEditModal(inst)}
                            className="p-2 bg-surface-light hover:bg-primary/20 text-text-secondary hover:text-primary rounded-lg transition-all"
                            title="Edit Institution"
                          >
                            <Edit size={14} />
                          </button>
                          <button
                            onClick={() => handleDeleteInstitution(inst.id, inst.name)}
                            className="p-2 bg-surface-light hover:bg-error/20 text-text-secondary hover:text-error rounded-lg transition-all"
                            title="Delete Institution"
                          >
                            <Trash2 size={14} />
                          </button>
                        </div>
                      </td>
                    </tr>
                  )
                })}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* ➕ MODAL: REGISTER / EDIT INSTITUTION */}
      {showAddModal && (
        <div className="fixed inset-0 bg-background/80 backdrop-blur-md flex items-center justify-center p-4 z-50">
          <div className="bg-surface border border-card-border rounded-3xl p-6 sm:p-8 max-w-xl w-full shadow-2xl space-y-6">
            <div className="flex items-center justify-between pb-4 border-b border-card-border">
              <div className="flex items-center gap-2">
                <Building2 className="text-primary" size={22} />
                <h3 className="text-xl font-extrabold text-text-primary">
                  {editingInst ? 'Edit Institution Details' : 'Register New Institution'}
                </h3>
              </div>
              <button
                onClick={() => setShowAddModal(false)}
                className="text-text-muted hover:text-text-primary p-1 rounded-lg"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleSaveInstitution} className="space-y-4 text-xs">
              <div>
                <label className="block font-semibold text-text-secondary mb-1">
                  Full Institution / College Name *
                </label>
                <input
                  type="text"
                  required
                  value={name}
                  onChange={e => setName(e.target.value)}
                  placeholder="e.g. Government Engineering College Modasa"
                  className="w-full bg-surface-light border border-card-border rounded-xl p-3 text-text-primary focus:outline-none focus:border-primary text-xs"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-text-secondary mb-1">
                    Short Name / Display Title *
                  </label>
                  <input
                    type="text"
                    required
                    value={shortName}
                    onChange={e => setShortName(e.target.value)}
                    placeholder="e.g. GEC Modasa"
                    className="w-full bg-surface-light border border-card-border rounded-xl p-3 text-text-primary focus:outline-none focus:border-primary text-xs"
                  />
                </div>

                <div>
                  <label className="block font-semibold text-text-secondary mb-1">
                    GTU / College Code *
                  </label>
                  <input
                    type="text"
                    required
                    value={code}
                    onChange={e => setCode(e.target.value)}
                    placeholder="e.g. 016 or 624"
                    className="w-full bg-surface-light border border-card-border rounded-xl p-3 text-text-primary focus:outline-none focus:border-primary text-xs"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-text-secondary mb-1">City *</label>
                  <input
                    type="text"
                    value={city}
                    onChange={e => setCity(e.target.value)}
                    placeholder="e.g. Modasa"
                    className="w-full bg-surface-light border border-card-border rounded-xl p-3 text-text-primary focus:outline-none focus:border-primary text-xs"
                  />
                </div>

                <div>
                  <label className="block font-semibold text-text-secondary mb-1">State</label>
                  <input
                    type="text"
                    value={stateName}
                    onChange={e => setStateName(e.target.value)}
                    className="w-full bg-surface-light border border-card-border rounded-xl p-3 text-text-primary focus:outline-none focus:border-primary text-xs"
                  />
                </div>
              </div>

              {/* Auto Generate Credentials Helper */}
              <div className="p-4 bg-primary/10 border border-primary/30 rounded-2xl space-y-3">
                <div className="flex items-center justify-between">
                  <span className="font-bold text-primary flex items-center gap-1.5">
                    <Key size={14} /> Institution Admin Credentials
                  </span>
                  <button
                    type="button"
                    onClick={generateAutoCredentials}
                    className="text-[11px] bg-primary text-background font-extrabold px-3 py-1 rounded-lg hover:opacity-90 flex items-center gap-1 shadow-sm cursor-pointer"
                  >
                    <Sparkles size={12} /> Auto-Generate Unique ID & Pass
                  </button>
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-[11px] text-text-muted mb-1">
                      Admin Email (Login ID) *
                    </label>
                    <input
                      type="email"
                      required
                      value={adminEmail}
                      onChange={e => setAdminEmail(e.target.value)}
                      placeholder="admin@gecmodasa.ac.in"
                      className="w-full bg-surface border border-card-border rounded-xl p-2.5 text-text-primary font-mono text-xs focus:outline-none focus:border-primary"
                    />
                  </div>

                  <div>
                    <label className="block text-[11px] text-text-muted mb-1">
                      Admin Password *
                    </label>
                    <input
                      type="text"
                      required
                      value={adminPassword}
                      onChange={e => setAdminPassword(e.target.value)}
                      placeholder="GECMODASA@2026!"
                      className="w-full bg-surface border border-card-border rounded-xl p-2.5 text-text-primary font-mono text-xs focus:outline-none focus:border-primary"
                    />
                  </div>
                </div>
              </div>

              <div className="flex items-center justify-end gap-3 pt-3">
                <button
                  type="button"
                  onClick={() => setShowAddModal(false)}
                  className="px-4 py-2.5 rounded-xl border border-card-border text-text-secondary hover:text-text-primary text-xs font-semibold"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={formSubmitting}
                  className="bg-primary text-background font-extrabold px-6 py-2.5 rounded-xl hover:opacity-90 transition-all text-xs flex items-center gap-2 shadow-lg shadow-primary/20 cursor-pointer"
                >
                  {formSubmitting ? (
                    <div className="w-4 h-4 border-2 border-background border-t-transparent rounded-full animate-spin" />
                  ) : (
                    <>
                      <Check size={16} />
                      {editingInst ? 'Save Changes' : 'Create & Generate Portal'}
                    </>
                  )}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* 🎉 SUCCESS MODAL: CREATED CREDENTIALS PACKAGE */}
      {createdCredentials && (
        <div className="fixed inset-0 bg-background/85 backdrop-blur-md flex items-center justify-center p-4 z-50">
          <div className="bg-surface border border-primary/40 rounded-3xl p-6 sm:p-8 max-w-md w-full shadow-2xl space-y-6 text-center">
            <div className="w-16 h-16 mx-auto rounded-3xl bg-primary/10 border border-primary/30 flex items-center justify-center shadow-xl">
              <Sparkles className="text-primary" size={32} />
            </div>

            <div className="space-y-1">
              <h3 className="text-2xl font-extrabold text-text-primary tracking-tight">
                Portal Created Successfully!
              </h3>
              <p className="text-xs text-text-secondary">
                The dedicated institution admin portal for <strong>{createdCredentials.name}</strong> is now live.
              </p>
            </div>

            <div className="bg-surface-light border border-card-border rounded-2xl p-4 text-left space-y-3 text-xs font-mono">
              <div>
                <span className="text-text-muted block text-[10px] uppercase font-bold">Portal URL</span>
                <a
                  href={createdCredentials.loginUrl}
                  target="_blank"
                  rel="noreferrer"
                  className="text-primary underline flex items-center gap-1 font-semibold"
                >
                  {createdCredentials.loginUrl} <ExternalLink size={12} />
                </a>
              </div>

              <div>
                <span className="text-text-muted block text-[10px] uppercase font-bold">Admin ID / Email</span>
                <span className="text-cyan-accent font-bold text-sm">{createdCredentials.adminEmail}</span>
              </div>

              <div>
                <span className="text-text-muted block text-[10px] uppercase font-bold">Default Password</span>
                <span className="text-primary font-bold text-sm">{createdCredentials.adminPassword}</span>
              </div>
            </div>

            <div className="space-y-2.5">
              <button
                onClick={() => {
                  const msg = `🏫 *${createdCredentials.name}* (Code: ${createdCredentials.code})\n🔑 Portal URL: ${createdCredentials.loginUrl}\n👤 Admin ID: ${createdCredentials.adminEmail}\n🔒 Password: ${createdCredentials.adminPassword}\n\nPlease login to manage your college students, attendance, and documents.`
                  copyToClipboard(msg, 'all_creds')
                }}
                className="w-full bg-primary text-background font-extrabold py-3 px-4 rounded-xl hover:opacity-90 transition-all text-xs flex items-center justify-center gap-2 shadow-lg shadow-primary/20 cursor-pointer"
              >
                {copiedId === 'all_creds' ? (
                  <>
                    <Check size={16} /> Copied Credentials Package!
                  </>
                ) : (
                  <>
                    <Copy size={16} /> Copy Credentials Package for College
                  </>
                )}
              </button>

              <button
                onClick={() => setCreatedCredentials(null)}
                className="w-full py-2.5 text-xs text-text-muted hover:text-text-primary transition-colors"
              >
                Done
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
