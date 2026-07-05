// Supabase Edge Function: Generate Birth Map
// Called when a user purchases their Cosmic Fingerprint report.
// Atomically deducts 200 Stardust, generates a comprehensive astrological
// birth map via Gemini, and stores it per-user per-language permanently.
// Subsequent calls for the same language return the cached map at no cost.
//
// Also supports generating a Birth Map for a "Loved One" (see the
// `loved_ones` table, migration 018): pass `loved_one_id` in the body and
// the function reads/writes against `loved_one_birth_maps` (keyed by
// loved_one_id) instead of `birth_maps` (keyed by user_id+birth_data_version).
// loved_ones rows are immutable once created, so there's no version
// dimension to track for them.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const BIRTH_MAP_COST = 200;

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

async function generateContent(params: {
  sunSign: string;
  moonSign: string;
  risingSign: string;
  mcSign: string;
  birthYear: number;
  birthCity: string;
  language: string;
}): Promise<Record<string, unknown>> {
  const { sunSign, moonSign, risingSign, mcSign, birthYear, birthCity, language } = params;
  const currentYear = new Date().getFullYear();
  const nextYear = currentYear + 1;
  const yearAfter = currentYear + 2;

  const identity = `someone born in ${birthYear}${birthCity ? ` in ${birthCity}` : ""}, with Sun in ${sunSign}, Moon in ${moonSign}, Rising in ${risingSign}${mcSign ? `, and Midheaven in ${mcSign}` : ""}`;

  const langInstruction = language === "tr"
    ? "\n\nIMPORTANT: Respond entirely in Turkish. All text values in the JSON must be in Turkish."
    : "\n\nRespond entirely in English.";

  const prompt = `You are a master astrologer and cosmic guide for the luxury app Cosmira.
Create a deeply personalized, comprehensive Cosmic Fingerprint Birth Map for ${identity}.

This is a premium, one-time-purchase report. Every section must synthesize ALL placements together — not just Sun sign astrology. Write with luxury, emotional depth, and specificity. This should feel like a personal letter from the cosmos.

Return a JSON object with EXACTLY this structure:

{
  "cosmic_fingerprint": "A poetic, singular opening paragraph (4-5 sentences) capturing the essence of this cosmic combination — their soul's unique signature. Make it feel like the stars are speaking directly to them.",

  "personality": {
    "core_essence": "4-5 sentences synthesizing Sun + Moon + Rising into a vivid, specific portrait — HOW they move through the world, HOW they feel internally, HOW they appear to others.",
    "light_side": ["6 specific character strengths genuinely derived from their exact chart combination — not generic zodiac descriptions"],
    "shadow_side": ["3 shadow patterns framed with compassion — what they are learning to integrate, phrased as growth not flaws"],
    "unique_gifts": "2 sentences on what makes this specific cosmic combination rare and powerful"
  },

  "life_purpose": {
    "soul_mission": "4-5 sentences on their deeper purpose — what their soul chose to experience and contribute in this lifetime, derived from their chart synthesis",
    "north_node_path": "3-4 sentences on the direction their soul is growing toward and the qualities they are developing in this life",
    "karmic_lessons": ["3 specific karmic themes they are working through — tied to their chart placements, framed as evolution not punishment"]
  },

  "love_and_relationships": {
    "love_style": "4-5 sentences on how they love, how they need to be loved, and their emotional landscape in relationships — synthesizing Moon (inner needs), Rising (how they appear), and Sun (what they offer)",
    "what_they_seek": "3-4 sentences on their ideal partner, what draws them in initially, and what sustains them long-term",
    "relationship_patterns": "3-4 sentences on recurring dynamics in their love life and what they are learning through intimacy",
    "venus_wisdom": "1 elegant, specific sentence of cosmic love advice for this exact combination"
  },

  "career_and_destiny": {
    "purpose_and_calling": "4-5 sentences on their professional path and what they are cosmically called to build, lead, create, or heal — using MC sign and Sun sign synthesis",
    "natural_talents": ["5 professional strengths that emerge naturally from their chart combination"],
    "ideal_paths": ["4 career themes or domains that resonate with their cosmic blueprint — specific fields or archetypes, not generic advice"],
    "success_formula": "1 elegant sentence on how this specific combination achieves greatness"
  },

  "strengths_and_challenges": {
    "superpowers": ["6 genuine superpowers — specific, empowering, derived from their chart — not generic positivity"],
    "growth_edges": ["3 growth challenges specific to their chart, framed as cosmic invitations not weaknesses"],
    "transformation_key": "1 sentence on their single greatest lever for transformation and evolution"
  },

  "cosmic_timing": {
    "current_chapter": "4-5 sentences on the current life phase and what themes are most active for this chart combination right now",
    "year_predictions": [
      {
        "year": ${currentYear},
        "theme": "short evocative phrase for this year's overarching energy",
        "forecast": "4-5 sentences on what ${currentYear} holds — specific opportunities, shifts, and invitations for this chart"
      },
      {
        "year": ${nextYear},
        "theme": "short evocative phrase for ${nextYear}'s energy",
        "forecast": "4-5 sentences on ${nextYear}'s gifts, challenges, and cosmic invitations for this chart"
      },
      {
        "year": ${yearAfter},
        "theme": "short evocative phrase for ${yearAfter}'s energy",
        "forecast": "4-5 sentences on the horizon ${yearAfter} opens for this specific cosmic combination"
      }
    ]
  },

  "cosmic_wisdom": "A closing cosmic letter (5-6 sentences) — written as if the stars speak directly to this person. Personal, profound, and beautiful. Reference their specific chart combination. End with an empowering declaration of who they are."
}

Tone: premium, intimate, wise, emotionally resonant, empowering — like a luxury astrologer who has studied this person for years.
Every sentence must feel specific to THEIR combination, not generic horoscope language.
Return ONLY valid JSON. No markdown, no extra text.${langInstruction}`;

  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${GEMINI_API_KEY}`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: {
          temperature: 0.9,
          maxOutputTokens: 4096,
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
  const text = data.candidates[0].content.parts[0].text;
  return JSON.parse(text);
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS_HEADERS });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: "Authorization required" }),
        { status: 401, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } }
      );
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);
    const token = authHeader.replace("Bearer ", "");
    const { data: { user }, error: authError } = await supabase.auth.getUser(token);

    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: "Invalid token" }),
        { status: 401, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } }
      );
    }

    const userId = user.id;

    let body: Record<string, string>;
    try {
      body = await req.json();
    } catch (e) {
      throw new Error(`STEP_BODY_PARSE: ${e instanceof Error ? e.message : String(e)}`);
    }

    const { sun_sign, moon_sign, rising_sign, mc_sign, birth_date, birth_city, loved_one_id } = body;
    const language = body.language ?? "en";
    const lovedOneId = loved_one_id || null;

    if (!sun_sign || !moon_sign || !rising_sign) {
      return new Response(
        JSON.stringify({ error: `STEP_VALIDATE: missing fields sun=${sun_sign} moon=${moon_sign} rising=${rising_sign}` }),
        { status: 400, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } }
      );
    }

    const otherLang = language === "en" ? "tr" : "en";

    // The Loved-One flow scopes caching/charging to loved_one_id (rows are
    // immutable once created — no version dimension needed). The self flow
    // scopes to birth_data_version, read server-side so the client can't
    // spoof it — birth data can change (see edit_birth_data RPC), and older
    // versions are left in place as history.
    const mapsTable = lovedOneId ? "loved_one_birth_maps" : "birth_maps";
    let scopeFilter: Record<string, string | number>;

    if (lovedOneId) {
      const { data: lovedOne, error: lovedOneError } = await supabase
        .from("loved_ones")
        .select("id")
        .eq("id", lovedOneId)
        .eq("user_id", userId)
        .maybeSingle();

      if (lovedOneError) throw new Error(`STEP_LOVED_ONE_FETCH: ${lovedOneError.message}`);
      if (!lovedOne) {
        return new Response(
          JSON.stringify({ error: "loved_one_not_found" }),
          { status: 404, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } }
        );
      }
      scopeFilter = { loved_one_id: lovedOneId };
    } else {
      const { data: profileRow, error: profileError } = await supabase
        .from("profiles")
        .select("birth_data_version")
        .eq("id", userId)
        .single();

      if (profileError) throw new Error(`STEP_PROFILE_FETCH: ${profileError.message}`);
      scopeFilter = { user_id: userId, birth_data_version: profileRow.birth_data_version ?? 0 };
    }

    // Return cached map if already purchased for this scope and language —
    // no cost
    const { data: existing, error: existingError } = await supabase
      .from(mapsTable)
      .select("*")
      .match(scopeFilter)
      .eq("language", language)
      .maybeSingle();

    if (existingError) throw new Error(`STEP_CACHE_CHECK: ${existingError.message}`);

    if (existing) {
      // Also generate the other language in background if missing
      const { data: otherExists } = await supabase
        .from(mapsTable).select("id").match(scopeFilter).eq("language", otherLang).maybeSingle();
      if (!otherExists) {
        const birthYear = birth_date ? new Date(birth_date).getFullYear() : new Date().getFullYear();
        generateContent({ sunSign: sun_sign, moonSign: moon_sign, risingSign: rising_sign, mcSign: mc_sign ?? "", birthYear, birthCity: birth_city ?? "", language: otherLang })
          .then(c => supabase.from(mapsTable).insert({ user_id: userId, ...scopeFilter, content: c, language: otherLang }))
          .catch(e => console.error("Background other-lang birth map failed:", e));
      }
      return new Response(
        JSON.stringify({ cached: true, birth_map: existing }),
        { headers: { ...CORS_HEADERS, "Content-Type": "application/json" } }
      );
    }

    // Check if this scope already has a birth map in any language (already
    // paid for it)
    const { data: anyExisting } = await supabase
      .from(mapsTable).select("id").match(scopeFilter).limit(1).maybeSingle();

    if (!anyExisting) {
      // First-time purchase — atomically deduct stardust
      const { data: spendOk, error: spendError } = await supabase.rpc("spend_stardust", {
        p_user_id: userId,
        p_amount: BIRTH_MAP_COST,
        p_description: lovedOneId ? "Cosmic Fingerprint: Birth Map (Loved One)" : "Cosmic Fingerprint: Birth Map",
      });

      if (spendError) throw new Error(`STEP_SPEND: ${spendError.message}`);
      if (spendOk === false || spendOk === null) {
        return new Response(
          JSON.stringify({ error: "insufficient_stardust" }),
          { status: 402, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } }
        );
      }
    }
    // else: already paid — generate additional language for free

    const birthYear = birth_date
      ? new Date(birth_date).getFullYear()
      : new Date().getFullYear();

    const genParams = {
      sunSign: sun_sign, moonSign: moon_sign, risingSign: rising_sign,
      mcSign: mc_sign ?? "", birthYear, birthCity: birth_city ?? "",
    };

    // Generate ONLY the primary language synchronously so we can respond fast.
    // The secondary language is generated in the background after we respond.
    let content: Record<string, unknown>;
    try {
      content = await generateContent({ ...genParams, language });
    } catch (genErr) {
      if (!anyExisting) {
        try {
          await supabase.rpc("earn_stardust", {
            p_user_id: userId, p_amount: BIRTH_MAP_COST,
            p_type: "refund", p_description: "Refund: birth map generation failed",
          });
        } catch (refundErr) {
          console.error("Refund failed after generation error:", refundErr);
        }
      }
      throw new Error(`STEP_GEMINI: ${genErr instanceof Error ? genErr.message : String(genErr)}`);
    }

    const { data: inserted, error: insertError } = await supabase
      .from(mapsTable)
      .insert({ user_id: userId, ...scopeFilter, content, language })
      .select()
      .single();

    if (insertError) {
      if (!anyExisting) {
        try {
          await supabase.rpc("earn_stardust", {
            p_user_id: userId, p_amount: BIRTH_MAP_COST,
            p_type: "refund", p_description: "Refund: birth map insert failed",
          });
        } catch (refundErr) {
          console.error("Refund failed after insert error:", refundErr);
        }
      }
      throw new Error(`STEP_INSERT: ${insertError.message} (code: ${insertError.code})`);
    }

    // Check if other language already exists, then kick off background generation.
    // We do NOT await this — the response is returned immediately above.
    const { data: otherExists } = await supabase
      .from(mapsTable).select("id").match(scopeFilter).eq("language", otherLang).maybeSingle();

    if (!otherExists) {
      generateContent({ ...genParams, language: otherLang })
        .then((otherContent) =>
          supabase.from(mapsTable)
            .insert({ user_id: userId, ...scopeFilter, content: otherContent, language: otherLang })
        )
        .catch((e: unknown) => console.error("Background other-lang generation failed:", e));
    }

    return new Response(
      JSON.stringify({ cached: false, birth_map: inserted }),
      { headers: { ...CORS_HEADERS, "Content-Type": "application/json" } }
    );
  } catch (error) {
    const msg = error instanceof Error ? error.message : JSON.stringify(error);
    console.error("generate-birth-map error:", msg);
    return new Response(
      JSON.stringify({ error: msg }),
      { status: 500, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } }
    );
  }
});
