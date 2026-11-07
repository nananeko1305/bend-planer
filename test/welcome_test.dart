import 'package:bend_planer/l10n/app_localizations.dart';
import 'package:bend_planer/l10n/locale_controller.dart';
import 'package:bend_planer/screens/welcome_screen.dart';
import 'package:bend_planer/services/first_run.dart';
import 'package:bend_planer/theme/app_colors.dart';
import 'package:bend_planer/theme/app_theme.dart';
import 'package:bend_planer/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The app root as main.dart builds it: the look and the language picked on
/// the welcome apply to everything at once.
Widget app({required VoidCallback onDone}) => AnimatedBuilder(
  animation: Listenable.merge([themeController, localeController]),
  builder: (context, _) => MaterialApp(
    theme: AppTheme.current,
    locale: localeController.locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: kSupportedLocales,
    localeListResolutionCallback: resolveLocale,
    home: WelcomeScreen(onDone: onDone),
  ),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() async {
    await themeController.select(SkinId.bina);
    await localeController.select(null);
  });

  void smallPhone(WidgetTester tester) {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('language, then look, then done', (tester) async {
    smallPhone(tester);
    var done = false;
    await tester.pumpWidget(app(onDone: () => done = true));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Srpski'));
    await tester.pumpAndSettle();
    expect(localeController.locale, kSerbianLatin);
    expect(find.text('Dalje'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Next'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Pick your look'), findsOneWidget);

    // Swiping to the next look switches the whole app to it.
    await tester.drag(find.byType(PageView).last, const Offset(-250, 0));
    await tester.pumpAndSettle();
    expect(themeController.skin, SkinId.neon);

    await tester.tap(find.text("Let's go"));
    expect(done, isTrue);
    expect(tester.takeException(), isNull);
  });

  for (final locale in [kSerbianLatin, const Locale('en')]) {
    for (final skin in SkinId.values) {
      testWidgets('fits 360x640: ${skin.name} ${locale.languageCode}', (
        tester,
      ) async {
        smallPhone(tester);
        await localeController.select(locale);
        await themeController.select(skin);
        await tester.pumpWidget(app(onDone: () {}));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }

  test('the welcome is shown once per phone', () async {
    expect(await welcomePending(), isTrue);
    await markWelcomed();
    expect(await welcomePending(), isFalse);
  });
}
