/**
 * ragIndexer.ts — Orchestrates PDF text extraction → chunking → Supabase insertion
 * for the Full RAG pipeline. Called after every document upload.
 */

import { extractTextFromPdf, isPdfTextExtractable } from './pdfTextExtractor';
import { chunkText, type TextChunk } from './textChunker';
import { supabase } from '../config/supabase';

export interface RagIndexResult {
  success: boolean;
  chunksCreated: number;
  totalChars: number;
  pageCount: number;
  error?: string;
  skippedReason?: string;
}

/**
 * Index a PDF document for RAG search.
 * Extracts text, chunks it, and inserts into document_chunks table.
 *
 * @param file - The uploaded PDF File object
 * @param documentId - The UUID of the parent document record in `documents` table
 * @param metadata - Department, semester, subject, institution context
 */
export async function indexDocumentForRag(
  file: File,
  documentId: string,
  metadata: {
    institutionId: string;
    department: string;
    semester: string;
    subjectName: string;
  }
): Promise<RagIndexResult> {
  // Only process PDFs
  if (!file.name.toLowerCase().endsWith('.pdf')) {
    return {
      success: false,
      chunksCreated: 0,
      totalChars: 0,
      pageCount: 0,
      skippedReason: 'Not a PDF file — RAG indexing skipped.',
    };
  }

  try {
    // 1. Check if text is extractable (not a scanned image PDF)
    const isExtractable = await isPdfTextExtractable(file);
    if (!isExtractable) {
      return {
        success: false,
        chunksCreated: 0,
        totalChars: 0,
        pageCount: 0,
        skippedReason: 'PDF appears to be scanned images without selectable text. OCR support coming soon.',
      };
    }

    // 2. Extract full text
    const extraction = await extractTextFromPdf(file);
    if (extraction.charCount < 100) {
      return {
        success: false,
        chunksCreated: 0,
        totalChars: extraction.charCount,
        pageCount: extraction.pageCount,
        skippedReason: 'PDF contains too little text to index.',
      };
    }

    // 3. Chunk the text
    const chunks = chunkText(extraction.fullText);
    if (chunks.length === 0) {
      return {
        success: false,
        chunksCreated: 0,
        totalChars: extraction.charCount,
        pageCount: extraction.pageCount,
        skippedReason: 'Text chunking produced no usable chunks.',
      };
    }

    // 4. Delete any existing chunks for this document (re-indexing support)
    await supabase
      .from('document_chunks')
      .delete()
      .eq('document_id', documentId);

    // 5. Batch insert chunks into document_chunks table
    const BATCH_SIZE = 20;
    let totalInserted = 0;

    for (let i = 0; i < chunks.length; i += BATCH_SIZE) {
      const batch = chunks.slice(i, i + BATCH_SIZE).map((chunk: TextChunk) => ({
        document_id: documentId,
        institution_id: metadata.institutionId,
        department: metadata.department,
        semester: metadata.semester,
        subject_name: metadata.subjectName,
        chunk_index: chunk.chunkIndex,
        chunk_content: chunk.content,
        token_count: chunk.tokenCount,
      }));

      const { error: insertError } = await supabase
        .from('document_chunks')
        .insert(batch);

      if (insertError) {
        console.error(`RAG chunk batch insert error (batch ${i / BATCH_SIZE}):`, insertError);
        // Continue with remaining batches
      } else {
        totalInserted += batch.length;
      }
    }

    return {
      success: totalInserted > 0,
      chunksCreated: totalInserted,
      totalChars: extraction.charCount,
      pageCount: extraction.pageCount,
    };
  } catch (err: any) {
    console.error('RAG indexing error:', err);
    return {
      success: false,
      chunksCreated: 0,
      totalChars: 0,
      pageCount: 0,
      error: err.message || 'Unknown RAG indexing error.',
    };
  }
}
