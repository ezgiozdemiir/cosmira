import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web/web.dart' as web;

void webRedirect(String url) => web.window.location.href = url;

bool get isInPopup => web.window.opener != null;

void closePopup() => web.window.close();

/// Hard-reloads the current page so that Supabase re-reads the session
/// from localStorage (e.g. after another tab wrote it via email confirmation).
void reloadPage() => web.window.location.reload();

/// Returns the raw session JSON at [key] in localStorage, or null if absent.
/// Supabase Flutter stores the session at "sb-{projectRef}-auth-token".
String? readLocalStorage(String key) {
  final value = web.window.localStorage.getItem(key);
  if (value == null || value.isEmpty || value == 'null') return null;
  return value;
}

/// Returns all localStorage keys as a newline-separated string.
String dumpLocalStorageKeys() {
  final keys = <String>[];
  final len = web.window.localStorage.length;
  for (int i = 0; i < len; i++) {
    final k = web.window.localStorage.key(i);
    if (k != null) keys.add(k);
  }
  return keys.isEmpty ? '(empty)' : keys.join('\n');
}

/// Returns the PKCE [code] query parameter from the current URL, or null.
String? getUrlQueryCode() =>
    Uri.parse(web.window.location.href).queryParameters['code'];

/// Removes the [code] query parameter from the browser URL without reloading.
void clearUrlCode() {
  final uri = Uri.parse(web.window.location.href);
  if (!uri.queryParameters.containsKey('code')) return;
  final newParams = Map<String, String>.from(uri.queryParameters)..remove('code');
  final newUri = uri.replace(queryParameters: newParams.isEmpty ? null : newParams);
  web.window.history.replaceState(null, '', newUri.toString());
}

/// GotrueAsyncStorage backed by raw window.localStorage (no "flutter." prefix).
/// This ensures the PKCE code_verifier is in the same storage as the session
/// and is visible to any same-origin tab — unlike SharedPreferences which adds
/// a "flutter." prefix and may not be shared reliably across page loads.
class _WebGotrueStorage extends GotrueAsyncStorage {
  const _WebGotrueStorage();

  @override
  Future<String?> getItem({required String key}) async {
    final v = web.window.localStorage.getItem(key);
    return (v == null || v.isEmpty) ? null : v;
  }

  @override
  Future<void> setItem({required String key, required String value}) async =>
      web.window.localStorage.setItem(key, value);

  @override
  Future<void> removeItem({required String key}) async =>
      web.window.localStorage.removeItem(key);
}

GotrueAsyncStorage? get pkceStorage => const _WebGotrueStorage();

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
