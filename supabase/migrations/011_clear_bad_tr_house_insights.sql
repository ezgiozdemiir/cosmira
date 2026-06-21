-- Migration 011: Remove Turkish house_insights rows that have Turkish sign names.
-- These were generated before the edge function was fixed to keep sign in English.
-- The app will regenerate them correctly on next load.
DELETE FROM public.house_insights
WHERE language = 'tr'
  AND content::text ~* '"sign"\s*:\s*"(koç|boğa|ikizler|yengeç|aslan|başak|terazi|akrep|yay|oğlak|kova|balık)"';
