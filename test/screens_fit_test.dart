import 'package:bend_planer/l10n/locale_controller.dart';
import 'package:bend_planer/screens/gigs_tab.dart';
import 'package:bend_planer/screens/report_tab.dart';
import 'package:bend_planer/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

/// Every look, both languages, on a small phone: nothing may overflow.
void main() {
  final today = DateTime.now();
  String day(int offset) {
    final d = today.add(Duration(days: offset));
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  final gigs = [
    gigOn(day(0), id: 'tonight'),
    gigOn(day(-1), id: 'yesterday'),
    gigOn(day(6), id: 'later', hasTip: false),
    gigOn(day(-3), id: 'gone', cancelled: true),
  ];

  for (final skin in SkinId.values) {
    for (final locale in [kSerbianLatin, const Locale('en')]) {
      testWidgets('home and report fit 360 px: ${skin.name} ${locale.languageCode}', (tester) async {
        tester.view.physicalSize = const Size(360, 780);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final data = fakeData(gigs);

        await tester.pumpWidget(inApp(GigsTab(data: data, profile: me), skin: skin, locale: locale));
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.text(locale.languageCode == 'sr' ? 'Čeka bakšiš'.toUpperCase() : 'AWAITING TIP'), findsOneWidget);

        await tester.pumpWidget(inApp(ReportTab(data: data, profile: me), skin: skin, locale: locale));
        await tester.pump();
        expect(tester.takeException(), isNull);
      });
    }
  }
}
