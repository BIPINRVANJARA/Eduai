export interface ExtractedDocMetadata {
  title: string;
  category: 'timetable' | 'lab_manual' | 'assignment' | 'notes' | 'pyq' | 'syllabus' | 'circular' | 'fee_structure' | 'placement' | 'project' | 'attendance_report' | 'other';
  department: string;
  semester: string;
  division: string;
  subject_name: string;
  tags: string[];
  content_summary: string;
  file_url?: string;
  explanation: string;
}

export interface ExtractedAlertMetadata {
  title: string;
  message: string;
  category: 'attendance' | 'marks' | 'fees' | 'timetable' | 'holiday' | 'general' | 'emergency';
  department: string;
  semester: string;
  priority: 'normal' | 'high' | 'urgent';
  explanation: string;
}

export type AdminActionType = 'INSERT_DOCUMENT' | 'BROADCAST_ALERT' | 'UPDATE_ATTENDANCE_MARKS' | 'QUERY_INFO' | 'GENERAL_CHAT';

export interface StudentScoreData {
  enrollment_no: string;
  student_name?: string;
  overall_attendance?: number;
  subject?: string;
  mid_sem_marks?: number;
  practical_marks?: number;
}

export interface UniversalAdminResponse {
  actionType: AdminActionType;
  requiresConfirmation: boolean;
  message: string;
  documentData?: ExtractedDocMetadata;
  alertData?: ExtractedAlertMetadata;
  scoresData?: StudentScoreData[];
  suggestedFollowUp?: string;
}

const GROQ_API_KEY = (import.meta as any).env?.VITE_GROQ_API_KEY || '';

export async function parseUniversalAdminCommand(
  prompt: string,
  attachedFile?: { name: string; size: number } | null,
  fileSnippetText?: string | null
): Promise<UniversalAdminResponse> {
  const systemPrompt = `You are Eduai Universal Admin AI Agent.
You are the central academic operating intelligence for the institution admin. You handle ALL administrative actions:
1. Academic Document Ingestion (Timetables, Lab Manuals, Assignments, Syllabus, Lecture Notes, Exam Papers, Circulars).
2. Campus Broadcasts & Alerts (Holiday notices, attendance warnings, exam announcements, fee reminders).
3. Student Attendance & Marks Ingestion (From text lists, spreadsheets, or paper register photos).
4. System Queries & Administrative assistance.

CRITICAL RULES FOR DOCUMENT ANALYSIS & TAG GENERATION (actionType = "INSERT_DOCUMENT"):
- When the admin uploads or refers to a document (e.g. "this is aipd assignment of sem 5" or attaches a file):
  1. ACCURATE SUBJECT MAPPING:
     - "aipd" / "aipde" -> "Artificial Intelligence and Product Development (AIPD)"
     - "aipe" -> "Artificial Intelligence and Prompt Engineering (AIPE)"
     - "fbc" -> "Fundamentals of Blockchain (FBC)"
     - "cloud" -> "Cloud Computing (CLOUD)"
     - "iot" -> "Internet of Things (IOT)"
     - "mp" -> "Microprocessors & Microcontrollers (MP)"
     - "dsa" -> "Data Structures & Algorithms (DSA)"
     - "dbms" -> "Database Management Systems (DBMS)"
     - "cn" -> "Computer Networks (CN)"
     - "os" -> "Operating Systems (OS)"
     - "se" -> "Software Engineering (SE)"
     - "ml" -> "Machine Learning (ML)"
     - "wd" / "wt" -> "Web Development / Web Technology (WD)"
     - "maths" / "am" -> "Applied Mathematics"
     - "c" / "cpp" / "java" / "python" -> Programming in C / C++ / Java / Python

  2. CATEGORY DETECTION:
     - "assignment", "problem set", "homework", "task" -> "assignment"
     - "timetable", "schedule", "routine", "time table" -> "timetable"
     - "lab manual", "practical", "lab journal", "experiment" -> "lab_manual"
     - "circular", "notice", "announcement", "guideline" -> "circular"
     - "syllabus", "curriculum", "course outline" -> "syllabus"
     - "pyq", "previous year", "old paper", "exam paper", "question paper" -> "pyq"
     - "notes", "lecture notes", "materials", "unit summary" -> "notes"

  3. MULTILINGUAL & INTENT TAG GENERATION (ESSENTIAL):
     Always generate 12 to 16 comprehensive, search-optimized tags in the "tags" array so students & parents can find this document using any natural phrase or voice query:
     - Subject acronyms: e.g. "aipd", "aipd assignment", "aipd sem 5"
     - Full Subject Name: e.g. "artificial intelligence and product development"
     - Category & Type: e.g. "assignment", "assignment 1", "gtu assignment", "practical assignment"
     - Department & Sem combinations: e.g. "sem 5", "semester 5", "sem 5 it", "information technology"
     - Gujarati Multilingual Tags: e.g. "gu: એઆઈપીડી", "gu: એસાઇનમેન્ટ", "gu: સેમેસ્ટર 5", "gu: ઇન્ફોર્મેશન ટેકનોલોજી"
     - Hindi Multilingual Tags: e.g. "hi: असाइनमेंट", "hi: सेमेस्टर 5"

  4. TITLE & CONTENT SUMMARY:
     - Formulate a clean, professional title: e.g. "AIPD Assignment 1 - Artificial Intelligence & Product Development (Sem 5)"
     - Provide a clear 2-3 sentence content summary describing what students will study/submit.

CRITICAL RULES FOR CAMPUS ALERTS (actionType = "BROADCAST_ALERT"):
- Formulate title, clean announcement message, target department, target semester, priority (normal/high/urgent).

CRITICAL RULES FOR ATTENDANCE & MARKS (actionType = "UPDATE_ATTENDANCE_MARKS"):
- Extract enrollment_no, student_name, overall_attendance, subject, mid_sem_marks, practical_marks.

JSON Output Schema:
{
  "actionType": "INSERT_DOCUMENT" | "BROADCAST_ALERT" | "UPDATE_ATTENDANCE_MARKS" | "QUERY_INFO" | "GENERAL_CHAT",
  "requiresConfirmation": boolean,
  "message": "Friendly explanation to the admin explaining that the document has been analyzed, tags generated, and asking for confirmation before writing to the database",
  "documentData": {
    "title": "AIPD Assignment 1 - Artificial Intelligence & Product Development",
    "category": "assignment",
    "department": "Information Technology",
    "semester": "5",
    "division": "All",
    "subject_name": "Artificial Intelligence and Product Development (AIPD)",
    "tags": ["aipd", "aipd assignment", "artificial intelligence and product development", "sem 5", "semester 5", "sem 5 it", "information technology", "assignment 1", "gtu assignment", "practical assignment", "gu: એઆઈપીડી", "gu: એસાઇનમેન્ટ", "gu: સેમેસ્ટર 5"],
    "content_summary": "Official Semester 5 assignment covering Artificial Intelligence and Product Development concepts, model design, and practical exercises.",
    "explanation": "Inferred subject 'Artificial Intelligence and Product Development' for Semester 5 Information Technology with 13 multilingual and voice-search tags."
  },
  "alertData": { ... },
  "scoresData": [ ... ]
}`;

  try {
    const userMessage = `Admin Prompt: "${prompt}"
Attached File Name: ${attachedFile ? `"${attachedFile.name}" (${(attachedFile.size / 1024).toFixed(1)} KB)` : 'None'}
${fileSnippetText ? `File Content Snippet: """${fileSnippetText}"""` : ''}`;

    const modelsToTry = [
      'openai/gpt-oss-120b',
      'llama-3.3-70b-versatile',
      'llama-3.1-70b-versatile',
      'llama-3.1-8b-instant'
    ];

    let lastError: any = null;
    let parsed: any = null;

    for (const modelName of modelsToTry) {
      try {
        const response = await fetch('https://api.groq.com/openai/v1/chat/completions', {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${GROQ_API_KEY}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            model: modelName,
            messages: [
              { role: 'system', content: systemPrompt },
              { role: 'user', content: userMessage }
            ],
            temperature: 0.1,
            response_format: { type: 'json_object' }
          })
        });

        if (response.ok) {
          const data = await response.json();
          const content = data.choices?.[0]?.message?.content;
          if (content) {
            parsed = JSON.parse(content);
            break;
          }
        } else {
          lastError = new Error(`Groq model ${modelName} error: ${response.statusText}`);
        }
      } catch (err) {
        lastError = err;
      }
    }

    if (!parsed) {
      throw lastError || new Error('Groq AI model response failed.');
    }

    // Fallback tag builder if tags array was short
    let generatedTags: string[] = Array.isArray(parsed.documentData?.tags) ? parsed.documentData.tags : [];
    if (parsed.documentData && generatedTags.length < 4) {
      const pLower = prompt.toLowerCase();
      const sLower = (parsed.documentData.subject_name || '').toLowerCase();
      generatedTags = [
        ...generatedTags,
        pLower,
        sLower,
        `sem ${parsed.documentData.semester || '5'}`,
        parsed.documentData.category || 'document',
        `gu: ${parsed.documentData.subject_name || 'દસ્તાવેજ'}`,
      ].filter(t => t.trim().length > 0);
    }

    return {
      actionType: parsed.actionType || (attachedFile ? 'INSERT_DOCUMENT' : 'GENERAL_CHAT'),
      requiresConfirmation: parsed.requiresConfirmation ?? (parsed.actionType === 'INSERT_DOCUMENT' || parsed.actionType === 'BROADCAST_ALERT' || parsed.actionType === 'UPDATE_ATTENDANCE_MARKS'),
      message: parsed.message || 'I have analyzed your document and automatically generated academic tags and categorization. Please review below:',
      documentData: parsed.documentData ? {
        title: parsed.documentData.title || (attachedFile ? attachedFile.name.replace(/\.[^/.]+$/, '') : 'Academic Document'),
        category: parsed.documentData.category || (prompt.toLowerCase().includes('syllabus') ? 'syllabus' : 'other'),
        department: parsed.documentData.department || 'Information Technology',
        semester: String(parsed.documentData.semester || '1'),
        division: parsed.documentData.division || 'All',
        subject_name: parsed.documentData.subject_name || parsed.documentData.title || '',
        tags: generatedTags,
        content_summary: parsed.documentData.content_summary || prompt,
        file_url: (prompt.match(/(https?:\/\/[^\s\)]+)/i) || [])[1] || parsed.documentData.file_url,
        explanation: parsed.documentData.explanation || 'Extracted document metadata with auto-generated tags.'
      } : undefined,
      alertData: parsed.alertData ? {
        title: parsed.alertData.title || '📢 Campus Announcement',
        message: parsed.alertData.message || prompt,
        category: parsed.alertData.category || 'general',
        department: parsed.alertData.department || 'All',
        semester: String(parsed.alertData.semester || 'All'),
        priority: parsed.alertData.priority || 'normal',
        explanation: parsed.alertData.explanation || 'Processed campus alert.'
      } : undefined,
      scoresData: Array.isArray(parsed.scoresData) ? parsed.scoresData : undefined
    };
  } catch (error) {
    console.error('Universal Groq Agent error:', error);
    // Fallback logic
    const lower = prompt.toLowerCase();
    const isDoc = attachedFile || lower.includes('upload') || lower.includes('pdf') || lower.includes('timetable') || lower.includes('assignment') || lower.includes('manual') || lower.includes('syllabus') || lower.includes('http');
    
    if (isDoc) {
      const isSem5 = lower.includes('sem 5') || lower.includes('5th sem') || lower.includes('sem5');
      const isAipd = lower.includes('aipd') || lower.includes('artificial intelligence');
      const isFbc = lower.includes('fbc') || lower.includes('blockchain');

      return {
        actionType: 'INSERT_DOCUMENT',
        requiresConfirmation: true,
        message: '📄 I analyzed your document details and generated comprehensive academic search tags. Please confirm before adding to the repository:',
        documentData: {
          title: attachedFile ? attachedFile.name.replace(/\.[^/.]+$/, '') : (isAipd ? 'AIPD Assignment - Sem 5' : 'Academic Document'),
          category: lower.includes('syllabus') ? 'syllabus' : (lower.includes('assignment') ? 'assignment' : (lower.includes('timetable') ? 'timetable' : (lower.includes('manual') ? 'lab_manual' : 'notes'))),
          department: 'Information Technology',
          semester: isSem5 ? '5' : '1',
          division: 'All',
          subject_name: isAipd ? 'Artificial Intelligence and Product Development (AIPD)' : (isFbc ? 'Fundamentals of Blockchain (FBC)' : 'Information Technology Subject'),
          tags: isAipd 
            ? ['aipd', 'aipd assignment', 'artificial intelligence', 'sem 5', 'semester 5', 'information technology', 'gtu', 'gu: એઆઈપીડી', 'gu: એસાઇનમેન્ટ']
            : ['academic_doc', 'semester 5', 'gtu', 'it_department'],
          file_url: (prompt.match(/(https?:\/\/[^\s\)]+)/i) || [])[1],
          content_summary: prompt || 'Academic document uploaded via AI Copilot.',
          explanation: 'Auto-categorized document with generated multilingual search tags.'
        }
      };
    }

    return {
      actionType: 'GENERAL_CHAT',
      requiresConfirmation: false,
      message: 'I am your Eduai Universal Admin AI. How may I assist you with document uploads, student records, or announcements today?'
    };
  }
}

export async function parseAdminUploadPrompt(
  prompt: string,
  attachedFile?: { name: string; size: number } | string | null
): Promise<ExtractedDocMetadata> {
  const fileObj = typeof attachedFile === 'string'
    ? { name: attachedFile, size: 1024 * 100 }
    : attachedFile;

  const res = await parseUniversalAdminCommand(prompt, fileObj);
  if (res.documentData) return res.documentData;
  return {
    title: fileObj ? fileObj.name.replace(/\.[^/.]+$/, '') : 'Academic Document',
    category: 'other',
    department: 'Information Technology',
    semester: '1',
    division: 'All',
    subject_name: '',
    tags: ['academic_doc', 'semester 1'],
    content_summary: prompt,
    explanation: 'Processed upload request.'
  };
}

export async function parseAdminAlertPrompt(
  prompt: string
): Promise<ExtractedAlertMetadata> {
  const res = await parseUniversalAdminCommand(prompt, null);
  if (res.alertData) return res.alertData;
  return {
    title: '📢 Campus Notice',
    message: prompt,
    category: 'general',
    department: 'All',
    semester: 'All',
    priority: 'normal',
    explanation: 'Processed announcement.'
  };
}

