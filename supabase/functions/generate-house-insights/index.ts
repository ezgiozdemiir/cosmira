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

const ZODIAC_SIGNS = [
  "aries", "taurus", "gemini", "cancer", "leo", "virgo",
  "libra", "scorpio", "sagittarius", "capricorn", "aquarius", "pisces",
];

const HOUSE_THEMES = [
  "Self & Identity",
  "Values & Resources",
  "Communication & Mind",
  "Home & Roots",
  "Creativity & Joy",
  "Work & Health",
  "Partnerships",
  "Transformation",
  "Philosophy & Growth",
  "Career & Legacy",
  "Community & Hopes",
  "Soul & Surrender",
];

function wholeSignHouses(risingSign: string): string[] {
  const index = ZODIAC_SIGNS.indexOf(risingSign.toLowerCase());
  if (index === -1) return [];
  return Array.from({ length: 12 }, (_, i) => ZODIAC_SIGNS[(index + i) % 12]);
}

async function generateHouseContent(normalised: string, language: string): Promise<unknown[]> {
  const houses = wholeSignHouses(normalised);
  const houseList = houses
    .map((sign, i) => `House ${i + 1} (${HOUSE_THEMES[i]}): ${sign}`)
    .join("\n");

  const prompt = `You are a luxury astrology AI for the app Cosmira. The user has ${normalised} Rising, giving them these whole-sign house placements:
${houseList}

Write a rich, personal astrological interpretation for each of the 12 houses — how that sign's energy specifically shapes that life area for someone with ${normalised} Rising. Each interpretation should be 2-3 elegant, emotionally resonant sentences.

Return ONLY a valid JSON array with exactly 12 objects in order:
[
  { "house": 1, "sign": "sign_name", "theme": "Self & Identity", "interpretation": "..." },
  ...
]

Tone: premium, calming, feminine, specific — never generic or childish.${language === "tr" ? "\n\nIMPORTANT: Respond in Turkish. Translate ONLY the \"theme\" and \"interpretation\" fields. The \"sign\" field must always remain lowercase English (e.g. \"aquarius\", \"pisces\", \"aries\")." : ""}`;

  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${GEMINI_API_KEY}`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: {
          temperature: 0.8,
          maxOutputTokens: 3000,
          responseMimeType: "application/json",
          thinkingConfig: { thinkingBudget: 0 },
        },
      }),
    }
  );

  const data = await response.json();
  if (!response.ok || !data.candidates) {
    throw new Error(`Gemini API error: ${JSON.stringify(data)}`);
  }
  return JSON.parse(data.candidates[0].content.parts[0].text);
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS_HEADERS });
  }

  try {
    const body = await req.json();
    const rising_sign = body.rising_sign;
    const language: string = body.language ?? "en";
    const normalised = rising_sign?.toLowerCase();

    if (!normalised || !ZODIAC_SIGNS.includes(normalised)) {
      return new Response(
        JSON.stringify({ error: "valid rising_sign is required" }),
        { status: 400, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } }
      );
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);
    const otherLang = language === "en" ? "tr" : "en";

    const { data: cached } = await supabase
      .from("house_insights")
      .select("*")
      .eq("rising_sign", normalised)
      .eq("language", language)
      .maybeSingle();

    if (cached) {
      return new Response(JSON.stringify({ cached: true, insight: cached }), {
        headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
      });
    }

    const { data: otherCached } = await supabase
      .from("house_insights").select("id").eq("rising_sign", normalised).eq("language", otherLang).maybeSingle();

    // Generate both languages in parallel
    const [primaryResult, otherResult] = await Promise.allSettled([
      generateHouseContent(normalised, language),
      otherCached ? Promise.resolve(null) : generateHouseContent(normalised, otherLang),
    ]);

    if (primaryResult.status === "rejected") throw primaryResult.reason;
    const content = primaryResult.value;

    const { data: inserted, error } = await supabase
      .from("house_insights")
      .insert({ rising_sign: normalised, content, language })
      .select()
      .single();

    if (error) throw error;

    // Insert other language (best-effort)
    if (otherResult.status === "fulfilled" && otherResult.value !== null) {
      await supabase.from("house_insights")
        .insert({ rising_sign: normalised, content: otherResult.value, language: otherLang })
        .catch((e: unknown) => console.error("Other-lang house insights insert failed:", e));
    }

    return new Response(JSON.stringify({ cached: false, insight: inserted }), {
      headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("Error generating house insights:", error);
    return new Response(
      JSON.stringify({ error: error instanceof Error ? error.message : JSON.stringify(error) }),
      { status: 500, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } }
    );
  }
});
