// Supabase Edge Function: Calculate real Astrocartography lines.
//
// Astrocartography previously showed IDENTICAL static content to every
// user. This computes genuine AC (rising) / DC (setting) / MC (culminating)
// / IC (anti-culminating) line paths for 8 planets, from each person's
// actual birth date/time/city — pure deterministic astronomy, no AI cost,
// cached permanently (see migration 019) since the input never changes
// (self is re-scoped by birth_data_version when birth data is edited;
// loved_ones rows are immutable).
//
// Astronomy: astronomy-engine, same library already used and validated in
// calculate-natal-chart. Per-planet RA/Dec are computed as geocentric
// equator-of-date coordinates: GeoVector() (J2000 equatorial) rotated to
// equator-of-date via Rotation_EQJ_EQD(), then read off via
// EquatorFromVector() — the documented astronomy-engine pattern for this
// conversion.
//
// MC/IC: a planet culminates where local sidereal time equals its RA, i.e.
// longitude = RA - GAST (IC is the opposite meridian, +180).
// AC/DC: for a sweep of latitudes, solve the standard rise/set hour-angle
// equation H0 = acos(-tan(lat)*tan(dec)) (undefined => circumpolar, skipped
// at that latitude); rising uses H = -H0, setting uses H = +H0, matching
// the local-sidereal-time identity LST = GAST + longitude = RA + H.
//
// Validation (runs on every request, not just at dev time): the person's
// own Ascendant — already computed and validated elsewhere in this
// codebase — is by definition exactly on the horizon at their own birth
// latitude/longitude at the birth instant. Converting it to equatorial
// coordinates and running it through this exact AC-line formula must
// reproduce their own birth coordinates; if it doesn't, something is wrong
// with the sign convention and we fail loudly rather than cache bad data.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import * as Astronomy from "https://esm.sh/astronomy-engine@2";
import { DateTime } from "https://esm.sh/luxon@3";
import { ascendantLongitude, ramcAndObliquity, eclipticToEquatorial, normalizeDeg } from "../_shared/astro-math.ts";
import { geocodeCity } from "../_shared/geocode.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const ENGINE_VERSION = "v1";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const PLANET_BODIES: Record<string, Astronomy.Body> = {
  sun: Astronomy.Body.Sun,
  moon: Astronomy.Body.Moon,
  venus: Astronomy.Body.Venus,
  mars: Astronomy.Body.Mars,
  jupiter: Astronomy.Body.Jupiter,
  saturn: Astronomy.Body.Saturn,
  uranus: Astronomy.Body.Uranus,
  neptune: Astronomy.Body.Neptune,
};

interface PlanetLines {
  mc_lon: number;
  ic_lon: number;
  ac: [number, number][];
  dc: [number, number][];
}

function equatorOfDate(body: Astronomy.Body, date: Date) {
  const vecJ2000 = Astronomy.GeoVector(body, date, false);
  const rotation = Astronomy.Rotation_EQJ_EQD(date);
  const vecOfDate = Astronomy.RotateVector(rotation, vecJ2000);
  const eq = Astronomy.EquatorFromVector(vecOfDate);
  return { raDeg: eq.ra * 15, decDeg: eq.dec };
}

// H0 = hour angle at the horizon for a body of declination decDeg, at
// latitude latDeg. Returns null if the body is circumpolar (never crosses
// the horizon) at that latitude.
function horizonHourAngleDeg(latDeg: number, decDeg: number): number | null {
  const latRad = (latDeg * Math.PI) / 180;
  const decRad = (decDeg * Math.PI) / 180;
  const tanProduct = Math.tan(latRad) * Math.tan(decRad);
  if (Math.abs(tanProduct) > 1) return null;
  return (Math.acos(-tanProduct) * 180) / Math.PI;
}

function computeLinesForBody(raDeg: number, decDeg: number, gastDeg: number): PlanetLines {
  const mcLon = normalizeDeg(raDeg - gastDeg);
  const icLon = normalizeDeg(mcLon + 180);

  const ac: [number, number][] = [];
  const dc: [number, number][] = [];

  for (let lat = -66; lat <= 66; lat += 2) {
    const h0Deg = horizonHourAngleDeg(lat, decDeg);
    if (h0Deg === null) continue;
    ac.push([lat, normalizeDeg(raDeg - h0Deg - gastDeg)]); // rising: H = -H0
    dc.push([lat, normalizeDeg(raDeg + h0Deg - gastDeg)]); // setting: H = +H0
  }

  return { mc_lon: mcLon, ic_lon: icLon, ac, dc };
}

// See file header — proves the AC-line formula/sign-convention are correct
// by checking it reproduces the person's own birth coordinates via their
// own (independently, already-validated) Ascendant.
function validateAgainstOwnAscendant(
  utcDate: Date,
  birthLatDeg: number,
  birthLngDeg: number
): boolean {
  const { gastDeg, eps } = ramcAndObliquity(utcDate, birthLngDeg);
  const ascLon = ascendantLongitude(utcDate, birthLatDeg, birthLngDeg);
  const { raDeg, decDeg } = eclipticToEquatorial(ascLon, eps);

  const h0Deg = horizonHourAngleDeg(birthLatDeg, decDeg);
  if (h0Deg === null) return false;

  const computedLng = normalizeDeg(raDeg - h0Deg - gastDeg);
  const target = normalizeDeg(birthLngDeg);
  const diff = Math.min(Math.abs(computedLng - target), 360 - Math.abs(computedLng - target));
  return diff < 0.5; // degrees — generous tolerance for a hard identity check
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

    const { birth_date, birth_time, birth_city, loved_one_id } = await req.json();
    if (!birth_date || !birth_time || !birth_city) {
      return new Response(
        JSON.stringify({ error: "birth_date, birth_time, and birth_city are all required." }),
        { status: 400, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } }
      );
    }

    const lovedOneId = loved_one_id || null;
    const linesTable = lovedOneId ? "loved_one_astrocartography_lines" : "astrocartography_lines";
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

    // Cache check — this computation is deterministic given birth data, so
    // a hit never needs recomputation (unlike AI content, there's no
    // "missing language" case to fill in).
    const { data: existing, error: existingError } = await supabase
      .from(linesTable)
      .select("content")
      .match(scopeFilter)
      .eq("engine_version", ENGINE_VERSION)
      .maybeSingle();

    if (existingError) throw new Error(`STEP_CACHE_CHECK: ${existingError.message}`);

    if (existing) {
      return new Response(
        JSON.stringify({ cached: true, lines: existing.content }),
        { headers: { ...CORS_HEADERS, "Content-Type": "application/json" } }
      );
    }

    const geo = await geocodeCity(birth_city);
    const localDateTime = DateTime.fromISO(`${birth_date}T${birth_time}`, { zone: geo.timezone });
    if (!localDateTime.isValid) {
      throw new Error(`Could not interpret birth date/time: ${localDateTime.invalidReason}`);
    }
    const utcDate = localDateTime.toUTC().toJSDate();

    if (!validateAgainstOwnAscendant(utcDate, geo.latitude, geo.longitude)) {
      throw new Error("STEP_VALIDATE: astrocartography formula failed self-check against natal Ascendant");
    }

    const { gastDeg } = ramcAndObliquity(utcDate, geo.longitude);

    const planets: Record<string, PlanetLines> = {};
    for (const [name, bodyEnum] of Object.entries(PLANET_BODIES)) {
      const { raDeg, decDeg } = equatorOfDate(bodyEnum, utcDate);
      planets[name] = computeLinesForBody(raDeg, decDeg, gastDeg);
    }

    const content = { engine_version: ENGINE_VERSION, planets };

    const { error: insertError } = await supabase
      .from(linesTable)
      .insert({ user_id: userId, ...scopeFilter, content, engine_version: ENGINE_VERSION });

    if (insertError) throw new Error(`STEP_INSERT: ${insertError.message} (code: ${insertError.code})`);

    return new Response(
      JSON.stringify({ cached: false, lines: content }),
      { headers: { ...CORS_HEADERS, "Content-Type": "application/json" } }
    );
  } catch (error) {
    const message = String(error instanceof Error ? error.message : error);
    const status = message.includes("CITY_NOT_FOUND") ? 400 : 500;
    const friendly = message.includes("CITY_NOT_FOUND")
      ? "Could not find that city. Try a more specific name (e.g. 'Paris, France')."
      : message;
    console.error("calculate-astrocartography-lines error:", message);
    return new Response(JSON.stringify({ error: friendly }), {
      status,
      headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
    });
  }
});
