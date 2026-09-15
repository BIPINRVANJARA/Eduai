import { lazy, Suspense } from 'react'
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import Layout from './components/Layout'
import { useAuth } from './contexts/AuthContext'

// Route-level code splitting for fast initial load
const LandingPage = lazy(() => import('./pages/LandingPage'))
const LoginPage = lazy(() => import('./pages/LoginPage'))
const DashboardPage = lazy(() => import('./pages/DashboardPage'))
const DepartmentsPage = lazy(() => import('./pages/DepartmentsPage'))
const StudentsPage = lazy(() => import('./pages/StudentsPage'))
const ApprovalsPage = lazy(() => import('./pages/ApprovalsPage'))
const SuperAdminPage = lazy(() => import('./pages/SuperAdminPage'))
const AttendanceMarksPage = lazy(() => import('./pages/AttendanceMarksPage'))
const DocumentsPage = lazy(() => import('./pages/DocumentsPage'))
const UploadPage = lazy(() => import('./pages/UploadPage'))
const AlertsPage = lazy(() => import('./pages/AlertsPage'))
const SettingsPage = lazy(() => import('./pages/SettingsPage'))
const AiCommandCenterPage = lazy(() => import('./pages/AiCommandCenterPage'))

const PageLoader = () => (
  <div className="min-h-screen bg-background text-text-primary flex flex-col items-center justify-center gap-3">
    <div className="w-8 h-8 border-2 border-primary border-t-transparent rounded-full animate-spin" />
    <span className="text-xs text-text-secondary font-medium tracking-wide">Loading Edu AI...</span>
  </div>
)

function App() {
  const { session, loading } = useAuth()

  if (loading) {
    return <PageLoader />
  }

  return (
    <Router>
      <Suspense fallback={<PageLoader />}>
        <Routes>
          {/* 🌟 Edu AI Premium Landing Page */}
          <Route path="/" element={<LandingPage />} />
          <Route path="/landing" element={<LandingPage />} />

          <Route 
            path="/login" 
            element={session ? <Navigate to="/ai-copilot" replace /> : <LoginPage />} 
          />
          
          {/* 👑 Super Admin (Platform Owner) Dedicated Portal */}
          <Route path="/super-admin" element={<SuperAdminPage />} />

          {/* 🏫 Institution College & Department Admin Portal */}
          <Route element={<Layout />}>
            <Route path="/ai-copilot" element={<AiCommandCenterPage />} />
            <Route path="/departments" element={<DepartmentsPage />} />
            <Route path="/approvals" element={<ApprovalsPage />} />
            <Route path="/attendance-marks" element={<AttendanceMarksPage />} />
            <Route path="/dashboard" element={<DashboardPage />} />
            <Route path="/students" element={<StudentsPage />} />
            <Route path="/documents" element={<DocumentsPage />} />
            <Route path="/upload" element={<UploadPage />} />
            <Route path="/alerts" element={<AlertsPage />} />
            <Route path="/settings" element={<SettingsPage />} />
          </Route>
        </Routes>
      </Suspense>
    </Router>
  )
}

export default App
