import React, { useState } from 'react'
import { 
  Sparkles, 
  Calendar, 
  CheckCircle2, 
  Clock, 
  MapPin, 
  ChevronRight, 
  Bell, 
  ShieldCheck, 
  BookOpen, 
  MessageSquare 
} from 'lucide-react'

export type IPhoneScreenType = 
  | 'student-hero' 
  | 'timetable' 
  | 'attendance' 
  | 'ai-copilot' 
  | 'parent' 
  | 'documents' 
  | 'alerts'

interface IPhone17MockupProps {
  screen?: IPhoneScreenType
  className?: string
  scale?: number
  tiltDegree?: number
  customContent?: React.ReactNode
  showGlow?: boolean
}

export default function IPhone17Mockup({
  screen = 'student-hero',
  className = '',
  tiltDegree = 0,
  customContent,
  showGlow = true
}: IPhone17MockupProps) {
  const [activeLang, setActiveLang] = useState<'en' | 'gu' | 'hi'>('en')
  const [heroPromptExpanded, setHeroPromptExpanded] = useState(false)

  return (
    <div 
      className={`relative select-none transition-transform duration-500 ${className}`}
      style={{
        transform: tiltDegree !== 0 ? `rotate(${tiltDegree}deg)` : undefined
      }}
    >
      {/* Ambient Atmospheric Glow (Subtle & Restrained) */}
      {showGlow && (
        <div className="absolute -inset-4 bg-gradient-to-tr from-primary/15 via-accent/10 to-cyan/10 rounded-[54px] blur-2xl opacity-60 -z-10 pointer-events-none" />
      )}

      {/* iPhone 17 Titanium Outer Hardware Frame */}
      <div className="w-[300px] sm:w-[320px] md:w-[340px] h-[630px] sm:h-[660px] md:h-[690px] bg-[#171B26] p-[9px] rounded-[50px] shadow-[0_25px_60px_-15px_rgba(0,0,0,0.9),0_0_0_1px_rgba(255,255,255,0.12),inset_0_1px_2px_rgba(255,255,255,0.25)] border border-[#2B3448] relative flex flex-col justify-between overflow-hidden">
        
        {/* Antenna / Titanium Side Seams */}
        <div className="absolute top-28 -left-[2px] w-[2px] h-8 bg-white/20 rounded-r" />
        <div className="absolute top-44 -left-[2px] w-[2px] h-12 bg-white/20 rounded-r" />
        <div className="absolute top-36 -right-[2px] w-[2px] h-14 bg-white/20 rounded-l" />

        {/* Inner OLED Glass Screen Container */}
        <div className="w-full h-full bg-[#0B0F17] rounded-[42px] overflow-hidden flex flex-col relative border border-white/5 shadow-inner">
          
          {/* iOS 18/19 Status Bar */}
          <div className="w-full pt-3 px-6 flex items-center justify-between z-30 select-none">
            <span className="text-[11px] font-semibold tracking-tight text-white/90">9:41</span>
            
            {/* Precision Dynamic Island */}
            <div className="w-[84px] h-[22px] bg-black rounded-full flex items-center justify-end px-2 gap-1.5 shadow-[inset_0_0_2px_rgba(255,255,255,0.2)]">
              <div className="w-2.5 h-2.5 rounded-full bg-[#0d121d] border border-white/10" />
              <div className="w-2 h-2 rounded-full bg-[#061e12] border border-primary/40 flex items-center justify-center">
                <div className="w-1 h-1 rounded-full bg-primary animate-pulse" />
              </div>
            </div>

            <div className="flex items-center gap-1.5 text-white/90">
              <svg className="w-3 h-3 fill-current" viewBox="0 0 24 24"><path d="M12 3c-4.97 0-9 4.03-9 9 0 2.12.74 4.07 1.97 5.61L4.35 19.4c-.39.39-.39 1.02 0 1.41.39.39 1.02.39 1.41 0l1.9-1.9C9.17 19.65 10.53 20 12 20c4.97 0 9-4.03 9-9s-4.03-9-9-9zm0 15c-3.31 0-6-2.69-6-6s2.69-6 6-6 6 2.69 6 6-2.69 6-6 6z"/></svg>
              <div className="w-4 h-2.5 border border-white/70 rounded-[3px] p-[1px] flex items-center">
                <div className="w-full h-full bg-white rounded-[1px]" />
              </div>
            </div>
          </div>

          {/* Screen Content Render */}
          <div className="flex-1 overflow-y-auto overflow-x-hidden p-4 space-y-3 relative text-left text-text-primary text-xs font-sans select-none scrollbar-none">
            {customContent ? (
              customContent
            ) : screen === 'student-hero' ? (
              /* SCREEN 1: STUDENT HERO */
              <div className="space-y-3 animate-fade-in">
                {/* Greeting & Date */}
                <div className="flex items-center justify-between pt-1">
                  <div>
                    <p className="text-[10px] text-text-secondary uppercase tracking-wider font-semibold">Tuesday · 18 August</p>
                    <h2 className="text-base font-extrabold tracking-tight text-white flex items-center gap-1.5">
                      Good morning, Bipin
                      <span className="w-2 h-2 rounded-full bg-primary inline-block" />
                    </h2>
                  </div>
                  <div className="w-8 h-8 rounded-full bg-surface-light border border-white/10 flex items-center justify-center text-primary font-bold text-xs">
                    B
                  </div>
                </div>

                {/* Academic Progress & Attendance Bento */}
                <div className="grid grid-cols-2 gap-2">
                  <div className="bg-surface p-3 rounded-2xl border border-card-border space-y-1.5">
                    <span className="text-[10px] text-text-secondary font-medium">Semester Progress</span>
                    <div className="flex items-baseline gap-1">
                      <span className="text-xl font-extrabold text-white">82%</span>
                      <span className="text-[9px] text-primary font-semibold">Sem 5</span>
                    </div>
                    <div className="w-full bg-surface-light h-1.5 rounded-full overflow-hidden">
                      <div className="bg-primary h-full rounded-full w-[82%]" />
                    </div>
                  </div>

                  <div className="bg-surface p-3 rounded-2xl border border-card-border space-y-1.5">
                    <div className="flex items-center justify-between">
                      <span className="text-[10px] text-text-secondary font-medium">Attendance</span>
                      <span className="text-[9px] text-primary bg-primary/10 px-1.5 py-0.5 rounded-md font-bold">Eligible</span>
                    </div>
                    <div className="flex items-baseline gap-1">
                      <span className="text-xl font-extrabold text-primary">87.4%</span>
                    </div>
                    <p className="text-[9px] text-text-secondary">Req: 75% GTU Norm</p>
                  </div>
                </div>

                {/* Next Class Focus Card */}
                <div className="bg-gradient-to-br from-surface to-surface-light p-3.5 rounded-2xl border border-primary/20 relative overflow-hidden shadow-lg">
                  <div className="absolute top-0 right-0 w-20 h-20 bg-primary/5 rounded-full blur-xl pointer-events-none" />
                  <div className="flex items-center justify-between mb-1.5">
                    <span className="text-[9px] uppercase tracking-wider font-extrabold text-primary bg-primary/15 px-2 py-0.5 rounded-md">
                      Next Lecture · In 25 Mins
                    </span>
                    <span className="text-[10px] text-text-secondary font-mono">10:30 AM</span>
                  </div>
                  <h3 className="text-xs font-bold text-white leading-snug">Artificial Intelligence & Machine Learning</h3>
                  <div className="flex items-center gap-3 mt-2 text-[10px] text-text-secondary">
                    <span className="flex items-center gap-1"><MapPin size={11} className="text-accent" /> Lab 2 (New Block)</span>
                    <span className="flex items-center gap-1"><Clock size={11} className="text-primary" /> Prof. Sharma</span>
                  </div>
                </div>

                {/* Interactive AI Query Box */}
                <div 
                  onClick={() => setHeroPromptExpanded(!heroPromptExpanded)}
                  className="bg-surface p-3 rounded-2xl border border-cyan/30 cursor-pointer hover:border-cyan/50 transition-all space-y-2"
                >
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-1.5 text-cyan font-bold text-[11px]">
                      <Sparkles size={13} className="animate-spin-slow" />
                      <span>AI Academic Copilot</span>
                    </div>
                    <span className="text-[9px] bg-cyan/15 text-cyan px-1.5 py-0.5 rounded font-mono">Context Verified</span>
                  </div>
                  
                  <div className="bg-surface-light/80 p-2 rounded-xl border border-white/5 flex items-center justify-between">
                    <span className="text-[10px] text-white/90 font-medium">"What do I have tomorrow?"</span>
                    <ChevronRight size={12} className="text-cyan" />
                  </div>

                  {heroPromptExpanded && (
                    <div className="text-[10px] text-text-secondary bg-[#081320] p-2.5 rounded-xl border border-cyan/20 space-y-1 animate-fade-in">
                      <p className="text-white font-medium">You have 4 classes tomorrow:</p>
                      <p className="text-[9.5px]">· 10:30 — AIPE (Lab 2)</p>
                      <p className="text-[9.5px]">· 12:00 — DBMS (Room 204)</p>
                      <p className="text-[9.5px]">· 14:00 — Cyber Security</p>
                      <p className="text-[9.5px]">· 15:30 — Project Lab</p>
                    </div>
                  )}
                </div>
              </div>
            ) : screen === 'timetable' ? (
              /* SCREEN 2: TIMETABLE */
              <div className="space-y-2.5 animate-fade-in">
                <div className="flex items-center justify-between pt-1">
                  <div>
                    <h2 className="text-sm font-extrabold text-white">Daily Timetable</h2>
                    <p className="text-[10px] text-text-secondary">Monday · Semester 5 (IT)</p>
                  </div>
                  <span className="text-[9px] bg-primary/10 text-primary font-bold px-2 py-0.5 rounded-md">Live Room Sync</span>
                </div>

                <div className="space-y-1.5">
                  <div className="bg-surface-light/40 p-2.5 rounded-xl border border-card-border flex items-center justify-between">
                    <div>
                      <span className="text-[9px] text-text-secondary font-mono">09:00 - 10:00</span>
                      <h4 className="text-[11px] font-semibold text-white/80">Applied Mathematics V</h4>
                      <p className="text-[9px] text-text-secondary">Room 102 · Dr. Patel</p>
                    </div>
                    <span className="text-[9px] text-text-secondary bg-white/5 px-2 py-0.5 rounded">Completed</span>
                  </div>

                  <div className="bg-gradient-to-r from-surface to-[#16271a] p-2.5 rounded-xl border border-primary/40 shadow-sm flex items-center justify-between">
                    <div>
                      <span className="text-[9px] text-primary font-mono font-bold">10:30 - 12:00 · CURRENT</span>
                      <h4 className="text-[11px] font-extrabold text-white">Artificial Intelligence & ML</h4>
                      <p className="text-[9px] text-primary/90 flex items-center gap-1">
                        <MapPin size={9} /> Lab 2 · Prof. Dave
                      </p>
                    </div>
                    <span className="text-[9px] bg-primary text-background font-black px-2 py-0.5 rounded shadow">In Session</span>
                  </div>

                  <div className="bg-surface p-2.5 rounded-xl border border-card-border flex items-center justify-between">
                    <div>
                      <span className="text-[9px] text-text-secondary font-mono">12:00 - 13:00</span>
                      <h4 className="text-[11px] font-semibold text-white">Database Management Systems</h4>
                      <p className="text-[9px] text-text-secondary">Room 204 · Prof. Mehta</p>
                    </div>
                    <span className="text-[9px] text-accent bg-accent/10 px-2 py-0.5 rounded font-semibold">Upcoming</span>
                  </div>

                  <div className="bg-surface p-2.5 rounded-xl border border-card-border flex items-center justify-between">
                    <div>
                      <span className="text-[9px] text-text-secondary font-mono">14:00 - 15:30</span>
                      <h4 className="text-[11px] font-semibold text-white">Cyber Security Operations</h4>
                      <p className="text-[9px] text-text-secondary">Security Lab · Prof. Vora</p>
                    </div>
                    <span className="text-[9px] text-text-secondary bg-white/5 px-2 py-0.5 rounded">Next</span>
                  </div>
                </div>
              </div>
            ) : screen === 'attendance' ? (
              /* SCREEN 3: ATTENDANCE */
              <div className="space-y-3 animate-fade-in">
                <div className="flex items-center justify-between pt-1">
                  <h2 className="text-sm font-extrabold text-white">Attendance Monitor</h2>
                  <span className="text-[9px] bg-primary/15 text-primary font-bold px-2 py-0.5 rounded-md flex items-center gap-1">
                    <CheckCircle2 size={10} /> Exam Eligible
                  </span>
                </div>

                {/* Overall Gauge Circular Progress */}
                <div className="bg-surface p-3.5 rounded-2xl border border-card-border flex items-center justify-between">
                  <div>
                    <span className="text-[10px] text-text-secondary">Aggregate Attendance</span>
                    <div className="text-2xl font-black text-primary tracking-tight">87.4%</div>
                    <p className="text-[9px] text-white/70">Safe by 12.4% above GTU cut-off</p>
                  </div>

                  <div className="relative w-14 h-14 flex items-center justify-center">
                    <svg className="w-14 h-14 -rotate-90" viewBox="0 0 36 36">
                      <path
                        className="text-surface-light stroke-current"
                        strokeWidth="3.5"
                        fill="none"
                        d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                      />
                      <path
                        className="text-primary stroke-current"
                        strokeWidth="3.5"
                        strokeDasharray="87.4, 100"
                        strokeLinecap="round"
                        fill="none"
                        d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                      />
                    </svg>
                    <span className="absolute text-[10px] font-extrabold text-white">87%</span>
                  </div>
                </div>

                {/* Subject Breakdown List */}
                <div className="space-y-2">
                  <div className="bg-surface p-2.5 rounded-xl border border-card-border space-y-1">
                    <div className="flex justify-between text-[10px] font-semibold">
                      <span className="text-white">AI & Machine Learning (AIPE)</span>
                      <span className="text-primary">84.6%</span>
                    </div>
                    <div className="w-full bg-surface-light h-1 rounded-full overflow-hidden">
                      <div className="bg-primary h-full rounded-full w-[84.6%]" />
                    </div>
                  </div>

                  <div className="bg-surface p-2.5 rounded-xl border border-card-border space-y-1">
                    <div className="flex justify-between text-[10px] font-semibold">
                      <span className="text-white">Database Management (DBMS)</span>
                      <span className="text-primary">91.2%</span>
                    </div>
                    <div className="w-full bg-surface-light h-1 rounded-full overflow-hidden">
                      <div className="bg-primary h-full rounded-full w-[91.2%]" />
                    </div>
                  </div>

                  <div className="bg-surface p-2.5 rounded-xl border border-card-border space-y-1">
                    <div className="flex justify-between text-[10px] font-semibold">
                      <span className="text-white">Cyber Security & Forensics</span>
                      <span className="text-accent">78.4%</span>
                    </div>
                    <div className="w-full bg-surface-light h-1 rounded-full overflow-hidden">
                      <div className="bg-accent h-full rounded-full w-[78.4%]" />
                    </div>
                  </div>

                  <div className="bg-surface p-2.5 rounded-xl border border-card-border space-y-1">
                    <div className="flex justify-between text-[10px] font-semibold">
                      <span className="text-white">Mathematics V</span>
                      <span className="text-primary">89.1%</span>
                    </div>
                    <div className="w-full bg-surface-light h-1 rounded-full overflow-hidden">
                      <div className="bg-primary h-full rounded-full w-[89.1%]" />
                    </div>
                  </div>
                </div>
              </div>
            ) : screen === 'ai-copilot' ? (
              /* SCREEN 4: MULTILINGUAL AI COPILOT */
              <div className="space-y-2.5 animate-fade-in">
                <div className="flex items-center justify-between pt-1">
                  <div className="flex items-center gap-1.5 text-cyan font-bold text-xs">
                    <Sparkles size={14} className="text-cyan" />
                    <span>Academic AI Copilot</span>
                  </div>
                  <div className="flex gap-1 bg-surface p-0.5 rounded-md border border-white/5">
                    <button 
                      onClick={() => setActiveLang('en')} 
                      className={`px-1.5 py-0.5 rounded text-[9px] font-bold ${activeLang === 'en' ? 'bg-cyan text-background' : 'text-text-secondary'}`}
                    >
                      EN
                    </button>
                    <button 
                      onClick={() => setActiveLang('gu')} 
                      className={`px-1.5 py-0.5 rounded text-[9px] font-bold ${activeLang === 'gu' ? 'bg-cyan text-background' : 'text-text-secondary'}`}
                    >
                      ગુજ
                    </button>
                    <button 
                      onClick={() => setActiveLang('hi')} 
                      className={`px-1.5 py-0.5 rounded text-[9px] font-bold ${activeLang === 'hi' ? 'bg-cyan text-background' : 'text-text-secondary'}`}
                    >
                      हिं
                    </button>
                  </div>
                </div>

                {/* Conversation bubbles */}
                <div className="space-y-2 text-[10px]">
                  {/* User query */}
                  <div className="flex justify-end">
                    <div className="bg-primary text-background font-bold px-3 py-1.5 rounded-2xl rounded-tr-xs max-w-[85%]">
                      {activeLang === 'en' && "How much attendance do I have in AIPE?"}
                      {activeLang === 'gu' && "મારી AIPE માં attendance કેટલી છે?"}
                      {activeLang === 'hi' && "मेरी AIPE में attendance कितनी है?"}
                    </div>
                  </div>

                  {/* AI response */}
                  <div className="flex justify-start">
                    <div className="bg-surface p-2.5 rounded-2xl rounded-tl-xs border border-cyan/20 max-w-[92%] space-y-1">
                      <div className="flex items-center gap-1 text-cyan text-[9px] font-bold">
                        <ShieldCheck size={11} /> Verified Campus Record
                      </div>
                      <p className="text-white">
                        {activeLang === 'en' && "Your AIPE attendance is 84.6%. You are in good standing (above 75% GTU threshold)."}
                        {activeLang === 'gu' && "તમારી AIPE માં હાજરી 84.6% છે. તમે 75% ની મર્યાદાથી સુરક્ષિત છો."}
                        {activeLang === 'hi' && "आपकी AIPE में उपस्थिति 84.6% है। आप 75% अनिवार्य सीमा से ऊपर हैं।"}
                      </p>
                    </div>
                  </div>

                  {/* Second query */}
                  <div className="flex justify-end pt-1">
                    <div className="bg-primary text-background font-bold px-3 py-1.5 rounded-2xl rounded-tr-xs max-w-[85%]">
                      {activeLang === 'en' && "What classes do I have tomorrow?"}
                      {activeLang === 'gu' && "કાલે મારી કઈ classes છે?"}
                      {activeLang === 'hi' && "कल मेरी कौनसी कक्षाएं हैं?"}
                    </div>
                  </div>

                  {/* Second response */}
                  <div className="flex justify-start">
                    <div className="bg-surface p-2.5 rounded-2xl rounded-tl-xs border border-card-border max-w-[92%] space-y-1 text-white/90">
                      <p className="font-semibold text-white">
                        {activeLang === 'en' && "You have 4 sessions tomorrow:"}
                        {activeLang === 'gu' && "કાલે તમારી 4 કક્ષા છે:"}
                        {activeLang === 'hi' && "कल आपकी 4 कक्षाएं हैं:"}
                      </p>
                      <p className="text-[9px] text-text-secondary">· 10:30 — AIPE (Lab 2)</p>
                      <p className="text-[9px] text-text-secondary">· 12:00 — DBMS (Room 204)</p>
                      <p className="text-[9px] text-text-secondary">· 14:00 — Cyber Security</p>
                    </div>
                  </div>
                </div>
              </div>
            ) : screen === 'parent' ? (
              /* SCREEN 5: PARENT GUARDIAN VIEW */
              <div className="space-y-3 animate-fade-in">
                <div className="flex items-center justify-between pt-1">
                  <div>
                    <h2 className="text-sm font-extrabold text-white">Bipin's Academic Overview</h2>
                    <p className="text-[10px] text-text-secondary">Semester 5 · Information Technology</p>
                  </div>
                  <span className="text-[9px] bg-accent/15 text-accent font-bold px-2 py-0.5 rounded-md">Verified Parent</span>
                </div>

                <div className="bg-surface p-3.5 rounded-2xl border border-accent/20 space-y-2">
                  <div className="flex items-center justify-between">
                    <span className="text-[10px] text-text-secondary">Overall Semester Attendance</span>
                    <span className="text-[9px] text-primary font-bold">Good Standing ✅</span>
                  </div>
                  <div className="text-2xl font-black text-white">87.4%</div>
                  <div className="w-full bg-surface-light h-1.5 rounded-full overflow-hidden">
                    <div className="bg-primary h-full rounded-full w-[87.4%]" />
                  </div>
                  <p className="text-[9.5px] text-text-secondary pt-0.5">
                    Attendance has remained above the mandatory 75% GTU threshold throughout August.
                  </p>
                </div>

                <div className="bg-surface p-3 rounded-xl border border-card-border space-y-1.5">
                  <span className="text-[9px] uppercase tracking-wider font-bold text-accent">Latest Academic Update</span>
                  <div className="flex justify-between items-center text-[10px]">
                    <span className="text-white font-medium">AIPE Mid-Sem Exam</span>
                    <span className="text-primary font-bold">28 / 30 (Grade A+)</span>
                  </div>
                  <div className="flex justify-between items-center text-[10px]">
                    <span className="text-white font-medium">DBMS Practical Assessment</span>
                    <span className="text-primary font-bold">29 / 30 (Grade A+)</span>
                  </div>
                </div>

                <div className="bg-surface-light p-2.5 rounded-xl border border-white/5 flex items-center justify-between text-[10px]">
                  <span className="text-white font-semibold">Exam Eligibility Status</span>
                  <span className="text-primary font-bold bg-primary/10 px-2 py-0.5 rounded">Eligible for GTU Final</span>
                </div>
              </div>
            ) : screen === 'documents' ? (
              /* SCREEN 6: DOCUMENTS */
              <div className="space-y-2.5 animate-fade-in">
                <div className="flex items-center justify-between pt-1">
                  <h2 className="text-sm font-extrabold text-white">Academic Repository</h2>
                  <span className="text-[9px] bg-white/5 text-text-secondary px-2 py-0.5 rounded">14+ Tags</span>
                </div>

                <div className="space-y-1.5">
                  <div className="bg-surface p-2.5 rounded-xl border border-card-border space-y-1">
                    <div className="flex justify-between items-start">
                      <h4 className="text-[10.5px] font-bold text-white">AIPE Complete Lab Manual</h4>
                      <span className="text-[8.5px] bg-primary/15 text-primary px-1.5 py-0.5 rounded font-mono">PDF · 3.4MB</span>
                    </div>
                    <p className="text-[9px] text-text-secondary">Official GTU practical experiments 1 to 12</p>
                    <div className="flex gap-1 pt-1">
                      <span className="text-[8px] bg-surface-light px-1.5 py-0.5 rounded text-text-secondary">#lab_manual</span>
                      <span className="text-[8px] bg-surface-light px-1.5 py-0.5 rounded text-text-secondary">#aipe</span>
                      <span className="text-[8px] bg-surface-light px-1.5 py-0.5 rounded text-text-secondary">#sem5</span>
                    </div>
                  </div>

                  <div className="bg-surface p-2.5 rounded-xl border border-card-border space-y-1">
                    <div className="flex justify-between items-start">
                      <h4 className="text-[10.5px] font-bold text-white">DBMS Assignment 02 & Schema</h4>
                      <span className="text-[8.5px] bg-accent/15 text-accent px-1.5 py-0.5 rounded font-mono">DOCX · 1.1MB</span>
                    </div>
                    <p className="text-[9px] text-text-secondary">Submission deadline: Aug 25 · Prof. Mehta</p>
                  </div>

                  <div className="bg-surface p-2.5 rounded-xl border border-card-border space-y-1">
                    <div className="flex justify-between items-start">
                      <h4 className="text-[10.5px] font-bold text-white">Semester 5 Mid-Sem Exam Schedule</h4>
                      <span className="text-[8.5px] bg-warning/15 text-warning px-1.5 py-0.5 rounded font-mono">CIRCULAR</span>
                    </div>
                    <p className="text-[9px] text-text-secondary">Official college timetable & seat allotment</p>
                  </div>
                </div>
              </div>
            ) : (
              /* SCREEN 7: CAMPUS ALERTS */
              <div className="space-y-2.5 animate-fade-in">
                <div className="flex items-center justify-between pt-1">
                  <h2 className="text-sm font-extrabold text-white">Campus Alerts</h2>
                  <span className="text-[9px] bg-primary text-background font-bold px-2 py-0.5 rounded">2 New</span>
                </div>

                <div className="space-y-2">
                  <div className="bg-gradient-to-br from-surface to-[#1c2230] p-3 rounded-xl border border-primary/30 space-y-1">
                    <div className="flex items-center justify-between">
                      <span className="text-[9px] font-bold text-primary flex items-center gap-1">
                        <Bell size={10} /> Official Announcement
                      </span>
                      <span className="text-[8px] text-text-secondary font-mono">10m ago</span>
                    </div>
                    <h4 className="text-[11px] font-bold text-white">Independence Day Holiday Notice</h4>
                    <p className="text-[9.5px] text-text-secondary">
                      Campus will remain closed on August 15. All regular classes and laboratory sessions will resume on August 16.
                    </p>
                  </div>

                  <div className="bg-surface p-3 rounded-xl border border-card-border space-y-1">
                    <div className="flex items-center justify-between">
                      <span className="text-[9px] font-bold text-accent flex items-center gap-1">
                        <Calendar size={10} /> Exam Update
                      </span>
                      <span className="text-[8px] text-text-secondary font-mono">2h ago</span>
                    </div>
                    <h4 className="text-[11px] font-bold text-white">Mid-Semester Exam Timetable Published</h4>
                    <p className="text-[9.5px] text-text-secondary">
                      The official schedule for Sem 3 and Sem 5 has been uploaded to the Academic Repository.
                    </p>
                  </div>
                </div>
              </div>
            )}
          </div>

          {/* iOS Bottom Navigation Bar & Home Indicator */}
          <div className="w-full bg-[#0E1420]/95 backdrop-blur border-t border-white/5 px-6 py-2 flex items-center justify-between z-20">
            <div className="flex flex-col items-center text-primary">
              <BookOpen size={14} />
              <span className="text-[8px] font-bold mt-0.5">Today</span>
            </div>
            <div className="flex flex-col items-center text-text-secondary hover:text-white transition-colors">
              <Calendar size={14} />
              <span className="text-[8px] mt-0.5">Schedule</span>
            </div>
            <div className="flex flex-col items-center text-text-secondary hover:text-white transition-colors">
              <MessageSquare size={14} />
              <span className="text-[8px] mt-0.5">AI Copilot</span>
            </div>
            <div className="flex flex-col items-center text-text-secondary hover:text-white transition-colors">
              <Bell size={14} />
              <span className="text-[8px] mt-0.5">Alerts</span>
            </div>
          </div>

          {/* Bottom Home Indicator Pill */}
          <div className="w-full pb-1.5 pt-0.5 flex justify-center bg-[#0E1420]">
            <div className="w-28 h-1 bg-white/40 rounded-full" />
          </div>

        </div>
      </div>
    </div>
  )
}
