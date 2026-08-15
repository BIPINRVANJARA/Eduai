import { useState, useEffect } from 'react'
import { Link } from 'react-router-dom'
import { 
  Sparkles, 
  ArrowRight, 
  CheckCircle2, 
  Calendar, 
  ShieldCheck, 
  Activity, 
  Lock, 
  ChevronRight, 
  Zap, 
  Check, 
  Languages, 
  BookOpen, 
  FileSpreadsheet, 
  BarChart3, 
  Menu, 
  X 
} from 'lucide-react'
import IPhone17Mockup, { type IPhoneScreenType } from '../components/landing/IPhone17Mockup'

export default function LandingPage() {
  // Navigation & Scroll states
  const [isScrolled, setIsScrolled] = useState(false)
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false)

  // Interactive Storytelling State (5 Stages)
  const [activeStoryStage, setActiveStoryStage] = useState<IPhoneScreenType>('timetable')

  // Interactive AI Copilot Language & Prompt state
  const [aiLang, setAiLang] = useState<'en' | 'gu' | 'hi'>('en')
  const [activeAiQueryIndex, setActiveAiQueryIndex] = useState(0)

  // Role Experience Tab State
  const [activeRole, setActiveRole] = useState<'student' | 'parent' | 'faculty' | 'institution'>('student')

  // Ingestion Simulator State
  const [ingestionState, setIngestionState] = useState<'idle' | 'processing' | 'completed'>('idle')
  const [ingestionProgress, setIngestionProgress] = useState(0)

  // Security Architecture Accordion State
  const [securityExpanded, setSecurityExpanded] = useState(false)

  // Demo Modal State
  const [showDemoModal, setShowDemoModal] = useState(false)
  const [demoForm, setDemoForm] = useState({ name: '', college: '', email: '', role: 'Principal / HOD' })
  const [demoSubmitted, setDemoSubmitted] = useState(false)

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 40)
    }
    window.addEventListener('scroll', handleScroll)
    return () => window.removeEventListener('scroll', handleScroll)
  }, [])

  // Ingestion Simulator Action
  const triggerIngestionSimulation = () => {
    if (ingestionState === 'processing') return
    setIngestionState('processing')
    setIngestionProgress(0)

    const interval = setInterval(() => {
      setIngestionProgress(prev => {
        if (prev >= 100) {
          clearInterval(interval)
          setIngestionState('completed')
          return 100
        }
        return prev + 20
      })
    }, 280)
  }

  // Multilingual AI prompts
  const aiPrompts = {
    en: [
      { q: "How much attendance do I have in AIPE?", a: "Your attendance in AIPE is 84.6% (11 out of 13 sessions). You are well above the mandatory 75% GTU eligibility threshold." },
      { q: "What classes do I have tomorrow?", a: "You have 4 sessions tomorrow: 10:30 AM AIPE (Lab 2), 12:00 PM DBMS (Room 204), 2:00 PM Cyber Security, and 3:30 PM Project Lab." },
      { q: "Give me the Lab Manual for Database Systems.", a: "Found 'DBMS_Practical_Manual_2026.pdf' (3.2 MB) in your department repository. Verified by Prof. Mehta." }
    ],
    gu: [
      { q: "મારી AIPE માં attendance કેટલી છે?", a: "તમારી AIPE માં હાજરી 84.6% છે (13 માંથી 11 સત્રો). તમે GTU ના 75% ના નિયમ મુજબ પરીક્ષા માટે સંપૂર્ણ રીતે યોગ્ય છો." },
      { q: "કાલે મારી કઈ classes છે?", a: "કાલે તમારી 4 કક્ષા છે: 10:30 AIPE (લેબ 2), 12:00 DBMS (રૂમ 204), 2:00 સાયબર સિક્યુરિટી, અને 3:30 પ્રોજેક્ટ લેબ." },
      { q: "મને ડેટાબેઝ મેનેજમેન્ટનું લેબ મેન્યુઅલ આપો.", a: "તમારા વિભાગમાંથી 'DBMS_Practical_Manual_2026.pdf' (3.2 MB) ઉપલબ્ધ છે. પ્રો. મહેતા દ્વારા ચકાસાયેલ છે." }
    ],
    hi: [
      { q: "मेरी AIPE में attendance कितनी है?", a: "आपकी AIPE में उपस्थिति 84.6% है (13 में से 11 सत्र)। आप 75% अनिवार्य GTU सीमा से सुरक्षित रूप से ऊपर हैं।" },
      { q: "कल मेरी कौनसी कक्षाएं हैं?", a: "कल आपकी 4 कक्षाएं हैं: सुबह 10:30 AIPE (लैब 2), दोपहर 12:00 DBMS (कमरा 204), दोपहर 2:00 साइबर सिक्योरिटी, और 3:30 प्रोजेक्ट लैब।" },
      { q: "मुझे डेटाबेस का लैब मैनुअल दीजिए।", a: "'DBMS_Practical_Manual_2026.pdf' (3.2 MB) उपलब्ध है। प्रो. मेहता द्वारा सत्यापित।" }
    ]
  }

  return (
    <div className="min-h-screen bg-[#0B0F17] text-[#F7F8FA] font-sans selection:bg-primary selection:text-[#0B0F17] overflow-x-hidden">
      
      {/* ==================================================================== */}
      {/* 1. MINIMAL PREMIUM NAVIGATION BAR                                    */}
      {/* ==================================================================== */}
      <nav 
        className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${
          isScrolled 
            ? 'bg-[#0B0F17]/85 backdrop-blur-md border-b border-white/8 py-3.5 shadow-2xl' 
            : 'bg-transparent py-5'
        }`}
      >
        <div className="max-w-7xl mx-auto px-6 sm:px-8 flex items-center justify-between">
          {/* Brand Mark */}
          <Link to="/" className="flex items-center gap-2.5 group">
            <div className="w-8 h-8 rounded-xl bg-[#131B2A] border border-white/10 flex items-center justify-center shadow-md group-hover:border-primary/40 transition-colors">
              <div className="w-2.5 h-2.5 rounded-full bg-primary animate-pulse" />
            </div>
            <div className="flex flex-col">
              <span className="text-base font-extrabold tracking-tight text-white group-hover:text-primary transition-colors">
                Timestunner
              </span>
              <span className="text-[9px] uppercase tracking-widest text-text-secondary -mt-1 font-semibold">
                Eduai Academic OS
              </span>
            </div>
          </Link>

          {/* Desktop Navigation Links */}
          <div className="hidden md:flex items-center gap-7 text-xs font-medium text-text-secondary">
            <a href="#product" className="hover:text-white transition-colors">Product</a>
            <a href="#experience" className="hover:text-white transition-colors">For Students</a>
            <a href="#admin" className="hover:text-white transition-colors">For Colleges</a>
            <a href="#copilot" className="hover:text-white transition-colors">AI Copilot</a>
            <a href="#security" className="hover:text-white transition-colors">Security</a>
            <a href="#benchmarks" className="hover:text-white transition-colors">Targets</a>
          </div>

          {/* Right Action CTAs */}
          <div className="hidden sm:flex items-center gap-3">
            <Link
              to="/super-admin"
              className="text-xs font-bold text-text-secondary hover:text-white px-3 py-2 rounded-xl transition-colors flex items-center gap-1.5"
            >
              <ShieldCheck size={14} className="text-primary" />
              Super Admin
            </Link>

            <Link
              to="/login"
              className="text-xs font-bold text-white bg-[#131B2A] border border-white/10 hover:border-white/25 px-4 py-2 rounded-xl transition-all shadow-sm"
            >
              College Admin Log In
            </Link>

            <button
              onClick={() => setShowDemoModal(true)}
              className="text-xs font-extrabold text-[#0B0F17] bg-primary hover:bg-[#c4f85e] px-4 py-2 rounded-xl transition-all shadow-lg shadow-primary/20 cursor-pointer flex items-center gap-1.5"
            >
              Request a Demo
            </button>
          </div>

          {/* Mobile Menu Toggle */}
          <button 
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            className="md:hidden text-white/80 p-1.5 rounded-lg bg-surface border border-white/10"
          >
            {mobileMenuOpen ? <X size={20} /> : <Menu size={20} />}
          </button>
        </div>

        {/* Mobile Dropdown */}
        {mobileMenuOpen && (
          <div className="md:hidden bg-[#0B0F17]/95 backdrop-blur-xl border-b border-white/10 px-6 py-6 space-y-4 text-sm animate-fade-in">
            <div className="flex flex-col space-y-3 font-medium text-text-secondary">
              <a href="#product" onClick={() => setMobileMenuOpen(false)} className="hover:text-white">Product</a>
              <a href="#experience" onClick={() => setMobileMenuOpen(false)} className="hover:text-white">For Students</a>
              <a href="#admin" onClick={() => setMobileMenuOpen(false)} className="hover:text-white">For Colleges</a>
              <a href="#copilot" onClick={() => setMobileMenuOpen(false)} className="hover:text-white">AI Copilot</a>
              <a href="#security" onClick={() => setMobileMenuOpen(false)} className="hover:text-white">Security</a>
            </div>
            <div className="pt-4 border-t border-white/10 flex flex-col gap-2.5">
              <Link to="/login" className="w-full text-center py-2.5 rounded-xl bg-surface border border-white/10 font-bold text-xs text-white">
                College Admin Log In
              </Link>
              <Link to="/super-admin" className="w-full text-center py-2.5 rounded-xl bg-surface border border-white/10 font-bold text-xs text-text-secondary">
                Super Admin Portal
              </Link>
              <button onClick={() => { setShowDemoModal(true); setMobileMenuOpen(false); }} className="w-full text-center py-2.5 rounded-xl bg-primary text-background font-extrabold text-xs">
                Request a Demo
              </button>
            </div>
          </div>
        )}
      </nav>

      {/* ==================================================================== */}
      {/* 2. HERO SECTION — FEATURING PRIMARY IPHONE 17 PRO MAX                */}
      {/* ==================================================================== */}
      <section className="relative pt-32 sm:pt-40 pb-20 sm:pb-32 px-6 sm:px-8 max-w-7xl mx-auto">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 lg:gap-8 items-center">
          
          {/* Left Column: Headline, Proposition & Actions */}
          <div className="lg:col-span-7 space-y-7 text-left">
            
            {/* Quiet Eyebrow Badge */}
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#131B2A] border border-white/10 text-xs font-semibold text-text-secondary shadow-inner">
              <span className="w-2 h-2 rounded-full bg-primary" />
              <span className="tracking-wider uppercase text-[10px] font-bold text-white/90">
                The Academic Operating System
              </span>
            </div>

            {/* Hero Headline */}
            <h1 className="text-4xl sm:text-6xl lg:text-7xl font-extrabold tracking-tight text-white leading-[1.06]">
              Your entire academic life. <br />
              <span className="text-white">Finally in sync.</span>
            </h1>

            {/* Supporting Copy */}
            <p className="text-base sm:text-lg text-text-secondary max-w-xl font-normal leading-relaxed">
              Timestunner connects students, parents, faculty, and institutions through one intelligent academic system. Less searching. Less paperwork. More academic control.
            </p>

            {/* CTAs */}
            <div className="flex flex-col sm:flex-row items-start sm:items-center gap-3.5 pt-2">
              <a
                href="#experience"
                className="w-full sm:w-auto px-6 py-3.5 rounded-xl bg-primary hover:bg-[#c4f85e] text-[#0B0F17] font-black text-sm transition-all shadow-xl shadow-primary/20 flex items-center justify-center gap-2 group cursor-pointer"
              >
                <span>Explore Timestunner</span>
                <ArrowRight size={16} className="group-hover:translate-x-1 transition-transform" />
              </a>

              <a
                href="#admin"
                className="w-full sm:w-auto px-6 py-3.5 rounded-xl bg-[#131B2A] hover:bg-[#1A2436] text-white border border-white/10 font-bold text-sm transition-all flex items-center justify-center gap-2"
              >
                <span>For Colleges</span>
                <ChevronRight size={16} className="text-text-secondary" />
              </a>
            </div>

            {/* Quiet Credibility Statement */}
            <div className="pt-4 flex items-center gap-2 text-xs font-medium text-text-secondary/80">
              <span className="text-primary font-bold">●</span>
              <span>Timetables · Attendance · Marks · Documents · Multilingual AI</span>
            </div>
          </div>

          {/* Right Column: Grounded Photorealistic iPhone 17 Pro Max */}
          <div className="lg:col-span-5 flex justify-center relative">
            <IPhone17Mockup
              screen="student-hero"
              tiltDegree={-2}
              className="hover:scale-[1.01] transition-transform duration-700"
            />
          </div>
        </div>
      </section>

      {/* ==================================================================== */}
      {/* 3. TRUST / SOCIAL PROOF STRIP                                        */}
      {/* ==================================================================== */}
      <section className="border-y border-white/6 bg-[#0E1420]/60 py-10 px-6">
        <div className="max-w-6xl mx-auto text-center space-y-4">
          <p className="text-[11px] uppercase tracking-widest font-extrabold text-text-secondary/70">
            Built for the realities of modern higher education
          </p>
          <div className="flex flex-wrap items-center justify-center gap-6 sm:gap-10 text-xs sm:text-sm font-extrabold tracking-wider text-text-secondary">
            <span className="hover:text-white transition-colors">STUDENTS</span>
            <span className="text-white/20">/</span>
            <span className="hover:text-white transition-colors">FACULTY</span>
            <span className="text-white/20">/</span>
            <span className="hover:text-white transition-colors">HODs</span>
            <span className="text-white/20">/</span>
            <span className="hover:text-white transition-colors">ADMINISTRATORS</span>
            <span className="text-white/20">/</span>
            <span className="hover:text-white transition-colors">PARENTS</span>
            <span className="text-white/20">/</span>
            <span className="hover:text-white transition-colors">INSTITUTIONS</span>
          </div>
        </div>
      </section>

      {/* ==================================================================== */}
      {/* 4. THE PROBLEM: ACADEMIC FRAGMENTATION VS TIMESTUNNER                */}
      {/* ==================================================================== */}
      <section id="problem" className="py-24 sm:py-32 px-6 sm:px-8 max-w-7xl mx-auto">
        <div className="space-y-4 max-w-3xl mb-16 text-left">
          <span className="text-xs uppercase tracking-widest font-extrabold text-primary">The Fragmentation Problem</span>
          <h2 className="text-3xl sm:text-5xl font-extrabold tracking-tight text-white leading-tight">
            Academic information shouldn't be scattered everywhere.
          </h2>
          <p className="text-base text-text-secondary leading-relaxed">
            Students and faculty waste hours searching across disconnected channels, while parents remain completely in the dark. Timestunner replaces confusion with clarity.
          </p>
        </div>

        {/* Editorial Contrast Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 items-stretch">
          
          {/* Traditional Academic Life */}
          <div className="bg-[#131B2A]/40 border border-white/8 rounded-3xl p-8 space-y-6 flex flex-col justify-between">
            <div className="space-y-4">
              <span className="text-[11px] uppercase tracking-widest font-extrabold text-danger bg-danger/10 px-3 py-1 rounded-md inline-block">
                Traditional Campus Chaos
              </span>
              <h3 className="text-xl font-bold text-white">Fragmented & Manual</h3>
              <p className="text-sm text-text-secondary leading-relaxed">
                Important timetables buried in unsearchable WhatsApp chats, marks locked in faculty spreadsheets, and attendance shortfalls discovered too late.
              </p>
            </div>

            <div className="space-y-2.5 pt-4 text-xs text-text-secondary">
              <div className="flex items-center gap-2.5 p-2.5 bg-[#0B0F17] rounded-xl border border-white/5">
                <X size={14} className="text-danger shrink-0" />
                <span>Lost PDF attachments in 20+ different class groups</span>
              </div>
              <div className="flex items-center gap-2.5 p-2.5 bg-[#0B0F17] rounded-xl border border-white/5">
                <X size={14} className="text-danger shrink-0" />
                <span>Manual attendance rolls calculated only at end-of-term</span>
              </div>
              <div className="flex items-center gap-2.5 p-2.5 bg-[#0B0F17] rounded-xl border border-white/5">
                <X size={14} className="text-danger shrink-0" />
                <span>Parents unaware of student status until exam hall tickets are blocked</span>
              </div>
            </div>
          </div>

          {/* Timestunner Unified OS */}
          <div className="bg-gradient-to-br from-[#131B2A] to-[#172338] border border-primary/30 rounded-3xl p-8 space-y-6 flex flex-col justify-between shadow-2xl relative overflow-hidden">
            <div className="absolute top-0 right-0 w-36 h-36 bg-primary/10 rounded-full blur-2xl pointer-events-none" />
            
            <div className="space-y-4 relative z-10">
              <span className="text-[11px] uppercase tracking-widest font-extrabold text-primary bg-primary/15 px-3 py-1 rounded-md inline-block">
                Timestunner Experience
              </span>
              <h3 className="text-xl font-bold text-white">One Intelligent Academic System</h3>
              <p className="text-sm text-text-secondary leading-relaxed">
                A single source of verified academic truth. Live timetable sync, continuous attendance monitoring, instant marks access, and an AI copilot that knows your campus.
              </p>
            </div>

            <div className="space-y-2.5 pt-4 text-xs text-white relative z-10">
              <div className="flex items-center gap-2.5 p-2.5 bg-[#0B0F17]/80 rounded-xl border border-primary/20">
                <CheckCircle2 size={14} className="text-primary shrink-0" />
                <span>All lab manuals, circulars & syllabi indexed with 14+ tags</span>
              </div>
              <div className="flex items-center gap-2.5 p-2.5 bg-[#0B0F17]/80 rounded-xl border border-primary/20">
                <CheckCircle2 size={14} className="text-primary shrink-0" />
                <span>Live GTU 75% attendance threshold monitoring & defaulter warnings</span>
              </div>
              <div className="flex items-center gap-2.5 p-2.5 bg-[#0B0F17]/80 rounded-xl border border-primary/20">
                <CheckCircle2 size={14} className="text-primary shrink-0" />
                <span>Guardian visibility with verified OTP-secured child overview</span>
              </div>
            </div>
          </div>

        </div>
      </section>

      {/* ==================================================================== */}
      {/* 5. CORE PRODUCT SECTION — FOUR PILLARS                                */}
      {/* ==================================================================== */}
      <section id="product" className="py-24 sm:py-32 px-6 sm:px-8 max-w-7xl mx-auto border-t border-white/6">
        <div className="space-y-4 max-w-3xl mb-16 text-left">
          <span className="text-xs uppercase tracking-widest font-extrabold text-primary">Platform Capabilities</span>
          <h2 className="text-3xl sm:text-5xl font-extrabold tracking-tight text-white">
            Everything students need. <br />
            Everything colleges need.
          </h2>
          <p className="text-base text-text-secondary">
            Engineered around the daily rhythm of university campuses.
          </p>
        </div>

        {/* 4 Core Pillars Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 text-left">
          
          {/* 1. Timetable */}
          <div className="bg-surface p-6 rounded-3xl border border-card-border hover:border-primary/40 transition-all space-y-4 flex flex-col justify-between group">
            <div className="space-y-3">
              <div className="w-10 h-10 rounded-2xl bg-primary/10 border border-primary/30 flex items-center justify-center text-primary group-hover:scale-110 transition-transform">
                <Calendar size={20} />
              </div>
              <h3 className="text-lg font-bold text-white">Timetable</h3>
              <p className="text-xs text-text-secondary leading-relaxed">
                Know where you need to be next. Live daily schedule with class rooms, laboratory assignments, and sudden schedule changes.
              </p>
            </div>
            <div className="bg-[#0B0F17] p-3 rounded-2xl border border-white/5 text-[10px] text-text-secondary space-y-1">
              <span className="text-primary font-bold">Next Lecture:</span>
              <p className="text-white font-semibold">10:30 AM · AI & ML (Lab 2)</p>
            </div>
          </div>

          {/* 2. Attendance */}
          <div className="bg-surface p-6 rounded-3xl border border-card-border hover:border-primary/40 transition-all space-y-4 flex flex-col justify-between group">
            <div className="space-y-3">
              <div className="w-10 h-10 rounded-2xl bg-primary/10 border border-primary/30 flex items-center justify-center text-primary group-hover:scale-110 transition-transform">
                <Activity size={20} />
              </div>
              <h3 className="text-lg font-bold text-white">Attendance</h3>
              <p className="text-xs text-text-secondary leading-relaxed">
                Know whether you're eligible. Subject-level attendance tracking calibrated against GTU 75% examination thresholds.
              </p>
            </div>
            <div className="bg-[#0B0F17] p-3 rounded-2xl border border-white/5 text-[10px] flex items-center justify-between">
              <span className="text-white font-bold">Current Standing</span>
              <span className="text-primary font-black bg-primary/10 px-2 py-0.5 rounded">87.4% Eligible</span>
            </div>
          </div>

          {/* 3. Academic Records */}
          <div className="bg-surface p-6 rounded-3xl border border-card-border hover:border-primary/40 transition-all space-y-4 flex flex-col justify-between group">
            <div className="space-y-3">
              <div className="w-10 h-10 rounded-2xl bg-accent/10 border border-accent/30 flex items-center justify-center text-accent group-hover:scale-110 transition-transform">
                <BarChart3 size={20} />
              </div>
              <h3 className="text-lg font-bold text-white">Academic Records</h3>
              <p className="text-xs text-text-secondary leading-relaxed">
                Your marks, without the spreadsheet hunt. Instant access to mid-semester test results, practical scores, and term evaluations.
              </p>
            </div>
            <div className="bg-[#0B0F17] p-3 rounded-2xl border border-white/5 text-[10px] flex items-center justify-between">
              <span className="text-white font-semibold">Mid-Sem Avg</span>
              <span className="text-accent font-bold">28.5 / 30 (Grade A+)</span>
            </div>
          </div>

          {/* 4. Documents */}
          <div className="bg-surface p-6 rounded-3xl border border-card-border hover:border-primary/40 transition-all space-y-4 flex flex-col justify-between group">
            <div className="space-y-3">
              <div className="w-10 h-10 rounded-2xl bg-cyan/10 border border-cyan/30 flex items-center justify-center text-cyan group-hover:scale-110 transition-transform">
                <BookOpen size={20} />
              </div>
              <h3 className="text-lg font-bold text-white">Documents</h3>
              <p className="text-xs text-text-secondary leading-relaxed">
                The right academic document, when you need it. Lab manuals, circulars, syllabus PDFs, and official university notices.
              </p>
            </div>
            <div className="bg-[#0B0F17] p-3 rounded-2xl border border-white/5 text-[10px] flex items-center justify-between">
              <span className="text-white font-semibold">Indexed Files</span>
              <span className="text-cyan font-bold">14+ Multilingual Tags</span>
            </div>
          </div>

        </div>
      </section>

      {/* ==================================================================== */}
      {/* 6. PRODUCT EXPERIENCE: THREE IPHONE 17 PRO DISPLAY                   */}
      {/* ==================================================================== */}
      <section id="experience" className="py-24 sm:py-32 px-6 sm:px-8 max-w-7xl mx-auto border-t border-white/6">
        <div className="text-center space-y-4 max-w-3xl mx-auto mb-20">
          <span className="text-xs uppercase tracking-widest font-extrabold text-primary">Product Experience</span>
          <h2 className="text-3xl sm:text-5xl font-extrabold tracking-tight text-white">
            Everything you need. <br />
            Right when you need it.
          </h2>
          <p className="text-base text-text-secondary">
            Experience the native mobile interface built with Apple-grade polish for everyday campus life.
          </p>
        </div>

        {/* 3 iPhones Side-by-Side */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-10 items-center justify-items-center">
          
          {/* Phone 1: Timetable */}
          <div className="space-y-6 flex flex-col items-center">
            <IPhone17Mockup screen="timetable" tiltDegree={-1} />
            <div className="text-center space-y-1.5 max-w-xs">
              <h4 className="text-base font-extrabold text-white">Know what's next.</h4>
              <p className="text-xs text-text-secondary">
                Your daily schedule, lab allocations, room numbers, and faculty changes synced in real time.
              </p>
            </div>
          </div>

          {/* Phone 2: Attendance */}
          <div className="space-y-6 flex flex-col items-center">
            <IPhone17Mockup screen="attendance" tiltDegree={0} />
            <div className="text-center space-y-1.5 max-w-xs">
              <h4 className="text-base font-extrabold text-white">Know where you stand.</h4>
              <p className="text-xs text-text-secondary">
                Track your attendance percentage per subject and stay safely above the mandatory 75% exam threshold.
              </p>
            </div>
          </div>

          {/* Phone 3: AI Copilot */}
          <div className="space-y-6 flex flex-col items-center">
            <IPhone17Mockup screen="ai-copilot" tiltDegree={1} />
            <div className="text-center space-y-1.5 max-w-xs">
              <h4 className="text-base font-extrabold text-white">Ask. Don't search.</h4>
              <p className="text-xs text-text-secondary">
                Your academic copilot understands queries in English, Gujarati, and Hindi with verified database retrieval.
              </p>
            </div>
          </div>

        </div>
      </section>

      {/* ==================================================================== */}
      {/* 7. STICKY STORYTELLING SCROLL SHOWCASE (5 APP STATES)                */}
      {/* ==================================================================== */}
      <section className="py-24 sm:py-32 px-6 sm:px-8 max-w-7xl mx-auto border-t border-white/6 bg-[#0E1420]/40 rounded-3xl my-10">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
          
          {/* Left Column: Stage Selectors */}
          <div className="lg:col-span-6 space-y-6 text-left">
            <div className="space-y-2">
              <span className="text-xs uppercase tracking-widest font-extrabold text-primary">Interactive Product Tour</span>
              <h2 className="text-3xl sm:text-4xl font-extrabold text-white tracking-tight">
                One app. Every academic moment.
              </h2>
              <p className="text-sm text-text-secondary">
                Click through the 5 core lifecycle moments of a student's daily routine:
              </p>
            </div>

            <div className="space-y-2.5">
              {[
                { id: 'timetable', title: '01 · Your Day', desc: 'Real-time lectures, room indicators, and faculty schedule updates.' },
                { id: 'attendance', title: '02 · Your Progress', desc: 'Subject-by-subject attendance records with automated GTU eligibility indicators.' },
                { id: 'documents', title: '03 · Your Documents', desc: 'Instant repository search for lab manuals, assignment briefs, and circulars.' },
                { id: 'ai-copilot', title: '04 · Your AI Copilot', desc: 'Natural language academic Q&A in English, Gujarati, and Hindi.' },
                { id: 'alerts', title: '05 · Campus Broadcasts', desc: 'Instant administrative announcements and emergency holiday notices.' }
              ].map(stage => (
                <div
                  key={stage.id}
                  onClick={() => setActiveStoryStage(stage.id as IPhoneScreenType)}
                  className={`p-4 rounded-2xl border transition-all cursor-pointer ${
                    activeStoryStage === stage.id
                      ? 'bg-surface border-primary/50 shadow-lg'
                      : 'bg-transparent border-white/5 hover:border-white/20'
                  }`}
                >
                  <div className="flex items-center justify-between">
                    <h4 className={`text-sm font-bold ${activeStoryStage === stage.id ? 'text-primary' : 'text-white'}`}>
                      {stage.title}
                    </h4>
                    {activeStoryStage === stage.id && <Check size={16} className="text-primary" />}
                  </div>
                  <p className="text-xs text-text-secondary mt-1">{stage.desc}</p>
                </div>
              ))}
            </div>
          </div>

          {/* Right Column: Dynamic Screen Morphing iPhone 17 */}
          <div className="lg:col-span-6 flex justify-center">
            <IPhone17Mockup 
              screen={activeStoryStage} 
              className="scale-105 transition-all duration-500" 
            />
          </div>

        </div>
      </section>

      {/* ==================================================================== */}
      {/* 8. DEDICATED MULTILINGUAL AI COPILOT SECTION                         */}
      {/* ==================================================================== */}
      <section id="copilot" className="py-24 sm:py-32 px-6 sm:px-8 max-w-7xl mx-auto border-t border-white/6">
        <div className="text-center space-y-4 max-w-3xl mx-auto mb-16">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-cyan/10 border border-cyan/30 text-cyan text-xs font-bold">
            <Sparkles size={14} />
            <span>Context-Aware Academic Intelligence</span>
          </div>
          <h2 className="text-3xl sm:text-5xl font-extrabold tracking-tight text-white">
            Ask your academics.
          </h2>
          <p className="text-base text-text-secondary">
            Timestunner's AI Copilot understands your academic context and retrieves verified information directly from your institution's live database.
          </p>
        </div>

        {/* Live Interactive Conversational Tester */}
        <div className="max-w-4xl mx-auto bg-surface rounded-3xl border border-card-border p-6 sm:p-10 shadow-2xl space-y-8">
          
          {/* Language Switcher */}
          <div className="flex flex-wrap items-center justify-between gap-4 border-b border-card-border pb-6">
            <div className="flex items-center gap-2">
              <Languages size={18} className="text-cyan" />
              <span className="text-xs font-bold text-white uppercase tracking-wider">Select Multilingual Dialect:</span>
            </div>

            <div className="flex gap-2">
              {(['en', 'gu', 'hi'] as const).map(lang => (
                <button
                  key={lang}
                  onClick={() => { setAiLang(lang); setActiveAiQueryIndex(0); }}
                  className={`px-3 py-1.5 rounded-xl text-xs font-bold transition-all cursor-pointer ${
                    aiLang === lang
                      ? 'bg-cyan text-background shadow-md'
                      : 'bg-surface-light text-text-secondary hover:text-white border border-white/5'
                  }`}
                >
                  {lang === 'en' ? 'English' : lang === 'gu' ? 'ગુજરાતી (Gujarati)' : 'हिन्दी (Hindi)'}
                </button>
              ))}
            </div>
          </div>

          {/* Quick Query Picker */}
          <div className="space-y-2">
            <span className="text-xs font-semibold text-text-secondary">Try an example student prompt:</span>
            <div className="flex flex-wrap gap-2">
              {aiPrompts[aiLang].map((item, idx) => (
                <button
                  key={idx}
                  onClick={() => setActiveAiQueryIndex(idx)}
                  className={`px-3.5 py-2 rounded-xl text-xs font-medium transition-all text-left cursor-pointer ${
                    activeAiQueryIndex === idx
                      ? 'bg-primary/15 border border-primary/40 text-primary font-bold'
                      : 'bg-surface-light border border-white/5 text-text-secondary hover:text-white'
                  }`}
                >
                  "{item.q}"
                </button>
              ))}
            </div>
          </div>

          {/* AI Dialogue Visualizer */}
          <div className="bg-[#0B0F17] rounded-2xl p-6 border border-white/10 space-y-4">
            {/* Student Message */}
            <div className="flex justify-end">
              <div className="bg-primary text-background font-bold px-4 py-2.5 rounded-2xl rounded-tr-xs text-sm max-w-lg shadow">
                "{aiPrompts[aiLang][activeAiQueryIndex].q}"
              </div>
            </div>

            {/* AI Verified Response */}
            <div className="flex justify-start">
              <div className="bg-surface p-4 rounded-2xl rounded-tl-xs border border-cyan/30 text-sm max-w-xl space-y-2 text-white shadow-lg">
                <div className="flex items-center justify-between border-b border-white/5 pb-1.5">
                  <span className="text-[10px] font-bold text-cyan flex items-center gap-1.5 uppercase tracking-wider">
                    <ShieldCheck size={13} /> Verified Institution Data
                  </span>
                  <span className="text-[10px] font-mono text-text-secondary">Latency: 420ms</span>
                </div>
                <p className="text-white/90 leading-relaxed">
                  {aiPrompts[aiLang][activeAiQueryIndex].a}
                </p>
              </div>
            </div>
          </div>

          {/* Live Voice & Document Retrieval Showcase with Real Screenshots */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-8 pt-4 items-center">
            <div className="flex flex-col items-center space-y-3">
              <IPhone17Mockup imageSrc="/mockups/voice_assistant_response.jpeg" className="scale-95" />
              <div className="text-center space-y-1">
                <span className="text-[11px] font-bold text-primary">Student Voice Assistant (ગુજરાતી · English · हिंदी)</span>
                <p className="text-[10px] text-text-secondary">Instant spoken query answers and direct assignment document download</p>
              </div>
            </div>

            <div className="flex flex-col items-center space-y-3">
              <IPhone17Mockup imageSrc="/mockups/ai_chat_document.jpeg" className="scale-95" />
              <div className="text-center space-y-1">
                <span className="text-[11px] font-bold text-cyan">In-Chat Syllabus & Assignment Fetch</span>
                <p className="text-[10px] text-text-secondary">"Give me Fbc 1st assignment" → instant PDF preview & download link</p>
              </div>
            </div>
          </div>

          <div className="text-center pt-2">
            <p className="text-xs text-text-secondary">
              🔒 The AI only responds with data verified from the student's authenticated institution. Zero hallucinations.
            </p>
          </div>
        </div>
      </section>

      {/* ==================================================================== */}
      {/* 9. "NOT JUST AN AI CHATBOT" DATA PIPELINE ARCHITECTURE               */}
      {/* ==================================================================== */}
      <section className="py-24 px-6 sm:px-8 max-w-7xl mx-auto border-t border-white/6 text-left">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
          <div className="lg:col-span-6 space-y-4">
            <span className="text-xs uppercase tracking-widest font-extrabold text-primary">Deterministic RAG Pipeline</span>
            <h2 className="text-3xl sm:text-4xl font-extrabold text-white leading-tight">
              Not a chatbot. <br />
              An academic system with intelligence built in.
            </h2>
            <p className="text-sm text-text-secondary leading-relaxed">
              Unlike generic public chatbots, Timestunner operates on a closed-loop academic pipeline. It connects directly to live student rosters, GTU syllabus rules, uploaded lab manuals, and faculty announcements.
            </p>
          </div>

          <div className="lg:col-span-6 bg-surface p-6 rounded-3xl border border-card-border space-y-3">
            <span className="text-[10px] uppercase font-mono tracking-wider text-text-secondary">Live Academic Data Pipeline</span>
            <div className="space-y-2 text-xs">
              <div className="p-3 bg-[#0B0F17] rounded-xl border border-white/5 flex items-center justify-between">
                <span className="text-white font-semibold">1. Verified Student Records & GTU Roll</span>
                <span className="text-primary font-mono text-[10px]">Indexed</span>
              </div>
              <div className="p-3 bg-[#0B0F17] rounded-xl border border-white/5 flex items-center justify-between">
                <span className="text-white font-semibold">2. Institution Documents & Lab Manuals</span>
                <span className="text-primary font-mono text-[10px]">14+ Tags</span>
              </div>
              <div className="p-3 bg-[#0B0F17] rounded-xl border border-white/5 flex items-center justify-between">
                <span className="text-white font-semibold">3. Daily Timetable & Room Sync</span>
                <span className="text-primary font-mono text-[10px]">Live</span>
              </div>
              <div className="p-3 bg-gradient-to-r from-surface to-cyan/15 rounded-xl border border-cyan/30 flex items-center justify-between font-bold">
                <span className="text-cyan flex items-center gap-1.5"><Sparkles size={14} /> Timestunner Academic AI Core</span>
                <span className="text-white text-[10px] bg-cyan/20 px-2 py-0.5 rounded">Deterministic</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ==================================================================== */}
      {/* 10. ROLE-BASED EXPERIENCES: STUDENT / PARENT / FACULTY / INSTITUTION  */}
      {/* ==================================================================== */}
      <section className="py-24 sm:py-32 px-6 sm:px-8 max-w-7xl mx-auto border-t border-white/6">
        <div className="text-center space-y-4 max-w-3xl mx-auto mb-16">
          <span className="text-xs uppercase tracking-widest font-extrabold text-primary">Role-Tailored Portals</span>
          <h2 className="text-3xl sm:text-5xl font-extrabold tracking-tight text-white">
            Tailored for every campus stakeholder.
          </h2>
          <p className="text-base text-text-secondary">
            Students, parents, faculty, and administrators each get dedicated experiences built around their exact needs.
          </p>
        </div>

        {/* Role Switcher Tabs */}
        <div className="flex justify-center mb-10">
          <div className="inline-flex bg-surface p-1.5 rounded-2xl border border-card-border gap-1">
            {[
              { id: 'student', label: 'Student' },
              { id: 'parent', label: 'Parent / Guardian' },
              { id: 'faculty', label: 'Faculty' },
              { id: 'institution', label: 'Institution Admin' }
            ].map(r => (
              <button
                key={r.id}
                onClick={() => setActiveRole(r.id as any)}
                className={`px-4 sm:px-6 py-2 rounded-xl text-xs font-extrabold transition-all cursor-pointer ${
                  activeRole === r.id
                    ? 'bg-primary text-background shadow-md'
                    : 'text-text-secondary hover:text-white'
                }`}
              >
                {r.label}
              </button>
            ))}
          </div>
        </div>

        {/* Role Content Display */}
        <div className="bg-surface rounded-3xl border border-card-border p-8 sm:p-12 text-left">
          {activeRole === 'student' && (
            <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center animate-fade-in">
              <div className="lg:col-span-7 space-y-4">
                <span className="text-xs font-extrabold text-primary uppercase tracking-wider">For Students</span>
                <h3 className="text-2xl sm:text-3xl font-extrabold text-white">Stay ahead of your semester.</h3>
                <p className="text-sm text-text-secondary leading-relaxed">
                  Never miss a lecture or find out you're debarred when it's too late. Timestunner gives you complete real-time visibility over your daily schedule, attendance standing, internal marks, and exam notes.
                </p>
                <div className="grid grid-cols-2 gap-3 pt-2 text-xs">
                  <div className="p-3 bg-[#0B0F17] rounded-xl border border-white/5">
                    <h5 className="font-bold text-white">Live Attendance Tracker</h5>
                    <p className="text-[11px] text-text-secondary">GTU 75% threshold guardrail</p>
                  </div>
                  <div className="p-3 bg-[#0B0F17] rounded-xl border border-white/5">
                    <h5 className="font-bold text-white">Multilingual AI Copilot</h5>
                    <p className="text-[11px] text-text-secondary">Instant academic answers</p>
                  </div>
                </div>
              </div>
              <div className="lg:col-span-5 flex justify-center">
                <IPhone17Mockup screen="student-hero" className="scale-95" />
              </div>
            </div>
          )}

          {activeRole === 'parent' && (
            <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center animate-fade-in">
              <div className="lg:col-span-7 space-y-4">
                <span className="text-xs font-extrabold text-accent uppercase tracking-wider">For Parents & Guardians</span>
                <h3 className="text-2xl sm:text-3xl font-extrabold text-white">Know how they're doing — without asking.</h3>
                <p className="text-sm text-text-secondary leading-relaxed">
                  Parents receive direct, peaceful updates on their child's attendance progress and exam eligibility through a secure, OTP-authenticated mobile dashboard.
                </p>
                <div className="space-y-2 pt-2 text-xs">
                  <div className="flex items-center gap-2 text-white">
                    <CheckCircle2 size={16} className="text-accent" />
                    <span>Real-time notifications if attendance drops toward defalcation</span>
                  </div>
                  <div className="flex items-center gap-2 text-white">
                    <CheckCircle2 size={16} className="text-accent" />
                    <span>Mid-sem marks and university exam registration eligibility</span>
                  </div>
                </div>
              </div>
              <div className="lg:col-span-5 flex justify-center">
                <IPhone17Mockup screen="parent" className="scale-95" />
              </div>
            </div>
          )}

          {activeRole === 'faculty' && (
            <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center animate-fade-in">
              <div className="lg:col-span-7 space-y-4">
                <span className="text-xs font-extrabold text-primary uppercase tracking-wider">For Faculty & HODs</span>
                <h3 className="text-2xl sm:text-3xl font-extrabold text-white">Spend less time maintaining spreadsheets.</h3>
                <p className="text-sm text-text-secondary leading-relaxed">
                  Upload subject attendance rolls and marks spreadsheets once. Timestunner automatically parses rows, maps enrollment numbers, and computes student averages.
                </p>
                <div className="grid grid-cols-2 gap-3 pt-2 text-xs">
                  <div className="p-3 bg-[#0B0F17] rounded-xl border border-white/5">
                    <h5 className="font-bold text-white">Universal AI Ingestion</h5>
                    <p className="text-[11px] text-text-secondary">Parses messy Excel files</p>
                  </div>
                  <div className="p-3 bg-[#0B0F17] rounded-xl border border-white/5">
                    <h5 className="font-bold text-white">Campus Broadcasts</h5>
                    <p className="text-[11px] text-text-secondary">One-click push announcements</p>
                  </div>
                </div>
              </div>
              <div className="lg:col-span-5 flex justify-center">
                <IPhone17Mockup screen="portal" className="scale-95" />
              </div>
            </div>
          )}

          {activeRole === 'institution' && (
            <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center animate-fade-in">
              <div className="lg:col-span-7 space-y-4">
                <span className="text-xs font-extrabold text-cyan uppercase tracking-wider">For Institutions & Deans</span>
                <h3 className="text-2xl sm:text-3xl font-extrabold text-white">One academic system across your campus.</h3>
                <p className="text-sm text-text-secondary leading-relaxed">
                  Manage multiple engineering departments, student approvals, faculty roles, and compliance records under strict enterprise tenant isolation.
                </p>
                <div className="flex gap-4 pt-2">
                  <Link to="/login" className="px-5 py-2.5 rounded-xl bg-primary text-background font-black text-xs">
                    Access College Portal
                  </Link>
                  <Link to="/super-admin" className="px-5 py-2.5 rounded-xl bg-[#0B0F17] border border-white/10 font-bold text-xs text-white">
                    Platform Super Admin
                  </Link>
                </div>
              </div>
              <div className="lg:col-span-5 flex justify-center">
                <IPhone17Mockup screen="register" className="scale-95" />
              </div>
            </div>
          )}
        </div>
      </section>

      {/* ==================================================================== */}
      {/* 11. DATA INGESTION TRANSFORMATION SECTION                            */}
      {/* ==================================================================== */}
      <section className="py-24 sm:py-32 px-6 sm:px-8 max-w-7xl mx-auto border-t border-white/6 text-left">
        <div className="space-y-4 max-w-3xl mb-16">
          <span className="text-xs uppercase tracking-widest font-extrabold text-primary">Automated Ingestion</span>
          <h2 className="text-3xl sm:text-5xl font-extrabold tracking-tight text-white leading-tight">
            From spreadsheet to structured academic data.
          </h2>
          <p className="text-base text-text-secondary">
            Upload messy faculty spreadsheets once. The system automatically reconciles enrollment numbers, computes attendance, and updates student profiles in seconds.
          </p>
        </div>

        {/* Live Ingestion Simulator Card */}
        <div className="bg-surface rounded-3xl border border-card-border p-8 sm:p-10 shadow-2xl">
          <div className="grid grid-cols-1 md:grid-cols-12 gap-8 items-center">
            
            {/* Left: Input Spreadsheet */}
            <div className="md:col-span-5 bg-[#0B0F17] p-6 rounded-2xl border border-white/10 space-y-3">
              <div className="flex items-center gap-2 text-xs font-bold text-text-secondary">
                <FileSpreadsheet size={16} className="text-primary" />
                <span>attendance_sem5_roster.xlsx</span>
              </div>
              <div className="space-y-1.5 text-[11px] font-mono text-text-secondary bg-surface-light p-3 rounded-xl">
                <p>· 61 Student Enrollments</p>
                <p>· 6 Academic Subjects</p>
                <p>· 366 Attendance & Marks Entries</p>
              </div>
              <button
                onClick={triggerIngestionSimulation}
                disabled={ingestionState === 'processing'}
                className="w-full py-2.5 rounded-xl bg-primary text-background font-extrabold text-xs transition-all hover:bg-[#c4f85e] cursor-pointer disabled:opacity-50"
              >
                {ingestionState === 'idle' ? '▶ Process Roster (366 Records)' : ingestionState === 'processing' ? `Processing ${ingestionProgress}%...` : '✓ Ingestion Complete'}
              </button>
            </div>

            {/* Middle: Transformation Indicator */}
            <div className="md:col-span-2 flex flex-col items-center justify-center text-center py-4">
              <Zap size={24} className={`text-primary ${ingestionState === 'processing' ? 'animate-bounce' : ''}`} />
              <span className="text-[10px] font-mono text-text-secondary mt-1">AI Transformer</span>
            </div>

            {/* Right: Structured Output */}
            <div className="md:col-span-5 bg-[#0B0F17] p-6 rounded-2xl border border-primary/30 space-y-3">
              <div className="flex items-center justify-between text-xs font-bold text-white">
                <span>Timestunner Live Database</span>
                <span className="text-primary text-[10px] font-mono">
                  {ingestionState === 'completed' ? 'Synced' : 'Waiting'}
                </span>
              </div>
              <div className="space-y-1.5 text-[11px] text-text-secondary bg-surface-light p-3 rounded-xl">
                <p className="text-white font-semibold">✓ 61 Student Profiles Synchronized</p>
                <p className="text-white font-semibold">✓ 366 Subject Marks & Attendance Computed</p>
                <p className="text-primary font-bold">✓ GTU Defaulter Warnings Evaluated</p>
              </div>
            </div>

          </div>
        </div>
      </section>

      {/* ==================================================================== */}
      {/* 12. COLLEGE ADMIN & APP-TO-WEB ECOSYSTEM CONNECTION                  */}
      {/* ==================================================================== */}
      <section id="admin" className="py-24 sm:py-32 px-6 sm:px-8 max-w-7xl mx-auto border-t border-white/6">
        <div className="text-center space-y-4 max-w-3xl mx-auto mb-16">
          <span className="text-xs uppercase tracking-widest font-extrabold text-primary">Connected Ecosystem</span>
          <h2 className="text-3xl sm:text-5xl font-extrabold tracking-tight text-white">
            One academic system. <br />
            Different experiences.
          </h2>
          <p className="text-base text-text-secondary">
            Students and parents access Timestunner via mobile. Faculty and institution administrators operate through the high-density desktop web dashboard.
          </p>
        </div>

        {/* App + Web Split Presentation */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center">
          
          {/* Left: Mobile App */}
          <div className="lg:col-span-5 flex flex-col items-center">
            <IPhone17Mockup screen="student-hero" className="scale-95" />
            <span className="text-xs font-bold text-text-secondary mt-3">Timestunner Mobile (Student & Parent)</span>
          </div>

          {/* Right: Desktop Browser Preview */}
          <div className="lg:col-span-7 bg-surface rounded-3xl border border-card-border p-6 sm:p-8 space-y-4 text-left shadow-2xl">
            <div className="flex items-center justify-between border-b border-card-border pb-3">
              <div className="flex items-center gap-2">
                <div className="w-3 h-3 rounded-full bg-danger/80" />
                <div className="w-3 h-3 rounded-full bg-warning/80" />
                <div className="w-3 h-3 rounded-full bg-primary/80" />
                <span className="text-[11px] font-mono text-text-secondary ml-2">campus.timestunner.ac.in/admin</span>
              </div>
              <span className="text-[10px] bg-primary/10 text-primary font-bold px-2 py-0.5 rounded">Active SaaS Session</span>
            </div>

            <div className="space-y-3 text-xs">
              <h4 className="text-base font-extrabold text-white">Institutional AI Command Center</h4>
              <p className="text-text-secondary leading-relaxed">
                Admins can broadcast campus alerts, verify student admissions, inspect department attendance health, and upload academic documents with automatic AI multi-lingual tag generation.
              </p>

              <div className="grid grid-cols-2 gap-3 pt-2">
                <div className="bg-[#0B0F17] p-3 rounded-xl border border-white/5">
                  <span className="text-[10px] text-text-secondary">Total Enrolled Students</span>
                  <p className="text-lg font-black text-white">5,000+ Active</p>
                </div>
                <div className="bg-[#0B0F17] p-3 rounded-xl border border-white/5">
                  <span className="text-[10px] text-text-secondary">Verified Academic Docs</span>
                  <p className="text-lg font-black text-primary">100% Synced</p>
                </div>
              </div>

              <div className="pt-4 flex gap-3">
                <Link
                  to="/login"
                  className="px-5 py-2.5 rounded-xl bg-primary text-background font-extrabold text-xs transition-all shadow"
                >
                  Log into College Admin Portal →
                </Link>
                <Link
                  to="/super-admin"
                  className="px-5 py-2.5 rounded-xl bg-[#0B0F17] border border-white/10 text-white font-bold text-xs"
                >
                  Super Admin
                </Link>
              </div>
            </div>
          </div>

        </div>
      </section>

      {/* ==================================================================== */}
      {/* 13. MULTI-TENANT & ENTERPRISE SECURITY SECTION                       */}
      {/* ==================================================================== */}
      <section id="security" className="py-24 sm:py-32 px-6 sm:px-8 max-w-7xl mx-auto border-t border-white/6 text-left">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
          
          <div className="lg:col-span-6 space-y-6">
            <span className="text-xs uppercase tracking-widest font-extrabold text-primary">Enterprise Security</span>
            <h2 className="text-3xl sm:text-4xl font-extrabold text-white leading-tight">
              Every institution gets its own secure academic environment.
            </h2>
            <p className="text-sm text-text-secondary leading-relaxed">
              Timestunner enforces row-level security and strict multi-tenant isolation. Academic records belonging to Asian Institute of Technology never cross into Government Polytechnic Himmatnagar.
            </p>

            <div className="space-y-3 pt-2 text-xs">
              <div className="flex items-center gap-3 p-3 bg-surface rounded-xl border border-card-border">
                <ShieldCheck size={18} className="text-primary shrink-0" />
                <div>
                  <h5 className="font-bold text-white">Strict Tenant Isolation</h5>
                  <p className="text-text-secondary text-[11px]">Database queries scoped by institution ID at the schema level</p>
                </div>
              </div>

              <div className="flex items-center gap-3 p-3 bg-surface rounded-xl border border-card-border">
                <Lock size={18} className="text-accent shrink-0" />
                <div>
                  <h5 className="font-bold text-white">2-Factor Parent Verification</h5>
                  <p className="text-text-secondary text-[11px]">Live SMS OTP verification prevents unauthorized record lookups</p>
                </div>
              </div>
            </div>

            <button
              onClick={() => setSecurityExpanded(!securityExpanded)}
              className="text-xs font-bold text-primary flex items-center gap-1 hover:underline cursor-pointer"
            >
              {securityExpanded ? 'Hide Architecture Details ↑' : 'How Tenant Isolation Works ↓'}
            </button>
          </div>

          <div className="lg:col-span-6 bg-surface p-8 rounded-3xl border border-card-border space-y-4">
            <div className="flex items-center justify-between border-b border-card-border pb-3 text-xs">
              <span className="font-mono text-text-secondary">Security Topology</span>
              <span className="text-primary font-bold">100% Isolated</span>
            </div>

            {/* College A */}
            <div className="bg-[#0B0F17] p-4 rounded-2xl border border-primary/20 space-y-2">
              <div className="flex justify-between items-center text-xs">
                <span className="font-bold text-white">College Tenant A (e.g. AIT Vadali)</span>
                <span className="text-[9px] bg-primary/10 text-primary px-1.5 py-0.5 rounded font-mono">Isolated</span>
              </div>
              <p className="text-[11px] text-text-secondary">Students · Marks · Documents · Real-time Alerts</p>
            </div>

            {/* College B */}
            <div className="bg-[#0B0F17] p-4 rounded-2xl border border-accent/20 space-y-2">
              <div className="flex justify-between items-center text-xs">
                <span className="font-bold text-white">College Tenant B (e.g. GPH Himmatnagar)</span>
                <span className="text-[9px] bg-accent/10 text-accent px-1.5 py-0.5 rounded font-mono">Isolated</span>
              </div>
              <p className="text-[11px] text-text-secondary">Students · Marks · Documents · Real-time Alerts</p>
            </div>

            {securityExpanded && (
              <div className="text-[11px] text-text-secondary bg-surface-light p-4 rounded-xl space-y-2 animate-fade-in border border-white/5">
                <p className="text-white font-bold">Enterprise Security Architecture:</p>
                <p>· Supabase Postgres Row-Level Security (RLS) policies enforce institution ownership on every query.</p>
                <p>· AI Retrieval RAG filters all embeddings and database context strictly by the user's institution ID.</p>
              </div>
            )}
          </div>

        </div>
      </section>

      {/* ==================================================================== */}
      {/* 14. PERFORMANCE BENCHMARKS & ENGINEERING TARGETS                     */}
      {/* ==================================================================== */}
      <section id="benchmarks" className="py-20 px-6 sm:px-8 max-w-7xl mx-auto border-t border-white/6 text-left">
        <div className="space-y-4 max-w-3xl mb-12">
          <span className="text-xs uppercase tracking-widest font-extrabold text-primary">Engineering Principles</span>
          <h2 className="text-2xl sm:text-4xl font-extrabold text-white">
            Built for speed and precision.
          </h2>
          <p className="text-xs text-text-secondary">
            Engineering design targets measured across the Timestunner platform cluster:
          </p>
        </div>

        <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
          <div className="bg-surface p-6 rounded-3xl border border-card-border space-y-1">
            <div className="text-3xl sm:text-4xl font-black text-primary tracking-tight">&lt; 850 ms</div>
            <p className="text-xs font-bold text-white">Target AI Response Time</p>
            <p className="text-[10px] text-text-secondary">Context-aware retrieval</p>
          </div>

          <div className="bg-surface p-6 rounded-3xl border border-card-border space-y-1">
            <div className="text-3xl sm:text-4xl font-black text-accent tracking-tight">&lt; 3.5 sec</div>
            <p className="text-xs font-bold text-white">Batch Roster Ingestion</p>
            <p className="text-[10px] text-text-secondary">366 records parsed</p>
          </div>

          <div className="bg-surface p-6 rounded-3xl border border-card-border space-y-1">
            <div className="text-3xl sm:text-4xl font-black text-white tracking-tight">60 FPS</div>
            <p className="text-xs font-bold text-white">Fluid Interaction</p>
            <p className="text-[10px] text-text-secondary">Native flutter & react UI</p>
          </div>

          <div className="bg-surface p-6 rounded-3xl border border-card-border space-y-1">
            <div className="text-3xl sm:text-4xl font-black text-primary tracking-tight">100%</div>
            <p className="text-xs font-bold text-white">Tenant Isolation</p>
            <p className="text-[10px] text-text-secondary">Strict database scoping</p>
          </div>
        </div>
      </section>

      {/* ==================================================================== */}
      {/* 15. PRODUCT PHILOSOPHY SECTION                                       */}
      {/* ==================================================================== */}
      <section className="py-24 sm:py-32 px-6 sm:px-8 max-w-5xl mx-auto text-center border-t border-white/6">
        <blockquote className="text-2xl sm:text-4xl font-extrabold text-white leading-snug tracking-tight">
          "Technology should remove academic friction, not create another portal to manage."
        </blockquote>
        <p className="text-xs sm:text-sm text-text-secondary mt-6 max-w-xl mx-auto leading-relaxed">
          Timestunner was designed around real academic workflows — giving students clarity, parents quiet confidence, and institutions flawless coordination.
        </p>
      </section>

      {/* ==================================================================== */}
      {/* 16. FINAL CALL TO ACTION                                             */}
      {/* ==================================================================== */}
      <section className="py-24 sm:py-32 px-6 sm:px-8 max-w-7xl mx-auto border-t border-white/6 text-center">
        <div className="max-w-3xl mx-auto space-y-6">
          <h2 className="text-4xl sm:text-6xl font-extrabold text-white tracking-tight leading-tight">
            Bring your academic system together.
          </h2>
          <p className="text-base text-text-secondary max-w-xl mx-auto">
            Timestunner gives students, parents, faculty, and institutions one intelligent place to stay in sync.
          </p>

          <div className="flex flex-col sm:flex-row items-center justify-center gap-4 pt-4">
            <button
              onClick={() => setShowDemoModal(true)}
              className="w-full sm:w-auto px-8 py-4 rounded-xl bg-primary hover:bg-[#c4f85e] text-[#0B0F17] font-black text-sm transition-all shadow-xl shadow-primary/25 cursor-pointer"
            >
              Request Institutional Demo →
            </button>

            <Link
              to="/login"
              className="w-full sm:w-auto px-8 py-4 rounded-xl bg-surface hover:bg-surface-light text-white border border-white/10 font-bold text-sm transition-all"
            >
              College Admin Portal
            </Link>

            <Link
              to="/super-admin"
              className="w-full sm:w-auto px-8 py-4 rounded-xl bg-surface hover:bg-surface-light text-text-secondary hover:text-white border border-white/10 font-bold text-sm transition-all"
            >
              Super Admin
            </Link>
          </div>

          <p className="text-xs text-text-secondary/70 pt-6">
            Built for modern colleges. Designed around real academic workflows.
          </p>
        </div>
      </section>

      {/* ==================================================================== */}
      {/* 17. MINIMAL FOOTER                                                   */}
      {/* ==================================================================== */}
      <footer className="border-t border-white/8 bg-[#0B0F17] py-16 px-6 sm:px-8">
        <div className="max-w-7xl mx-auto grid grid-cols-2 md:grid-cols-4 gap-10 text-left text-xs">
          
          {/* Col 1: Brand */}
          <div className="col-span-2 md:col-span-1 space-y-3">
            <div className="flex items-center gap-2">
              <div className="w-6 h-6 rounded-lg bg-surface border border-white/10 flex items-center justify-center text-primary font-black text-xs">
                T
              </div>
              <span className="font-extrabold text-white text-sm">Timestunner</span>
            </div>
            <p className="text-text-secondary text-[11px] leading-relaxed">
              The AI-powered Academic Operating System for colleges, students, and parents.
            </p>
            <p className="text-[10px] text-text-secondary/60">
              © 2026 Timestunner · Eduai Platform
            </p>
          </div>

          {/* Col 2: Product */}
          <div className="space-y-2.5">
            <h5 className="font-bold text-white text-xs uppercase tracking-wider">Product</h5>
            <ul className="space-y-2 text-text-secondary">
              <li><a href="#copilot" className="hover:text-white transition-colors">AI Copilot</a></li>
              <li><a href="#product" className="hover:text-white transition-colors">Timetable Sync</a></li>
              <li><a href="#product" className="hover:text-white transition-colors">Attendance Tracker</a></li>
              <li><a href="#product" className="hover:text-white transition-colors">Academic Records</a></li>
              <li><a href="#product" className="hover:text-white transition-colors">Document Repository</a></li>
            </ul>
          </div>

          {/* Col 3: Platform */}
          <div className="space-y-2.5">
            <h5 className="font-bold text-white text-xs uppercase tracking-wider">Platform</h5>
            <ul className="space-y-2 text-text-secondary">
              <li><a href="#experience" className="hover:text-white transition-colors">For Students</a></li>
              <li><a href="#experience" className="hover:text-white transition-colors">For Parents</a></li>
              <li><a href="#experience" className="hover:text-white transition-colors">For Faculty</a></li>
              <li><Link to="/login" className="hover:text-white transition-colors">College Admin Portal</Link></li>
              <li><Link to="/super-admin" className="hover:text-white transition-colors">Super Admin Portal</Link></li>
            </ul>
          </div>

          {/* Col 4: Security & Compliance */}
          <div className="space-y-2.5">
            <h5 className="font-bold text-white text-xs uppercase tracking-wider">Security & Standards</h5>
            <ul className="space-y-2 text-text-secondary">
              <li><a href="#security" className="hover:text-white transition-colors">Multi-Tenant Isolation</a></li>
              <li><a href="#security" className="hover:text-white transition-colors">Row-Level Security (RLS)</a></li>
              <li><span className="text-white/40">GTU Examination Norms</span></li>
              <li><span className="text-white/40">Encrypted Student Storage</span></li>
            </ul>
          </div>

        </div>
      </footer>

      {/* ==================================================================== */}
      {/* 18. DEMO REQUEST MODAL                                               */}
      {/* ==================================================================== */}
      {showDemoModal && (
        <div className="fixed inset-0 z-50 bg-background/80 backdrop-blur-md flex items-center justify-center p-4">
          <div className="bg-surface w-full max-w-md p-8 rounded-3xl border border-card-border shadow-2xl space-y-6 relative text-left">
            <button
              onClick={() => { setShowDemoModal(false); setDemoSubmitted(false); }}
              className="absolute top-5 right-5 text-text-secondary hover:text-white p-1 rounded-lg bg-surface-light cursor-pointer"
            >
              <X size={16} />
            </button>

            {demoSubmitted ? (
              <div className="text-center space-y-3 py-6 animate-fade-in">
                <div className="w-12 h-12 rounded-full bg-primary/20 border border-primary text-primary mx-auto flex items-center justify-center">
                  <Check size={24} />
                </div>
                <h3 className="text-lg font-bold text-white">Demo Request Received!</h3>
                <p className="text-xs text-text-secondary">
                  Our academic engineering team will connect with <strong>{demoForm.college}</strong> within 24 hours.
                </p>
                <button
                  onClick={() => setShowDemoModal(false)}
                  className="mt-4 px-6 py-2.5 rounded-xl bg-primary text-background font-extrabold text-xs"
                >
                  Close Window
                </button>
              </div>
            ) : (
              <>
                <div className="space-y-1">
                  <span className="text-[10px] font-bold text-primary uppercase tracking-wider">Institutional Pilot</span>
                  <h3 className="text-xl font-extrabold text-white">Request Timestunner for Your Campus</h3>
                  <p className="text-xs text-text-secondary">
                    Schedule a 15-minute live platform demonstration and pilot setup.
                  </p>
                </div>

                <form
                  onSubmit={e => {
                    e.preventDefault()
                    setDemoSubmitted(true)
                  }}
                  className="space-y-3 text-xs"
                >
                  <div>
                    <label className="block text-text-secondary font-semibold mb-1">Your Full Name</label>
                    <input
                      required
                      type="text"
                      value={demoForm.name}
                      onChange={e => setDemoForm({ ...demoForm, name: e.target.value })}
                      placeholder="e.g. Dr. Rajesh Patel"
                      className="w-full bg-surface-light border border-card-border rounded-xl px-3.5 py-2.5 text-white focus:outline-none focus:border-primary"
                    />
                  </div>

                  <div>
                    <label className="block text-text-secondary font-semibold mb-1">College / University Name</label>
                    <input
                      required
                      type="text"
                      value={demoForm.college}
                      onChange={e => setDemoForm({ ...demoForm, college: e.target.value })}
                      placeholder="e.g. Government Polytechnic"
                      className="w-full bg-surface-light border border-card-border rounded-xl px-3.5 py-2.5 text-white focus:outline-none focus:border-primary"
                    />
                  </div>

                  <div>
                    <label className="block text-text-secondary font-semibold mb-1">Institutional Email</label>
                    <input
                      required
                      type="email"
                      value={demoForm.email}
                      onChange={e => setDemoForm({ ...demoForm, email: e.target.value })}
                      placeholder="admin@college.ac.in"
                      className="w-full bg-surface-light border border-card-border rounded-xl px-3.5 py-2.5 text-white focus:outline-none focus:border-primary"
                    />
                  </div>

                  <div>
                    <label className="block text-text-secondary font-semibold mb-1">Designation</label>
                    <select
                      value={demoForm.role}
                      onChange={e => setDemoForm({ ...demoForm, role: e.target.value })}
                      className="w-full bg-surface-light border border-card-border rounded-xl px-3.5 py-2.5 text-white focus:outline-none focus:border-primary"
                    >
                      <option>Principal / Director</option>
                      <option>Head of Department (HOD)</option>
                      <option>Faculty Member</option>
                      <option>IT Administrator</option>
                      <option>Student Representative</option>
                    </select>
                  </div>

                  <button
                    type="submit"
                    className="w-full py-3 rounded-xl bg-primary text-background font-black text-xs hover:bg-[#c4f85e] transition-all shadow-lg cursor-pointer mt-2"
                  >
                    Submit Demo Request →
                  </button>
                </form>
              </>
            )}
          </div>
        </div>
      )}

    </div>
  )
}
