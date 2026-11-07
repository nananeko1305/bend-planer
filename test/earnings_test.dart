import 'package:bend_planer/models/gig.dart';
import 'package:bend_planer/models/gig_draft.dart';
import 'package:bend_planer/models/report.dart';
import 'package:bend_planer/money/money.dart';
import 'package:flutter_test/flutter_test.dart';

Gig gig(
  String date, {
  int price = 150000,
  List<String> players = const ['ana', 'bob'],
  TipSplit split = TipSplit.equal,
  int? tip,
  Map<String, int> tips = const {},
  Currency currency = Currency.eur,
  bool cancelled = false,
}) => Gig(
  id: 'g$date$price',
  ownerId: 'ana',
  draft: GigDraft(
    date: date,
    start: '20:00',
    priceMinor: price,
    currency: currency,
    tipSplit: split,
    players: players,
  ),
  tipMinor: tip,
  tips: tips,
  cancelled: cancelled,
  createdAt: DateTime(2026),
);

void main() {
  final now = DateTime(2026, 11, 7);

  test('the agreed price splits evenly over the players and adds up', () {
    final shares = gig(
      '2026-10-03',
      price: 100000,
      players: ['ana', 'bob', 'cia'],
    ).priceSharesWith(const []);
    expect(shares, {'ana': 33334, 'bob': 33333, 'cia': 33333});
    expect(shares.values.reduce((a, b) => a + b), 100000);
  });

  test('a gig from before "Ko svira" counts the band as it is now', () {
    final old = gig('2026-10-03', price: 90000, players: const [], tip: 3000);
    expect(old.priceSharesWith(['ana', 'bob', 'cia']), {
      'ana': 30000,
      'bob': 30000,
      'cia': 30000,
    });
    expect(old.tipSharesWith(['ana', 'bob', 'cia']), {
      'ana': 1000,
      'bob': 1000,
      'cia': 1000,
    });
    expect(old.tipShares, isEmpty);
  });

  test('my month: price part plus my tips, across both ways and tips only', () {
    final r = MonthReport.of(
      [
        gig('2026-10-03', tip: 10000), // 750 + 50 each
        gig(
          '2026-10-10',
          price: 0,
          split: TipSplit.own,
          tips: {'ana': 12000, 'bob': 3000},
        ),
        gig(
          '2026-10-17',
          players: ['bob'],
          currency: Currency.rsd,
          price: 3000000,
        ),
        gig('2026-10-24', cancelled: true),
      ],
      DateTime(2026, 10),
      now,
    );
    final ana = r.mine('ana');
    expect(ana.total, {Currency.eur: 75000 + 5000 + 12000});
    expect(ana.fromPrice, {Currency.eur: 75000});
    expect(ana.tips, {Currency.eur: 17000});
    expect(ana.gigs, 2);
    expect(ana.average, {Currency.eur: 46000});
    final bob = r.mine('bob');
    expect(bob.gigs, 3);
    expect(bob.total, {
      Currency.eur: 75000 + 5000 + 3000,
      Currency.rsd: 3000000,
    });
    // Bob earned more once his dinars count (on the rough scale, for order only).
    expect(r.membersByEarnings.first.key, 'bob');
    expect(r.mine('nobody').gigs, 0);
  });

  test('a year: the whole year, month by month, and next year booked', () {
    final r = MonthReport.ofYear(
      [
        gig('2026-01-15'),
        gig('2026-01-20', price: 50000),
        gig('2026-11-07'),
        gig('2025-12-31'),
        gig('2027-03-01'),
      ],
      2026,
      now,
    );
    expect(r.yearly, isTrue);
    expect(r.gigs, 3);
    expect(r.agreed, {Currency.eur: 350000});
    expect(r.byMonth[0], {Currency.eur: 200000});
    expect(r.byMonth[10], {Currency.eur: 150000});
    expect(r.byMonth[5], isEmpty);
    expect(r.nextGigs, 1);
    expect(r.mine('ana').gigs, 3);
  });
}
