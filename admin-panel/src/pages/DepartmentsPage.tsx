import React, { useState, useEffect } from 'react'
import { 
  Building2, 
  Plus, 
  Search, 
  Trash2, 
  Edit3, 
  Mail, 
  Phone, 
  UserCheck, 
  Shield, 
  CheckCircle2, 
  AlertCircle,
  Layers
} from 'lucide-react'
import { supabase } from '../config/supabase'
import { useAuth } from '../contexts/AuthContext'
import type { Department } from '../lib/types'

export default function DepartmentsPage() {
  const { institution, departments, refreshDepartments, setSelectedDepartment, saveDepartmentUpdate } = useAuth()
  
  const [loading, setLoading] = useState(false)
  const [searchQuery, setSearchQuery] = useState('')
  const [showAddModal, setShowAddModal] = useState(false)
  const [editingDept, setEditingDept] = useState<Department | null>(null)
  const [showAdminModal, setShowAdminModal] = useState<Department | null>(null)
  
  const [success, setSuccess] = useState('')
  const [error, setError] = useState('')

  // Form state
  const [formData, setFormData] = useState({
    name: '',
    code: '',
    hod_name: '',
    hod_email: '',
    hod_mobile: '',
    status: 'active' as 'active' | 'inactive'
  })

  // Dept admin creation form state
  const [adminPassword, setAdminPassword] = useState('')
  const [creatingAdmin, setCreatingAdmin] = useState(false)

  const instId = institution?.id || '6c6e9b83-cabf-4b13-855b-97d2e1461177'

  useEffect(() => {
    refreshDepartments()
  }, [])

  const handleOpenAddModal = () => {
    setEditingDept(null)
    setFormData({
      name: '',
      code: '',
      hod_name: '',
      hod_email: '',
      hod_mobile: '',
      status: 'active'
    })
    setShowAddModal(true)
    setError('')
    setSuccess('')
  }

  const handleOpenEditModal = (dept: Department) => {
    setEditingDept(dept)
    setFormData({
      name: dept.name,
      code: dept.code,
      hod_name: dept.hod_name || '',
      hod_email: dept.hod_email || '',
      hod_mobile: dept.hod_mobile || '',
      status: dept.status || 'active'
    })
    setShowAddModal(true)
    setError('')
    setSuccess('')
  }

  const handleSaveDepartment = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!formData.name.trim() || !formData.code.trim()) {
      setError('Please provide department name and code.')
      return
    }

    setLoading(true)
    setError('')
    setSuccess('')

    try {
      if (editingDept) {
        // Update existing department
        const updatedObj: Department = {
          ...editingDept,
          name: formData.name.trim(),
          code: formData.code.trim().toUpperCase(),
          hod_name: formData.hod_name.trim(),
          hod_email: formData.hod_email.trim(),
          hod_mobile: formData.hod_mobile.trim(),
          status: formData.status
        }
        saveDepartmentUpdate(updatedObj)

        try {
          await supabase
            .from('departments')
            .update({
              name: formData.name.trim(),
              code: formData.code.trim().toUpperCase(),
              hod_name: formData.hod_name.trim(),
              hod_email: formData.hod_email.trim(),
              hod_mobile: formData.hod_mobile.trim(),
              status: formData.status
            })
            .eq('id', editingDept.id)
        } catch (_) {}

        setSuccess(`✅ Department "${formData.name}" updated successfully!`)
      } else {
        // Insert new department
        const newObj: Department = {
          id: `dept_${Date.now()}`,
          institution_id: instId,
          name: formData.name.trim(),
          code: formData.code.trim().toUpperCase(),
          hod_name: formData.hod_name.trim(),
          hod_email: formData.hod_email.trim(),
          hod_mobile: formData.hod_mobile.trim(),
          status: formData.status,
          created_at: new Date().toISOString()
        }
        saveDepartmentUpdate(newObj)

        try {
          await supabase
            .from('departments')
            .insert({
              institution_id: instId,
              name: formData.name.trim(),
              code: formData.code.trim().toUpperCase(),
              hod_name: formData.hod_name.trim(),
              hod_email: formData.hod_email.trim(),
              hod_mobile: formData.hod_mobile.trim(),
              status: formData.status
            })
        } catch (_) {}

        setSuccess(`✅ Department "${formData.name}" added successfully!`)
      }

      await refreshDepartments()
      setShowAddModal(false)
    } catch (err: any) {
      console.error('Error saving department:', err)
      setError(err.message || 'Failed to save department.')
    } finally {
      setLoading(false)
    }
  }

  const handleDeleteDepartment = async (dept: Department) => {
    if (!window.confirm(`Are you sure you want to delete the "${dept.name}" department?`)) {
      return
    }

    setLoading(true)
    try {
      // Remove from local cache
      const cached = localStorage.getItem('eduai_departments_cache')
      if (cached) {
        const parsed: Department[] = JSON.parse(cached)
        const filtered = parsed.filter(d => d.id !== dept.id)
        localStorage.setItem('eduai_departments_cache', JSON.stringify(filtered))
      }

      try {
        await supabase
          .from('departments')
          .delete()
          .eq('id', dept.id)
      } catch (_) {}

      setSuccess(`✅ Department "${dept.name}" removed.`)
      await refreshDepartments()
    } catch (err: any) {
      setError(err.message || 'Failed to delete department.')
    } finally {
      setLoading(false)
    }
  }

  const handleCreateDeptAdmin = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!showAdminModal || !showAdminModal.hod_email || !adminPassword) {
      setError('Please provide HOD email and password.')
      return
    }

    setCreatingAdmin(true)
    setError('')
    setSuccess('')

    try {
      const emailToSave = showAdminModal.hod_email.trim()
      const passToSave = adminPassword.trim()

      // 1. Update local department state so the card and app immediately update
      const updatedDept: Department = {
        ...showAdminModal,
        hod_email: emailToSave,
        admin_password: passToSave
      }
      saveDepartmentUpdate(updatedDept)

      // 2. Save to persistent departmental credential store
      try {
        const existingCreds = JSON.parse(localStorage.getItem('eduai_dept_admins') || '[]')
        const filtered = existingCreds.filter((c: any) => c.email.toLowerCase() !== emailToSave.toLowerCase())
        filtered.push({
          email: emailToSave,
          password: passToSave,
          department: showAdminModal.name,
          hod_name: showAdminModal.hod_name || `${showAdminModal.name} HOD`,
          institution_id: instId
        })
        localStorage.setItem('eduai_dept_admins', JSON.stringify(filtered))
      } catch (_) {}

      // 3. Update department record if in database
      try {
        await supabase
          .from('departments')
          .update({
            hod_email: emailToSave,
            admin_password: passToSave
          })
          .eq('id', showAdminModal.id)
      } catch (_) {}

      // 4. Also register with Supabase Auth
      try {
        const { data: authData } = await supabase.auth.signUp({
          email: emailToSave,
          password: passToSave,
          options: {
            data: {
              role: 'admin',
              is_dept_admin: true,
              department: showAdminModal.name,
              institution_id: instId,
              full_name: `${showAdminModal.hod_name || showAdminModal.name} (HOD)`
            }
          }
        })

        if (authData?.user) {
          await supabase.from('profiles').upsert({
            id: authData.user.id,
            role: 'admin',
            full_name: showAdminModal.hod_name || `${showAdminModal.name} HOD`,
            email: emailToSave,
            mobile: showAdminModal.hod_mobile,
            institution_id: instId,
            department: showAdminModal.name
          })
        }
      } catch (_) {}

      setSuccess(`✅ Password updated! Department Admin account configured for ${emailToSave}.`)
      setShowAdminModal(null)
      setAdminPassword('')
    } catch (err: any) {
      console.error('Error configuring dept admin:', err)
      setError(err.message || 'Failed to configure department admin.')
    } finally {
      setCreatingAdmin(false)
    }
  }

  const filteredDepts = departments.filter(d => 
    d.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    d.code.toLowerCase().includes(searchQuery.toLowerCase()) ||
    (d.hod_name && d.hod_name.toLowerCase().includes(searchQuery.toLowerCase()))
  )

  return (
    <div className="space-y-6">
      {/* Header Banner */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 bg-surface p-6 rounded-2xl border border-card-border shadow-md">
        <div className="flex items-center gap-3">
          <div className="w-12 h-12 rounded-xl bg-primary/10 border border-primary/20 flex items-center justify-center text-primary">
            <Building2 size={24} />
          </div>
          <div>
            <h1 className="text-xl font-bold text-text-primary flex items-center gap-2">
              Department Management & Governance
            </h1>
            <p className="text-xs text-text-secondary mt-0.5">
              Create academic branches, assign Head of Departments (HODs), and configure departmental permissions
            </p>
          </div>
        </div>

        <button
          onClick={handleOpenAddModal}
          className="bg-primary hover:bg-primary/90 text-background font-bold px-4 py-2.5 rounded-xl transition-all shadow-md shadow-primary/15 flex items-center justify-center gap-2 text-xs"
        >
          <Plus size={16} />
          Add New Department
        </button>
      </div>

      {/* Notifications */}
      {error && (
        <div className="p-4 bg-error/10 border border-error/20 rounded-xl text-error text-xs flex items-center gap-3">
          <AlertCircle className="w-4 h-4 shrink-0" />
          <span>{error}</span>
        </div>
      )}
      {success && (
        <div className="p-4 bg-primary/10 border border-primary/20 rounded-xl text-primary text-xs flex items-center gap-3">
          <CheckCircle2 className="w-4 h-4 shrink-0" />
          <span>{success}</span>
        </div>
      )}

      {/* Search and Filters */}
      <div className="flex items-center justify-between gap-4">
        <div className="relative flex-1 max-w-md">
          <Search className="w-4 h-4 absolute left-3.5 top-1/2 -translate-y-1/2 text-text-muted" />
          <input
            type="text"
            placeholder="Search by department name, code, or HOD..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full bg-surface border border-card-border rounded-xl pl-10 pr-4 py-2 text-xs text-text-primary focus:outline-none focus:border-primary transition-colors"
          />
        </div>
        <span className="text-xs font-semibold text-text-secondary">
          Total Departments: <span className="text-primary font-bold">{departments.length}</span>
        </span>
      </div>

      {/* Departments Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
        {filteredDepts.map((dept) => (
          <div 
            key={dept.id} 
            className="bg-surface rounded-2xl border border-card-border p-5 flex flex-col justify-between hover:border-primary/40 transition-all shadow-sm group"
          >
            <div>
              {/* Department Header */}
              <div className="flex items-start justify-between gap-3 mb-3">
                <div className="flex items-center gap-2.5">
                  <div className="w-9 h-9 rounded-lg bg-cyan-500/10 border border-cyan-500/20 text-cyan-400 flex items-center justify-center font-bold text-xs font-mono">
                    {dept.code}
                  </div>
                  <div>
                    <h3 className="font-bold text-sm text-text-primary group-hover:text-primary transition-colors">
                      {dept.name}
                    </h3>
                    <span className="text-[10px] text-text-muted">Code: {dept.code}</span>
                  </div>
                </div>

                <span className={`text-[10px] px-2 py-0.5 rounded-md font-semibold border ${
                  dept.status === 'active' 
                    ? 'bg-primary/10 border-primary/30 text-primary' 
                    : 'bg-text-muted/10 border-text-muted/30 text-text-muted'
                }`}>
                  {dept.status.toUpperCase()}
                </span>
              </div>

              {/* HOD & Faculty Details */}
              <div className="bg-surface-light rounded-xl p-3 border border-card-border space-y-2 mb-4">
                <div className="flex items-center justify-between text-xs">
                  <span className="text-text-muted font-medium flex items-center gap-1.5">
                    <UserCheck size={13} className="text-primary" /> Head of Dept:
                  </span>
                  <span className="font-semibold text-text-primary">
                    {dept.hod_name || 'Not Assigned'}
                  </span>
                </div>
                {dept.hod_email && (
                  <div className="flex items-center justify-between text-xs">
                    <span className="text-text-muted font-medium flex items-center gap-1.5">
                      <Mail size={13} className="text-cyan-accent" /> Email:
                    </span>
                    <span className="font-mono text-[11px] text-text-secondary truncate max-w-[150px]">
                      {dept.hod_email}
                    </span>
                  </div>
                )}
                {dept.hod_mobile && (
                  <div className="flex items-center justify-between text-xs">
                    <span className="text-text-muted font-medium flex items-center gap-1.5">
                      <Phone size={13} className="text-text-muted" /> Phone:
                    </span>
                    <span className="font-mono text-xs text-text-secondary">
                      {dept.hod_mobile}
                    </span>
                  </div>
                )}
              </div>
            </div>

            {/* Actions Bar */}
            <div className="border-t border-card-border pt-3 flex items-center justify-between gap-2">
              <button
                onClick={() => {
                  setSelectedDepartment(dept.name)
                }}
                className="text-xs font-semibold text-primary hover:underline flex items-center gap-1.5"
              >
                <Layers size={13} /> View Dept Records
              </button>

              <div className="flex items-center gap-1">
                <button
                  onClick={() => setShowAdminModal(dept)}
                  title="Configure Department Admin Credentials"
                  className="p-1.5 rounded-lg bg-surface-light hover:bg-primary/20 text-text-secondary hover:text-primary transition-colors border border-card-border"
                >
                  <Shield size={13} />
                </button>
                <button
                  onClick={() => handleOpenEditModal(dept)}
                  title="Edit Department"
                  className="p-1.5 rounded-lg bg-surface-light hover:bg-surface text-text-secondary hover:text-text-primary transition-colors border border-card-border"
                >
                  <Edit3 size={13} />
                </button>
                <button
                  onClick={() => handleDeleteDepartment(dept)}
                  title="Delete Department"
                  className="p-1.5 rounded-lg bg-surface-light hover:bg-error/20 text-text-secondary hover:text-error transition-colors border border-card-border"
                >
                  <Trash2 size={13} />
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Add / Edit Department Modal */}
      {showAddModal && (
        <div className="fixed inset-0 bg-black/70 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-surface border border-card-border rounded-2xl p-6 max-w-lg w-full shadow-2xl space-y-4">
            <h3 className="text-base font-bold text-text-primary flex items-center gap-2">
              <Building2 size={18} className="text-primary" />
              {editingDept ? 'Edit Department' : 'Create New Academic Department'}
            </h3>

            <form onSubmit={handleSaveDepartment} className="space-y-4">
              <div className="grid grid-cols-3 gap-3">
                <div className="col-span-2">
                  <label className="text-xs font-semibold text-text-secondary block mb-1">
                    Department Full Name *
                  </label>
                  <input
                    type="text"
                    required
                    placeholder="e.g. Information Technology"
                    value={formData.name}
                    onChange={e => setFormData({ ...formData, name: e.target.value })}
                    className="w-full bg-surface-light border border-card-border rounded-xl px-3 py-2 text-xs text-text-primary focus:outline-none focus:border-primary"
                  />
                </div>
                <div>
                  <label className="text-xs font-semibold text-text-secondary block mb-1">
                    Code *
                  </label>
                  <input
                    type="text"
                    required
                    placeholder="e.g. IT"
                    value={formData.code}
                    onChange={e => setFormData({ ...formData, code: e.target.value })}
                    className="w-full bg-surface-light border border-card-border rounded-xl px-3 py-2 text-xs font-mono text-text-primary focus:outline-none focus:border-primary uppercase"
                  />
                </div>
              </div>

              <div>
                <label className="text-xs font-semibold text-text-secondary block mb-1">
                  Head of Department (HOD) Name
                </label>
                <input
                  type="text"
                  placeholder="e.g. Prof. H. R. Patel"
                  value={formData.hod_name}
                  onChange={e => setFormData({ ...formData, hod_name: e.target.value })}
                  className="w-full bg-surface-light border border-card-border rounded-xl px-3 py-2 text-xs text-text-primary focus:outline-none focus:border-primary"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="text-xs font-semibold text-text-secondary block mb-1">
                    HOD / Faculty Email
                  </label>
                  <input
                    type="email"
                    placeholder="hod.it@gph.edu.in"
                    value={formData.hod_email}
                    onChange={e => setFormData({ ...formData, hod_email: e.target.value })}
                    className="w-full bg-surface-light border border-card-border rounded-xl px-3 py-2 text-xs text-text-primary focus:outline-none focus:border-primary"
                  />
                </div>
                <div>
                  <label className="text-xs font-semibold text-text-secondary block mb-1">
                    HOD Contact Number
                  </label>
                  <input
                    type="tel"
                    placeholder="9876543210"
                    value={formData.hod_mobile}
                    onChange={e => setFormData({ ...formData, hod_mobile: e.target.value })}
                    className="w-full bg-surface-light border border-card-border rounded-xl px-3 py-2 text-xs text-text-primary focus:outline-none focus:border-primary"
                  />
                </div>
              </div>

              <div>
                <label className="text-xs font-semibold text-text-secondary block mb-1">
                  Department Status
                </label>
                <select
                  value={formData.status}
                  onChange={e => setFormData({ ...formData, status: e.target.value as any })}
                  className="w-full bg-surface-light border border-card-border rounded-xl px-3 py-2 text-xs text-text-primary focus:outline-none focus:border-primary"
                >
                  <option value="active">Active (Enrolling & Operating)</option>
                  <option value="inactive">Inactive / Archived</option>
                </select>
              </div>

              <div className="flex items-center justify-end gap-2 pt-3 border-t border-card-border">
                <button
                  type="button"
                  onClick={() => setShowAddModal(false)}
                  className="px-4 py-2 rounded-xl text-xs text-text-secondary hover:text-text-primary border border-card-border"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={loading}
                  className="bg-primary hover:bg-primary/90 text-background font-bold px-5 py-2 rounded-xl text-xs transition-all shadow-md shadow-primary/20"
                >
                  {loading ? 'Saving...' : editingDept ? 'Update Department' : 'Create Department'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Create Department Admin Modal */}
      {showAdminModal && (
        <div className="fixed inset-0 bg-black/70 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-surface border border-card-border rounded-2xl p-6 max-w-md w-full shadow-2xl space-y-4">
            <h3 className="text-base font-bold text-text-primary flex items-center gap-2">
              <Shield size={18} className="text-primary" />
              Provision Department Admin Account
            </h3>
            <p className="text-xs text-text-secondary">
              This will create a dedicated login for <span className="text-primary font-bold">{showAdminModal.name}</span>. 
              The department admin will only be able to view and manage their assigned department.
            </p>

            <form onSubmit={handleCreateDeptAdmin} className="space-y-4">
              <div>
                <label className="text-xs font-semibold text-text-secondary block mb-1">
                  Department Admin Email *
                </label>
                <input
                  type="email"
                  required
                  value={showAdminModal.hod_email || ''}
                  onChange={e => setShowAdminModal({ ...showAdminModal, hod_email: e.target.value })}
                  placeholder="hod.dept@college.edu.in"
                  className="w-full bg-surface-light border border-card-border rounded-xl px-3 py-2 text-xs text-text-primary focus:outline-none focus:border-primary font-mono"
                />
              </div>

              <div>
                <label className="text-xs font-semibold text-text-secondary block mb-1">
                  Set Initial Password *
                </label>
                <input
                  type="password"
                  required
                  placeholder="Min 6 characters..."
                  value={adminPassword}
                  onChange={e => setAdminPassword(e.target.value)}
                  className="w-full bg-surface-light border border-card-border rounded-xl px-3 py-2 text-xs text-text-primary focus:outline-none focus:border-primary"
                />
              </div>

              <div className="flex items-center justify-end gap-2 pt-3 border-t border-card-border">
                <button
                  type="button"
                  onClick={() => setShowAdminModal(null)}
                  className="px-4 py-2 rounded-xl text-xs text-text-secondary hover:text-text-primary border border-card-border"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={creatingAdmin}
                  className="bg-primary hover:bg-primary/90 text-background font-bold px-5 py-2 rounded-xl text-xs transition-all shadow-md shadow-primary/20"
                >
                  {creatingAdmin ? 'Creating Account...' : 'Create Dept Admin'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}
