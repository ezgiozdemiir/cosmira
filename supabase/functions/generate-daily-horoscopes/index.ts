// Supabase Edge Function: Generate Daily Horoscopes
// Runs via cron at 00:00 UTC daily
// Generates 12 horoscopes (one per sign) using Gemini API
// Cost: ~12 Gemini calls/day ≈ $0.01/day

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const ZODIAC_SIGNS = [
  "aries", "taurus", "gemini", "cancer", "leo", "virgo",
  "libra", "scorpio", "sagittarius", "capricorn", "aquarius", "pisces",
];

const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

interface HoroscopeData {
  sign: string;
  date: string;
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

async function generateHoroscope(sign: string, date: string): Promise<HoroscopeData> {
  const prompt = `You are a luxury astrology AI for the app Cosmira. Generate a daily horoscope for ${sign} on ${date}.

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
Return ONLY valid JSON, no markdown.`;

  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${GEMINI_API_KEY}`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: {
          temperature: 0.8,
          maxOutputTokens: 500,
          responseMimeType: "application/json",
        },
      }),
    }
  );

  const data = await response.json();
  const text = data.candidates[0].content.parts[0].text;
  const parsed = JSON.parse(text);

  return {
    sign,
    date,
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

serve(async (req) => {
  try {
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);
    const today = new Date().toISOString().split("T")[0];

    // Check if today's horoscopes already exist
    const { data: existing } = await supabase
      .from("daily_horoscopes")
      .select("sign")
      .eq("date", today);

    const existingSigns = new Set((existing || []).map((h: any) => h.sign));
    const missingSigns = ZODIAC_SIGNS.filter((s) => !existingSigns.has(s));

    if (missingSigns.length === 0) {
      return new Response(JSON.stringify({ message: "All horoscopes already generated" }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    const horoscopes: HoroscopeData[] = [];

    // Generate sequentially to respect rate limits
    for (const sign of missingSigns) {
      const horoscope = await generateHoroscope(sign, today);
      horoscopes.push(horoscope);
      // Small delay to avoid rate limiting
      await new Promise((r) => setTimeout(r, 500));
    }

    // Batch insert
    const { error } = await supabase.from("daily_horoscopes").insert(horoscopes);

    if (error) throw error;

    return new Response(
      JSON.stringify({
        message: `Generated ${horoscopes.length} horoscopes for ${today}`,
        signs: horoscopes.map((h) => h.sign),
      }),
      { headers: { "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("Error generating horoscopes:", error);
    return new Response(JSON.stringify({ error: String(error) }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
