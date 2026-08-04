-- ============================================================
-- Migration 025: enable realtime on notification_log.
--
-- unreadNotificationsCountProvider (lib/features/notifications/presentation/
-- providers/unread_notifications_provider.dart) uses .stream() to drive the
-- bell badge on the home screen. That only receives live postgres_changes
-- events for tables added to the supabase_realtime publication -- and
-- notification_log was never added, so the client got the initial unread
-- count but never saw the UPDATE when markNotificationsReadProvider marked
-- rows read. Result: the badge stayed lit until the app restarted and
-- re-fetched from scratch.
-- ============================================================

ALTER PUBLICATION supabase_realtime ADD TABLE public.notification_log;
