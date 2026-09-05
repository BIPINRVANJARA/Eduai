-- ============================================================================
-- FULL RAG: document_chunks table + search_document_chunks RPC
-- Run this in Supabase SQL Editor
-- ============================================================================

-- 1. Chunks table with auto-generated full-text search vector
CREATE TABLE IF NOT EXISTS public.document_chunks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id UUID NOT NULL REFERENCES public.documents(id) ON DELETE CASCADE,
    institution_id UUID NOT NULL,
    department TEXT,
    semester TEXT,
    subject_name TEXT,
    chunk_index INT NOT NULL,
    chunk_content TEXT NOT NULL,
    token_count INT DEFAULT 0,
    search_vector TSVECTOR GENERATED ALWAYS AS (
        to_tsvector('english', chunk_content)
    ) STORED,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. GIN index for blazing fast full-text search
CREATE INDEX IF NOT EXISTS idx_chunks_search ON public.document_chunks USING GIN(search_vector);
CREATE INDEX IF NOT EXISTS idx_chunks_doc_id ON public.document_chunks(document_id);
CREATE INDEX IF NOT EXISTS idx_chunks_institution ON public.document_chunks(institution_id);

-- 3. RPC function: full-text search scoped to institution & department
CREATE OR REPLACE FUNCTION search_document_chunks(
    query_text TEXT,
    match_count INT DEFAULT 8,
    filter_institution_id UUID DEFAULT NULL,
    filter_department TEXT DEFAULT NULL
)
RETURNS TABLE(
    id UUID,
    document_id UUID,
    chunk_index INT,
    chunk_content TEXT,
    department TEXT,
    subject_name TEXT,
    rank FLOAT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        dc.id,
        dc.document_id,
        dc.chunk_index,
        dc.chunk_content,
        dc.department,
        dc.subject_name,
        ts_rank(dc.search_vector, plainto_tsquery('english', query_text))::FLOAT AS rank
    FROM public.document_chunks dc
    WHERE dc.search_vector @@ plainto_tsquery('english', query_text)
      AND (filter_institution_id IS NULL OR dc.institution_id = filter_institution_id)
      AND (filter_department IS NULL OR dc.department = filter_department)
    ORDER BY rank DESC
    LIMIT match_count;
END;
$$ LANGUAGE plpgsql;

-- 4. Enable RLS with open read access
ALTER TABLE public.document_chunks ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'document_chunks' AND policyname = 'Allow authenticated read chunks') THEN
        CREATE POLICY "Allow authenticated read chunks" ON public.document_chunks
            FOR SELECT TO authenticated USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'document_chunks' AND policyname = 'Allow anon read chunks') THEN
        CREATE POLICY "Allow anon read chunks" ON public.document_chunks
            FOR SELECT TO anon USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'document_chunks' AND policyname = 'Allow insert chunks') THEN
        CREATE POLICY "Allow insert chunks" ON public.document_chunks
            FOR INSERT WITH CHECK (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'document_chunks' AND policyname = 'Allow delete chunks') THEN
        CREATE POLICY "Allow delete chunks" ON public.document_chunks
            FOR DELETE USING (true);
    END IF;
END $$;

SELECT 'document_chunks table and search_document_chunks RPC created successfully!' AS status;
