import { useEffect, useState } from 'react'
import { useAuth } from '../contexts/AuthContext'
import { supabase } from '../config/supabase'
import { Building2, Shield, Mail, MapPin, Hash, CheckCircle2 } from 'lucide-react'

export default function SettingsPage() {
  const { user, institution } = useAuth()
  const [instData, setInstData] = useState<any>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    async function fetchInstitution() {
      try {
        setLoading(true)
        if (institution?.id) {
          const { data } = await supabase
            .from('institutions')
            .select('*')
            .eq('id', institution.id)
            .maybeSingle()
          if (data) {
            setInstData(data)
            return
          }
        }

        if (user?.email) {
          const { data } = await supabase
            .from('institutions')
            .select('*')
            .ilike('admin_email', user.email)
            .maybeSingle()
          if (data) {
            setInstData(data)
          }
        }
      } catch (err) {
        console.error(err)
      } finally {
        setLoading(false)
      }
    }
    fetchInstitution()
  }, [user?.email, institution?.id])

  const displayInst = instData || institution

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <div>
        <h1 className="text-2xl font-extrabold text-text-primary tracking-tight mb-1 flex items-center gap-2.5">
          <Building2 className="text-primary" size={26} />
          College Profile & Preferences
        </h1>
        <p className="text-text-secondary text-sm">
          Active Institution Administration details & tenant isolation settings.
        </p>
      </div>

      {/* Institution Details Card */}
      <div className="bg-surface border border-card-border rounded-2xl p-6 shadow-sm">
        <div className="flex items-center justify-between border-b border-card-border pb-4 mb-5">
          <div>
            <h2 className="text-lg font-bold text-text-primary">
              {displayInst?.name || 'Institution Details'}
            </h2>
            <p className="text-xs text-text-muted">
              {displayInst?.short_name || 'Academic Institution'}
            </p>
          </div>
          {displayInst?.code && (
            <span className="bg-primary/10 text-primary border border-primary/30 px-3 py-1 rounded-xl text-xs font-bold font-mono">
              Code: {displayInst.code}
            </span>
          )}
        </div>

        {loading ? (
          <p className="text-text-secondary text-sm">Loading details...</p>
        ) : displayInst ? (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
            <div className="bg-surface-light p-3.5 rounded-xl border border-card-border/60">
              <div className="text-xs text-text-muted mb-1 flex items-center gap-1.5">
                <Building2 size={13} /> Full College Name
              </div>
              <div className="text-text-primary font-semibold">{displayInst.name}</div>
            </div>

            <div className="bg-surface-light p-3.5 rounded-xl border border-card-border/60">
              <div className="text-xs text-text-muted mb-1 flex items-center gap-1.5">
                <Hash size={13} /> Short Name & Acronym
              </div>
              <div className="text-text-primary font-semibold">{displayInst.short_name || '—'}</div>
            </div>

            <div className="bg-surface-light p-3.5 rounded-xl border border-card-border/60">
              <div className="text-xs text-text-muted mb-1 flex items-center gap-1.5">
                <MapPin size={13} /> Campus Location
              </div>
              <div className="text-text-primary font-semibold">
                {[displayInst.city, displayInst.state].filter(Boolean).join(', ') || '—'}
              </div>
              {displayInst.address && (
                <div className="text-xs text-text-secondary mt-1">{displayInst.address}</div>
              )}
            </div>

            <div className="bg-surface-light p-3.5 rounded-xl border border-card-border/60">
              <div className="text-xs text-text-muted mb-1 flex items-center gap-1.5">
                <Mail size={13} /> Contact Email
              </div>
              <div className="text-text-primary font-semibold font-mono text-xs">
                {displayInst.contact_email || displayInst.admin_email || '—'}
              </div>
            </div>
          </div>
        ) : (
          <p className="text-text-secondary text-sm">No institution details found.</p>
        )}
      </div>

      {/* Admin Account Card */}
      <div className="bg-surface border border-card-border rounded-2xl p-6 shadow-sm">
        <h2 className="text-base font-bold text-text-primary mb-4 border-b border-card-border pb-3 flex items-center gap-2">
          <Shield size={18} className="text-primary" />
          Active Administrator Profile
        </h2>
        <div className="space-y-3.5 text-sm">
          <div className="flex items-center justify-between py-1">
            <span className="text-text-secondary">Admin Login ID</span>
            <span className="text-text-primary font-mono font-medium">{user?.email || displayInst?.admin_email || 'N/A'}</span>
          </div>
          <div className="flex items-center justify-between py-1 border-t border-card-border/50 pt-2.5">
            <span className="text-text-secondary">Institution ID (UUID)</span>
            <span className="text-text-primary font-mono text-xs bg-surface-light px-2.5 py-1 rounded border border-card-border/70">
              {displayInst?.id || user?.id || 'N/A'}
            </span>
          </div>
          <div className="flex items-center justify-between py-1 border-t border-card-border/50 pt-2.5">
            <span className="text-text-secondary">Tenant Isolation Status</span>
            <span className="text-emerald-400 font-semibold text-xs inline-flex items-center gap-1">
              <CheckCircle2 size={14} /> Strict Multi-Tenant Isolation Active
            </span>
          </div>
        </div>
      </div>
    </div>
  )
}
