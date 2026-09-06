import fs from 'fs'
import path from 'path'

const supabaseUrl = 'https://ifframkwyjegmxubscnk.supabase.co'
const supabaseKey = 'sb_publishable_r5vlF_TnG3bb4Sxfm_tGMw_nJZ7-o4O'
const institutionId = '6c6e9b83-cabf-4b13-855b-97d2e1461177' // Govt Polytechnic Himmatnagar
const department = 'Information Technology'
const semester = '5'

// Classify file based on name
function classifyFile(fileName) {
  const lower = fileName.toLowerCase()
  let category = 'syllabus' // default allowed category
  let subject = 'Information Technology'
  let cleanTitle = fileName.replace(/\.[^/.]+$/, '').trim()
  let division = 'All'

  // Division detection
  if (lower.includes('div a') || lower.includes('a division')) division = 'A'
  else if (lower.includes('div b') || lower.includes('b division')) division = 'B'

  // Category detection (must map to: 'timetable', 'assignment', 'lab_manual', 'syllabus')
  if (lower.includes('assignment')) {
    category = 'assignment'
  } else if (lower.includes('lab manual') || lower.includes('labmanual')) {
    category = 'lab_manual'
  } else if (lower.includes('timetable') || lower.includes('time table') || lower.includes('tt2026') || lower.includes('exam time table')) {
    category = 'timetable'
  } else {
    category = 'syllabus'
  }

  // Subject detection
  if (lower.includes('aipd')) {
    subject = 'Artificial Intelligence and Product Development (AIPD)'
  } else if (lower.includes('aipe') || lower.includes('aiwpe')) {
    subject = 'Artificial Intelligence and Prompt Engineering (AIPE)'
  } else if (lower.includes('fbc') || lower.includes('blockchain')) {
    subject = 'Fundamentals of Blockchain (FBC)'
  } else if (lower.includes('cdct')) {
    subject = 'Cyber Security and Digital Crime Tracking (CDCT)'
  } else if (lower.includes('4361602')) {
    subject = 'Information Technology Course (4361602)'
  } else if (lower.includes('project') || lower.includes('team-guide')) {
    subject = 'Capstone Project Work & Seminar'
  } else if (lower.includes('scholarship')) {
    subject = 'Student Welfare & Scholarship'
  } else if (lower.includes('attendance')) {
    subject = 'Student Academic Review & Attendance'
  } else if (category === 'timetable') {
    subject = 'Class & Examination Schedule'
  }

  // Tags generation
  const tags = [
    'sem 5',
    'semester 5',
    'it department',
    'information technology',
    'gph',
    'govt polytechnic himatnagar',
    category,
    cleanTitle.toLowerCase(),
    subject.toLowerCase()
  ]

  if (subject.includes('AIPD')) tags.push('aipd', 'ai product development', 'aipd sem 5', 'એઆઈપીડી')
  if (subject.includes('AIPE')) tags.push('aipe', 'ai prompt engineering', 'aipe sem 5', 'aiwpe', 'એઆઈપીઈ')
  if (subject.includes('FBC')) tags.push('fbc', 'blockchain', 'fundamentals of blockchain', 'fbc sem 5', 'બ્લોકચેન')
  if (subject.includes('CDCT')) tags.push('cdct', 'cyber security', 'digital crime tracking', 'cdct sem 5', 'સાયબર સિક્યોરિટી')
  if (category === 'timetable') tags.push('timetable', 'tt', 'schedule', 'exam schedule', 'સમયપત્રક')
  if (category === 'assignment') tags.push('assignment', 'submission', 'gtu assignment', 'એસાઇનમેન્ટ')
  if (category === 'lab_manual') tags.push('lab manual', 'practical', 'experiment', 'લેબ મેન્યુઅલ')

  return {
    category,
    subject,
    cleanTitle,
    division,
    tags: Array.from(new Set(tags))
  }
}

// Split text into ~1800 character chunks with 300 char overlap
function chunkText(fullText) {
  const TARGET_SIZE = 1800
  const OVERLAP = 300
  const chunks = []

  if (!fullText || fullText.trim().length === 0) return chunks

  const clean = fullText.replace(/\s+/g, ' ').trim()
  if (clean.length <= TARGET_SIZE) {
    chunks.push(clean)
    return chunks
  }

  let start = 0
  while (start < clean.length) {
    let end = start + TARGET_SIZE
    if (end >= clean.length) {
      chunks.push(clean.substring(start).trim())
      break
    }
    const lastSpace = clean.lastIndexOf(' ', end)
    if (lastSpace > start + 500) {
      end = lastSpace
    }
    chunks.push(clean.substring(start, end).trim())
    start = Math.max(start + 1, end - OVERLAP)
  }

  return chunks
}

async function run() {
  console.log('🚀 Starting Sem 5 Bulk PDF Ingestion & RAG Indexing Pipeline...\n')
  
  const sem5Dir = path.join(process.cwd(), '..', 'Sem 5')
  if (!fs.existsSync(sem5Dir)) {
    console.error('Directory not found:', sem5Dir)
    return
  }

  const files = fs.readdirSync(sem5Dir)
  console.log(`📂 Found ${files.length} total files in Sem 5 directory.`)

  const pdfjsLib = await import('pdfjs-dist/legacy/build/pdf.mjs')

  let successCount = 0
  let totalChunksInserted = 0

  for (let idx = 0; idx < files.length; idx++) {
    const fileName = files[idx]
    const filePath = path.join(sem5Dir, fileName)
    const stats = fs.statSync(filePath)
    const fileExt = path.extname(fileName).toLowerCase()
    
    console.log(`\n[${idx + 1}/${files.length}] Processing: "${fileName}" (${(stats.size / 1024).toFixed(1)} KB)`)

    const classification = classifyFile(fileName)
    const fileBuffer = fs.readFileSync(filePath)

    // 1. Upload to Supabase Storage
    const safeStorageName = `sem5/${encodeURIComponent(fileName)}`
    const storageUrl = `${supabaseUrl}/storage/v1/object/documents/${safeStorageName}`
    const publicDownloadUrl = `${supabaseUrl}/storage/v1/object/public/documents/${safeStorageName}`

    try {
      await fetch(storageUrl, {
        method: 'POST',
        headers: {
          apikey: supabaseKey,
          Authorization: `Bearer ${supabaseKey}`,
          'Content-Type': fileExt === '.pdf' ? 'application/pdf' : 'application/octet-stream'
        },
        body: fileBuffer
      })
    } catch (_) {}

    // 2. Extract real text from PDF if .pdf
    let extractedText = ''
    let pageCount = 0

    if (fileExt === '.pdf') {
      try {
        const doc = await pdfjsLib.getDocument({ data: new Uint8Array(fileBuffer) }).promise
        pageCount = doc.numPages
        for (let p = 1; p <= pageCount; p++) {
          try {
            const page = await doc.getPage(p)
            const content = await page.getTextContent()
            const textItems = content.items.map(i => i.str).join(' ')
            if (textItems.trim().length > 0) {
              extractedText += `\n--- Page ${p} ---\n` + textItems
            }
          } catch (_) {}
        }
      } catch (pdfErr) {
        console.warn(`  ⚠️ Could not parse PDF text:`, pdfErr.message)
      }
    }

    console.log(`  📄 Extracted ${extractedText.length} characters from ${pageCount} pages.`)

    // 3. Insert or Update Record in `documents` Table
    const docPayload = {
      institution_id: institutionId,
      title: classification.cleanTitle,
      description: `Official Semester 5 ${classification.subject} material: ${classification.cleanTitle} for ${department}.`,
      category: classification.category,
      department: department,
      semester: semester,
      division: classification.division,
      subject_name: classification.subject,
      tags: classification.tags,
      content_summary: extractedText.length > 200 ? extractedText.slice(0, 500) + '...' : `Academic material for ${classification.cleanTitle}`,
      file_url: publicDownloadUrl,
      file_name: fileName,
      file_size: stats.size
    }

    let docId = null
    try {
      const insertDocRes = await fetch(`${supabaseUrl}/rest/v1/documents`, {
        method: 'POST',
        headers: {
          apikey: supabaseKey,
          Authorization: `Bearer ${supabaseKey}`,
          'Content-Type': 'application/json',
          Prefer: 'return=representation'
        },
        body: JSON.stringify(docPayload)
      })

      if (insertDocRes.ok) {
        const insertedData = await insertDocRes.json()
        docId = insertedData[0]?.id
        console.log(`  💾 Registered in documents table with ID: ${docId}`)
      } else {
        const errText = await insertDocRes.text()
        console.error(`  ❌ Error registering document:`, errText)
      }
    } catch (dbErr) {
      console.error(`  ❌ DB insert error:`, dbErr.message)
    }

    if (!docId) {
      // Fallback search existing doc by file_name
      try {
        const fetchExisting = await fetch(`${supabaseUrl}/rest/v1/documents?file_name=eq.${encodeURIComponent(fileName)}&limit=1`, {
          headers: { apikey: supabaseKey, Authorization: `Bearer ${supabaseKey}` }
        })
        const existData = await fetchExisting.json()
        if (existData && existData.length > 0) docId = existData[0].id
      } catch (_) {}
    }

    if (!docId) {
      console.warn(`  ⚠️ Skipping chunk indexing because document ID was not obtained.`)
      continue
    }

    // 4. Create text chunks and index into `document_chunks` table for RAG
    let chunks = []
    if (extractedText.trim().length > 100) {
      const rawChunks = chunkText(extractedText)
      chunks = rawChunks.map((c) => {
        return `DOCUMENT: ${classification.cleanTitle}\nSUBJECT: ${classification.subject} | SEMESTER 5 ${department}\nCATEGORY: ${classification.category.toUpperCase()}\n\nEXCERPT:\n${c}`
      })
    } else {
      chunks = [
        `DOCUMENT: ${classification.cleanTitle}\nSUBJECT: ${classification.subject} | SEMESTER 5 ${department}\nCATEGORY: ${classification.category.toUpperCase()}\n\nDETAILS: Official semester 5 ${classification.subject} material (${fileName}). Topics and keywords: ${classification.tags.join(', ')}`
      ]
    }

    // Delete any old chunks for this docId
    try {
      await fetch(`${supabaseUrl}/rest/v1/document_chunks?document_id=eq.${docId}`, {
        method: 'DELETE',
        headers: { apikey: supabaseKey, Authorization: `Bearer ${supabaseKey}` }
      })
    } catch (_) {}

    // Batch insert chunks
    let chunksInsertedForDoc = 0
    for (let cIdx = 0; cIdx < chunks.length; cIdx++) {
      const chunkPayload = {
        document_id: docId,
        institution_id: institutionId,
        department: department,
        semester: semester,
        subject_name: classification.subject,
        chunk_index: cIdx,
        chunk_content: chunks[cIdx],
        token_count: Math.ceil(chunks[cIdx].length / 4)
      }

      try {
        const chunkRes = await fetch(`${supabaseUrl}/rest/v1/document_chunks`, {
          method: 'POST',
          headers: {
            apikey: supabaseKey,
            Authorization: `Bearer ${supabaseKey}`,
            'Content-Type': 'application/json',
            Prefer: 'return=minimal'
          },
          body: JSON.stringify(chunkPayload)
        })
        if (chunkRes.ok) {
          chunksInsertedForDoc++
          totalChunksInserted++
        }
      } catch (cErr) {
        console.warn(`  ⚠️ Chunk ${cIdx} insert error:`, cErr.message)
      }
    }

    console.log(`  ⚡ Successfully indexed ${chunksInsertedForDoc} RAG chunks into PostgreSQL search_vector!`)
    successCount++
  }

  console.log(`\n======================================================`)
  console.log(`🎉 SEM 5 BULK RAG INGESTION COMPLETE!`)
  console.log(`📁 Documents successfully registered: ${successCount} / ${files.length}`)
  console.log(`📚 Total RAG Search Chunks Active: ${totalChunksInserted}`)
  console.log(`======================================================\n`)
}

run()
