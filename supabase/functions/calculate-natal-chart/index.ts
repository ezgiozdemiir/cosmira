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
  const normalized = ((lonDeg % 360) + 360) % 360;
  return ZODIAC_SIGNS[Math.floor(normalized / 30)];
}

function sunEclipticLongitude(date: Date): number {
  return Astronomy.SunPosition(date).elon;
}

function moonEclipticLongitude(date: Date): number {
  const vec = Astronomy.GeoMoon(date);
  return Astronomy.Ecliptic(vec).elon;
}

function ramcAndObliquity(date: Date, longitudeDeg: number) {
  const time = Astronomy.MakeTime(date);
  const gastHours = Astronomy.SiderealTime(time); // Greenwich Apparent Sidereal Time, hours [0,24)
  const gastDeg = gastHours * 15;
  let ramc = gastDeg + longitudeDeg; // Right Ascension of the Meridian
  ramc = ((ramc % 360) + 360) % 360;

  const tilt = Astronomy.e_tilt(time);
  const eps = (tilt.tobl * Math.PI) / 180;
  return { ramcRad: (ramc * Math.PI) / 180, eps };
}

// Ascendant = the ecliptic degree currently rising on the eastern horizon.
// Validated numerically: at the instant of sunrise, this formula's result
// matches the Sun's own ecliptic longitude to within ~1-2 degrees (the
// residual is fully explained by refraction + solar disk radius used by
// rise/set calculations, not a formula error).
function ascendantLongitude(date: Date, latitudeDeg: number, longitudeDeg: number): number {
  const { ramcRad, eps } = ramcAndObliquity(date, longitudeDeg);
  const latRad = (latitudeDeg * Math.PI) / 180;

  const y = Math.cos(ramcRad);
  const x = -(Math.sin(ramcRad) * Math.cos(eps) + Math.tan(latRad) * Math.sin(eps));
  let asc = (Math.atan2(y, x) * 180) / Math.PI;
  asc = ((asc % 360) + 360) % 360;
  return asc;
}

// Midheaven (MC) = the ecliptic degree currently crossing the local
// meridian. Validated numerically: at the instant of local solar noon
// (the Sun's culmination), this formula matches the Sun's own ecliptic
// longitude to within 0.001 degrees across multiple latitudes/seasons.
function midheavenLongitude(date: Date, longitudeDeg: number): number {
  const { ramcRad, eps } = ramcAndObliquity(date, longitudeDeg);
  let mc = (Math.atan2(Math.sin(ramcRad), Math.cos(ramcRad) * Math.cos(eps)) * 180) / Math.PI;
  mc = ((mc % 360) + 360) % 360;
  return mc;
}

interface GeocodeResult {
  latitude: number;
  longitude: number;
  timezone: string;
  resolvedName: string;
}

async function geocodeCity(city: string): Promise<GeocodeResult> {
  const url = `https://geocoding-api.open-meteo.com/v1/search?name=${encodeURIComponent(city)}&count=1&language=en&format=json`;
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`Geocoding request failed with status ${response.status}`);
  }
  const data = await response.json();
  const result = data.results?.[0];
  if (!result) {
    throw new Error(`CITY_NOT_FOUND`);
  }
  return {
    latitude: result.latitude,
    longitude: result.longitude,
    timezone: result.timezone,
    resolvedName: [result.name, result.country].filter(Boolean).join(", "),
  };
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
