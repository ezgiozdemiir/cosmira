// Supabase Edge Function: Calculate Big Three (Sun / Moon / Rising signs)
// Called on-demand from the app right after a user enters/edits their
// birth date, time, and city. Pure computation — no DB writes here, the
// client saves the returned signs + coordinates onto its own profile row.
//
// Geocoding: Open-Meteo Geocoding API (free, no API key required).
// Astronomy: astronomy-engine (Sun/Moon ecliptic longitude, sidereal time,
// obliquity of the ecliptic) — the Ascendant is derived from the standard
// RAMC/obliquity/latitude formula, validated against sunrise = Ascendant
// identity before writing this function.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import * as Astronomy from "https://esm.sh/astronomy-engine@2";
import { DateTime } from "https://esm.sh/luxon@3";
import { ascendantLongitude, midheavenLongitude, normalizeDeg } from "../_shared/astro-math.ts";
import { geocodeCity } from "../_shared/geocode.ts";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const ZODIAC_SIGNS = [
  "aries", "taurus", "gemini", "cancer", "leo", "virgo",
  "libra", "scorpio", "sagittarius", "capricorn", "aquarius", "pisces",
];

function signFromLongitude(lonDeg: number): string {
  return ZODIAC_SIGNS[Math.floor(normalizeDeg(lonDeg) / 30)];
}

function sunEclipticLongitude(date: Date): number {
  return Astronomy.SunPosition(date).elon;
}

function moonEclipticLongitude(date: Date): number {
  const vec = Astronomy.GeoMoon(date);
  return Astronomy.Ecliptic(vec).elon;
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS_HEADERS });
  }

  try {
    const { birth_date, birth_time, birth_city } = await req.json();

    if (!birth_date || !birth_time || !birth_city) {
      return new Response(
        JSON.stringify({ error: "birth_date, birth_time, and birth_city are all required." }),
        { status: 400, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } }
      );
    }

    const geo = await geocodeCity(birth_city);

    const localDateTime = DateTime.fromISO(`${birth_date}T${birth_time}`, { zone: geo.timezone });
    if (!localDateTime.isValid) {
      throw new Error(`Could not interpret birth date/time: ${localDateTime.invalidReason}`);
    }
    const utcDate = localDateTime.toUTC().toJSDate();

    const sunLon = sunEclipticLongitude(utcDate);
    const moonLon = moonEclipticLongitude(utcDate);
    const ascLon = ascendantLongitude(utcDate, geo.latitude, geo.longitude);
    const mcLon = midheavenLongitude(utcDate, geo.longitude);

    return new Response(
      JSON.stringify({
        sun_sign: signFromLongitude(sunLon),
        moon_sign: signFromLongitude(moonLon),
        rising_sign: signFromLongitude(ascLon),
        mc_sign: signFromLongitude(mcLon),
        birth_lat: geo.latitude,
        birth_lng: geo.longitude,
        resolved_city: geo.resolvedName,
        timezone: geo.timezone,
      }),
      { headers: { ...CORS_HEADERS, "Content-Type": "application/json" } }
    );
  } catch (error) {
    const message = String(error);
    const status = message.includes("CITY_NOT_FOUND") ? 400 : 500;
    const friendly = message.includes("CITY_NOT_FOUND")
      ? "Could not find that city. Try a more specific name (e.g. 'Paris, France')."
      : message;
    return new Response(JSON.stringify({ error: friendly }), {
      status,
      headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
    });
  }
});
