/**
 * textChunker.ts — Splits extracted text into overlapping chunks for RAG indexing.
 *
 * Strategy:
 * - Target chunk size: ~500 tokens (~2000 chars)
 * - Overlap: ~100 tokens (~400 chars)
 * - Splits on paragraph boundaries first, then sentence boundaries, then word boundaries
 * - Preserves context across chunk boundaries via overlap
 */

export interface TextChunk {
  chunkIndex: number;
  content: string;
  tokenCount: number;
}

const TARGET_CHUNK_CHARS = 2000;   // ~500 tokens
const OVERLAP_CHARS = 400;         // ~100 tokens overlap
const MIN_CHUNK_CHARS = 200;       // Discard tiny trailing chunks

/**
 * Estimate token count from character count (rough: 1 token ≈ 4 chars for English)
 */
function estimateTokens(text: string): number {
  return Math.ceil(text.length / 4);
}

/**
 * Split text into chunks with overlap, respecting paragraph/sentence boundaries.
 */
export function chunkText(fullText: string): TextChunk[] {
  if (!fullText || fullText.trim().length < MIN_CHUNK_CHARS) {
    if (fullText && fullText.trim().length > 0) {
      return [{ chunkIndex: 0, content: fullText.trim(), tokenCount: estimateTokens(fullText.trim()) }];
    }
    return [];
  }

  // Normalize whitespace but preserve paragraph breaks
  const normalized = fullText
    .replace(/\r\n/g, '\n')
    .replace(/[ \t]+/g, ' ')
    .replace(/\n{3,}/g, '\n\n')
    .trim();

  const chunks: TextChunk[] = [];
  let startPos = 0;
  let chunkIndex = 0;

  while (startPos < normalized.length) {
    let endPos = startPos + TARGET_CHUNK_CHARS;

    if (endPos >= normalized.length) {
      // Last chunk — take everything remaining
      const remaining = normalized.slice(startPos).trim();
      if (remaining.length >= MIN_CHUNK_CHARS || chunks.length === 0) {
        chunks.push({
          chunkIndex,
          content: remaining,
          tokenCount: estimateTokens(remaining),
        });
      } else if (chunks.length > 0) {
        // Merge tiny tail into previous chunk
        const prev = chunks[chunks.length - 1];
        prev.content += '\n' + remaining;
        prev.tokenCount = estimateTokens(prev.content);
      }
      break;
    }

    // Try to break at paragraph boundary (\n\n)
    let breakPos = normalized.lastIndexOf('\n\n', endPos);
    if (breakPos <= startPos) {
      // Try sentence boundary (. or ? or ! followed by space/newline)
      const sentenceRegex = /[.!?]\s/g;
      let lastSentenceEnd = -1;
      sentenceRegex.lastIndex = startPos;
      let match;
      while ((match = sentenceRegex.exec(normalized)) !== null) {
        if (match.index > endPos) break;
        if (match.index > startPos + MIN_CHUNK_CHARS) {
          lastSentenceEnd = match.index + 1; // Include the punctuation
        }
      }
      breakPos = lastSentenceEnd > startPos ? lastSentenceEnd : -1;
    } else {
      breakPos += 1; // Move past the first \n of \n\n
    }

    if (breakPos <= startPos) {
      // Try word boundary
      const spacePos = normalized.lastIndexOf(' ', endPos);
      breakPos = spacePos > startPos + MIN_CHUNK_CHARS ? spacePos : endPos;
    }

    const chunkContent = normalized.slice(startPos, breakPos).trim();
    if (chunkContent.length > 0) {
      chunks.push({
        chunkIndex,
        content: chunkContent,
        tokenCount: estimateTokens(chunkContent),
      });
      chunkIndex++;
    }

    // Move start position back by overlap amount for context continuity
    startPos = Math.max(startPos + 1, breakPos - OVERLAP_CHARS);
  }

  return chunks;
}
