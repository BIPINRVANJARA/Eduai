/**
 * pdfTextExtractor.ts — Extracts full text content from PDF files using pdfjs-dist.
 * Runs entirely client-side in the browser. No server needed.
 */

import * as pdfjsLib from 'pdfjs-dist';

// Configure the worker for Vite builds
pdfjsLib.GlobalWorkerOptions.workerSrc = new URL(
  'pdfjs-dist/build/pdf.worker.mjs',
  import.meta.url
).toString();

export interface PdfExtractionResult {
  fullText: string;
  pageCount: number;
  charCount: number;
  extractedPages: number;
}

/**
 * Extract all text from a PDF file.
 * @param file — The PDF File object from file input
 * @returns Full extracted text with page separators
 */
export async function extractTextFromPdf(file: File): Promise<PdfExtractionResult> {
  const arrayBuffer = await file.arrayBuffer();
  const pdf = await pdfjsLib.getDocument({ data: arrayBuffer }).promise;
  const pageCount = pdf.numPages;

  const pageTexts: string[] = [];
  let extractedPages = 0;

  for (let pageNum = 1; pageNum <= pageCount; pageNum++) {
    try {
      const page = await pdf.getPage(pageNum);
      const textContent = await page.getTextContent();

      // Concatenate all text items from this page
      const pageText = textContent.items
        .filter((item: any) => item.str !== undefined)
        .map((item: any) => {
          // Add newline if the item ends a line (hasEOL flag)
          return item.hasEOL ? item.str + '\n' : item.str;
        })
        .join('');

      if (pageText.trim().length > 0) {
        pageTexts.push(`--- Page ${pageNum} ---\n${pageText.trim()}`);
        extractedPages++;
      }
    } catch (err) {
      console.warn(`Failed to extract text from page ${pageNum}:`, err);
    }
  }

  const fullText = pageTexts.join('\n\n');

  return {
    fullText,
    pageCount,
    charCount: fullText.length,
    extractedPages,
  };
}

/**
 * Quick check if a PDF has extractable text (not just scanned images).
 * Checks first 3 pages and returns true if any text was found.
 */
export async function isPdfTextExtractable(file: File): Promise<boolean> {
  try {
    const arrayBuffer = await file.arrayBuffer();
    const pdf = await pdfjsLib.getDocument({ data: arrayBuffer }).promise;
    const pagesToCheck = Math.min(3, pdf.numPages);

    for (let pageNum = 1; pageNum <= pagesToCheck; pageNum++) {
      const page = await pdf.getPage(pageNum);
      const textContent = await page.getTextContent();
      const text = textContent.items
        .filter((item: any) => item.str !== undefined)
        .map((item: any) => item.str)
        .join('');
      if (text.trim().length > 50) return true;
    }
    return false;
  } catch {
    return false;
  }
}
