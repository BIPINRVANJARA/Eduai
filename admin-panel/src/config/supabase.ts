import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://ifframkwyjegmxubscnk.supabase.co'
const supabaseKey = 'sb_publishable_r5vlF_TnG3bb4Sxfm_tGMw_nJZ7-o4O'

export const supabase = createClient(supabaseUrl, supabaseKey)
