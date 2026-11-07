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

/// The month in numbers, worked out from the gigs every time it is shown and
/// never stored, so it cannot drift from them.
class MonthReport {
  MonthReport._(this.month);

  /// First day of the month.
  final DateTime month;

  /// Gigs in the month that were not cancelled, played or still ahead.
  int gigs = 0;
  int cancelled = 0;
  final Amounts agreed = {};
  final Amounts tips = {};
  final Amounts total = {};

  /// Total per gig, per currency (gigs in that currency only).
  final Amounts average = {};
  Gig? biggestTip;
  final List<TypeRow> byType = [];

  /// Past gigs with a tip that nobody has entered yet.
  int tipsPending = 0;

  /// The month after, as booked so far.
  int nextGigs = 0;
  final Amounts nextAgreed = {};

  bool get isEmpty => gigs == 0 && cancelled == 0;

  static bool inMonth(Gig g, DateTime month) =>
      g.day.year == month.year && g.day.month == month.month;

  factory MonthReport.of(Iterable<Gig> all, DateTime month, DateTime now) {
    final first = DateTime(month.year, month.month);
    final next = DateTime(month.year, month.month + 1);
    final r = MonthReport._(first);
    final rows = <GigType, TypeRow>{};
    final counts = <Currency, int>{};
    for (final g in all) {
      if (inMonth(g, next) && !g.cancelled) {
        r.nextGigs++;
        _add(r.nextAgreed, g.currency, g.priceMinor);
      }
      if (!inMonth(g, first)) continue;
      if (g.cancelled) {
        r.cancelled++;
        continue;
      }
      r.gigs++;
      counts[g.currency] = (counts[g.currency] ?? 0) + 1;
      _add(r.agreed, g.currency, g.priceMinor);
      _add(r.total, g.currency, g.totalMinor);
      if (g.tipMinor != null) {
        _add(r.tips, g.currency, g.tipMinor!);
        if (r.biggestTip == null || _beats(g, r.biggestTip!)) r.biggestTip = g;
      }
      if (g.statusOn(now) == GigStatus.awaitingTip) r.tipsPending++;
      final row = rows.putIfAbsent(g.type, () => TypeRow(g.type));
      row.count++;
      _add(row.total, g.currency, g.totalMinor);
    }
    for (final e in counts.entries) {
      r.average[e.key] = (r.total[e.key]! / e.value).round();
    }
    r.byType.addAll(rows.values);
    r.byType.sort((a, b) => _key(b.total).compareTo(_key(a.total)));
    return r;
  }

  /// A bigger tip wins; euros count over dinars at a rough 117 to one, only
  /// to pick one gig to show, never in a sum.
  static bool _beats(Gig a, Gig b) =>
      _inEuroish(a.tipMinor!, a.currency) > _inEuroish(b.tipMinor!, b.currency);

  static double _inEuroish(int minor, Currency c) =>
      c == Currency.eur ? minor.toDouble() : minor / 117;

  static double _key(Amounts a) =>
      _inEuroish(a[Currency.eur] ?? 0, Currency.eur) +
      _inEuroish(a[Currency.rsd] ?? 0, Currency.rsd);
}
