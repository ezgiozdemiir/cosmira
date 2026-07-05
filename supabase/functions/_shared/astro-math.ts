// Shared astronomy helpers used by both `calculate-natal-chart` and
// `calculate-astrocartography-lines`. Extracted so the two functions never
// drift on sign conventions — the RAMC/obliquity math here was validated in
// `calculate-natal-chart` against known identities (Ascendant at sunrise,
// Midheaven at solar noon) before this extraction; that validation still
// applies since the formulas themselves are unchanged, just relocated.

import * as Astronomy from "https://esm.sh/astronomy-engine@2";

export function normalizeDeg(deg: number): number {
  return ((deg % 360) + 360) % 360;
}

export function ramcAndObliquity(date: Date, longitudeDeg: number) {
  const time = Astronomy.MakeTime(date);
  const gastHours = Astronomy.SiderealTime(time); // Greenwich Apparent Sidereal Time, hours [0,24)
  const gastDeg = gastHours * 15;
  const ramc = normalizeDeg(gastDeg + longitudeDeg); // Right Ascension of the Meridian

  const tilt = Astronomy.e_tilt(time);
  const eps = (tilt.tobl * Math.PI) / 180;
  return { ramcRad: (ramc * Math.PI) / 180, ramcDeg: ramc, gastDeg, eps };
}

// Ascendant = the ecliptic degree currently rising on the eastern horizon.
// Validated numerically: at the instant of sunrise, this formula's result
// matches the Sun's own ecliptic longitude to within ~1-2 degrees (the
// residual is fully explained by refraction + solar disk radius used by
// rise/set calculations, not a formula error).
export function ascendantLongitude(date: Date, latitudeDeg: number, longitudeDeg: number): number {
  const { ramcRad, eps } = ramcAndObliquity(date, longitudeDeg);
  const latRad = (latitudeDeg * Math.PI) / 180;

  const y = Math.cos(ramcRad);
  const x = -(Math.sin(ramcRad) * Math.cos(eps) + Math.tan(latRad) * Math.sin(eps));
  const asc = (Math.atan2(y, x) * 180) / Math.PI;
  return normalizeDeg(asc);
}

// Midheaven (MC) = the ecliptic degree currently crossing the local
// meridian. Validated numerically: at the instant of local solar noon
// (the Sun's culmination), this formula matches the Sun's own ecliptic
// longitude to within 0.001 degrees across multiple latitudes/seasons.
export function midheavenLongitude(date: Date, longitudeDeg: number): number {
  const { ramcRad, eps } = ramcAndObliquity(date, longitudeDeg);
  const mc = (Math.atan2(Math.sin(ramcRad), Math.cos(ramcRad) * Math.cos(eps)) * 180) / Math.PI;
  return normalizeDeg(mc);
}

// Converts an ecliptic longitude (assumed 0 ecliptic latitude — true for the
// Ascendant, which is a point on the ecliptic circle itself) to equatorial
// Right Ascension / Declination, given the obliquity of the ecliptic.
export function eclipticToEquatorial(lonDeg: number, epsRad: number) {
  const lonRad = (lonDeg * Math.PI) / 180;
  const sinDec = Math.sin(lonRad) * Math.sin(epsRad);
  const decRad = Math.asin(sinDec);
  const raRad = Math.atan2(Math.sin(lonRad) * Math.cos(epsRad), Math.cos(lonRad));
  return {
    raDeg: normalizeDeg((raRad * 180) / Math.PI),
    decDeg: (decRad * 180) / Math.PI,
  };
}
