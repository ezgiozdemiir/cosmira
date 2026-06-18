// Supabase Edge Function: Generate Daily Horoscopes
// Runs via cron at 00:00 UTC daily
// Generates 36 horoscopes (12 signs x 3 points: sun/moon/rising) using Gemini API
// Cost: ~36 Gemini calls/day ≈ $0.03/day

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const ZODIAC_SIGNS = [
  "aries", "taurus", "gemini", "cancer", "leo", "virgo",
  "libra", "scorpio", "sagittarius", "capricorn", "aquarius", "pisces",
];

const POINTS = ["sun", "moon", "rising"] as const;
type Point = typeof POINTS[number];

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

async function generateHoroscope(sign: string, point: Point, date: string): Promise<HoroscopeData> {
  const prompt = `You are a luxury astrology AI for the app Cosmira. Generate a daily ${point.toUpperCase()} sign horoscope for someone with their ${point} in ${sign}, for ${date}.

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
    point,
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

    // Check which (sign, point) combos already exist for today.
    const { data: existing } = await supabase
      .from("daily_horoscopes")
      .select("sign, point")
      .eq("date", today);

    const existingKeys = new Set((existing || []).map((h: any) => `${h.sign}:${h.point}`));
    const missing: { sign: string; point: Point }[] = [];
    for (const sign of ZODIAC_SIGNS) {
      for (const point of POINTS) {
        if (!existingKeys.has(`${sign}:${point}`)) {
          missing.push({ sign, point });
        }
      }
    }

    if (missing.length === 0) {
      return new Response(JSON.stringify({ message: "All horoscopes already generated" }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    const horoscopes: HoroscopeData[] = [];

    // Generate sequentially to respect rate limits
    for (const { sign, point } of missing) {
      const horoscope = await generateHoroscope(sign, point, today);
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
        entries: horoscopes.map((h) => `${h.sign}:${h.point}`),
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
