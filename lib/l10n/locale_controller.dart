import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serbian, Latin script. Plain `sr` means Cyrillic to the date formats and
/// the date picker, which would put Cyrillic months in a Latin interface.
const Locale kSerbianLatin = Locale.fromSubtags(
  languageCode: 'sr',
  scriptCode: 'Latn',
);

/// The languages of the app.
const List<Locale> kSupportedLocales = [Locale('en'), kSerbianLatin];

/// Holds the language picked on this phone and persists it.
/// null = follow the phone; otherwise English or Serbian (Latin).
class LocaleController extends ChangeNotifier {
  static const _key = 'locale_code';

  Locale? _locale;
  Locale? get locale => _locale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    _locale = switch (code) {
      'sr' => kSerbianLatin,
      'en' => const Locale('en'),
      _ => null,
    };
    notifyListeners();
  }

  /// Saves the language code only; Serbian always comes back as Latin.
  Future<void> select(Locale? locale) async {
    _locale = locale?.languageCode == 'sr' ? kSerbianLatin : locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, locale.languageCode);
    }
  }
}

/// Languages close enough that Serbian (Latin) reads better than English.
const _serbianLike = {'sr', 'hr', 'bs', 'sh', 'cnr', 'me'};

/// Picks the app language for the phone's: any Serbian becomes Latin.
Locale resolveLocale(List<Locale>? phone, Iterable<Locale> supported) {
  for (final l in phone ?? const <Locale>[]) {
    if (_serbianLike.contains(l.languageCode)) return kSerbianLatin;
    if (l.languageCode == 'en') return const Locale('en');
  }
  return const Locale('en');
}

final LocaleController localeController = LocaleController();
