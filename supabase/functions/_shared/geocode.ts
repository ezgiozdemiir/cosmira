// Shared geocoding helper used by any edge function that needs to turn a
// birth city into coordinates + IANA timezone. Open-Meteo Geocoding API
// (free, no API key required) — extracted from `calculate-natal-chart` so
// `calculate-astrocartography-lines` can reuse the exact same proven call.

export interface GeocodeResult {
  latitude: number;
  longitude: number;
  timezone: string;
  resolvedName: string;
}

export async function geocodeCity(city: string): Promise<GeocodeResult> {
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
