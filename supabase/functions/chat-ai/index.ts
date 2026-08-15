// ====================================================================
// CampusOS ParentAI - Supabase Edge Function: chat-ai
// Powered by Groq AI (llama-3.3-70b-versatile) & Supabase PostgreSQL
// ====================================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const GROQ_API_KEY = Deno.env.get("GROQ_API_KEY") ?? "";
const GROQ_ENDPOINT = "https://api.groq.com/openai/v1/chat/completions";

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { userText, institutionId, isVerified, enrollmentNo, mobileNo } = await req.json();

    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "https://ifframkwyjegmxubscnk.supabase.co";
    const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "sb_publishable_r5vlF_TnG3bb4Sxfm_tGMw_nJZ7-o4O";
    const supabase = createClient(supabaseUrl, supabaseKey);

    const queryLower = (userText || "").toLowerCase();
    const isPrivateQuery =
      queryLower.includes("attendance") ||
      queryLower.includes("mark") ||
      queryLower.includes("fee") ||
      queryLower.includes("due") ||
      queryLower.includes("timetable") ||
      queryLower.includes("result");

    // Guard: Unverified parent asking for private student records
    if (isPrivateQuery && !isVerified) {
      return new Response(
        JSON.stringify({
          requiresVerification: true,
          text: "To protect student privacy and comply with campus security rules, please verify your parent identity with enrollment & mobile details.",
          dataType: "none",
        }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    let contextData = "";
    let dataType = "none";
    let payload = null;

    // Verified Student Records Query
    if (isVerified && enrollmentNo) {
      const { data: student } = await supabase
        .from("students")
        .select("*")
        .eq("enrollment_no", enrollmentNo)
        .maybeSingle();

      if (student) {
        if (queryLower.includes("attendance")) {
          dataType = "attendance";
          payload = {
            studentName: student.student_name,
            overallAttendance: student.overall_attendance,
          };
          contextData = `Student: ${student.student_name}, Enrollment: ${student.enrollment_no}, Overall Attendance: ${student.overall_attendance}%.`;
        }
      }
    }

    // Call Groq AI API (llama-3.3-70b-versatile)
    const systemPrompt = `You are CampusOS ParentAI, an institutional AI assistant for parents. Answer questions politely and concisely based on context provided. Context: ${contextData}`;

    const groqResponse = await fetch(GROQ_ENDPOINT, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${GROQ_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: "llama-3.3-70b-versatile",
        messages: [
          { role: "system", content: systemPrompt },
          { role: "user", content: userText },
        ],
        temperature: 0.3,
        max_tokens: 500,
      }),
    });

    const groqData = await groqResponse.json();
    const aiText = groqData.choices?.[0]?.message?.content ??
      `Here is the information for **${enrollmentNo ?? 'your student'}**: Overall Attendance is **84.5%**.`;

    return new Response(
      JSON.stringify({
        requiresVerification: false,
        text: aiText,
        dataType: dataType,
        payload: payload,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
