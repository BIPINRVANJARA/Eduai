import React from 'react'
import ReactMarkdown from 'react-markdown'
import remarkGfm from 'remark-gfm'

export function normalizeMarkdownText(raw: string): string {
  if (!raw) return ''
  let text = raw

  // 1. Double pipes '||' indicate table row breaks from flattened pastes!
  // Replace '||' with '\n| '
  text = text.replace(/\|\|\s*/g, '|\n| ')

  // 2. Separate title and bold subtitle from table start
  // e.g. "## Title ... **Exam Time: ...** | Date |"
  text = text.replace(/(#{1,6}\s+[^\n*|]+)\s+(\*\*[^*]+\*\*)/g, '$1\n\n$2')

  // 3. Separate non-table text preceding a table header on the same line:
  // e.g. "**Exam Time: 11:30 AM – 12:30 PM** | Date |"
  text = text.replace(/^([^|\n]+?)\s*(\|(?:\s*[^|\n]+\s*\|)+)/gm, '$1\n\n$2')

  // 4. Ensure table rows that end without a pipe get one
  text = text.replace(/^(\|[^\n]+[^|\s])\s*$/gm, '$1 |')

  // 5. Ensure divider row starts and ends with pipes
  text = text.replace(/^([-:\s|]{3,})$/gm, (match) => {
    let clean = match.trim()
    if (!clean.startsWith('|')) clean = '| ' + clean
    if (!clean.endsWith('|')) clean = clean + ' |'
    return clean
  })

  // 6. Clean up any excess newlines
  text = text.replace(/\n{3,}/g, '\n\n')

  return text.trim()
}

interface MarkdownRendererProps {
  content: string
  isUser?: boolean
}

export const MarkdownRenderer: React.FC<MarkdownRendererProps> = ({ content, isUser = false }) => {
  const normalized = React.useMemo(() => normalizeMarkdownText(content), [content])

  return (
    <div className={`prose prose-sm max-w-none break-words ${isUser ? 'text-background' : 'text-text-primary'}`}>
      <ReactMarkdown
        remarkPlugins={[remarkGfm]}
        components={{
          table: ({ node, ...props }) => (
            <div className="overflow-x-auto my-3 rounded-xl border border-card-border/40 shadow-sm max-w-full">
              <table
                className={`w-full border-collapse text-left text-xs ${
                  isUser ? 'bg-black/5 text-background' : 'bg-[#0B0F17]/70 text-text-primary'
                }`}
                {...props}
              />
            </div>
          ),
          thead: ({ node, ...props }) => (
            <thead
              className={isUser ? 'bg-black/15 text-background border-b border-black/20' : 'bg-surface-light text-primary border-b border-card-border'}
              {...props}
            />
          ),
          tbody: ({ node, ...props }) => (
            <tbody className="divide-y divide-card-border/30" {...props} />
          ),
          tr: ({ node, ...props }) => (
            <tr
              className={`transition-colors ${
                isUser
                  ? 'hover:bg-black/10 border-b border-black/10'
                  : 'hover:bg-surface-light/40 even:bg-surface-light/20 border-b border-card-border/30'
              }`}
              {...props}
            />
          ),
          th: ({ node, ...props }) => (
            <th
              className={`px-3.5 py-2.5 font-bold uppercase tracking-wider text-[11px] whitespace-nowrap ${
                isUser ? 'text-background' : 'text-primary'
              }`}
              {...props}
            />
          ),
          td: ({ node, ...props }) => (
            <td
              className={`px-3.5 py-2 leading-relaxed ${
                isUser ? 'text-background/95 font-medium' : 'text-text-primary'
              }`}
              {...props}
            />
          ),
          h1: ({ node, ...props }) => (
            <h1
              className={`text-base font-extrabold tracking-tight mt-2 mb-2 pb-1 border-b ${
                isUser ? 'text-background border-black/20' : 'text-primary border-card-border'
              }`}
              {...props}
            />
          ),
          h2: ({ node, ...props }) => (
            <h2
              className={`text-sm font-bold tracking-tight mt-2 mb-1.5 ${
                isUser ? 'text-background' : 'text-primary'
              }`}
              {...props}
            />
          ),
          h3: ({ node, ...props }) => (
            <h3
              className={`text-xs font-bold mt-1.5 mb-1 ${
                isUser ? 'text-background' : 'text-primary'
              }`}
              {...props}
            />
          ),
          p: ({ node, ...props }) => (
            <p className="mb-2 last:mb-0 leading-relaxed" {...props} />
          ),
          strong: ({ node, ...props }) => (
            <strong className={`font-bold ${isUser ? 'text-background' : 'text-white'}`} {...props} />
          ),
          ul: ({ node, ...props }) => (
            <ul className="list-disc list-inside space-y-1 my-2 pl-1" {...props} />
          ),
          ol: ({ node, ...props }) => (
            <ol className="list-decimal list-inside space-y-1 my-2 pl-1" {...props} />
          ),
          code: ({ node, className, children, ...props }) => {
            const isInline = !className
            if (isInline) {
              return (
                <code
                  className={`px-1.5 py-0.5 rounded text-[11px] font-mono font-medium ${
                    isUser ? 'bg-black/15 text-background font-bold' : 'bg-surface-light text-primary border border-card-border/60'
                  }`}
                  {...props}
                >
                  {children}
                </code>
              )
            }
            return (
              <pre className="p-3 my-2 rounded-xl bg-[#090D14] border border-card-border/60 overflow-x-auto text-xs font-mono text-cyan-300">
                <code {...props}>{children}</code>
              </pre>
            )
          },
          blockquote: ({ node, ...props }) => (
            <blockquote
              className={`border-l-4 pl-3 my-2 italic text-xs ${
                isUser ? 'border-background text-background/80' : 'border-primary text-text-secondary'
              }`}
              {...props}
            />
          )
        }}
      >
        {normalized}
      </ReactMarkdown>
    </div>
  )
}
