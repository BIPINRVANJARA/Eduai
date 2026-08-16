import React, { useState, useRef, useEffect } from 'react'
import { 
  FileSpreadsheet, 
  Upload, 
  Download, 
  CheckCircle2, 
  Save, 
  Search, 
  Users,
  RefreshCw
} from 'lucide-react'
import * as XLSX from 'xlsx'
import Papa from 'papaparse'
import { supabase } from '../config/supabase'
import { useAuth } from '../contexts/AuthContext'

interface StudentRecord {
  id: string
  enrollment_no: string
  full_name: string
  department: string
  semester: string | number
  division: string
  overall_attendance: number
  marks_data: Record<string, { mid_sem?: number; practical?: number; total?: number; attendance?: number }>
  status?: string
}

interface ParsedRow {
  enrollment_no: string
  student_name?: string
  attendance?: number
  subject?: string
  mid_sem_marks?: number
  practical_marks?: number
  matchedStudent?: StudentRecord
  isValid: boolean
}

export default function AttendanceMarksPage() {
  const { institution, selectedDepartment } = useAuth()
  const [activeTab, setActiveTab] = useState<'excel_upload' | 'live_grid'>('excel_upload')
  const [students, setStudents] = useState<StudentRecord[]>([])
  const [isLoadingStudents, setIsLoadingStudents] = useState(true)

  // Filter for live grid
  const [selectedDept, setSelectedDept] = useState('All')
  const [selectedSem, setSelectedSem] = useState('All')
  const [gridSearch, setGridSearch] = useState('')
  const [activeSubjectFilter, setActiveSubjectFilter] = useState('All')
  const [editedGrid, setEditedGrid] = useState<{ [id: string]: { attendance: number; midSem: number; practical: number } }>({})
  const [isSavingGrid, setIsSavingGrid] = useState(false)

  // Excel Upload state
  const [uploadDept, setUploadDept] = useState(selectedDepartment !== 'all' ? selectedDepartment : 'Information Technology')
  const [uploadSem, setUploadSem] = useState('5')
  const [uploadedFile, setUploadedFile] = useState<File | null>(null)
  const [parsedRows, setParsedRows] = useState<ParsedRow[]>([])
  const [isSyncing, setIsSyncing] = useState(false)
  const [syncSuccessCount, setSyncSuccessCount] = useState<number | null>(null)
  const [syncTotalRows, setSyncTotalRows] = useState<number | null>(null)
  const fileInputRef = useRef<HTMLInputElement>(null)

  useEffect(() => {
    fetchStudents()
  }, [institution?.id, selectedDepartment])

  const fetchStudents = async () => {
    setIsLoadingStudents(true)
    try {
      let query = supabase
        .from('students')
        .select('*')
        .order('enrollment_no', { ascending: true })

      if (institution?.id) {
        query = query.eq('institution_id', institution.id)
      }

      if (selectedDepartment && selectedDepartment !== 'all') {
        query = query.eq('department', selectedDepartment)
      }

      const { data, error } = await query

      if (error) throw error
      const list = (data || []).map((s: any) => ({
        ...s,
        department: s.department || s.branch_name || 'Information Technology',
        semester: s.semester != null ? String(s.semester) : (s.current_semester != null ? String(s.current_semester) : '5'),
        overall_attendance: s.overall_attendance != null ? Number(s.overall_attendance) : 85.0,
        marks_data: s.marks_data || {}
      }))
      setStudents(list)

      // Initialize edited grid state
      const initialGrid: any = {}
      list.forEach(s => {
        const defaultSubject = s.marks_data ? Object.keys(s.marks_data)[0] : 'General'
        const marks = s.marks_data?.[defaultSubject] || {}
        initialGrid[s.id] = {
          attendance: s.overall_attendance,
          midSem: marks.mid_sem ?? 24,
          practical: marks.practical ?? 28
        }
      })
      setEditedGrid(initialGrid)
    } catch (err: any) {
      console.error('Error loading students:', err)
    } finally {
      setIsLoadingStudents(false)
    }
  }

  // 1. DOWNLOAD EXCEL SAMPLE TEMPLATE
  const handleDownloadTemplate = () => {
    const sampleData = [
      {
        'Enrollment No': '246240316092',
        'Student Name': 'Parmar Varshil Jayeshkumar',
        'Subject Name': 'AIPE',
        'Overall Attendance %': 86.7,
        'Mid Sem Marks (Out of 30)': 14,
        'Practical Marks (Out of 30)': 23
      },
      {
        'Enrollment No': '246240316092',
        'Student Name': 'Parmar Varshil Jayeshkumar',
        'Subject Name': 'AIPD',
        'Overall Attendance %': 73.3,
        'Mid Sem Marks (Out of 30)': 18,
        'Practical Marks (Out of 30)': 18
      },
      {
        'Enrollment No': '246240316095',
        'Student Name': 'Patel Devansi Dahyabhai',
        'Subject Name': 'AIPE',
        'Overall Attendance %': 80.3,
        'Mid Sem Marks (Out of 30)': 22,
        'Practical Marks (Out of 30)': 15
      }
    ]

    const worksheet = XLSX.utils.json_to_sheet(sampleData)
    const workbook = XLSX.utils.book_new()
    XLSX.utils.book_append_sheet(workbook, worksheet, 'Attendance & Marks')
    XLSX.writeFile(workbook, 'Timestunner_Attendance_Marks_Template.xlsx')
  }

  // 2. PARSE EXCEL / CSV FILE
  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      processFile(e.target.files[0])
    }
  }

  const processFile = async (file: File) => {
    setUploadedFile(file)
    setSyncSuccessCount(null)
    setSyncTotalRows(null)

    try {
      const fileName = file.name.toLowerCase()
      let rawData: any[] = []

      if (fileName.endsWith('.csv')) {
        const text = await file.text()
        const parsed = Papa.parse(text, { header: true, skipEmptyLines: true })
        rawData = parsed.data
      } else {
        const buffer = await file.arrayBuffer()
        const workbook = XLSX.read(buffer, { type: 'array' })
        const firstSheetName = workbook.SheetNames[0]
        const worksheet = workbook.Sheets[firstSheetName]
        rawData = XLSX.utils.sheet_to_json(worksheet)
      }

      // Map columns flexibly
      const mappedRows: ParsedRow[] = rawData.map((row: any) => {
        // Find enrollment key
        const enrKey = Object.keys(row).find(k => 
          /enroll|roll|enr/i.test(k)
        )
        const enr = enrKey ? String(row[enrKey]).trim() : ''

        // Find student name key
        const nameKey = Object.keys(row).find(k => 
          /name|student/i.test(k)
        )
        const sName = nameKey ? String(row[nameKey]).trim() : undefined

        // Find attendance key
        const attKey = Object.keys(row).find(k => 
          /att|percentage|%/i.test(k)
        )
        const attVal = attKey && row[attKey] != null ? parseFloat(String(row[attKey]).replace(/%/g, '')) : undefined

        // Find subject key
        const subKey = Object.keys(row).find(k => 
          /subject|course/i.test(k)
        )
        const subject = subKey ? String(row[subKey]).trim() : 'General'

        // Find mid sem marks
        const marksKey = Object.keys(row).find(k => 
          /mid|internal|mark|score/i.test(k) && !/prac/i.test(k)
        )
        const midMarks = marksKey && row[marksKey] != null ? parseFloat(String(row[marksKey])) : undefined

        // Find practical marks
        const pracKey = Object.keys(row).find(k => 
          /prac|lab/i.test(k)
        )
        const pracMarks = pracKey && row[pracKey] != null ? parseFloat(String(row[pracKey])) : undefined

        // Match with database student
        const matched = students.find(s => s.enrollment_no?.toLowerCase() === enr.toLowerCase())

        return {
          enrollment_no: enr,
          student_name: sName || matched?.full_name,
          attendance: attVal,
          subject,
          mid_sem_marks: midMarks,
          practical_marks: pracMarks,
          matchedStudent: matched,
          isValid: Boolean(enr && (attVal !== undefined || midMarks !== undefined))
        }
      }).filter(r => r.enrollment_no)

      setParsedRows(mappedRows)
    } catch (err: any) {
      alert(`Error reading file: ${err.message}`)
    }
  }

  // 3. SYNC PARSED ROWS TO DATABASE (AUTO-CREATING ALL PROFILES & MULTI-SUBJECT MARKS)
  const handleSyncToDatabase = async () => {
    if (parsedRows.length === 0) return
    setIsSyncing(true)

    try {
      // Group all subject rows by unique enrollment_no
      const studentMap = new Map<string, {
        name: string,
        subjectRows: ParsedRow[]
      }>()

      for (const row of parsedRows) {
        if (!row.enrollment_no) continue
        const enr = row.enrollment_no.trim()

        if (!studentMap.has(enr)) {
          studentMap.set(enr, {
            name: row.student_name || 'Student',
            subjectRows: []
          })
        }

        const entry = studentMap.get(enr)!
        if (row.student_name && entry.name === 'Student') {
          entry.name = row.student_name
        }
        entry.subjectRows.push(row)
      }

      let processedStudents = 0

      // Ingest / Upsert each unique student
      for (const [enr, studentInfo] of studentMap.entries()) {
        // 1. Calculate overall average attendance across all subjects
        const validAttendances = studentInfo.subjectRows
          .map(r => r.attendance)
          .filter((a): a is number => a !== undefined && !isNaN(a))

        const avgAttendance = validAttendances.length > 0
          ? Number((validAttendances.reduce((a, b) => a + b, 0) / validAttendances.length).toFixed(1))
          : 85.0

        // 2. Build combined marks_data dictionary
        const marksObj: Record<string, any> = {}
        for (const r of studentInfo.subjectRows) {
          const sub = r.subject || 'General'
          marksObj[sub] = {
            mid_sem: r.mid_sem_marks ?? 20,
            practical: r.practical_marks ?? 25,
            attendance: r.attendance ?? 85.0,
            total: 30
          }
        }

        // 3. Check if student already exists in DB
        const { data: existingStudent } = await supabase
          .from('students')
          .select('id, marks_data, full_name, department, semester')
          .eq('enrollment_no', enr)
          .maybeSingle()

        if (existingStudent) {
          // Update existing student with merged subjects & fresh attendance
          const { error: updateErr } = await supabase
            .from('students')
            .update({
              full_name: studentInfo.name !== 'Student' ? studentInfo.name : existingStudent.full_name,
              overall_attendance: avgAttendance,
              marks_data: { ...(existingStudent.marks_data || {}), ...marksObj },
              department: uploadDept,
              semester: parseInt(uploadSem) || 5
            })
            .eq('id', existingStudent.id)

          if (updateErr) throw updateErr
        } else {
          // Insert NEW student record with safe required field fallbacks
          const cleanEmail = `${enr.toLowerCase().replace(/[^a-z0-9]/g, '')}@gph.ac.in`
          const { error: insertErr } = await supabase
            .from('students')
            .insert({
              enrollment_no: enr,
              full_name: studentInfo.name,
              email: cleanEmail,
              mobile: '9999999999',
              parent_email: `parent_${cleanEmail}`,
              parent_mobile: '9999999999',
              department: uploadDept,
              semester: parseInt(uploadSem) || 5,
              division: 'A',
              overall_attendance: avgAttendance,
              marks_data: marksObj,
              status: 'approved',
              institution_id: 'gph_624'
            })

          if (insertErr) throw insertErr
        }

        processedStudents++
      }

      setSyncSuccessCount(processedStudents)
      setSyncTotalRows(parsedRows.length)
      await fetchStudents()
    } catch (err: any) {
      console.error('Sync failed:', err)
      alert(`Failed to sync to database: ${err.message || JSON.stringify(err)}`)
    } finally {
      setIsSyncing(false)
    }
  }

  // 4. SAVE LIVE GRID CHANGES
  const handleSaveGridChanges = async () => {
    setIsSavingGrid(true)
    try {
      const promises = Object.entries(editedGrid).map(async ([studentId, data]) => {
        const student = students.find(s => s.id === studentId)
        if (!student) return

        const currentMarks = student.marks_data || {}
        const targetSub = activeSubjectFilter === 'All' ? Object.keys(currentMarks)[0] || 'General' : activeSubjectFilter

        return supabase
          .from('students')
          .update({
            overall_attendance: data.attendance,
            marks_data: {
              ...currentMarks,
              [targetSub]: {
                ...(currentMarks[targetSub] || {}),
                mid_sem: data.midSem,
                practical: data.practical,
                total: 30
              }
            }
          })
          .eq('id', studentId)
      })

      await Promise.all(promises)
      alert('✅ All attendance & marks updated in live database!')
      await fetchStudents()
    } catch (err: any) {
      alert(`Error updating records: ${err.message}`)
    } finally {
      setIsSavingGrid(false)
    }
  }

  // Filter students for live grid tab with fuzzy/relaxed matching
  const gridFilteredStudents = students.filter(s => {
    const studentDept = (s.department || '').toLowerCase()
    const filterDept = selectedDept.toLowerCase()
    const matchesDept = 
      selectedDept === 'All' || 
      studentDept === filterDept ||
      studentDept.includes(filterDept) ||
      filterDept.includes(studentDept)

    const studentSemStr = String(s.semester ?? '').replace(/[^0-9]/g, '')
    const filterSemStr = String(selectedSem ?? '').replace(/[^0-9]/g, '')
    const matchesSem = selectedSem === 'All' || !filterSemStr || studentSemStr === filterSemStr

    const matchesSearch = !gridSearch.trim() || 
      s.full_name?.toLowerCase().includes(gridSearch.toLowerCase()) ||
      s.enrollment_no?.toLowerCase().includes(gridSearch.toLowerCase())

    return matchesDept && matchesSem && matchesSearch
  })

  // Collect all distinct subject names across all loaded students
  const allSubjectsSet = new Set<string>()
  students.forEach(s => {
    if (s.marks_data) {
      Object.keys(s.marks_data).forEach(sub => allSubjectsSet.add(sub))
    }
  })
  const availableSubjects = Array.from(allSubjectsSet)

  // Unique count in parsed rows
  const uniqueParsedCount = new Set(parsedRows.map(r => r.enrollment_no)).size

  return (
    <div className="space-y-6 max-w-7xl mx-auto pb-12">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <div className="flex items-center gap-2">
            <h1 className="text-2xl font-black text-text-primary tracking-tight">Attendance & Marks Ingestor</h1>
            <span className="text-[10px] bg-primary/20 text-primary px-2.5 py-0.5 rounded-full font-bold border border-primary/30">
              Bulk Auto-Sync
            </span>
          </div>
          <p className="text-xs text-text-secondary mt-1">
            Auto-create student profiles and bulk update attendance percentages & subject marks from Excel/CSV sheets
          </p>
        </div>

        {/* Tab Switcher */}
        <div className="flex items-center gap-1.5 bg-surface border border-card-border p-1 rounded-xl">
          <button
            onClick={() => setActiveTab('excel_upload')}
            className={`flex items-center gap-2 px-3.5 py-2 rounded-lg text-xs font-bold transition-all ${
              activeTab === 'excel_upload'
                ? 'bg-primary text-background shadow-md shadow-primary/20'
                : 'text-text-secondary hover:text-text-primary'
            }`}
          >
            <Upload size={14} />
            1. Excel / CSV Upload
          </button>
          <button
            onClick={() => {
              setActiveTab('live_grid')
              fetchStudents()
            }}
            className={`flex items-center gap-2 px-3.5 py-2 rounded-lg text-xs font-bold transition-all ${
              activeTab === 'live_grid'
                ? 'bg-primary text-background shadow-md shadow-primary/20'
                : 'text-text-secondary hover:text-text-primary'
            }`}
          >
            <FileSpreadsheet size={14} />
            2. Live Spreadsheet Grid ({students.length})
          </button>
        </div>
      </div>

      {/* TAB 1: EXCEL / CSV UPLOAD */}
      {activeTab === 'excel_upload' && (
        <div className="space-y-6">
          {/* Target Department & Semester Selection */}
          <div className="bg-surface border border-card-border rounded-2xl p-4 flex items-center justify-between">
            <div className="flex items-center gap-4 text-xs">
              <span className="text-text-secondary font-bold">Target Ingestion Class:</span>
              <div className="flex items-center gap-2">
                <label className="text-text-muted">Department:</label>
                <select
                  value={uploadDept}
                  onChange={e => setUploadDept(e.target.value)}
                  className="bg-surface-light border border-card-border rounded-lg p-1.5 text-text-primary font-semibold"
                >
                  <option value="Information Technology">Information Technology</option>
                  <option value="Computer Science & Engineering">Computer Science & Engineering</option>
                  <option value="Electronics & Communication">Electronics & Communication</option>
                  <option value="Mechanical Engineering">Mechanical Engineering</option>
                  <option value="Civil Engineering">Civil Engineering</option>
                </select>
              </div>

              <div className="flex items-center gap-2">
                <label className="text-text-muted">Semester:</label>
                <select
                  value={uploadSem}
                  onChange={e => setUploadSem(e.target.value)}
                  className="bg-surface-light border border-card-border rounded-lg p-1.5 text-text-primary font-semibold"
                >
                  {['1','2','3','4','5','6','7','8'].map(s => (
                    <option key={s} value={s}>Semester {s}</option>
                  ))}
                </select>
              </div>
            </div>

            <button
              onClick={handleDownloadTemplate}
              className="text-xs bg-surface-light hover:bg-card-border text-cyan-accent px-3 py-1.5 rounded-lg border border-card-border transition-colors flex items-center gap-1.5 font-bold"
            >
              <Download size={13} />
              Download Excel Template
            </button>
          </div>

          {/* Upload Drop Zone */}
          <div
            onClick={() => fileInputRef.current?.click()}
            className="border-2 border-dashed border-card-border hover:border-primary bg-surface hover:bg-surface-light/50 rounded-2xl p-8 text-center cursor-pointer transition-all space-y-3"
          >
            <input
              type="file"
              ref={fileInputRef}
              onChange={handleFileChange}
              accept=".xlsx,.xls,.csv"
              className="hidden"
            />
            <div className="w-14 h-14 bg-primary/10 border border-primary/30 rounded-2xl flex items-center justify-center mx-auto text-primary">
              <Upload size={28} />
            </div>
            <div>
              <h3 className="text-sm font-bold text-text-primary">
                {uploadedFile ? uploadedFile.name : 'Click to Upload or Drag & Drop Excel / CSV Sheet'}
              </h3>
              <p className="text-xs text-text-secondary mt-1">
                Supports .xlsx, .xls, .csv containing Enrollment No, Student Name, Subject, Attendance %, and Marks
              </p>
            </div>
            {uploadedFile && (
              <span className="inline-block text-[11px] bg-primary/20 text-primary px-3 py-1 rounded-full font-bold">
                ✓ Ready to process {(uploadedFile.size / 1024).toFixed(1)} KB ({parsedRows.length} rows detected)
              </span>
            )}
          </div>

          {/* Sync Success Banner */}
          {syncSuccessCount !== null && (
            <div className="bg-primary/15 border border-primary/30 rounded-2xl p-4 flex items-center justify-between text-primary text-xs font-bold animate-fadeIn">
              <div className="flex items-center gap-3">
                <CheckCircle2 size={18} />
                <span>🎉 Successfully created and synchronized {syncSuccessCount} student profiles ({syncTotalRows} subject records) to the live database!</span>
              </div>

              <button
                onClick={() => {
                  setActiveTab('live_grid')
                  fetchStudents()
                }}
                className="bg-primary text-background px-3 py-1.5 rounded-lg font-black text-xs hover:bg-primary-dark transition-all"
              >
                View in Live Grid →
              </button>
            </div>
          )}

          {/* Parsed Rows Preview Table */}
          {parsedRows.length > 0 && (
            <div className="bg-surface border border-card-border rounded-2xl overflow-hidden shadow-xl space-y-4 p-4">
              <div className="flex items-center justify-between">
                <div>
                  <h3 className="text-sm font-bold text-text-primary flex items-center gap-2">
                    <Users size={16} className="text-primary" />
                    Parsed Student Scores Preview
                  </h3>
                  <span className="text-xs text-text-muted">
                    {uniqueParsedCount} Unique Students Extracted • {parsedRows.length} Total Subject Entries
                  </span>
                </div>

                <button
                  onClick={handleSyncToDatabase}
                  disabled={isSyncing}
                  className="bg-primary text-background font-black text-xs px-5 py-2.5 rounded-xl hover:bg-primary-dark transition-all flex items-center gap-2 shadow-lg shadow-primary/20"
                >
                  {isSyncing ? (
                    <div className="w-4 h-4 border-2 border-background border-t-transparent rounded-full animate-spin" />
                  ) : (
                    <>
                      <CheckCircle2 size={16} />
                      Confirm & Ingest All {uniqueParsedCount} Students to Database
                    </>
                  )}
                </button>
              </div>

              <div className="overflow-x-auto max-h-[500px]">
                <table className="w-full text-left text-xs">
                  <thead className="bg-surface-light text-text-muted uppercase font-bold border-b border-card-border sticky top-0">
                    <tr>
                      <th className="p-3">Enrollment No</th>
                      <th className="p-3">Student Name</th>
                      <th className="p-3">Subject</th>
                      <th className="p-3">Attendance %</th>
                      <th className="p-3">Mid-Sem Marks</th>
                      <th className="p-3">Practical</th>
                      <th className="p-3">Action Status</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-card-border text-text-primary">
                    {parsedRows.map((row, idx) => (
                      <tr key={idx} className="hover:bg-surface-light/50 transition-colors">
                        <td className="p-3 font-mono font-bold text-cyan-accent">{row.enrollment_no}</td>
                        <td className="p-3 font-semibold">{row.student_name || '—'}</td>
                        <td className="p-3 text-text-secondary">{row.subject || 'General'}</td>
                        <td className="p-3 font-bold">
                          {row.attendance !== undefined ? (
                            <span className={row.attendance >= 75 ? 'text-primary' : 'text-error'}>
                              {row.attendance}%
                            </span>
                          ) : '—'}
                        </td>
                        <td className="p-3 font-mono">{row.mid_sem_marks !== undefined ? `${row.mid_sem_marks}/30` : '—'}</td>
                        <td className="p-3 font-mono">{row.practical_marks !== undefined ? `${row.practical_marks}/30` : '—'}</td>
                        <td className="p-3">
                          {row.matchedStudent ? (
                            <span className="text-[10px] bg-accent/15 text-accent px-2 py-0.5 rounded-full font-bold border border-accent/30">
                              ✓ Existing Student (Sync)
                            </span>
                          ) : (
                            <span className="text-[10px] bg-primary/15 text-primary px-2 py-0.5 rounded-full font-bold border border-primary/30">
                              ✨ Auto-Create & Approve
                            </span>
                          )}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}
        </div>
      )}

      {/* TAB 2: LIVE SPREADSHEET GRID */}
      {activeTab === 'live_grid' && (
        <div className="space-y-4">
          {/* Controls Bar */}
          <div className="bg-surface border border-card-border rounded-2xl p-4 flex flex-wrap items-center justify-between gap-4">
            <div className="flex flex-wrap items-center gap-3 text-xs">
              <div>
                <label className="text-text-muted block mb-1 font-bold">Department</label>
                <select
                  value={selectedDept}
                  onChange={e => setSelectedDept(e.target.value)}
                  className="bg-surface-light border border-card-border rounded-xl p-2 text-text-primary font-semibold"
                >
                  <option value="All">All Departments</option>
                  <option value="Information Technology">Information Technology</option>
                  <option value="Computer Science & Engineering">Computer Science & Engineering</option>
                  <option value="Electronics & Communication">Electronics & Communication</option>
                  <option value="Mechanical Engineering">Mechanical Engineering</option>
                  <option value="Civil Engineering">Civil Engineering</option>
                </select>
              </div>

              <div>
                <label className="text-text-muted block mb-1 font-bold">Semester</label>
                <select
                  value={selectedSem}
                  onChange={e => setSelectedSem(e.target.value)}
                  className="bg-surface-light border border-card-border rounded-xl p-2 text-text-primary font-semibold"
                >
                  <option value="All">All Semesters</option>
                  {['1','2','3','4','5','6','7','8'].map(s => (
                    <option key={s} value={s}>Semester {s}</option>
                  ))}
                </select>
              </div>

              {availableSubjects.length > 0 && (
                <div>
                  <label className="text-text-muted block mb-1 font-bold">Subject View</label>
                  <select
                    value={activeSubjectFilter}
                    onChange={e => setActiveSubjectFilter(e.target.value)}
                    className="bg-surface-light border border-card-border rounded-xl p-2 text-cyan-accent font-semibold"
                  >
                    <option value="All">All Subjects (Overview)</option>
                    {availableSubjects.map(sub => (
                      <option key={sub} value={sub}>{sub}</option>
                    ))}
                  </select>
                </div>
              )}

              <div>
                <label className="text-text-muted block mb-1 font-bold">Search</label>
                <div className="relative">
                  <Search size={14} className="absolute left-2.5 top-2.5 text-text-muted" />
                  <input
                    type="text"
                    value={gridSearch}
                    onChange={e => setGridSearch(e.target.value)}
                    placeholder="Search name or enrollment..."
                    className="bg-surface-light border border-card-border rounded-xl pl-8 pr-3 py-2 text-text-primary placeholder:text-text-muted"
                  />
                </div>
              </div>
            </div>

            <div className="flex items-center gap-2">
              <button
                onClick={fetchStudents}
                disabled={isLoadingStudents}
                className="bg-surface-light hover:bg-card-border text-text-secondary hover:text-text-primary text-xs px-3.5 py-2.5 rounded-xl border border-card-border transition-colors flex items-center gap-1.5 font-bold"
                title="Reload from Supabase"
              >
                <RefreshCw size={14} className={isLoadingStudents ? 'animate-spin' : ''} />
                Refresh
              </button>

              <button
                onClick={handleSaveGridChanges}
                disabled={isSavingGrid}
                className="bg-primary text-background font-black text-xs px-5 py-2.5 rounded-xl hover:bg-primary-dark transition-all flex items-center gap-2 shadow-lg shadow-primary/20"
              >
                {isSavingGrid ? (
                  <div className="w-4 h-4 border-2 border-background border-t-transparent rounded-full animate-spin" />
                ) : (
                  <>
                    <Save size={16} />
                    Save All Changes to Live DB
                  </>
                )}
              </button>
            </div>
          </div>

          {/* Live Editable Table */}
          <div className="bg-surface border border-card-border rounded-2xl overflow-hidden shadow-xl">
            <div className="p-3 bg-surface-light border-b border-card-border flex items-center justify-between text-xs text-text-secondary">
              <span>Showing <strong>{gridFilteredStudents.length}</strong> of <strong>{students.length}</strong> total students</span>
              {availableSubjects.length > 0 && (
                <span>Subjects: <strong>{availableSubjects.join(', ')}</strong></span>
              )}
            </div>

            <table className="w-full text-left text-xs">
              <thead className="bg-surface-light text-text-muted uppercase font-bold border-b border-card-border">
                <tr>
                  <th className="p-3.5">Enrollment No</th>
                  <th className="p-3.5">Student Name</th>
                  <th className="p-3.5">Class</th>
                  <th className="p-3.5 w-32">Overall Attendance %</th>
                  <th className="p-3.5">Subject Breakdown</th>
                  <th className="p-3.5">Eligibility</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-card-border text-text-primary">
                {isLoadingStudents ? (
                  <tr>
                    <td colSpan={6} className="p-8 text-center text-text-secondary">
                      Loading student records from Supabase...
                    </td>
                  </tr>
                ) : gridFilteredStudents.length === 0 ? (
                  <tr>
                    <td colSpan={6} className="p-8 text-center text-text-secondary">
                      No student records match the filter ({selectedDept} Sem {selectedSem}). Click <strong>"All Departments"</strong> or reload.
                    </td>
                  </tr>
                ) : (
                  gridFilteredStudents.map(student => {
                    const currentValues = editedGrid[student.id] || {
                      attendance: student.overall_attendance,
                      midSem: 24,
                      practical: 28
                    }

                    const isEligible = currentValues.attendance >= 75
                    const subjects = Object.entries(student.marks_data || {})

                    return (
                      <tr key={student.id} className="hover:bg-surface-light/40 transition-colors">
                        <td className="p-3.5 font-mono font-bold text-cyan-accent">
                          {student.enrollment_no}
                        </td>
                        <td className="p-3.5 font-semibold text-text-primary">
                          {student.full_name}
                        </td>
                        <td className="p-3.5 text-text-secondary">
                          Sem {student.semester}
                        </td>
                        <td className="p-3.5">
                          <input
                            type="number"
                            min="0"
                            max="100"
                            step="0.1"
                            value={currentValues.attendance}
                            onChange={e => {
                              const val = parseFloat(e.target.value) || 0
                              setEditedGrid(prev => ({
                                ...prev,
                                [student.id]: { ...currentValues, attendance: val }
                              }))
                            }}
                            className={`w-24 bg-surface-light border rounded-lg px-2 py-1 font-bold ${
                              isEligible 
                                ? 'border-primary/40 text-primary' 
                                : 'border-error/40 text-error'
                            }`}
                          />
                        </td>
                        <td className="p-3.5">
                          {subjects.length > 0 ? (
                            <div className="flex flex-wrap gap-1.5 max-w-md">
                              {subjects.map(([sub, data]) => (
                                <span
                                  key={sub}
                                  className="text-[11px] bg-surface-light border border-card-border px-2 py-1 rounded-md text-text-secondary"
                                >
                                  <strong className="text-text-primary">{sub}:</strong> Mid {data.mid_sem ?? '—'}/30 • Prac {data.practical ?? '—'}/30
                                </span>
                              ))}
                            </div>
                          ) : (
                            <span className="text-text-muted italic">No subject marks recorded</span>
                          )}
                        </td>
                        <td className="p-3.5">
                          {isEligible ? (
                            <span className="text-[11px] text-primary font-bold bg-primary/10 border border-primary/30 px-2 py-0.5 rounded-full">
                              Eligible (≥75%)
                            </span>
                          ) : (
                            <span className="text-[11px] text-error font-bold bg-error/10 border border-error/30 px-2 py-0.5 rounded-full">
                              Defaulter (&lt;75%)
                            </span>
                          )}
                        </td>
                      </tr>
                    )
                  })
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  )
}
