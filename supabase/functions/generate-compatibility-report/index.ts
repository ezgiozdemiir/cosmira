import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
  });
}

async function callGemini(prompt: string): Promise<Record<string, unknown>> {
  const res = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${GEMINI_API_KEY}`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: {
          temperature: 0.85,
          maxOutputTokens: 3000,
          responseMimeType: "application/json",
          thinkingConfig: { thinkingBudget: 0 },
        },
      }),
    }
  );
  const data = await res.json();
  if (!res.ok || !data.candidates?.[0]) {
    throw new Error(`Gemini error: ${JSON.stringify(data)}`);
  }
  return JSON.parse(data.candidates[0].content.parts[0].text);
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS_HEADERS });

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) return json({ error: "Unauthorized" }, 401);

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);
    const { data: { user }, error: authErr } = await supabase.auth.getUser(
      authHeader.replace("Bearer ", "")
    );
    if (authErr || !user) return json({ error: "Invalid token" }, 401);

    const body = await req.json();
    const { partner_id } = body;
    const language: string = body.language ?? "en";
    if (!partner_id) return json({ error: "partner_id is required" }, 400);

    // Return cached report if exists
    const { data: existing } = await supabase
      .from("compatibility_reports")
      .select("*")
      .eq("user_id", user.id)
      .eq("partner_id", partner_id)
      .eq("language", language)
      .maybeSingle();

    if (existing) return json({ cached: true, report: existing });

    // Fetch user profile
    const { data: profile, error: profileErr } = await supabase
      .from("profiles")
      .select("sun_sign, moon_sign, rising_sign, birth_date")
      .eq("id", user.id)
      .single();
    if (profileErr || !profile) throw new Error("Could not load user profile");

    // Fetch partner
    const { data: partner, error: partnerErr } = await supabase
      .from("compatibility_partners")
      .select("name, sun_sign, birth_date, relationship")
      .eq("id", partner_id)
      .eq("user_id", user.id)
      .single();
    if (partnerErr || !partner) return json({ error: "Partner not found" }, 404);

    const userAge = profile.birth_date
      ? new Date().getFullYear() - new Date(profile.birth_date).getFullYear()
      : null;
    const partnerAge = partner.birth_date
      ? new Date().getFullYear() - new Date(partner.birth_date).getFullYear()
      : null;

    const identity = `You (Sun: ${profile.sun_sign ?? "unknown"}${profile.moon_sign ? `, Moon: ${profile.moon_sign}` : ""}${profile.rising_sign ? `, Rising: ${profile.rising_sign}` : ""}${userAge ? `, ~${userAge} years old` : ""})`;
    const partnerIdentity = `${partner.name} (Sun: ${partner.sun_sign}${partnerAge ? `, ~${partnerAge} years old` : ""}, relationship: ${partner.relationship})`;

    const buildPrompt = (lang: string) =>
      `You are a master astrologer for the luxury app Cosmira. Generate a deeply personalised, premium compatibility report.

User: ${identity}
Partner: ${partnerIdentity}

Return ONLY valid JSON with EXACTLY this structure — all scores are integers 0-100:

{
  "overall_score": <integer 0-100>,
  "emotional_alignment": <integer 0-100>,
  "communication_score": <integer 0-100>,
  "karmic_bond": <integer 0-100>,
  "intimacy_energy": <integer 0-100>,
  "soulmate_probability": <integer 0-100>,
  "long_term_score": <integer 0-100>,
  "energetic_balance": <integer 0-100>,
  "ai_analysis": {
    "summary": "4-5 sentences — the cosmic essence of this pairing. Specific to these signs, not generic.",
    "emotional": "3-4 sentences on emotional depth, needs, and attunement between these two placements.",
    "communication": "3-4 sentences on how they think, talk, and understand each other.",
    "karmic": "3-4 sentences on past-life ties, soul lessons, and what they are here to teach each other.",
    "intimacy": "3-4 sentences on physical energy, attraction, and intimate resonance.",
    "long_term": "3-4 sentences on long-term compatibility, shared vision, and growth potential.",
    "conflicts": ["3 specific recurring challenge patterns for this combination — framed with compassion"],
    "strengths": ["4 genuine superpowers of this pairing — specific to these signs"],
    "advice": "2-3 sentences of personalised cosmic wisdom for this couple."
  }
}

Tone: premium, intimate, poetic, emotionally resonant. Every sentence must feel specific to THESE signs, not generic zodiac content. Return ONLY valid JSON.${lang === "tr" ? "\n\nIMPORTANT: Respond entirely in Turkish. All text values in the JSON must be in Turkish." : ""}`;

    const toInsertData = (r: Record<string, unknown>, lang: string) => ({
      user_id: user.id,
      partner_id,
      language: lang,
      overall_score: r.overall_score,
      emotional_alignment: r.emotional_alignment,
      communication_score: r.communication_score,
      karmic_bond: r.karmic_bond,
      intimacy_energy: r.intimacy_energy,
      soulmate_probability: r.soulmate_probability,
      long_term_score: r.long_term_score,
      energetic_balance: r.energetic_balance,
      ai_analysis: r.ai_analysis,
      is_deep_scan: true,
      stardust_cost: 0,
    });

    const otherLang = language === "en" ? "tr" : "en";
    const { data: otherExisting } = await supabase
      .from("compatibility_reports").select("id")
      .eq("user_id", user.id).eq("partner_id", partner_id).eq("language", otherLang).maybeSingle();

    // Generate both languages in parallel
    const [primaryResult, otherResult] = await Promise.allSettled([
      callGemini(buildPrompt(language)),
      otherExisting ? Promise.resolve(null) : callGemini(buildPrompt(otherLang)),
    ]);

    if (primaryResult.status === "rejected") throw new Error(`Gemini error: ${primaryResult.reason}`);
    const geminiResult = primaryResult.value;

    const { data: inserted, error: insertErr } = await supabase
      .from("compatibility_reports")
      .insert(toInsertData(geminiResult, language))
      .select()
      .single();

    if (insertErr) throw new Error(`Insert failed: ${insertErr.message}`);

    // Insert other language (best-effort)
    if (otherResult.status === "fulfilled" && otherResult.value !== null) {
      await supabase.from("compatibility_reports")
        .insert(toInsertData(otherResult.value, otherLang))
        .catch((e: unknown) => console.error("Other-lang compatibility report insert failed:", e));
    }

    return json({ cached: false, report: inserted });
  } catch (err) {
    const msg = err instanceof Error ? err.message : JSON.stringify(err);
    console.error("generate-compatibility-report:", msg);
    return json({ error: msg }, 500);
  }
});
