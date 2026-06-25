import 'package:supabase_flutter/supabase_flutter.dart';

void webRedirect(String url) {}
bool get isInPopup => false;
void closePopup() {}
Future<void> openOAuthPopupAndWait(String url) async {}
void reloadPage() {}
String? readLocalStorage(String key) => null;
String dumpLocalStorageKeys() => '(web only)';
String? getUrlQueryCode() => null;
void clearUrlCode() {}

// Non-web: use supabase_flutter's default SharedPreferences storage.
GotrueAsyncStorage? get pkceStorage => null;
