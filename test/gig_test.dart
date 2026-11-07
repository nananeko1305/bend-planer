import 'package:bend_planer/models/day_key.dart';
import 'package:bend_planer/models/gig.dart';
import 'package:bend_planer/models/gig_draft.dart';
import 'package:bend_planer/money/money.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  final now = DateTime(2026, 11, 7, 18);

  group('status', () {
    test('today and later is upcoming, whatever the hour', () {
      expect(gigOn('2026-11-07').statusOn(now), GigStatus.upcoming);
      expect(gigOn('2026-11-14').statusOn(now), GigStatus.upcoming);
    });

    test('a played gig with a tip waits for it until entered', () {
      expect(gigOn('2026-11-06').statusOn(now), GigStatus.awaitingTip);
      expect(gigOn('2026-11-06', tip: 0).statusOn(now), GigStatus.done);
      expect(gigOn('2026-11-06', hasTip: false).statusOn(now), GigStatus.done);
    });

    test('cancelled wins over everything', () {
      expect(gigOn('2026-11-06', cancelled: true).statusOn(now), GigStatus.cancelled);
      expect(gigOn('2026-11-14', cancelled: true).statusOn(now), GigStatus.cancelled);
    });

    test('days from today count calendar days', () {
      expect(gigOn('2026-11-07').daysFrom(now), 0);
      expect(gigOn('2026-11-08').daysFrom(DateTime(2026, 11, 7, 23, 59)), 1);
      // Across the end of summer time.
      expect(gigOn('2026-10-26').daysFrom(DateTime(2026, 10, 24, 12)), 2);
    });
  });

  group('writes', () {
    const draft = GigDraft(date: '2026-11-14', start: '20:00', priceMinor: 150000);

    test('a new gig carries exactly what the rules require', () {
      final map = Gig.newDocMap(draft, 'ana');
      expect(map.keys.toSet(), {
        'date', 'start', 'end', 'type', 'venue', 'city', 'address',
        'clientName', 'clientPhone', 'priceMinor', 'currency',
        'depositMinor', 'depositHolder', 'hasTip', 'notes',
        'ownerId', 'tipMinor', 'tipBy', 'cancelled', 'rev', 'updatedBy',
        'createdAt', 'updatedAt',
      });
      expect(map['rev'], 1);
      expect(map['tipMinor'], isNull);
      expect(map['currency'], 'EUR');
    });

    test('an edit bumps the revision and drops a tip that is gone', () {
      final gig = gigOn('2026-11-14', tip: 2000);
      final map = gig.editMap(
        const GigDraft(date: '2026-11-14', start: '21:00', priceMinor: 1, hasTip: false),
        'leader',
      );
      expect(map['rev'], 2);
      expect(map['updatedBy'], 'leader');
      expect(map.containsKey('tipMinor'), isTrue);
      expect(map['tipMinor'], isNull);
      expect(map.containsKey('ownerId'), isFalse);
    });

    test('no deposit means no holder', () {
      const d = GigDraft(date: '2026-11-14', start: '20:00', priceMinor: 1, depositHolder: 'x');
      expect(d.toMap()['depositHolder'], '');
    });
  });

  group('days and times', () {
    test('date keys round-trip', () {
      expect(dateKey(DateTime(2026, 3, 5)), '2026-03-05');
      expect(parseDateKey('2026-03-05'), DateTime(2026, 3, 5));
      expect(parseDateKey('5.3.2026'), isNull);
    });

    test('times typed in any common way', () {
      expect(parseTime('20'), '20:00');
      expect(parseTime('20.30'), '20:30');
      expect(parseTime('2030'), '20:30');
      expect(parseTime('9:5'), isNull);
      expect(parseTime('25:00'), isNull);
    });
  });

  group('money', () {
    test('whole amounts without decimals, others with', () {
      expect(formatMoney(150000, Currency.eur, 'sr-Latn'), '1.500 €');
      expect(formatMoney(150050, Currency.rsd, 'sr-Latn'), '1.500,50 RSD');
    });

    test('parsing the ways people type amounts', () {
      expect(parseMoney('1.500'), 150000);
      expect(parseMoney('1500,5'), 150050);
      expect(parseMoney('1 500 €'), 150000);
      expect(parseMoney('0'), isNull);
      expect(parseMoney('abc'), isNull);
    });
  });
}
