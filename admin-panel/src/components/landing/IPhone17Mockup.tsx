import React from 'react'

export type IPhoneScreenType = 
  | 'student-hero' 
  | 'timetable' 
  | 'attendance' 
  | 'ai-copilot' 
  | 'voice-copilot'
  | 'voice-listening'
  | 'parent' 
  | 'documents' 
  | 'alerts'
  | 'portal'
  | 'student-signin'
  | 'parent-signin'
  | 'register'
  | 'splash'
  | 'onboarding-docs'
  | 'onboarding-copilot'
  | 'onboarding-alerts'
  | 'onboarding-portals'

interface IPhone17MockupProps {
  screen?: IPhoneScreenType
  imageSrc?: string
  alt?: string
  className?: string
  tiltDegree?: number
  customContent?: React.ReactNode
  showGlow?: boolean
}

// Preset mapping to real device screenshots
const SCREEN_IMAGE_MAP: Record<IPhoneScreenType, string> = {
  'student-hero': '/mockups/student_profile.jpeg',
  'timetable': '/mockups/onboarding_repository.jpeg',
  'attendance': '/mockups/student_profile.jpeg',
  'ai-copilot': '/mockups/ai_chat_document.jpeg',
  'voice-copilot': '/mockups/voice_assistant_response.jpeg',
  'voice-listening': '/mockups/voice_assistant_listening.jpeg',
  'parent': '/mockups/parent_signin.jpeg',
  'documents': '/mockups/onboarding_repository.jpeg',
  'alerts': '/mockups/onboarding_broadcasts.jpeg',
  'portal': '/mockups/portal_select.jpeg',
  'student-signin': '/mockups/student_signin.jpeg',
  'parent-signin': '/mockups/parent_signin.jpeg',
  'register': '/mockups/student_register.jpeg',
  'splash': '/mockups/splash.jpeg',
  'onboarding-docs': '/mockups/onboarding_repository.jpeg',
  'onboarding-copilot': '/mockups/onboarding_copilot.jpeg',
  'onboarding-alerts': '/mockups/onboarding_broadcasts.jpeg',
  'onboarding-portals': '/mockups/onboarding_portals.jpeg',
}

export default function IPhone17Mockup({
  screen = 'student-hero',
  imageSrc,
  alt = 'Timestunner Mobile Application Screenshot',
  className = '',
  tiltDegree = 0,
  customContent,
  showGlow = true
}: IPhone17MockupProps) {
  const finalImageSrc = imageSrc || SCREEN_IMAGE_MAP[screen] || '/mockups/student_profile.jpeg'

  return (
    <div 
      className={`relative select-none transition-transform duration-500 ${className}`}
      style={{
        transform: tiltDegree !== 0 ? `rotate(${tiltDegree}deg)` : undefined
      }}
    >
      {/* Ambient Atmospheric Glow (Subtle Titanium Reflection) */}
      {showGlow && (
        <div className="absolute -inset-4 bg-gradient-to-tr from-primary/15 via-accent/10 to-cyan/10 rounded-[54px] blur-2xl opacity-60 -z-10 pointer-events-none" />
      )}

      {/* iPhone 17 Pro Max Titanium Outer Frame */}
      <div className="w-[280px] sm:w-[300px] md:w-[320px] h-[590px] sm:h-[630px] md:h-[670px] bg-[#171B26] p-[8px] sm:p-[9px] rounded-[48px] sm:rounded-[52px] shadow-[0_25px_60px_-15px_rgba(0,0,0,0.9),0_0_0_1px_rgba(255,255,255,0.14),inset_0_1px_2px_rgba(255,255,255,0.25)] border border-[#2B3448] relative flex flex-col justify-between overflow-hidden">
        
        {/* Hardware Titanium Antenna Seams */}
        <div className="absolute top-28 -left-[2px] w-[2px] h-8 bg-white/20 rounded-r" />
        <div className="absolute top-44 -left-[2px] w-[2px] h-12 bg-white/20 rounded-r" />
        <div className="absolute top-36 -right-[2px] w-[2px] h-14 bg-white/20 rounded-l" />

        {/* Inner OLED Glass Screen Container */}
        <div className="w-full h-full bg-[#0B0F17] rounded-[40px] sm:rounded-[44px] overflow-hidden flex flex-col relative border border-white/10 shadow-inner group">
          
          {/* Real Screenshot Container */}
          {customContent ? (
            <div className="flex-1 overflow-y-auto overflow-x-hidden p-4 space-y-3 relative text-left text-text-primary text-xs font-sans select-none scrollbar-none">
              {customContent}
            </div>
          ) : (
            <div className="w-full h-full relative overflow-hidden bg-[#0B0F17] flex items-center justify-center">
              <img 
                src={finalImageSrc} 
                alt={alt}
                className="w-full h-full object-cover object-top select-none pointer-events-none transition-transform duration-700 group-hover:scale-[1.02]"
                loading="lazy"
              />
            </div>
          )}

          {/* Precision Dynamic Island Overlay (Hardware Bezel Level) */}
          <div className="absolute top-3 left-1/2 -translate-x-1/2 w-[76px] sm:w-[84px] h-[20px] sm:h-[22px] bg-black rounded-full flex items-center justify-end px-2 gap-1.5 shadow-[0_2px_8px_rgba(0,0,0,0.8),inset_0_0_2px_rgba(255,255,255,0.25)] z-30 pointer-events-none">
            <div className="w-2.5 h-2.5 rounded-full bg-[#0d121d] border border-white/10" />
            <div className="w-2 h-2 rounded-full bg-[#061e12] border border-primary/40 flex items-center justify-center">
              <div className="w-1 h-1 rounded-full bg-primary animate-pulse" />
            </div>
          </div>

          {/* iOS Bottom Home Bar */}
          <div className="absolute bottom-1.5 left-1/2 -translate-x-1/2 w-28 h-1 bg-white/50 rounded-full z-30 pointer-events-none shadow" />

        </div>
      </div>
    </div>
  )
}
