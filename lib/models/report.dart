import '../money/money.dart';
import 'gig.dart';

/// Sums per currency; euros and dinars are never added together.
typedef Amounts = Map<Currency, int>;

void _add(Amounts sums, Currency c, int minor) =>
    sums[c] = (sums[c] ?? 0) + minor;

/// One line of "by type": how many gigs of a kind and what they brought.
class TypeRow {
  TypeRow(this.type);
  final GigType type;
  int count = 0;
  final Amounts total = {};
}

/// One member's month: their part of the agreed prices plus their tips.
class MemberEarnings {
  const MemberEarnings({
    required this.total,
    required this.fromPrice,
    required this.tips,
    required this.gigs,
    required this.average,
  });

  final Amounts total;
  final Amounts fromPrice;
  final Amounts tips;

  /// Gigs they play this month, played or still ahead, not cancelled.
  final int gigs;

  /// Earned per gig, per currency (their gigs in that currency only).
  final Amounts average;
}

/// The month in numbers, worked out from the gigs every time it is shown and
/// never stored, so it cannot drift from them. A month, or with [yearly] a
/// whole year.
class MonthReport {
  MonthReport._(this.month, {this.yearly = false});

  /// First day of the month, or of the year when [yearly].
  final DateTime month;
  final bool yearly;

  /// Gigs in the period that were not cancelled, played or still ahead.
  int gigs = 0;
  int cancelled = 0;
  final Amounts agreed = {};
  final Amounts tips = {};
  final Amounts total = {};

  /// Total per gig, per currency (gigs in that currency only).
  final Amounts average = {};
  Gig? biggestTip;
  final List<TypeRow> byType = [];

  /// What each member got in tips this month, by uid: their equal shares and
  /// their own entries together, per currency.
  final Map<String, Amounts> tipsByMember = {};

  /// Each member's part of the agreed prices, by uid.
  final Map<String, Amounts> priceByMember = {};

  /// Each member's earnings: price part plus tips, by uid.
  final Map<String, Amounts> earningsByMember = {};

  /// How many of the month's gigs each member plays, per currency.
  final Map<String, Map<Currency, int>> _gigsByMember = {};

  /// Past gigs with a tip that nobody has entered yet.
  int tipsPending = 0;

  /// The month (or year) after, as booked so far.
  int nextGigs = 0;
  final Amounts nextAgreed = {};

  /// A year only: each month's total, January first.
  final List<Amounts> byMonth = [for (var i = 0; i < 12; i++) {}];

  bool get isEmpty => gigs == 0 && cancelled == 0;

  /// [band] (uids) stands in for the players of gigs from before 1.2, when
  /// nobody was ticked.
  factory MonthReport.of(
    Iterable<Gig> all,
    DateTime month,
    DateTime now, {
    List<String> band = const [],
  }) => MonthReport._over(
    all,
    MonthReport._(DateTime(month.year, month.month)),
    DateTime(month.year, month.month + 1),
    DateTime(month.year, month.month + 2),
    now,
    band,
  );

  /// The whole of [year], with each month's total in [byMonth].
  factory MonthReport.ofYear(
    Iterable<Gig> all,
    int year,
    DateTime now, {
    List<String> band = const [],
  }) => MonthReport._over(
    all,
    MonthReport._(DateTime(year), yearly: true),
    DateTime(year + 1),
    DateTime(year + 2),
    now,
    band,
  );

  /// Fills [r] from the gigs on or after its first day and before [end];
  /// [end] to [nextEnd] is the period after, for what is already booked.
  static MonthReport _over(
    Iterable<Gig> all,
    MonthReport r,
    DateTime end,
    DateTime nextEnd,
    DateTime now,
    List<String> band,
  ) {
    bool within(Gig g, DateTime from, DateTime to) =>
        !g.day.isBefore(from) && g.day.isBefore(to);
    final rows = <GigType, TypeRow>{};
    final counts = <Currency, int>{};
    for (final g in all) {
      if (within(g, end, nextEnd) && !g.cancelled) {
        r.nextGigs++;
        _add(r.nextAgreed, g.currency, g.priceMinor);
      }
      if (!within(g, r.month, end)) continue;
      if (g.cancelled) {
        r.cancelled++;
        continue;
      }
      r.gigs++;
      counts[g.currency] = (counts[g.currency] ?? 0) + 1;
      _add(r.agreed, g.currency, g.priceMinor);
      _add(r.total, g.currency, g.totalMinor);
      final tip = g.tipTotal;
      if (tip != null) {
        _add(r.tips, g.currency, tip);
        if (r.biggestTip == null || _beats(g, r.biggestTip!)) r.biggestTip = g;
      }
      for (final share in g.priceSharesWith(band).entries) {
        _add(
          r.priceByMember.putIfAbsent(share.key, () => {}),
          g.currency,
          share.value,
        );
        _add(
          r.earningsByMember.putIfAbsent(share.key, () => {}),
          g.currency,
          share.value,
        );
      }
      for (final share in g.tipSharesWith(band).entries) {
        _add(
          r.tipsByMember.putIfAbsent(share.key, () => {}),
          g.currency,
          share.value,
        );
        _add(
          r.earningsByMember.putIfAbsent(share.key, () => {}),
          g.currency,
          share.value,
        );
      }
      for (final uid in g.playersOr(band)) {
        final counts = r._gigsByMember.putIfAbsent(uid, () => {});
        counts[g.currency] = (counts[g.currency] ?? 0) + 1;
      }
      if (g.statusOn(now) == GigStatus.awaitingTip) r.tipsPending++;
      if (r.yearly) _add(r.byMonth[g.day.month - 1], g.currency, g.totalMinor);
      final row = rows.putIfAbsent(g.type, () => TypeRow(g.type));
      row.count++;
      _add(row.total, g.currency, g.totalMinor);
    }
    for (final e in counts.entries) {
      r.average[e.key] = (r.total[e.key]! / e.value).round();
    }
    r.byType.addAll(rows.values);
    r.byType.sort((a, b) => weight(b.total).compareTo(weight(a.total)));
    return r;
  }

  /// A bigger tip wins; euros count over dinars at a rough 117 to one, only
  /// to pick one gig to show, never in a sum.
  static bool _beats(Gig a, Gig b) =>
      _inEuroish(a.tipTotal!, a.currency) > _inEuroish(b.tipTotal!, b.currency);

  /// Members by what they earned, most first (the same rough rate).
  List<MapEntry<String, Amounts>> get membersByEarnings =>
      earningsByMember.entries.toList()
        ..sort((a, b) => weight(b.value).compareTo(weight(a.value)));

  /// One member's month.
  MemberEarnings mine(String uid) {
    final total = earningsByMember[uid] ?? const <Currency, int>{};
    final counts = _gigsByMember[uid] ?? const <Currency, int>{};
    return MemberEarnings(
      total: total,
      fromPrice: priceByMember[uid] ?? const {},
      tips: tipsByMember[uid] ?? const {},
      gigs: counts.values.fold(0, (a, b) => a + b),
      average: {
        for (final e in counts.entries)
          if (e.value > 0) e.key: ((total[e.key] ?? 0) / e.value).round(),
      },
    );
  }

  static double _inEuroish(int minor, Currency c) =>
      c == Currency.eur ? minor.toDouble() : minor / 117;

  /// Euros and dinars on one scale (the same rough rate), only to order or
  /// size things, never to add up.
  static double weight(Amounts a) =>
      _inEuroish(a[Currency.eur] ?? 0, Currency.eur) +
      _inEuroish(a[Currency.rsd] ?? 0, Currency.rsd);
}
