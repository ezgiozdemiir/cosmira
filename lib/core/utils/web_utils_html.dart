import 'dart:async';

import 'package:web/web.dart' as web;

void webRedirect(String url) => web.window.location.href = url;

bool get isInPopup => web.window.opener != null;

void closePopup() => web.window.close();

/// Opens the OAuth URL in a popup window and waits until the popup closes.
/// When the popup completes OAuth, it closes itself (see main.dart).
/// Supabase then stores the session in localStorage, which the parent tab
/// picks up after reloading.
Future<void> openOAuthPopupAndWait(String url) async {
  final popup = web.window.open(
    url,
    'cosmira_auth',
    'width=500,height=700,top=100,left=200',
  );
  if (popup == null) {
    // Popup blocked — fall back to same-tab redirect.
    web.window.location.href = url;
    return;
  }
  while (!popup.closed) {
    await Future.delayed(const Duration(milliseconds: 500));
  }
  // Session is now in localStorage (written by popup's Supabase init).
  // Reload so this tab's Supabase client picks it up from storage.
  web.window.location.reload();
}
