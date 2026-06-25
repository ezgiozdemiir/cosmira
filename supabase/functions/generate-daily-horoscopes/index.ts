// Supabase Edge Function: Generate Daily Horoscopes
// Runs via cron at 00:00 UTC daily.
// Generates 72 horoscopes (12 signs × 3 points × 2 languages) using Gemini.
// Parallelised with a concurrency cap so all 72 finish well within the
// Edge Function 60-second timeout (target: ~20 s with concurrency=6).

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const ZODIAC_SIGNS = [
  "aries", "taurus", "gemini", "cancer", "leo", "virgo",
  "libra", "scorpio", "sagittarius", "capricorn", "aquarius", "pisces",
];

const POINTS = ["sun", "moon", "rising"] as const;
type Point = typeof POINTS[number];

const LANGUAGES = ["en", "tr"] as const;
type Language = typeof LANGUAGES[number];

const POINT_FOCUS: Record<Point, string> = {
  sun: "their core identity, willpower, and the general energy of the day",
  moon: "their emotional undercurrents, mood, and inner needs today",
  rising: "how they come across to others today and their instinctive first reactions",
};

const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

interface HoroscopeData {
  sign: string;
  point: Point;
  date: string;
  language: Language;
  horoscope_text: string;
  energy_score: number;
  aura_color: string;
  lucky_number: number;
  mood: string;
  daily_quote: string;
  spiritual_insight: string;
  spotify_track_id: string | null;
  spotify_track_name: string | null;
  spotify_artist: string | null;
}

async function generateHoroscope(
  sign: string,
  point: Point,
  date: string,
  language: Language,
  attempt = 0,
): Promise<HoroscopeData> {
  const langInstruction = language === "tr"
    ? "\n\nIMPORTANT: Respond entirely in Turkish. All text values in the JSON must be in Turkish."
    : "";

  const prompt =
    `You are a luxury astrology AI for the app Cosmira. Generate a daily ${point.toUpperCase()} sign horoscope for someone with their ${point} in ${sign}, for ${date}.

Focus specifically on ${POINT_FOCUS[point]}.

Return a JSON object with exactly these fields:
{
  "horoscope_text": "2-3 elegant sentences. Spiritual but not cringe. Empowering and specific.",
  "energy_score": <number 1-100>,
  "aura_color": "<hex color representing today's aura>",
  "lucky_number": <number 1-99>,
  "mood": "<one word mood>",
  "daily_quote": "<short inspiring quote aligned with today's cosmic energy>",
  "spiritual_insight": "<one sentence deep spiritual insight>"
}

Tone: premium, calming, feminine, emotionally resonant. Never childish or generic.
Return ONLY valid JSON, no markdown.${langInstruction}`;

  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${GEMINI_API_KEY}`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: {
          temperature: 0.8,
          maxOutputTokens: 500,
          responseMimeType: "application/json",
          thinkingConfig: { thinkingBudget: 0 },
        },
      }),
    },
  );

  const data = await response.json();

  if (response.status === 429 && attempt < 3) {
    const retryDelay =
      data?.error?.details
        ?.find((d: Record<string, unknown>) =>
          d["@type"]?.toString().includes("RetryInfo")
        )
        ?.retryDelay?.replace("s", "") ?? "20";
    const waitMs = (parseInt(retryDelay) + 2) * 1000;
    console.log(`Rate limited ${sign}:${point}:${language}, retry in ${waitMs}ms`);
    await new Promise((r) => setTimeout(r, waitMs));
    return generateHoroscope(sign, point, date, language, attempt + 1);
  }

  if (!response.ok || !data.candidates?.[0]) {
    throw new Error(`Gemini error for ${sign}:${point}:${language}: ${JSON.stringify(data)}`);
  }

  const parsed = JSON.parse(data.candidates[0].content.parts[0].text);
  return {
    sign,
    point,
    date,
    language,
    horoscope_text: parsed.horoscope_text,
    energy_score: Math.min(100, Math.max(1, parsed.energy_score)),
    aura_color: parsed.aura_color,
    lucky_number: parsed.lucky_number,
    mood: parsed.mood,
    daily_quote: parsed.daily_quote,
    spiritual_insight: parsed.spiritual_insight,
    spotify_track_id: null,
    spotify_track_name: null,
    spotify_artist: null,
  };
}

// Run up to `concurrency` promises at a time, collecting all results.
async function runWithConcurrency<T>(
  tasks: (() => Promise<T>)[],
  concurrency: number,
): Promise<PromiseSettledResult<T>[]> {
  const results: PromiseSettledResult<T>[] = [];
  let index = 0;

  async function worker() {
    while (index < tasks.length) {
      const i = index++;
      try {
        results[i] = { status: "fulfilled", value: await tasks[i]() };
      } catch (e) {
        results[i] = { status: "rejected", reason: e };
      }
    }
  }

  const workers = Array.from({ length: Math.min(concurrency, tasks.length) }, worker);
  await Promise.all(workers);
  return results;
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: { "Access-Control-Allow-Origin": "*", "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type" },
    });
  }

  try {
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);
    const today = new Date().toISOString().split("T")[0];

    const body = await req.json().catch(() => ({}));
    const concurrency: number = body?.concurrency ?? 6;

    // Find which combos are already generated for today.
    const { data: existing } = await supabase
      .from("daily_horoscopes")
      .select("sign, point, language")
      .eq("date", today);

    const existingKeys = new Set(
      (existing ?? []).map((h: any) => `${h.sign}:${h.point}:${h.language}`),
    );

    const missing: { sign: string; point: Point; language: Language }[] = [];
    for (const sign of ZODIAC_SIGNS) {
      for (const point of POINTS) {
        for (const language of LANGUAGES) {
          if (!existingKeys.has(`${sign}:${point}:${language}`)) {
            missing.push({ sign, point, language });
          }
        }
      }
    }

    if (missing.length === 0) {
      return new Response(
        JSON.stringify({ message: "All horoscopes already generated for " + today }),
        { headers: { "Content-Type": "application/json" } },
      );
    }

    console.log(`Generating ${missing.length} horoscopes with concurrency=${concurrency}`);

    const tasks = missing.map(
      ({ sign, point, language }) =>
        () => generateHoroscope(sign, point, today, language),
    );

    const results = await runWithConcurrency(tasks, concurrency);

    const succeeded: HoroscopeData[] = [];
    const failed: string[] = [];

    results.forEach((r, i) => {
      const { sign, point, language } = missing[i];
      if (r.status === "fulfilled") {
        succeeded.push(r.value);
      } else {
        console.error(`Failed ${sign}:${point}:${language}:`, r.reason);
        failed.push(`${sign}:${point}:${language}`);
      }
    });

    // Bulk insert all successes in one round-trip.
    if (succeeded.length > 0) {
      const { error } = await supabase.from("daily_horoscopes").insert(succeeded);
      if (error) console.error("Bulk insert error:", error);
    }

    return new Response(
      JSON.stringify({
        date: today,
        generated: succeeded.length,
        failed: failed.length,
        failedItems: failed,
      }),
      { headers: { "Content-Type": "application/json" } },
    );
  } catch (error) {
    console.error("Fatal error:", error);
    return new Response(JSON.stringify({ error: String(error) }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
