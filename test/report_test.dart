import 'package:bend_planer/models/app_user.dart';
import 'package:bend_planer/models/gig.dart';
import 'package:bend_planer/models/report.dart';
import 'package:bend_planer/money/money.dart';
import 'package:bend_planer/services/announcer.dart';
import 'package:bend_planer/services/worker_client.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  final now = DateTime(2026, 11, 7);

  test('a month: agreed, tips, totals per currency, cancelled apart', () {
    final r = MonthReport.of([
      gigOn('2026-10-03', id: 'a', tip: 35000),
      gigOn('2026-10-10', id: 'b', price: 90000, type: GigType.company, hasTip: false),
      gigOn('2026-10-17', id: 'c', price: 6000000, currency: Currency.rsd, tip: 500000),
      gigOn('2026-10-24', id: 'd', cancelled: true),
      gigOn('2026-10-31', id: 'e'),
      gigOn('2026-11-14', id: 'f'),
    ], DateTime(2026, 10), now);
    expect(r.gigs, 4);
    expect(r.cancelled, 1);
    expect(r.agreed, {Currency.eur: 390000, Currency.rsd: 6000000});
    expect(r.tips, {Currency.eur: 35000, Currency.rsd: 500000});
    expect(r.total[Currency.eur], 425000);
    expect(r.average[Currency.eur], 141667);
    expect(r.biggestTip!.id, 'a');
    expect(r.tipsPending, 1);
    expect(r.byType.first.type, GigType.wedding);
    expect(r.nextGigs, 1);
    expect(r.nextAgreed, {Currency.eur: 150000});
  });

  test('an empty month is empty', () {
    final r = MonthReport.of([], DateTime(2026, 10), now);
    expect(r.isEmpty, isTrue);
    expect(r.biggestTip, isNull);
  });

  group('announcements', () {
    Gig gig({required int rev, int pushRev = 0, String by = 'ana', int? tip, bool tipAnnounced = false}) => Gig(
      id: 'g',
      ownerId: 'ana',
      draft: gigOn('2026-11-14').draft,
      rev: rev,
      pushRev: pushRev,
      updatedBy: by,
      tipMinor: tip,
      tipBy: tip == null ? '' : by,
      tipAnnounced: tipAnnounced,
      createdAt: DateTime(2026),
    );

    List<String> pending(List<Gig> gigs, {String meId = 'ana', bool leader = false, List<AppUser> users = const []}) =>
        pendingAnnouncements(me: meId, leader: leader, gigs: gigs, users: users)
            .map((a) => a.key)
            .toList();

    test('my changes the worker has not caught up with', () {
      expect(pending([gig(rev: 1)]), ['gig:g:1']);
      expect(pending([gig(rev: 2, pushRev: 2)]), isEmpty);
      expect(pending([gig(rev: 2, by: 'bob')]), isEmpty);
    });

    test('a second edit is a new key', () {
      expect(pending([gig(rev: 3, pushRev: 2)]), ['gig:g:3']);
    });

    test('my tip, until announced', () {
      expect(pending([gig(rev: 1, pushRev: 1, tip: 2000)]), ['tip:g:2000']);
      expect(pending([gig(rev: 1, pushRev: 1, tip: 2000, tipAnnounced: true)]), isEmpty);
    });

    test('members, for leaders only, never the owner', () {
      const added = AppUser(uid: 'n', email: '', role: UserRole.member, disabled: false, announced: false);
      const owner = AppUser(uid: 'o', email: '', role: UserRole.owner, disabled: false, announced: false);
      expect(pending([], users: [added, owner]), isEmpty);
      expect(pending([], leader: true, users: [added, owner]), ['member:n:false']);
    });

    test('a kind the worker knows', () {
      expect(AnnounceKind.values.map((k) => k.name), ['gig', 'tip', 'member', 'feedback']);
    });
  });
}
