import { useState, useRef, useEffect } from 'react'
import { 
  Bot, 
  Send, 
  Paperclip, 
  X, 
  CheckCircle2, 
  AlertTriangle, 
  FileText, 
  Bell, 
  Tag, 
  Trash2, 
  Edit3,
  FileSpreadsheet,
  Plus,
  Files,
  Sparkles,
  CheckCheck
} from 'lucide-react'
import { supabase } from '../config/supabase'
import { useAuth } from '../contexts/AuthContext'
import { parseUniversalAdminCommand } from '../lib/groq'
import type { 
  UniversalAdminResponse, 
  ExtractedDocMetadata, 
  ExtractedAlertMetadata
} from '../lib/groq'

export interface BatchDocumentItem {
  id: string
  fileBlob?: File
  directFileUrl?: string
  fileMetadata: { name: string; size: number }
  docData: ExtractedDocMetadata
  confirmationStatus: 'pending' | 'confirmed' | 'cancelled'
  dbId?: string
}

function parsePastedSyllabusTable(rawText: string): BatchDocumentItem[] | null {
  const lines = rawText.split('\n').map(l => l.trim()).filter(l => l.length > 0)
  const results: BatchDocumentItem[] = []

  // Check if text has multiple URLs or download links
  const linkIndices: number[] = []
  for (let i = 0; i < lines.length; i++) {
    if (lines[i].includes('http://') || lines[i].includes('https://') || lines[i].toLowerCase().includes('[download')) {
      linkIndices.push(i)
    }
  }

  if (linkIndices.length >= 2) {
    let lastIndex = 0
    for (let k = 0; k < linkIndices.length; k++) {
      const linkLineIdx = linkIndices[k]
      const linkLine = lines[linkLineIdx]
      
      let url = ''
      const mdMatch = linkLine.match(/\[.*?\]\((https?:\/\/[^\s\)]+)\)/i)
      if (mdMatch) {
        url = mdMatch[1]
      } else {
        const directUrlMatch = linkLine.match(/(https?:\/\/[^\s\)]+)/i)
        if (directUrlMatch) url = directUrlMatch[1]
      }

      // Include all lines from lastIndex up to AND INCLUDING linkLineIdx
      const chunkLines = lines.slice(lastIndex, linkLineIdx + 1)
        .filter(l => !l.startsWith('#') && !['subject', 'code', 'download', 'sr', 'no', 'sr.'].includes(l.toLowerCase().replace(/[|]+/g, '').trim()))
      
      let subjectCode = ''
      let subjectName = ''

      // Clean link and pipes from all chunk lines
      const combinedText = chunkLines.map(l => 
        l.replace(/\[.*?\]\((https?:\/\/[^\s\)]+)\)/gi, '')
         .replace(/(https?:\/\/[^\s\)]+)/gi, '')
         .replace(/Download PDF/gi, '')
         .replace(/Download/gi, '')
      ).join(' ')

      const parts = combinedText.split('|').map(p => p.trim()).filter(p => p.length > 0 && !p.match(/^[-:]+$/))
      
      for (const part of parts) {
        const codeMatch = part.match(/\b([A-Z]{2,}\d{5,}|\d{7,})\b/i)
        if (codeMatch) {
          subjectCode = codeMatch[1].toUpperCase()
          const remainder = part.replace(codeMatch[0], '').replace(/^#?\s*\d+[\.\s\t]+/, '').trim()
          if (remainder.length > 2 && !subjectName) subjectName = remainder
        } else if (!part.match(/^\d+$/) && !['#', 'subject', 'code', 'download'].includes(part.toLowerCase())) {
          if (!subjectName) {
            subjectName = part.replace(/^#?\s*\d+[\.\s\t]+/, '').trim()
          }
        }
      }

      if (!subjectCode) {
        const codeMatch = combinedText.match(/\b([A-Z]{2,}\d{5,}|\d{7,})\b/i)
        if (codeMatch) subjectCode = codeMatch[1].toUpperCase()
      }
      if (!subjectName) {
        let clean = combinedText
          .replace(/[|]+/g, ' ')
          .replace(/\b([A-Z]{2,}\d{5,}|\d{7,})\b/gi, '')
          .replace(/#?\b\d+\b/g, '')
          .replace(/Download/gi, '')
          .replace(/\s+/g, ' ')
          .trim()
        if (clean.length > 2) subjectName = clean
      }

      if (!subjectName && subjectCode) {
        subjectName = `Course ${subjectCode}`
      }

      if (subjectName || subjectCode || url) {
        const finalTitle = subjectCode ? `${subjectName} (${subjectCode}) Syllabus` : `${subjectName} Syllabus`
        const sLower = (subjectName + ' ' + subjectCode).toLowerCase()
        let detectedSem = '1'
        if (subjectCode.startsWith('DI02') || sLower.includes('sem 2') || sLower.includes('semester 2')) {
          detectedSem = '2'
        } else if (subjectCode.startsWith('DI03') || sLower.includes('sem 3') || sLower.includes('semester 3')) {
          detectedSem = '3'
        } else if (subjectCode.startsWith('DI04') || sLower.includes('sem 4') || sLower.includes('semester 4')) {
          detectedSem = '4'
        } else if (subjectCode.startsWith('DI05') || sLower.includes('sem 5') || sLower.includes('semester 5') || sLower.includes('blockchain') || sLower.includes('product development')) {
          detectedSem = '5'
        } else if (subjectCode.startsWith('DI06') || sLower.includes('sem 6') || sLower.includes('semester 6')) {
          detectedSem = '6'
        } else if (subjectCode.startsWith('DI01') || sLower.includes('sem 1') || sLower.includes('semester 1')) {
          detectedSem = '1'
        }

        const tags = [
          sLower,
          subjectCode.toLowerCase(),
          'syllabus',
          'gtu',
          'gtu syllabus',
          'course curriculum',
          `sem ${detectedSem}`,
          'it_department',
          `gu: ${subjectName} સિલેબસ`,
        ].filter(t => t.length > 0)

        results.push({
          id: `syllabus_multi_${Date.now()}_${k}`,
          directFileUrl: url || 'https://s3-ap-southeast-1.amazonaws.com/gtusitecirculars/Syallbus/' + (subjectCode || 'syllabus') + '.pdf',
          fileMetadata: {
            name: `${subjectCode || 'GTU'}_${subjectName.replace(/\s+/g, '_')}_Syllabus.pdf`,
            size: 1024 * 450
          },
          docData: {
            title: finalTitle,
            category: 'syllabus',
            department: 'Information Technology',
            semester: detectedSem,
            division: 'All',
            subject_name: subjectName || finalTitle,
            tags: tags,
            content_summary: `Official GTU syllabus for ${finalTitle}. Includes course objectives, unit-wise syllabus breakdown, credit distribution, and reference books.`,
            explanation: `Extracted from university syllabus table with direct cloud download link.`
          },
          confirmationStatus: 'pending'
        })
      }

      lastIndex = linkLineIdx + 1
    }
  }

  // METHOD 2: Single-line row parser (Fallback)
  if (results.length === 0) {
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i]
      if (line.startsWith('#') || line.toLowerCase().includes('subjectcode') || line.toLowerCase().includes('download')) {
        if (!line.includes('http') && !line.includes('DI0') && !line.includes('31')) continue
      }

      let url: string | null = null
      const mdLinkMatch = line.match(/\[.*?\]\((https?:\/\/[^\s\)]+)\)/i)
      if (mdLinkMatch) {
        url = mdLinkMatch[1]
      } else {
        const urlMatch = line.match(/(https?:\/\/[^\s\)]+)/i)
        if (urlMatch) url = urlMatch[1]
      }

      let cleanLine = line
        .replace(/\[.*?\]\((https?:\/\/[^\s\)]+)\)/gi, '')
        .replace(/(https?:\/\/[^\s\)]+)/gi, '')
        .replace(/Download PDF/gi, '')
        .replace(/Download/gi, '')
        .replace(/[|]+/g, ' ')
        .trim()

      let subjectCode = ''
      const codeMatch = cleanLine.match(/\b([A-Z]{2,}\d{5,}|\d{7,})\b/i)
      if (codeMatch) {
        subjectCode = codeMatch[1].toUpperCase()
        cleanLine = cleanLine.replace(codeMatch[0], '').trim()
      }

      cleanLine = cleanLine.replace(/^#?\s*\d+[\.\s\t]+/, '').trim()
      const subjectName = cleanLine.replace(/\s{2,}/g, ' ').trim()

      if (subjectName.length >= 2 || subjectCode.length >= 4) {
        const finalTitle = subjectCode 
          ? `${subjectName} (${subjectCode}) Syllabus` 
          : `${subjectName} Syllabus`
        
        const sLower = subjectName.toLowerCase()
        const isSem5 = sLower.includes('python') || sLower.includes('software') || sLower.includes('blockchain') || sLower.includes('intelligence') || sLower.includes('ai')
        const detectedSem = isSem5 ? '5' : '1'

        const tags = [
          sLower,
          subjectCode.toLowerCase(),
          'syllabus',
          'gtu',
          'gtu syllabus',
          'course curriculum',
          `sem ${detectedSem}`,
          'it_department',
          `gu: ${subjectName} સિલેબસ`,
        ].filter(t => t.length > 0)

        results.push({
          id: `syllabus_pasted_${Date.now()}_${i}`,
          directFileUrl: url || 'https://s3-ap-southeast-1.amazonaws.com/gtusitecirculars/Syallbus/' + (subjectCode || 'syllabus') + '.pdf',
          fileMetadata: {
            name: `${subjectCode || 'GTU'}_${subjectName.replace(/\s+/g, '_')}_Syllabus.pdf`,
            size: 1024 * 450
          },
          docData: {
            title: finalTitle,
            category: 'syllabus',
            department: 'Information Technology',
            semester: detectedSem,
            division: 'All',
            subject_name: subjectName || finalTitle,
            tags: tags,
            content_summary: `Official GTU syllabus for ${finalTitle}. Includes course objectives, unit-wise syllabus breakdown, credit distribution, and reference books.`,
            explanation: `Extracted from university syllabus table with direct cloud download link.`
          },
          confirmationStatus: 'pending'
        })
      }
    }
  }

  return results.length > 0 ? results : null
}

interface ChatMessage {
  id: string
  sender: 'admin' | 'ai'
  text: string
  timestamp: string
  attachedFiles?: { name: string; size: number }[]
  fileBlobs?: File[]
  actionResponse?: UniversalAdminResponse
  batchDocuments?: BatchDocumentItem[]
  confirmationStatus?: 'pending' | 'confirmed' | 'cancelled'
  dbResult?: { id: string; type: 'document' | 'alert' | 'scores' }
}

export default function AiCommandCenterPage() {
  const { user, institution } = useAuth()
  const [messages, setMessages] = useState<ChatMessage[]>([
    {
      id: 'welcome',
      sender: 'ai',
      text: `Hello ${institution?.short_name || institution?.name || 'Administrator'}! I am Eduai Intelligent Copilot for this campus.\n\nYou can select and attach multiple documents at once (e.g. all assignments, lab manuals, timetables, or notices). I will analyze all of them simultaneously, extract metadata, infer full subject titles, and generate 14+ multilingual search tags for every document!`,
      timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
    }
  ])
  
  const [inputPrompt, setInputPrompt] = useState('')
  const [selectedFiles, setSelectedFiles] = useState<File[]>([])
  const [isProcessing, setIsProcessing] = useState(false)
  const [processingProgressText, setProcessingProgressText] = useState('')
  const [executingMessageId, setExecutingMessageId] = useState<string | null>(null)
  const [batchExecutingDocId, setBatchExecutingDocId] = useState<string | null>(null)
  
  // Inline editing state for confirmation cards
  const [editingCardId, setEditingCardId] = useState<string | null>(null)
  const [editingBatchDocId, setEditingBatchDocId] = useState<string | null>(null)
  const [editedDoc, setEditedDoc] = useState<ExtractedDocMetadata | null>(null)
  const [editedAlert, setEditedAlert] = useState<ExtractedAlertMetadata | null>(null)
  const [newTagInput, setNewTagInput] = useState('')

  const fileInputRef = useRef<HTMLInputElement>(null)
  const chatEndRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    chatEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [messages, isProcessing])

  // Handle Multi-file selection
  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files.length > 0) {
      const newFiles = Array.from(e.target.files)
      // Deduplicate by name + size
      setSelectedFiles(prev => {
        const existingNames = new Set(prev.map(f => `${f.name}_${f.size}`))
        const filteredNew = newFiles.filter(f => !existingNames.has(`${f.name}_${f.size}`))
        return [...prev, ...filteredNew]
      })
    }
    // Reset file input so user can choose the same file again if needed
    if (fileInputRef.current) fileInputRef.current.value = ''
  }

  const handleRemoveFile = (indexToRemove: number) => {
    setSelectedFiles(prev => prev.filter((_, i) => i !== indexToRemove))
  }

  const handleClearAllFiles = () => {
    setSelectedFiles([])
  }

  // Handle AI analysis & sending message
  const handleSendMessage = async (promptOverride?: string) => {
    const textToSend = promptOverride || inputPrompt.trim()
    if (!textToSend && selectedFiles.length === 0) return

    const currentFiles = [...selectedFiles]
    const filesMetadata = currentFiles.map(f => ({ name: f.name, size: f.size }))

    const userMessage: ChatMessage = {
      id: `admin_${Date.now()}`,
      sender: 'admin',
      text: textToSend || (currentFiles.length > 1 ? `Uploaded ${currentFiles.length} academic documents for AI analysis.` : `Uploaded file: ${currentFiles[0]?.name}`),
      timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
      attachedFiles: filesMetadata,
      fileBlobs: currentFiles
    }

    setMessages(prev => [...prev, userMessage])
    setInputPrompt('')
    setSelectedFiles([])
    setIsProcessing(true)

    try {
      if (currentFiles.length === 0 && textToSend) {
        // Check if user pasted a syllabus table or list of subjects with links
        const parsedSyllabusList = parsePastedSyllabusTable(textToSend)
        if (parsedSyllabusList && parsedSyllabusList.length > 1) {
          const totalTags = parsedSyllabusList.reduce((acc, d) => acc + (d.docData.tags?.length || 0), 0)
          const aiMessage: ChatMessage = {
            id: `ai_batch_${Date.now()}`,
            sender: 'ai',
            text: `✨ Detected and parsed ${parsedSyllabusList.length} Syllabus Subjects with direct university cloud links! Generated ${totalTags} search tags across all subjects. Review and confirm below to store them directly into the campus repository:`,
            timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
            batchDocuments: parsedSyllabusList,
            confirmationStatus: 'pending'
          }
          setMessages(prev => [...prev, aiMessage])
          setIsProcessing(false)
          return
        }
      }

      if (currentFiles.length <= 1) {
        // Single file or text-only command
        const singleFile = currentFiles[0]
        const singleMeta = singleFile ? { name: singleFile.name, size: singleFile.size } : undefined

        let fileSnippetText: string | null = null
        if (singleFile) {
          if (singleFile.type.includes('text') || singleFile.name.endsWith('.txt') || singleFile.name.endsWith('.csv') || singleFile.name.endsWith('.json')) {
            try {
              const raw = await singleFile.text()
              fileSnippetText = raw.length > 2000 ? raw.substring(0, 2000) + '...' : raw
            } catch (_) {}
          }
        }

        setProcessingProgressText('Analyzing document content & generating multi-lingual tags...')
        const response = await parseUniversalAdminCommand(textToSend, singleMeta, fileSnippetText)

        const aiMessage: ChatMessage = {
          id: `ai_${Date.now()}`,
          sender: 'ai',
          text: response.message,
          timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
          actionResponse: response,
          confirmationStatus: response.requiresConfirmation ? 'pending' : undefined,
          fileBlobs: currentFiles
        }

        setMessages(prev => [...prev, aiMessage])
      } else {
        // MULTI-DOCUMENT BATCH ANALYSIS
        setProcessingProgressText(`Analyzing ${currentFiles.length} documents simultaneously with GPT OSS 120B...`)

        const batchResults: BatchDocumentItem[] = []

        for (let i = 0; i < currentFiles.length; i++) {
          const file = currentFiles[i]
          setProcessingProgressText(`Analyzing document (${i + 1}/${currentFiles.length}): "${file.name}"...`)

          let snippet: string | null = null
          if (file.type.includes('text') || file.name.endsWith('.txt') || file.name.endsWith('.csv') || file.name.endsWith('.json')) {
            try {
              const raw = await file.text()
              snippet = raw.length > 2000 ? raw.substring(0, 2000) + '...' : raw
            } catch (_) {}
          }

          const fileSpecificPrompt = textToSend 
            ? `${textToSend}. Specific Document: ${file.name}` 
            : `Analyze this academic file: ${file.name}`

          const res = await parseUniversalAdminCommand(fileSpecificPrompt, { name: file.name, size: file.size }, snippet)

          const docData: ExtractedDocMetadata = res.documentData || {
            title: file.name.replace(/\.[^/.]+$/, '').replace(/[-_]/g, ' '),
            category: file.name.toLowerCase().includes('assignment') ? 'assignment' : file.name.toLowerCase().includes('manual') ? 'lab_manual' : file.name.toLowerCase().includes('timetable') ? 'timetable' : 'notes',
            department: 'Information Technology',
            semester: '5',
            division: 'All',
            subject_name: 'Academic Course',
            tags: [file.name.toLowerCase().replace(/\.[^/.]+$/, ''), 'academic document', 'sem 5', 'information technology'],
            content_summary: `Academic file: ${file.name}`,
            explanation: `Extracted from ${file.name}`
          }

          batchResults.push({
            id: `batch_doc_${Date.now()}_${i}`,
            fileBlob: file,
            fileMetadata: { name: file.name, size: file.size },
            docData,
            confirmationStatus: 'pending'
          })
        }

        const totalTags = batchResults.reduce((acc, d) => acc + (d.docData.tags?.length || 0), 0)

        const aiMessage: ChatMessage = {
          id: `ai_batch_${Date.now()}`,
          sender: 'ai',
          text: `Analyzed all ${currentFiles.length} documents successfully! Generated subject titles, categories, and ${totalTags} multi-lingual search & voice tags across all files. Please review and confirm to sync them to the live campus repository.`,
          timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
          batchDocuments: batchResults,
          confirmationStatus: 'pending',
          fileBlobs: currentFiles
        }

        setMessages(prev => [...prev, aiMessage])
      }
    } catch (err: any) {
      setMessages(prev => [
        ...prev,
        {
          id: `ai_err_${Date.now()}`,
          sender: 'ai',
          text: `⚠️ Error processing documents: ${err.message || 'Something went wrong.'}`,
          timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
        }
      ])
    } finally {
      setIsProcessing(false)
      setProcessingProgressText('')
    }
  }

  // CONFIRM INDIVIDUAL DOCUMENT IN A BATCH
  const handleConfirmSingleBatchDoc = async (msgId: string, docItem: BatchDocumentItem) => {
    setBatchExecutingDocId(docItem.id)
    try {
      const docData = (editingBatchDocId === docItem.id && editedDoc) ? editedDoc : docItem.docData
      let fileUrl = docItem.directFileUrl || 'https://ifframkwyjegmxubscnk.supabase.co/storage/v1/object/public/documents/sample.pdf'
      let fileName = docItem.fileMetadata.name || `${docData.title}.pdf`
      let fileSize = docItem.fileMetadata.size || 1024 * 350

      // Upload file blob to Supabase Storage if file attached
      if (docItem.fileBlob) {
        const cleanName = docItem.fileBlob.name.replace(/[^a-zA-Z0-9._-]/g, '_')
        const path = `admin_${Date.now()}_${cleanName}`
        const { data: uploadData, error: uploadErr } = await supabase.storage
          .from('documents')
          .upload(path, docItem.fileBlob)

        if (!uploadErr && uploadData) {
          const { data: pubData } = supabase.storage.from('documents').getPublicUrl(uploadData.path)
          fileUrl = pubData.publicUrl
          fileName = docItem.fileBlob.name
          fileSize = docItem.fileBlob.size
        }
      }

      // Insert into Supabase documents table
      const currentInstId = institution?.id || '6c6e9b83-cabf-4b13-855b-97d2e1461177'
      const { data: insertRes, error: insertErr } = await supabase
        .from('documents')
        .insert({
          title: docData.title,
          description: docData.content_summary,
          category: docData.category,
          department: docData.department,
          semester: docData.semester,
          division: docData.division,
          subject_name: docData.subject_name || docData.title,
          tags: docData.tags,
          content_summary: docData.content_summary,
          file_url: fileUrl,
          file_name: fileName,
          file_size: fileSize,
          uploaded_by: user?.id || null,
          institution_id: currentInstId
        })
        .select()
        .single()

      if (insertErr) throw insertErr

      // Update message state
      setMessages(prev =>
        prev.map(m => {
          if (m.id === msgId && m.batchDocuments) {
            const updatedBatch = m.batchDocuments.map(b =>
              b.id === docItem.id
                ? { ...b, confirmationStatus: 'confirmed' as const, dbId: insertRes.id }
                : b
            )
            const allConfirmed = updatedBatch.every(b => b.confirmationStatus === 'confirmed')
            return {
              ...m,
              batchDocuments: updatedBatch,
              confirmationStatus: allConfirmed ? 'confirmed' : 'pending'
            }
          }
          return m
        })
      )
      setEditingBatchDocId(null)
    } catch (err: any) {
      alert(`Failed to save "${docItem.fileMetadata.name}": ${err.message}`)
    } finally {
      setBatchExecutingDocId(null)
    }
  }

  // CONFIRM ALL DOCUMENTS IN A BATCH SIMULTANEOUSLY
  const handleConfirmAllBatchDocs = async (msg: ChatMessage) => {
    if (!msg.batchDocuments) return
    setExecutingMessageId(msg.id)

    try {
      const currentInstId = institution?.id || '6c6e9b83-cabf-4b13-855b-97d2e1461177'
      const pendingDocs = msg.batchDocuments.filter(d => d.confirmationStatus !== 'confirmed')

      for (const docItem of pendingDocs) {
        let fileUrl = docItem.directFileUrl || 'https://ifframkwyjegmxubscnk.supabase.co/storage/v1/object/public/documents/sample.pdf'
        let fileName = docItem.fileMetadata.name || `${docItem.docData.title}.pdf`
        let fileSize = docItem.fileMetadata.size || 1024 * 350

        if (docItem.fileBlob) {
          const cleanName = docItem.fileBlob.name.replace(/[^a-zA-Z0-9._-]/g, '_')
          const path = `admin_${Date.now()}_${cleanName}`
          
          const { data: uploadData } = await supabase.storage
            .from('documents')
            .upload(path, docItem.fileBlob)

          if (uploadData) {
            const { data: pubData } = supabase.storage.from('documents').getPublicUrl(uploadData.path)
            fileUrl = pubData.publicUrl
            fileName = docItem.fileBlob.name
            fileSize = docItem.fileBlob.size
          }
        }

        await supabase
          .from('documents')
          .insert({
            title: docItem.docData.title,
            description: docItem.docData.content_summary,
            category: docItem.docData.category,
            department: docItem.docData.department,
            semester: docItem.docData.semester,
            division: docItem.docData.division,
            subject_name: docItem.docData.subject_name || docItem.docData.title,
            tags: docItem.docData.tags,
            content_summary: docItem.docData.content_summary,
            file_url: fileUrl,
            file_name: fileName,
            file_size: fileSize,
            uploaded_by: user?.id || null,
            institution_id: currentInstId
          })
      }

      setMessages(prev =>
        prev.map(m =>
          m.id === msg.id && m.batchDocuments
            ? {
                ...m,
                confirmationStatus: 'confirmed',
                batchDocuments: m.batchDocuments.map(d => ({ ...d, confirmationStatus: 'confirmed' }))
              }
            : m
        )
      )
    } catch (err: any) {
      alert(`Batch Ingestion Error: ${err.message}`)
    } finally {
      setExecutingMessageId(null)
    }
  }

  // CONFIRM & EXECUTE SINGLE ACTION
  const handleConfirmAction = async (msg: ChatMessage) => {
    if (!msg.actionResponse) return
    setExecutingMessageId(msg.id)

    try {
      if (msg.actionResponse.actionType === 'INSERT_DOCUMENT') {
        const docData = (editingCardId === msg.id && editedDoc) ? editedDoc : msg.actionResponse.documentData!
        
        let fileUrl = docData.file_url || ''
        const urlInText = msg.text.match(/(https?:\/\/[^\s\)]+)/i)
        if (!fileUrl && urlInText) {
          fileUrl = urlInText[1]
        }
        if (!fileUrl) {
          fileUrl = 'https://ifframkwyjegmxubscnk.supabase.co/storage/v1/object/public/documents/sample.pdf'
        }

        let fileName = msg.attachedFiles?.[0]?.name || `${docData.title}.pdf`
        let fileSize = msg.attachedFiles?.[0]?.size || 1024 * 150

        // Find file blob if uploaded locally
        const fileToUpload = msg.fileBlobs?.[0]
        if (fileToUpload) {
          const cleanName = fileToUpload.name.replace(/[^a-zA-Z0-9._-]/g, '_')
          const path = `admin_${Date.now()}_${cleanName}`
          const { data: uploadData, error: uploadErr } = await supabase.storage
            .from('documents')
            .upload(path, fileToUpload)

          if (!uploadErr && uploadData) {
            const { data: pubData } = supabase.storage.from('documents').getPublicUrl(uploadData.path)
            fileUrl = pubData.publicUrl
            fileName = fileToUpload.name
            fileSize = fileToUpload.size
          }
        }

        const currentInstId = institution?.id || '6c6e9b83-cabf-4b13-855b-97d2e1461177'
        const { data: insertRes, error: insertErr } = await supabase
          .from('documents')
          .insert({
            title: docData.title,
            description: docData.content_summary,
            category: docData.category,
            department: docData.department,
            semester: docData.semester,
            division: docData.division,
            subject_name: docData.subject_name || docData.title,
            tags: docData.tags,
            content_summary: docData.content_summary,
            file_url: fileUrl,
            file_name: fileName,
            file_size: fileSize,
            uploaded_by: user?.id || null,
            institution_id: currentInstId
          })
          .select()
          .single()

        if (insertErr) throw insertErr

        setMessages(prev =>
          prev.map(m =>
            m.id === msg.id
              ? {
                  ...m,
                  confirmationStatus: 'confirmed',
                  dbResult: { id: insertRes.id, type: 'document' }
                }
              : m
          )
        )
      } else if (msg.actionResponse.actionType === 'BROADCAST_ALERT') {
        const alertData = (editingCardId === msg.id && editedAlert) ? editedAlert : msg.actionResponse.alertData!
        const currentInstId = institution?.id || '6c6e9b83-cabf-4b13-855b-97d2e1461177'

        const { data: insertRes, error: insertErr } = await supabase
          .from('campus_alerts')
          .insert({
            title: alertData.title,
            message: alertData.message,
            category: alertData.category,
            department: alertData.department,
            semester: alertData.semester,
            priority: alertData.priority,
            created_by: user?.id || 'admin',
            institution_id: currentInstId
          })
          .select()
          .single()

        if (insertErr) throw insertErr

        setMessages(prev =>
          prev.map(m =>
            m.id === msg.id
              ? {
                  ...m,
                  confirmationStatus: 'confirmed',
                  dbResult: { id: insertRes.id, type: 'alert' }
                }
              : m
          )
        )
      } else if (msg.actionResponse.actionType === 'UPDATE_ATTENDANCE_MARKS') {
        const scores = msg.actionResponse.scoresData || []
        for (const s of scores) {
          if (!s.enrollment_no) continue

          const updatePayload: any = {}
          if (s.overall_attendance !== undefined) {
            updatePayload.overall_attendance = s.overall_attendance
          }

          if (s.subject && (s.mid_sem_marks !== undefined || s.practical_marks !== undefined)) {
            const { data: existingStudent } = await supabase
              .from('students')
              .select('marks_data')
              .eq('enrollment_no', s.enrollment_no)
              .maybeSingle()

            const currentMarks = (existingStudent?.marks_data as any) || {}
            currentMarks[s.subject] = {
              ...(currentMarks[s.subject] || {}),
              ...(s.mid_sem_marks !== undefined ? { mid_sem: s.mid_sem_marks } : {}),
              ...(s.practical_marks !== undefined ? { practical: s.practical_marks } : {}),
            }
            updatePayload.marks_data = currentMarks
          }

          await supabase
            .from('students')
            .update(updatePayload)
            .eq('enrollment_no', s.enrollment_no)
        }

        setMessages(prev =>
          prev.map(m =>
            m.id === msg.id
              ? {
                  ...m,
                  confirmationStatus: 'confirmed',
                  dbResult: { id: 'bulk_scores', type: 'scores' }
                }
              : m
          )
        )
      }
      setEditingCardId(null)
    } catch (err: any) {
      alert(`Database Action Failed: ${err.message}`)
    } finally {
      setExecutingMessageId(null)
    }
  }

  const handleCancelAction = (msgId: string) => {
    setMessages(prev =>
      prev.map(m =>
        m.id === msgId ? { ...m, confirmationStatus: 'cancelled' } : m
      )
    )
    setEditingCardId(null)
    setEditingBatchDocId(null)
  }

  const startEditCard = (msg: ChatMessage) => {
    if (!msg.actionResponse) return
    setEditingCardId(msg.id)
    if (msg.actionResponse.documentData) {
      setEditedDoc({ ...msg.actionResponse.documentData })
    }
    if (msg.actionResponse.alertData) {
      setEditedAlert({ ...msg.actionResponse.alertData })
    }
  }

  const startEditBatchDoc = (docItem: BatchDocumentItem) => {
    setEditingBatchDocId(docItem.id)
    setEditedDoc({ ...docItem.docData })
  }

  const handleAddTagToEditedDoc = () => {
    if (!newTagInput.trim() || !editedDoc) return
    const tagClean = newTagInput.trim().toLowerCase()
    if (!editedDoc.tags.includes(tagClean)) {
      setEditedDoc({
        ...editedDoc,
        tags: [...editedDoc.tags, tagClean]
      })
    }
    setNewTagInput('')
  }

  const handleRemoveTagFromEditedDoc = (tagToRemove: string) => {
    if (!editedDoc) return
    setEditedDoc({
      ...editedDoc,
      tags: editedDoc.tags.filter(t => t !== tagToRemove)
    })
  }

  const totalSelectedSize = selectedFiles.reduce((acc, f) => acc + f.size, 0)

  return (
    <div className="flex flex-col h-[calc(100vh-2rem)] max-w-5xl mx-auto">
      {/* Top Header */}
      <div className="flex items-center justify-between pb-4 border-b border-card-border">
        <div>
          <h1 className="text-2xl font-extrabold text-text-primary tracking-tight flex items-center gap-2">
            <Bot className="text-primary" size={26} />
            AI Command Center
          </h1>
          <p className="text-xs text-text-secondary mt-0.5">
            Multi-document batch ingestion, attendance & marks sync, and campus alerts
          </p>
        </div>
        <div className="flex items-center gap-2">
          <span className="text-[11px] bg-primary/10 text-primary font-bold px-3 py-1 rounded-full border border-primary/30 flex items-center gap-1.5">
            <Sparkles size={13} /> Multi-Document RAG Ingestion
          </span>
        </div>
      </div>

      {/* Messages List Area */}
      <div className="flex-1 overflow-y-auto py-6 space-y-6 pr-2">
        {messages.map((msg) => {
          const isAdmin = msg.sender === 'admin'

          return (
            <div
              key={msg.id}
              className={`flex flex-col ${isAdmin ? 'items-end' : 'items-start'} space-y-2`}
            >
              {/* Message Bubble */}
              <div
                className={`max-w-2xl rounded-2xl px-5 py-3.5 text-sm leading-relaxed shadow-sm ${
                  isAdmin
                    ? 'bg-primary text-background font-medium rounded-tr-none'
                    : 'bg-surface border border-card-border text-text-primary rounded-tl-none'
                }`}
              >
                {/* Attached files chips in user message */}
                {msg.attachedFiles && msg.attachedFiles.length > 0 && (
                  <div className="mb-2.5 space-y-1.5">
                    <div className="flex items-center gap-1.5 text-xs font-bold opacity-90">
                      <Files size={14} />
                      <span>{msg.attachedFiles.length} Document{msg.attachedFiles.length > 1 ? 's' : ''} Attached:</span>
                    </div>
                    <div className="flex flex-wrap gap-1.5">
                      {msg.attachedFiles.map((file, i) => (
                        <div key={i} className="flex items-center gap-1.5 px-2.5 py-1 bg-background/25 rounded-lg text-xs font-semibold">
                          <FileText size={12} />
                          <span className="truncate max-w-[180px]">{file.name}</span>
                          <span className="opacity-75 text-[10px]">
                            ({(file.size / 1024).toFixed(1)} KB)
                          </span>
                        </div>
                      ))}
                    </div>
                  </div>
                )}

                <div className="whitespace-pre-wrap">{msg.text}</div>

                <div
                  className={`text-[10px] mt-1.5 ${
                    isAdmin ? 'text-background/70 text-right' : 'text-text-muted text-left'
                  }`}
                >
                  {msg.timestamp}
                </div>
              </div>

              {/* ========================================================= */}
              {/* MULTI-DOCUMENT BATCH CONFIRMATION CARDS                   */}
              {/* ========================================================= */}
              {msg.batchDocuments && msg.batchDocuments.length > 0 && (
                <div className="w-full max-w-3xl bg-surface/95 backdrop-blur-md border border-card-border rounded-2xl p-5 shadow-2xl space-y-5">
                  {/* Batch Header & Actions */}
                  <div className="flex flex-wrap items-center justify-between gap-3 pb-3 border-b border-card-border">
                    <div className="flex items-center gap-2.5">
                      <div className="w-8 h-8 rounded-xl bg-primary/10 border border-primary/30 flex items-center justify-center text-primary">
                        <Files size={18} />
                      </div>
                      <div>
                        <h4 className="text-sm font-extrabold text-white">
                          Analyzed {msg.batchDocuments.length} Documents
                        </h4>
                        <p className="text-[11px] text-text-secondary">
                          {msg.batchDocuments.filter(d => d.confirmationStatus === 'confirmed').length} of {msg.batchDocuments.length} Synced to Campus Database
                        </p>
                      </div>
                    </div>

                    {msg.confirmationStatus === 'pending' && (
                      <div className="flex items-center gap-2">
                        <button
                          onClick={() => handleConfirmAllBatchDocs(msg)}
                          disabled={executingMessageId === msg.id}
                          className="bg-primary text-background font-black text-xs px-4 py-2 rounded-xl hover:bg-[#c4f85e] transition-all shadow-md flex items-center gap-1.5 cursor-pointer disabled:opacity-50"
                        >
                          {executingMessageId === msg.id ? (
                            <div className="w-4 h-4 border-2 border-background border-t-transparent rounded-full animate-spin" />
                          ) : (
                            <>
                              <CheckCheck size={16} />
                              Confirm & Ingest All ({msg.batchDocuments.length})
                            </>
                          )}
                        </button>
                        <button
                          onClick={() => handleCancelAction(msg.id)}
                          className="text-xs text-text-muted hover:text-error px-3 py-2 rounded-xl border border-card-border transition-colors"
                        >
                          Discard All
                        </button>
                      </div>
                    )}
                  </div>

                  {/* List of Analyzed Document Cards */}
                  <div className="space-y-4">
                    {msg.batchDocuments.map((docItem, idx) => {
                      const isConfirmed = docItem.confirmationStatus === 'confirmed'
                      const isEditingThis = editingBatchDocId === docItem.id
                      const currentDoc = (isEditingThis && editedDoc) ? editedDoc : docItem.docData

                      return (
                        <div
                          key={docItem.id}
                          className={`p-4 rounded-xl border transition-all ${
                            isConfirmed
                              ? 'bg-[#0B0F17]/80 border-primary/30'
                              : 'bg-surface-light/60 border-card-border hover:border-white/20'
                          }`}
                        >
                          {isEditingThis && editedDoc ? (
                            <div className="space-y-3 p-3 bg-surface rounded-xl border border-card-border text-xs">
                              <div>
                                <label className="text-text-muted block mb-1">Title</label>
                                <input
                                  type="text"
                                  value={editedDoc.title}
                                  onChange={e => setEditedDoc({ ...editedDoc, title: e.target.value })}
                                  className="w-full bg-surface-light border border-card-border rounded-lg p-2 text-text-primary"
                                />
                              </div>
                              <div className="grid grid-cols-3 gap-2">
                                <div>
                                  <label className="text-text-muted block mb-1">Category</label>
                                  <select
                                    value={editedDoc.category}
                                    onChange={e => setEditedDoc({ ...editedDoc, category: e.target.value as any })}
                                    className="w-full bg-surface-light border border-card-border rounded-lg p-2 text-text-primary"
                                  >
                                    <option value="assignment">Assignment</option>
                                    <option value="timetable">Timetable</option>
                                    <option value="lab_manual">Lab Manual</option>
                                    <option value="syllabus">Syllabus</option>
                                    <option value="notes">Lecture Notes</option>
                                    <option value="pyq">PYQ Exam Paper</option>
                                    <option value="circular">Circular</option>
                                  </select>
                                </div>
                                <div>
                                  <label className="text-text-muted block mb-1">Department</label>
                                  <input
                                    type="text"
                                    value={editedDoc.department}
                                    onChange={e => setEditedDoc({ ...editedDoc, department: e.target.value })}
                                    className="w-full bg-surface-light border border-card-border rounded-lg p-2 text-text-primary"
                                  />
                                </div>
                                <div>
                                  <label className="text-text-muted block mb-1">Semester</label>
                                  <input
                                    type="text"
                                    value={editedDoc.semester}
                                    onChange={e => setEditedDoc({ ...editedDoc, semester: e.target.value })}
                                    className="w-full bg-surface-light border border-card-border rounded-lg p-2 text-text-primary"
                                  />
                                </div>
                              </div>
                              <div className="flex justify-end gap-2 pt-2">
                                <button
                                  type="button"
                                  onClick={() => setEditingBatchDocId(null)}
                                  className="px-3 py-1 bg-surface-light border border-card-border rounded-lg text-text-secondary text-xs"
                                >
                                  Done Editing
                                </button>
                              </div>
                            </div>
                          ) : (
                            <div className="flex items-start justify-between gap-3">
                              <div className="space-y-1 flex-1">
                                <div className="flex items-center gap-2">
                                  <span className="text-[10px] font-bold text-text-secondary bg-surface px-2 py-0.5 rounded border border-white/5 font-mono">
                                    #{idx + 1}
                                  </span>
                                  <h5 className="text-sm font-bold text-white flex items-center gap-2">
                                    <FileText size={15} className="text-primary" />
                                    {currentDoc.title}
                                  </h5>
                                  {isConfirmed ? (
                                    <span className="text-[10px] font-bold text-primary bg-primary/15 px-2 py-0.5 rounded flex items-center gap-1">
                                      <CheckCircle2 size={12} /> Synced
                                    </span>
                                  ) : (
                                    <span className="text-[10px] font-bold text-warning bg-warning/15 px-2 py-0.5 rounded">
                                      Pending Review
                                    </span>
                                  )}
                                </div>

                                <div className="flex flex-wrap items-center gap-2 text-xs text-text-secondary pt-1">
                                  <span className="text-primary font-semibold capitalize bg-primary/10 px-2 py-0.5 rounded text-[11px]">
                                    {currentDoc.category.replace('_', ' ')}
                                  </span>
                                  <span>·</span>
                                  <span>{currentDoc.subject_name}</span>
                                  <span>·</span>
                                  <span className="text-cyan font-mono">Sem {currentDoc.semester} (Div {currentDoc.division})</span>
                                  <span>·</span>
                                  <span className="text-text-muted text-[11px] font-mono">
                                    {docItem.fileMetadata.name} ({(docItem.fileMetadata.size / 1024).toFixed(1)} KB)
                                  </span>
                                </div>

                                {/* Multi-lingual Search Tags Preview */}
                                <div className="pt-2">
                                  <div className="flex flex-wrap gap-1">
                                    {currentDoc.tags.slice(0, 10).map((t, ti) => (
                                      <span
                                        key={ti}
                                        className="text-[10px] bg-surface text-primary/90 px-2 py-0.5 rounded border border-white/5 font-mono"
                                      >
                                        #{t}
                                      </span>
                                    ))}
                                    {currentDoc.tags.length > 10 && (
                                      <span className="text-[10px] text-text-muted px-1 py-0.5">
                                        +{currentDoc.tags.length - 10} more tags
                                      </span>
                                    )}
                                  </div>
                                </div>
                              </div>

                              {/* Action Buttons for Single Document */}
                              {!isConfirmed && (
                                <div className="flex flex-col items-end gap-1.5 shrink-0">
                                  <button
                                    onClick={() => handleConfirmSingleBatchDoc(msg.id, docItem)}
                                    disabled={batchExecutingDocId === docItem.id}
                                    className="px-3.5 py-1.5 rounded-lg bg-primary text-background font-bold text-xs hover:bg-[#c4f85e] transition-all shadow cursor-pointer flex items-center gap-1"
                                  >
                                    {batchExecutingDocId === docItem.id ? (
                                      <div className="w-3.5 h-3.5 border-2 border-background border-t-transparent rounded-full animate-spin" />
                                    ) : (
                                      <>
                                        <CheckCircle2 size={13} />
                                        Confirm & Sync
                                      </>
                                    )}
                                  </button>
                                  <button
                                    onClick={() => startEditBatchDoc(docItem)}
                                    className="text-[11px] text-text-muted hover:text-primary transition-colors flex items-center gap-1 cursor-pointer"
                                  >
                                    <Edit3 size={11} /> Edit
                                  </button>
                                </div>
                              )}
                            </div>
                          )}
                        </div>
                      )
                    })}
                  </div>
                </div>
              )}

              {/* ========================================================= */}
              {/* SINGLE ACTION CONFIRMATION CARD (Document / Alert / Marks) */}
              {/* ========================================================= */}
              {msg.actionResponse?.requiresConfirmation && (
                <div className="w-full max-w-2xl bg-surface/95 backdrop-blur-md border border-card-border rounded-2xl p-5 shadow-2xl space-y-4">
                  {/* Card Status Header */}
                  <div className="flex items-center justify-between pb-3 border-b border-card-border">
                    <div className="flex items-center gap-2">
                      {msg.confirmationStatus === 'confirmed' ? (
                        <span className="flex items-center gap-1.5 text-xs font-bold text-primary bg-primary/15 px-2.5 py-1 rounded-full border border-primary/30">
                          <CheckCircle2 size={14} /> Synced to Database
                        </span>
                      ) : msg.confirmationStatus === 'cancelled' ? (
                        <span className="flex items-center gap-1.5 text-xs font-bold text-error bg-error/15 px-2.5 py-1 rounded-full border border-error/30">
                          <X size={14} /> Discarded
                        </span>
                      ) : (
                        <span className="flex items-center gap-1.5 text-xs font-bold text-warning bg-warning/15 px-2.5 py-1 rounded-full border border-warning/30 animate-pulse">
                          <AlertTriangle size={14} /> Confirmation Required
                        </span>
                      )}

                      <span className="text-xs font-semibold text-text-secondary">
                        {msg.actionResponse.actionType === 'INSERT_DOCUMENT' 
                          ? 'Academic Document & Tags' 
                          : msg.actionResponse.actionType === 'UPDATE_ATTENDANCE_MARKS'
                            ? 'Attendance & Marks Sync'
                            : 'Campus Broadcast Alert'}
                      </span>
                    </div>

                    {msg.confirmationStatus === 'pending' && (
                      <button
                        onClick={() => editingCardId === msg.id ? setEditingCardId(null) : startEditCard(msg)}
                        className="text-xs text-text-muted hover:text-primary flex items-center gap-1 transition-colors"
                      >
                        <Edit3 size={13} />
                        {editingCardId === msg.id ? 'Done Editing' : 'Edit Tags & Info'}
                      </button>
                    )}
                  </div>

                  {/* 1. DOCUMENT PREVIEW CONTENT */}
                  {msg.actionResponse.actionType === 'INSERT_DOCUMENT' && msg.actionResponse.documentData && (
                    <div className="space-y-3">
                      {editingCardId === msg.id && editedDoc ? (
                        <div className="space-y-3 p-3 bg-surface-light rounded-xl border border-card-border text-xs">
                          <div>
                            <label className="text-text-muted block mb-1">Title</label>
                            <input
                              type="text"
                              value={editedDoc.title}
                              onChange={e => setEditedDoc({ ...editedDoc, title: e.target.value })}
                              className="w-full bg-surface border border-card-border rounded-lg p-2 text-text-primary"
                            />
                          </div>
                          <div className="grid grid-cols-3 gap-2">
                            <div>
                              <label className="text-text-muted block mb-1">Category</label>
                              <select
                                value={editedDoc.category}
                                onChange={e => setEditedDoc({ ...editedDoc, category: e.target.value as any })}
                                className="w-full bg-surface border border-card-border rounded-lg p-2 text-text-primary"
                              >
                                <option value="assignment">Assignment</option>
                                <option value="timetable">Timetable</option>
                                <option value="lab_manual">Lab Manual</option>
                                <option value="syllabus">Syllabus</option>
                                <option value="notes">Lecture Notes</option>
                                <option value="pyq">PYQ Exam Paper</option>
                                <option value="circular">Circular</option>
                              </select>
                            </div>
                            <div>
                              <label className="text-text-muted block mb-1">Department</label>
                              <input
                                type="text"
                                value={editedDoc.department}
                                onChange={e => setEditedDoc({ ...editedDoc, department: e.target.value })}
                                className="w-full bg-surface border border-card-border rounded-lg p-2 text-text-primary"
                              />
                            </div>
                            <div>
                              <label className="text-text-muted block mb-1">Semester</label>
                              <input
                                type="text"
                                value={editedDoc.semester}
                                onChange={e => setEditedDoc({ ...editedDoc, semester: e.target.value })}
                                className="w-full bg-surface border border-card-border rounded-lg p-2 text-text-primary"
                              />
                            </div>
                          </div>

                          {/* Editable Tags Section */}
                          <div>
                            <label className="text-text-muted block mb-1">Search & Voice Match Tags</label>
                            <div className="flex flex-wrap gap-1.5 mb-2">
                              {editedDoc.tags.map((tag, i) => (
                                <span
                                  key={i}
                                  className="text-[11px] bg-primary/10 text-primary px-2 py-0.5 rounded-md border border-primary/30 flex items-center gap-1"
                                >
                                  {tag}
                                  <button
                                    type="button"
                                    onClick={() => handleRemoveTagFromEditedDoc(tag)}
                                    className="hover:text-error"
                                  >
                                    ×
                                  </button>
                                </span>
                              ))}
                            </div>
                            <div className="flex gap-2">
                              <input
                                type="text"
                                placeholder="Add custom tag (e.g. practical 1, unit 2)..."
                                value={newTagInput}
                                onChange={e => setNewTagInput(e.target.value)}
                                onKeyDown={e => {
                                  if (e.key === 'Enter') {
                                    e.preventDefault()
                                    handleAddTagToEditedDoc()
                                  }
                                }}
                                className="flex-1 bg-surface border border-card-border rounded-lg p-1.5 text-xs text-text-primary"
                              />
                              <button
                                type="button"
                                onClick={handleAddTagToEditedDoc}
                                className="bg-primary/20 text-primary border border-primary/30 px-3 py-1 rounded-lg text-xs font-bold flex items-center gap-1"
                              >
                                <Plus size={13} /> Add
                              </button>
                            </div>
                          </div>
                        </div>
                      ) : (
                        <div>
                          <h4 className="text-base font-bold text-text-primary flex items-center gap-2">
                            <FileText size={18} className="text-primary" />
                            {msg.actionResponse.documentData.title}
                          </h4>
                          <div className="grid grid-cols-3 gap-2 mt-3 text-xs">
                            <div className="bg-surface-light p-2.5 rounded-lg border border-card-border">
                              <span className="text-text-muted block">Category</span>
                              <span className="font-semibold text-primary capitalize">
                                {msg.actionResponse.documentData.category.replace('_', ' ')}
                              </span>
                            </div>
                            <div className="bg-surface-light p-2.5 rounded-lg border border-card-border">
                              <span className="text-text-muted block">Department</span>
                              <span className="font-semibold text-text-primary">
                                {msg.actionResponse.documentData.department}
                              </span>
                            </div>
                            <div className="bg-surface-light p-2.5 rounded-lg border border-card-border">
                              <span className="text-text-muted block">Semester / Class</span>
                              <span className="font-semibold text-cyan-accent">
                                Sem {msg.actionResponse.documentData.semester} (Div {msg.actionResponse.documentData.division})
                              </span>
                            </div>
                          </div>

                          {/* Multi-lingual Search Tags Preview */}
                          <div className="mt-3">
                            <span className="text-xs text-text-muted flex items-center gap-1 mb-1.5 font-bold">
                              <Tag size={12} className="text-primary" /> Auto-Generated Search & Voice Tags ({msg.actionResponse.documentData.tags.length}):
                            </span>
                            <div className="flex flex-wrap gap-1.5">
                              {msg.actionResponse.documentData.tags.map((tag, i) => (
                                <span
                                  key={i}
                                  className="text-[11px] bg-primary/10 text-primary px-2.5 py-0.5 rounded-md border border-primary/20 font-mono font-medium"
                                >
                                  #{tag}
                                </span>
                              ))}
                            </div>
                          </div>

                          {/* Content Summary */}
                          {msg.actionResponse.documentData.content_summary && (
                            <div className="mt-3 p-2.5 bg-surface-light/50 rounded-lg border border-card-border text-xs text-text-secondary">
                              <span className="font-bold text-text-primary block mb-0.5">Content Summary:</span>
                              {msg.actionResponse.documentData.content_summary}
                            </div>
                          )}
                        </div>
                      )}
                    </div>
                  )}

                  {/* 2. ATTENDANCE & MARKS PREVIEW TABLE */}
                  {msg.actionResponse.actionType === 'UPDATE_ATTENDANCE_MARKS' && msg.actionResponse.scoresData && (
                    <div className="space-y-3">
                      <div className="flex items-center gap-2">
                        <FileSpreadsheet size={18} className="text-cyan-accent" />
                        <h4 className="text-sm font-bold text-text-primary">
                          Parsed Student Scores ({msg.actionResponse.scoresData.length} Students)
                        </h4>
                      </div>

                      <div className="overflow-x-auto max-h-48 border border-card-border rounded-xl">
                        <table className="w-full text-left text-xs">
                          <thead className="bg-surface-light text-text-muted uppercase font-bold sticky top-0">
                            <tr>
                              <th className="p-2">Enrollment</th>
                              <th className="p-2">Name</th>
                              <th className="p-2">Attendance %</th>
                              <th className="p-2">Subject</th>
                              <th className="p-2">Mid-Sem</th>
                              <th className="p-2">Practical</th>
                            </tr>
                          </thead>
                          <tbody className="divide-y divide-card-border text-text-primary">
                            {msg.actionResponse.scoresData.map((s, idx) => (
                              <tr key={idx} className="hover:bg-surface-light/40">
                                <td className="p-2 font-mono text-cyan-accent font-bold">{s.enrollment_no}</td>
                                <td className="p-2">{s.student_name || '—'}</td>
                                <td className="p-2 font-bold">{s.overall_attendance ? `${s.overall_attendance}%` : '—'}</td>
                                <td className="p-2 text-text-secondary">{s.subject || 'General'}</td>
                                <td className="p-2 font-mono">{s.mid_sem_marks ? `${s.mid_sem_marks}/30` : '—'}</td>
                                <td className="p-2 font-mono">{s.practical_marks ? `${s.practical_marks}/30` : '—'}</td>
                              </tr>
                            ))}
                          </tbody>
                        </table>
                      </div>
                    </div>
                  )}

                  {/* 3. ALERT PREVIEW CONTENT */}
                  {msg.actionResponse.actionType === 'BROADCAST_ALERT' && msg.actionResponse.alertData && (
                    <div className="space-y-3">
                      {editingCardId === msg.id && editedAlert ? (
                        <div className="space-y-3 p-3 bg-surface-light rounded-xl border border-card-border text-xs">
                          <div>
                            <label className="text-text-muted block mb-1">Alert Title</label>
                            <input
                              type="text"
                              value={editedAlert.title}
                              onChange={e => setEditedAlert({ ...editedAlert, title: e.target.value })}
                              className="w-full bg-surface border border-card-border rounded-lg p-2 text-text-primary"
                            />
                          </div>
                          <div>
                            <label className="text-text-muted block mb-1">Message Body</label>
                            <textarea
                              rows={3}
                              value={editedAlert.message}
                              onChange={e => setEditedAlert({ ...editedAlert, message: e.target.value })}
                              className="w-full bg-surface border border-card-border rounded-lg p-2 text-text-primary"
                            />
                          </div>
                        </div>
                      ) : (
                        <div>
                          <h4 className="text-base font-bold text-text-primary flex items-center gap-2">
                            <Bell size={18} className="text-warning" />
                            {msg.actionResponse.alertData.title}
                          </h4>
                          <p className="text-xs text-text-secondary mt-2 bg-surface-light p-3 rounded-lg border border-card-border">
                            {msg.actionResponse.alertData.message}
                          </p>
                          <div className="flex items-center gap-2 mt-3 text-xs">
                            <span className="bg-surface-light px-2.5 py-1 rounded-md border border-card-border text-text-muted">
                              Target: <strong className="text-text-primary">{msg.actionResponse.alertData.department} (Sem {msg.actionResponse.alertData.semester})</strong>
                            </span>
                            <span className="bg-surface-light px-2.5 py-1 rounded-md border border-card-border text-text-muted">
                              Priority: <strong className="text-warning uppercase">{msg.actionResponse.alertData.priority}</strong>
                            </span>
                          </div>
                        </div>
                      )}
                    </div>
                  )}

                  {/* ACTION CONFIRMATION BUTTONS */}
                  {msg.confirmationStatus === 'pending' && (
                    <div className="flex items-center gap-3 pt-3 border-t border-card-border">
                      <button
                        onClick={() => handleConfirmAction(msg)}
                        disabled={executingMessageId === msg.id}
                        className="flex-1 bg-primary text-background font-bold py-2.5 px-4 rounded-xl hover:opacity-90 transition-all flex items-center justify-center gap-2 text-xs shadow-lg shadow-primary/20 cursor-pointer"
                      >
                        {executingMessageId === msg.id ? (
                          <div className="w-4 h-4 border-2 border-background border-t-transparent rounded-full animate-spin" />
                        ) : (
                          <>
                            <CheckCircle2 size={16} />
                            Confirm & Ingest to Database
                          </>
                        )}
                      </button>

                      <button
                        onClick={() => handleCancelAction(msg.id)}
                        className="px-4 py-2.5 rounded-xl border border-card-border text-text-muted hover:text-error hover:border-error/40 transition-colors text-xs font-semibold flex items-center gap-1.5"
                      >
                        <Trash2 size={14} /> Discard
                      </button>
                    </div>
                  )}
                </div>
              )}
            </div>
          )
        })}

        {isProcessing && (
          <div className="flex items-center gap-3 text-xs text-text-muted bg-surface/60 border border-card-border p-3.5 rounded-2xl w-fit animate-pulse">
            <Bot size={16} className="text-primary animate-spin" />
            {processingProgressText || 'Analyzing document content & generating multi-lingual tags with GPT OSS 120B...'}
          </div>
        )}

        <div ref={chatEndRef} />
      </div>

      {/* ========================================================= */}
      {/* ATTACHED MULTI-FILE TRAY BEFORE SENDING                   */}
      {/* ========================================================= */}
      {selectedFiles.length > 0 && (
        <div className="mb-2 p-3 bg-surface border border-primary/40 rounded-2xl shadow-xl space-y-2 animate-fade-in">
          <div className="flex items-center justify-between text-xs">
            <div className="flex items-center gap-2 text-text-primary font-bold">
              <Files size={15} className="text-primary" />
              <span>{selectedFiles.length} Document{selectedFiles.length > 1 ? 's' : ''} Ready for AI Analysis</span>
              <span className="text-text-muted font-normal">({(totalSelectedSize / 1024).toFixed(1)} KB Total)</span>
            </div>
            <div className="flex items-center gap-3">
              <button
                type="button"
                onClick={() => fileInputRef.current?.click()}
                className="text-[11px] text-primary hover:underline font-bold flex items-center gap-1"
              >
                <Plus size={13} /> Add More Files
              </button>
              <button
                type="button"
                onClick={handleClearAllFiles}
                className="text-[11px] text-text-muted hover:text-error transition-colors"
              >
                Clear All
              </button>
            </div>
          </div>

          <div className="flex flex-wrap gap-2 max-h-28 overflow-y-auto pr-1">
            {selectedFiles.map((file, idx) => (
              <div
                key={idx}
                className="flex items-center gap-2 px-3 py-1.5 bg-surface-light border border-card-border rounded-xl text-xs text-text-primary shadow-sm hover:border-primary/40 transition-colors"
              >
                <FileText size={14} className="text-primary shrink-0" />
                <span className="truncate max-w-[200px] font-medium">{file.name}</span>
                <span className="text-[10px] text-text-muted shrink-0">
                  ({(file.size / 1024).toFixed(1)} KB)
                </span>
                <button
                  type="button"
                  onClick={() => handleRemoveFile(idx)}
                  className="text-text-muted hover:text-error transition-colors p-0.5 ml-1"
                >
                  <X size={13} />
                </button>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* ========================================================= */}
      {/* BOTTOM INPUT BAR                                          */}
      {/* ========================================================= */}
      <div className="pt-3 border-t border-card-border">
        <form
          onSubmit={(e) => {
            e.preventDefault()
            handleSendMessage()
          }}
          className="flex items-center gap-2 bg-surface p-2 rounded-2xl border border-card-border focus-within:border-primary/60 transition-all shadow-lg"
        >
          {/* Multiple File Input */}
          <input
            type="file"
            ref={fileInputRef}
            onChange={handleFileSelect}
            className="hidden"
            multiple
            accept=".pdf,.png,.jpg,.jpeg,.csv,.xlsx,.xls,.docx,.txt"
          />

          <button
            type="button"
            onClick={() => fileInputRef.current?.click()}
            className={`p-2.5 rounded-xl border transition-all cursor-pointer ${
              selectedFiles.length > 0
                ? 'bg-primary text-background border-primary shadow-md'
                : 'bg-surface-light border-card-border text-text-secondary hover:text-primary hover:border-primary/40'
            }`}
            title="Attach Multiple Documents (PDF, DOCX, CSV, XLSX)"
          >
            <Paperclip size={18} />
          </button>

          <input
            type="text"
            value={inputPrompt}
            onChange={(e) => setInputPrompt(e.target.value)}
            placeholder={
              selectedFiles.length > 0
                ? `Analyze all ${selectedFiles.length} attached documents (or add optional notes like "Sem 5 IT")...`
                : 'e.g. "these are sem 5 IT assignments" or "Holiday notice for tomorrow"...'
            }
            className="flex-1 bg-transparent border-none px-3 text-sm text-text-primary placeholder:text-text-muted focus:outline-none"
            disabled={isProcessing}
          />

          <button
            type="submit"
            disabled={isProcessing || (!inputPrompt.trim() && selectedFiles.length === 0)}
            className="bg-primary text-background p-2.5 rounded-xl font-bold hover:opacity-90 transition-all disabled:opacity-40 disabled:cursor-not-allowed flex items-center justify-center cursor-pointer shadow-md"
          >
            <Send size={18} />
          </button>
        </form>
      </div>
    </div>
  )
}
