/// Days are stored as `yyyy-MM-dd` text: the push worker compares them as
/// text, in Belgrade days, and no time zone can shift them.
String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// The day of a [dateKey], at local midnight; null when it is not one.
DateTime? parseDateKey(String key) {
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(key);
  if (m == null) return null;
  return DateTime(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
}

/// Local midnight of [d].
DateTime dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

/// Whole days from [from] to [to], both taken at midnight; immune to the
/// one-hour days around daylight-saving changes.
int daysBetween(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

/// A time of day typed as "20", "20:00", "20.30" or "2030", as `HH:mm`;
/// null when it is not one.
String? parseTime(String input) {
  final s = input.trim().replaceAll('.', ':').replaceAll('h', '');
  final m = RegExp(r'^(\d{1,2})(?::?(\d{2}))?$').firstMatch(s);
  if (m == null) return null;
  final h = int.parse(m[1]!);
  final min = int.parse(m[2] ?? '0');
  if (h > 23 || min > 59) return null;
  return '${h.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}';
}
