import 'package:bend_planer/theme/app_colors.dart';
import 'package:bend_planer/theme/theme_controller.dart';
import 'package:bend_planer/widgets/skin_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support.dart';

/// The check follows the look that was picked, even though the parent keeps
/// the same const SkinPicker (found on a phone: the look changed, the check
/// stayed on Bina).
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() => themeController.select(SkinId.bina));

  String checked(WidgetTester tester) {
    final preview = find.ancestor(
      of: find.byIcon(Icons.check_circle_rounded),
      matching: find.byWidgetPredicate(
        (w) => w.runtimeType.toString() == '_Preview',
      ),
    );
    return (tester.widget(preview) as dynamic).name as String;
  }

  testWidgets('the check moves to the look tapped', (tester) async {
    await tester.pumpWidget(
      inApp(const SkinPicker(), locale: const Locale('en')),
    );
    expect(checked(tester), 'Stage');

    await tester.tap(find.text('Neon'));
    await tester.pumpAndSettle();
    expect(themeController.skin, SkinId.neon);
    expect(checked(tester), 'Neon');

    await tester.tap(find.text('Gold'));
    await tester.pumpAndSettle();
    expect(checked(tester), 'Gold');
  });
}
