import 'package:bend_planer/services/sync_status.dart';
import 'package:bend_planer/widgets/sync_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

/// The banner stays below the status bar and over the content, never pushing
/// it (found on a phone: it covered the clock and moved the tab down).
void main() {
  tearDown(() => syncController.value = SyncPhase.idle);

  testWidgets('below the status bar, content does not move', (tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 30);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      inApp(
        const Stack(
          children: [
            Positioned.fill(child: SafeArea(child: Text('Header'))),
            SyncBanner(),
          ],
        ),
        locale: const Locale('en'),
      ),
    );
    final headerTop = tester.getTopLeft(find.text('Header')).dy;

    for (final phase in [SyncPhase.syncing, SyncPhase.done]) {
      syncController.value = phase;
      // The spinner never settles; wait out the switch animation.
      await tester.pump(const Duration(milliseconds: 400));
      final label = find.text(
        phase == SyncPhase.syncing ? 'Syncing...' : 'Synced',
      );
      expect(label, findsOneWidget);
      expect(tester.getTopLeft(label).dy, greaterThanOrEqualTo(30));
      expect(tester.getTopLeft(find.text('Header')).dy, headerTop);
    }
  });
}
