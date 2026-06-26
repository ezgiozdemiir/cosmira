// Supabase Edge Function: Generate Premium AI Report
// Called on-demand when user spends Stardust
// Uses OpenAI for deep analysis, caches result

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const REPORT_PROMPTS: Record<string, string> = {
  compatibility_deep: `You are an expert astrologer for the luxury app Cosmira. Analyze the synastry between two natal charts.
Provide deep analysis in JSON format with fields:
- overall_analysis (3-4 paragraphs)
- emotional_alignment_analysis (text)
- communication_analysis (text)
- karmic_bond_analysis (text)
- intimacy_analysis (text)
- soulmate_indicators (array of strings)
- conflict_warnings (array of strings)
- long_term_advice (text)
- cosmic_summary (1 elegant sentence)
Tone: premium, wise, empowering. Never generic or childish.`,

  yearly_destiny: `You are an expert astrologer for the luxury app Cosmira. Generate a detailed yearly destiny report.
Provide analysis in JSON format with fields:
- yearly_theme (text)
- quarterly_forecasts (array of {quarter, theme, opportunities, challenges})
- career_outlook (text)
- love_forecast (text)
- health_energy (text)
- spiritual_growth (text)
- key_dates (array of {date, significance})
- cosmic_advice (text)
Tone: empowering, specific, luxurious. Never vague or generic.`,

  astrocartography: `You are an expert astrocartographer for the luxury app Cosmira. Analyze planetary lines and locations.
Provide analysis in JSON format with fields:
- overview (text)
- best_cities (array of {city, country, reason, energy_type, score})
- love_locations (array of {city, country, reason})
- career_locations (array of {city, country, reason})
- spiritual_locations (array of {city, country, reason})
- places_to_avoid (array of {city, country, reason})
- travel_timing (text)
Tone: insightful, practical, luxurious.`,
};

const STARDUST_COSTS: Record<string, number> = {
  compatibility_deep: 30,
  yearly_destiny: 50,
  astrocartography: 40,
};

const CACHE_TTL_DAYS: Record<string, number> = {
  compatibility_deep: 90,
  yearly_destiny: 365,
  astrocartography: 180,
};

function generateCacheKey(reportType: string, inputData: any): string {
  const input = JSON.stringify({ reportType, ...inputData });
  const encoder = new TextEncoder();
  const data = encoder.encode(input);
  let hash = 0;
  for (let i = 0; i < data.length; i++) {
    hash = ((hash << 5) - hash) + data[i];
    hash |= 0;
  }
  return `${reportType}_${Math.abs(hash).toString(36)}`;
}

serve(async (req) => {
  try {
    const { user_id, report_type, input_data } = await req.json();

    if (!user_id || !report_type || !input_data) {
      return new Response(JSON.stringify({ error: "Missing required fields" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);
    const cacheKey = generateCacheKey(report_type, input_data);

    // 1. Check cache
    const { data: cached } = await supabase
      .from("cached_reports")
      .select("*")
      .eq("cache_key", cacheKey)
      .gte("valid_until", new Date().toISOString())
      .single();

    if (cached) {
      return new Response(JSON.stringify({ cached: true, report: cached }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    // 2. Spend Stardust
    const cost = STARDUST_COSTS[report_type] || 20;
    const { data: spendResult } = await supabase.rpc("spend_stardust", {
      p_user_id: user_id,
      p_amount: cost,
      p_description: `Premium ${report_type} report`,
    });

    if (!spendResult) {
      return new Response(JSON.stringify({ error: "Insufficient Stardust" }), {
        status: 402,
        headers: { "Content-Type": "application/json" },
      });
    }

    const refund = async (reason: string) => {
      try {
        await supabase.rpc("earn_stardust", {
          p_user_id: user_id, p_amount: cost,
          p_type: "refund", p_description: `Refund: ${reason}`,
        });
      } catch (refundErr) {
        console.error("Refund failed:", refundErr);
      }
    };

    // 3. Generate with OpenAI
    const systemPrompt = REPORT_PROMPTS[report_type] || REPORT_PROMPTS.yearly_destiny;
    const userPrompt = `Input data:\n${JSON.stringify(input_data, null, 2)}\n\nReturn ONLY valid JSON.`;

    let openaiData: Record<string, unknown>;
    try {
      const openaiResponse = await fetch("https://api.openai.com/v1/chat/completions", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${OPENAI_API_KEY}`,
        },
        body: JSON.stringify({
          model: "gpt-4o-mini",
          messages: [
            { role: "system", content: systemPrompt },
            { role: "user", content: userPrompt },
          ],
          temperature: 0.7,
          max_tokens: 2000,
          response_format: { type: "json_object" },
        }),
      });
      openaiData = await openaiResponse.json();
    } catch (aiErr) {
      await refund(`${report_type} generation failed`);
      throw aiErr;
    }

    const content = JSON.parse((openaiData.choices as {message:{content:string}}[])[0].message.content);
    const usage = openaiData.usage as {prompt_tokens:number; completion_tokens:number};

    // Estimate cost (gpt-4o-mini pricing)
    const inputCost = (usage.prompt_tokens / 1_000_000) * 0.15;
    const outputCost = (usage.completion_tokens / 1_000_000) * 0.6;
    const totalCost = inputCost + outputCost;

    // 4. Cache the report
    const ttlDays = CACHE_TTL_DAYS[report_type] || 90;
    const validUntil = new Date();
    validUntil.setDate(validUntil.getDate() + ttlDays);

    const { data: report, error } = await supabase
      .from("cached_reports")
      .insert({
        user_id,
        report_type,
        ai_provider: "openai",
        cache_key: cacheKey,
        content,
        stardust_cost: cost,
        generation_cost_usd: totalCost,
        input_tokens: usage.prompt_tokens,
        output_tokens: usage.completion_tokens,
        valid_until: validUntil.toISOString(),
      })
      .select()
      .single();

    if (error) {
      await refund(`${report_type} insert failed`);
      throw error;
    }

    return new Response(JSON.stringify({ cached: false, report }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("Error generating premium report:", error);
    return new Response(JSON.stringify({ error: String(error) }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
