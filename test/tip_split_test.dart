import 'package:bend_planer/l10n/locale_controller.dart';
import 'package:bend_planer/models/app_user.dart';
import 'package:bend_planer/models/gig.dart';
import 'package:bend_planer/models/gig_draft.dart';
import 'package:bend_planer/models/report.dart';
import 'package:bend_planer/money/money.dart';
import 'package:bend_planer/theme/app_colors.dart';
import 'package:bend_planer/widgets/gig_card.dart';
import 'package:bend_planer/widgets/gig_tip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

/// A played gig with a tip, shared [split] among [players].
Gig played({
  TipSplit split = TipSplit.equal,
  List<String> players = const ['ana', 'bob', 'cia'],
  int? total,
  Map<String, int> tips = const {},
  String date = '2026-11-06',
  Currency currency = Currency.eur,
  int price = 100000,
}) => Gig(
  id: 'g$date',
  ownerId: 'ana',
  draft: GigDraft(
    date: date,
    start: '20:00',
    venue: 'Sala',
    priceMinor: price,
    currency: currency,
    tipSplit: split,
    players: players,
  ),
  tipMinor: total,
  tipBy: total == null ? '' : 'ana',
  tips: tips,
  createdAt: DateTime(2026),
);

void main() {
  final now = DateTime(2026, 11, 7, 18);

  group('shared equally', () {
    test('what does not divide goes a cent each to the first, and adds up', () {
      final shares = played(total: 10000).tipShares;
      expect(shares, {'ana': 3334, 'bob': 3333, 'cia': 3333});
      expect(shares.values.reduce((a, b) => a + b), 10000);
    });

    test('waits for the total, then is done', () {
      expect(played().statusOn(now), GigStatus.awaitingTip);
      expect(played().tipShares, isEmpty);
      expect(played(total: 0).statusOn(now), GigStatus.done);
      expect(played(total: 36000).tipTotal, 36000);
    });

    test('a gig from before 1.2 (nobody ticked) still has its total', () {
      final old = played(players: const [], total: 5000);
      expect(old.tipTotal, 5000);
      expect(old.tipShares, isEmpty);
    });
  });

  group('each their own', () {
    test('the total is the sum; done when every player entered, 0 too', () {
      final half = played(split: TipSplit.own, tips: {'ana': 10000});
      expect(half.tipTotal, 10000);
      expect(half.statusOn(now), GigStatus.awaitingTip);
      final all = played(
        split: TipSplit.own,
        tips: {'ana': 10000, 'bob': 5000, 'cia': 0},
      );
      expect(all.tipTotal, 15000);
      expect(all.statusOn(now), GigStatus.done);
      expect(all.totalMinor, 115000);
    });

    test('someone unticked after entering no longer counts', () {
      final g = played(
        split: TipSplit.own,
        players: const ['ana'],
        tips: {'ana': 100, 'bob': 900},
      );
      expect(g.tipTotal, 100);
      expect(g.tipShares, {'ana': 100});
      expect(g.tipComplete, isTrue);
    });

    test('the write changes one entry and names it', () {
      final map = Gig.ownTipMap('bob', 5000, 'ana');
      expect(map.keys.toSet(), {
        'tips.bob',
        'tipPlayer',
        'tipBy',
        'tipAnnounced',
        'updatedAt',
      });
      expect(map['tipPlayer'], 'bob');
      expect(map['tipBy'], 'ana');
    });
  });

  test('the report: band total and each member, both ways, per currency', () {
    final r = MonthReport.of(
      [
        played(date: '2026-10-03', total: 9000),
        played(
          date: '2026-10-10',
          split: TipSplit.own,
          tips: {'ana': 10000, 'bob': 0, 'cia': 2000},
        ),
        played(date: '2026-10-17', currency: Currency.rsd, total: 300000),
      ],
      DateTime(2026, 10),
      now,
    );
    expect(r.tips, {Currency.eur: 21000, Currency.rsd: 300000});
    expect(r.tipsByMember['ana'], {Currency.eur: 13000, Currency.rsd: 100000});
    expect(r.tipsByMember['bob'], {Currency.eur: 3000, Currency.rsd: 100000});
    expect(r.membersByEarnings.first.key, 'ana');
  });

  group('tips only', () {
    test('no agreed price: waits for the tip, then counts it alone', () {
      final g = played(price: 0);
      expect(g.tipOnly, isTrue);
      expect(g.statusOn(now), GigStatus.awaitingTip);
      final paid = played(price: 0, total: 12000);
      expect(paid.totalMinor, 12000);
      final r = MonthReport.of(
        [
          played(date: '2026-10-04', price: 0, total: 12000),
          played(date: '2026-10-05', total: 3000),
        ],
        DateTime(2026, 10),
        now,
      );
      expect(r.gigs, 2);
      expect(r.agreed, {Currency.eur: 100000});
      expect(r.tips, {Currency.eur: 15000});
    });

    for (final skin in SkinId.values) {
      for (final locale in [kSerbianLatin, const Locale('en')]) {
        testWidgets(
          'the card says so and fits 360 px: ${skin.name} ${locale.languageCode}',
          (tester) async {
            tester.view.physicalSize = const Size(360, 780);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.reset);
            final g = played(date: '2026-11-14', price: 0);
            await tester.pumpWidget(
              inApp(
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: GigCard(gig: g, now: now, onTap: () {}),
                ),
                skin: skin,
                locale: locale,
              ),
            );
            await tester.pump();
            expect(tester.takeException(), isNull);
            expect(
              find.text(locale.languageCode == 'sr' ? 'Za bakšiš' : 'For tips'),
              findsOneWidget,
            );
          },
        );
      }
    }
  });

  group('the tip card fits 360 px', () {
    const band = [
      me,
      AppUser(
        uid: 'bob',
        email: '',
        role: UserRole.member,
        disabled: false,
        firstName: 'Bogdan',
        lastName: 'Bogdanović',
      ),
      AppUser(
        uid: 'cia',
        email: '',
        role: UserRole.member,
        disabled: false,
        firstName: 'Cvijeta',
        lastName: 'Cvijetić',
      ),
    ];
    final gigs = {
      'equal': played(total: 10000),
      'own': played(split: TipSplit.own, tips: {'ana': 10000}),
      'none': played(),
    };
    for (final skin in SkinId.values) {
      for (final locale in [kSerbianLatin, const Locale('en')]) {
        for (final e in gigs.entries) {
          testWidgets('${e.key} ${skin.name} ${locale.languageCode}', (
            tester,
          ) async {
            tester.view.physicalSize = const Size(360, 780);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.reset);
            final data = fakeData([e.value], users: band);
            await tester.pumpWidget(
              inApp(
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: GigTipCard(
                    gig: e.value,
                    data: data,
                    profile: me,
                    played: true,
                  ),
                ),
                skin: skin,
                locale: locale,
              ),
            );
            await tester.pump();
            expect(tester.takeException(), isNull);
          });
        }
      }
    }
  });
}
