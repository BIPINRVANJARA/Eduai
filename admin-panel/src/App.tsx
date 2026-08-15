import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import Layout from './components/Layout'
import LoginPage from './pages/LoginPage'
import DashboardPage from './pages/DashboardPage'
import StudentsPage from './pages/StudentsPage'
import ApprovalsPage from './pages/ApprovalsPage'
import SuperAdminPage from './pages/SuperAdminPage'
import AttendanceMarksPage from './pages/AttendanceMarksPage'
import DocumentsPage from './pages/DocumentsPage'
import UploadPage from './pages/UploadPage'
import AlertsPage from './pages/AlertsPage'
import SettingsPage from './pages/SettingsPage'
import AiCommandCenterPage from './pages/AiCommandCenterPage'
import { useAuth } from './contexts/AuthContext'

function App() {
  const { session, loading } = useAuth()

  if (loading) {
    return <div className="min-h-screen bg-background text-text-primary flex items-center justify-center">Loading...</div>
  }

  return (
    <Router>
      <Routes>
        <Route 
          path="/login" 
          element={session ? <Navigate to="/ai-copilot" replace /> : <LoginPage />} 
        />
        
        {/* 👑 Super Admin (Platform Owner) Dedicated Portal */}
        <Route path="/super-admin" element={<SuperAdminPage />} />

        {/* 🏫 Institution College Admin Portal */}
        <Route element={<Layout />}>
          <Route path="/" element={<Navigate to="/ai-copilot" replace />} />
          <Route path="/ai-copilot" element={<AiCommandCenterPage />} />
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
    </Router>
  )
}

export default App
