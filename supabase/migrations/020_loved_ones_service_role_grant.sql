-- ============================================================
-- Migration 020: Fix missing service_role grant on loved_ones.
--
-- Migration 018 granted SELECT/INSERT/DELETE on loved_ones to
-- `authenticated` only. The `generate-birth-map` and
-- `calculate-astrocartography-lines` edge functions query loved_ones via
-- the SERVICE ROLE client to verify ownership before generating a report
-- for a Loved One — service_role bypasses Row Level Security, but NOT
-- table-level GRANTs, so every such lookup failed with
-- "permission denied for table loved_ones", surfacing to the app as a
-- generic Server Failure whenever generating a report for a saved Loved
-- One. loved_one_birth_maps / loved_one_astrocartography_unlocks /
-- loved_one_astrocartography_lines already correctly granted service_role
-- in their own migrations — this was simply missed for the parent table.
-- ============================================================

GRANT SELECT, INSERT, DELETE ON public.loved_ones TO service_role;
