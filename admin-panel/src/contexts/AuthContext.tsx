import { createContext, useContext, useEffect, useState } from 'react'
import type { Session, User } from '@supabase/supabase-js'
import { supabase } from '../config/supabase'

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

interface AuthContextType {
  session: Session | { user: { id: string; email: string; user_metadata: any } } | null
  user: User | { id: string; email: string; user_metadata: any } | null
  institution: InstitutionSession | null
  loading: boolean
  setInstitutionSession: (inst: InstitutionSession) => void
  signOut: () => Promise<void>
}

const AuthContext = createContext<AuthContextType>({
  session: null,
  user: null,
  institution: null,
  loading: true,
  setInstitutionSession: () => {},
  signOut: async () => {},
})

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [session, setSession] = useState<any | null>(null)
  const [user, setUser] = useState<any | null>(null)
  const [institution, setInstitution] = useState<InstitutionSession | null>(null)
  const [loading, setLoading] = useState(true)

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
      }
    } catch (err) {
      console.error('Error syncing institution:', err)
    }
  }

  useEffect(() => {
    // 1. Check if an institution session is active in storage
    const storedInst = sessionStorage.getItem('eduai_inst_session')
    if (storedInst) {
      try {
        const parsed: InstitutionSession = JSON.parse(storedInst)
        setInstitution(parsed)
        const mockUser = {
          id: parsed.id || 'admin',
          email: parsed.admin_email,
          user_metadata: {
            role: 'admin',
            institution_id: parsed.id,
            institution_code: parsed.code,
            full_name: `${parsed.short_name || parsed.name} Administrator`
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
        if (session.user.email) {
          await syncInstitutionFromEmail(session.user.email)
        }
      }
      setLoading(false)
    })

    return () => subscription.unsubscribe()
  }, [])

  const setInstitutionSession = (inst: InstitutionSession) => {
    sessionStorage.setItem('eduai_inst_session', JSON.stringify(inst))
    setInstitution(inst)
    const mockUser = {
      id: inst.id || 'admin',
      email: inst.admin_email,
      user_metadata: {
        role: 'admin',
        institution_id: inst.id,
        institution_code: inst.code,
        full_name: `${inst.short_name || inst.name} Administrator`
      }
    }
    setUser(mockUser)
    setSession({ user: mockUser })
  }

  const signOut = async () => {
    sessionStorage.removeItem('eduai_inst_session')
    setInstitution(null)
    setSession(null)
    setUser(null)
    await supabase.auth.signOut().catch(() => {})
  }

  return (
    <AuthContext.Provider value={{ session, user, institution, loading, setInstitutionSession, signOut }}>
      {children}
    </AuthContext.Provider>
  )
}

export const useAuth = () => {
  return useContext(AuthContext)
}
