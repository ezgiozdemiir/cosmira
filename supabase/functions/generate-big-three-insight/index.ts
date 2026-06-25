// Supabase Edge Function: Generate Big Three Insight
// Called on-demand from the natal chart screen. Keyed by the caller's
// Sun/Moon/Rising sign combination (not by user), so every user sharing
// the same Big Three reuses the same cached row — this is what makes it
// sustainable to offer premium tiers unlimited daily/monthly/yearly
// content without a per-request cost like the Stardust-gated reports.

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

type Tier = "free" | "premium";
type Period = "static" | "daily" | "monthly" | "yearly";

const VALID_TIERS: Tier[] = ["free", "premium"];
const VALID_PERIODS: Period[] = ["static", "daily", "monthly", "yearly"];

function periodKey(period: Period): string {
  const now = new Date();
  switch (period) {
    case "static":
      return "static";
    case "daily":
      return now.toISOString().split("T")[0];
    case "monthly":
      return now.toISOString().slice(0, 7);
    case "yearly":
      return String(now.getUTCFullYear());
  }
}

function promptFor(
  tier: Tier,
  period: Period,
  sunSign: string,
  moonSign: string,
  risingSign: string,
  key: string
): { system: string; schema: string } {
  const identity = `someone with Sun in ${sunSign}, Moon in ${moonSign}, and Rising in ${risingSign}`;

  if (tier === "free" && period === "static") {
    return {
      system: `You are a luxury astrology AI for the app Cosmira. Write a personality & abilities summary for ${identity}, synthesizing all three placements together (not just the Sun sign).`,
      schema: `{
  "summary": "2-3 elegant sentences describing their core personality, blending all three signs.",
  "strengths": ["3-4 short strength/ability phrases"],
  "growth_areas": ["2-3 short, gentle growth-area phrases"]
}`,
    };
  }

  if (tier === "free" && period === "daily") {
    return {
      system: `You are a luxury astrology AI for the app Cosmira. Write a brief daily cosmic nudge for ${identity}, for ${key}. Short and uplifting, blending their three placements.`,
      schema: `{
  "insight": "2 elegant sentences for today, blending all three signs.",
  "focus_area": "one short phrase naming today's main theme",
  "advice": "1 short actionable sentence"
}`,
    };
  }

  if (tier === "free" && period === "monthly") {
    return {
      system: `You are a luxury astrology AI for the app Cosmira. Write a brief monthly overview for ${identity}, for the month of ${key}, synthesizing all three placements.`,
      schema: `{
  "theme": "short phrase naming the month's overall theme",
  "forecast": "2-3 elegant sentences forecasting the month",
  "opportunities": "1 sentence on key opportunities"
}`,
    };
  }

  if (tier === "free" && period === "yearly") {
    return {
      system: `You are a luxury astrology AI for the app Cosmira. Write a brief yearly overview for ${identity}, for the year ${key}, synthesizing all three placements.`,
      schema: `{
  "theme": "short phrase naming the year's overall theme",
  "forecast": "2-3 elegant sentences forecasting the year",
  "cosmic_advice": "1 elegant closing sentence"
}`,
    };
  }

  if (tier === "premium" && period === "daily") {
    return {
      system: `You are a luxury astrology AI for the app Cosmira. Write a deep daily insight for ${identity}, for ${key}, synthesizing how all three placements interact today specifically (richer and more specific than a generic sun-sign horoscope).`,
      schema: `{
  "insight": "3-4 elegant, specific sentences for today.",
  "focus_area": "one short phrase naming today's main theme",
  "advice": "1 elegant actionable sentence"
}`,
    };
  }

  if (tier === "premium" && period === "monthly") {
    return {
      system: `You are a luxury astrology AI for the app Cosmira. Write a monthly forecast for ${identity}, for the month of ${key}, synthesizing all three placements.`,
      schema: `{
  "theme": "short phrase naming the month's overall theme",
  "forecast": "3-4 elegant sentences forecasting the month",
  "opportunities": "1-2 sentences on opportunities",
  "challenges": "1-2 sentences on challenges to navigate"
}`,
    };
  }

  // premium + yearly
  return {
    system: `You are a luxury astrology AI for the app Cosmira. Write a yearly forecast for ${identity}, for the year ${key}, synthesizing all three placements.`,
    schema: `{
  "theme": "short phrase naming the year's overall theme",
  "forecast": "4-5 elegant sentences forecasting the year",
  "quarterly_highlights": ["4 short phrases, one per quarter"],
  "cosmic_advice": "1 elegant closing sentence"
}`,
  };
}

async function generateContent(
  tier: Tier,
  period: Period,
  sunSign: string,
  moonSign: string,
  risingSign: string,
  key: string,
  language: string,
  attempt = 0,
): Promise<Record<string, unknown>> {
  const { system, schema } = promptFor(tier, period, sunSign, moonSign, risingSign, key);
  const prompt = `${system}

Return a JSON object with exactly these fields:
${schema}

Tone: premium, calming, feminine, emotionally resonant. Never childish or generic.
Return ONLY valid JSON, no markdown.${language === "tr" ? "\n\nIMPORTANT: Respond entirely in Turkish. All text values in the JSON must be in Turkish." : ""}`;

  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${GEMINI_API_KEY}`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: {
          temperature: 0.8,
          maxOutputTokens: 600,
          responseMimeType: "application/json",
          thinkingConfig: { thinkingBudget: 0 },
        },
      }),
    }
  );

  const data = await response.json();

  if (response.status === 429 && attempt < 2) {
    const retryDelayStr =
      data?.error?.details
        ?.find((d: Record<string, unknown>) =>
          d["@type"]?.toString().includes("RetryInfo")
        )
        ?.retryDelay?.replace("s", "") ?? "15";
    const retryDelaySec = parseInt(retryDelayStr);
    // If Gemini says wait > 60s it's a daily quota limit — don't retry, fail fast.
    if (retryDelaySec > 60) {
      throw new Error(`Gemini daily quota exceeded. Resets at midnight UTC.`);
    }
    const waitMs = Math.min(retryDelaySec + 2, 25) * 1000;
    console.log(`Rate limited ${tier}:${period}:${language}, retry in ${waitMs}ms (attempt ${attempt + 1})`);
    await new Promise((r) => setTimeout(r, waitMs));
    return generateContent(tier, period, sunSign, moonSign, risingSign, key, language, attempt + 1);
  }

  if (!response.ok || !data.candidates) {
    throw new Error(`Gemini API error: ${JSON.stringify(data)}`);
  }
  const text = data.candidates[0].content.parts[0].text;
  return JSON.parse(text);
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS_HEADERS });
  }

  try {
    const body = await req.json();
    const { sun_sign, moon_sign, rising_sign, tier, period } = body;
    const language: string = body.language ?? "en";

    if (!sun_sign || !moon_sign || !rising_sign) {
      return new Response(
        JSON.stringify({ error: "sun_sign, moon_sign, and rising_sign are all required." }),
        { status: 400, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } }
      );
    }
    if (!VALID_TIERS.includes(tier)) {
      return new Response(JSON.stringify({ error: `tier must be one of: ${VALID_TIERS.join(", ")}` }), {
        status: 400,
        headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
      });
    }
    if (!VALID_PERIODS.includes(period)) {
      return new Response(JSON.stringify({ error: `period must be one of: ${VALID_PERIODS.join(", ")}` }), {
        status: 400,
        headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
      });
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);
    const key = periodKey(period);

    const { data: cached } = await supabase
      .from("big_three_insights")
      .select("*")
      .eq("sun_sign", sun_sign)
      .eq("moon_sign", moon_sign)
      .eq("rising_sign", rising_sign)
      .eq("tier", tier)
      .eq("period", period)
      .eq("period_key", key)
      .eq("language", language)
      .maybeSingle();

    if (cached) {
      return new Response(JSON.stringify({ cached: true, insight: cached }), {
        headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
      });
    }

    const otherLang = language === "en" ? "tr" : "en";
    const { data: otherCached } = await supabase
      .from("big_three_insights")
      .select("id")
      .eq("sun_sign", sun_sign).eq("moon_sign", moon_sign).eq("rising_sign", rising_sign)
      .eq("tier", tier).eq("period", period).eq("period_key", key).eq("language", otherLang)
      .maybeSingle();

    // Generate primary language first, then other language sequentially
    // to avoid triggering Gemini rate limits when multiple periods are
    // requested simultaneously (daily + monthly + yearly on page load).
    const content = await generateContent(tier, period, sun_sign, moon_sign, rising_sign, key, language);

    let otherContent: Record<string, unknown> | null = null;
    if (!otherCached) {
      try {
        otherContent = await generateContent(tier, period, sun_sign, moon_sign, rising_sign, key, otherLang);
      } catch (e) {
        console.error(`Other-lang generation failed (${otherLang}):`, e);
      }
    }

    const { data: inserted, error } = await supabase
      .from("big_three_insights")
      .insert({ sun_sign, moon_sign, rising_sign, tier, period, period_key: key, content, language })
      .select()
      .single();

    if (error) throw error;

    // Insert other language (best-effort)
    if (otherContent !== null) {
      try {
        const { error: otherError } = await supabase.from("big_three_insights")
          .insert({ sun_sign, moon_sign, rising_sign, tier, period, period_key: key, content: otherContent, language: otherLang });
        if (otherError) console.error("Other-lang big-three insert failed:", otherError);
      } catch (e) {
        console.error("Other-lang big-three insert failed:", e);
      }
    }

    return new Response(JSON.stringify({ cached: false, insight: inserted }), {
      headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("Error generating big three insight:", error);
    return new Response(JSON.stringify({ error: error instanceof Error ? error.message : JSON.stringify(error) }), {
      status: 500,
      headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
    });
  }
});
