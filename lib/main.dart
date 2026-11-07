import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'l10n/locale_controller.dart';
import 'screens/auth_gate.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  _registerFontLicenses();
  await themeController.load();
  await localeController.load();
  runApp(const BendPlanerApp());
}

/// The bundled fonts come under the SIL Open Font License, which travels with
/// them: it shows on the licenses page.
void _registerFontLicenses() {
  const fonts = {
    'Unbounded': 'unbounded',
    'Manrope': 'manrope',
    'Tilt Neon': 'tiltneon',
    'Monoton': 'monoton',
    'Outfit': 'outfit',
    'Playfair Display': 'playfairdisplay',
  };
  LicenseRegistry.addLicense(() async* {
    for (final e in fonts.entries) {
      final text = await rootBundle.loadString(
        'assets/fonts/licenses/${e.value}-OFL.txt',
      );
      yield LicenseEntryWithLineBreaks([e.key], text);
    }
  });
}

class BendPlanerApp extends StatelessWidget {
  const BendPlanerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuild the whole app when the look or the language changes.
    return AnimatedBuilder(
      animation: Listenable.merge([themeController, localeController]),
      builder: (context, _) {
        return MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.current,
          locale: localeController.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: kSupportedLocales,
          localeListResolutionCallback: resolveLocale,
          builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
            value: AppTheme.overlayFor(themeController.colors),
            child: child!,
          ),
          home: const AuthGate(),
        );
      },
    );
  }
}
