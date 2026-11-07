import 'package:shared_preferences/shared_preferences.dart';

// Whether this phone has been through the welcome (language and look).
// Kept on the phone only, like the look and the language themselves.

const _key = 'welcome_done';

/// True until the welcome is finished on this phone.
Future<bool> welcomePending() async {
  final prefs = await SharedPreferences.getInstance();
  return !(prefs.getBool(_key) ?? false);
}

Future<void> markWelcomed() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_key, true);
}
