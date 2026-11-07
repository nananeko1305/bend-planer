import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/gig.dart';
import '../money/money.dart';

/// The locale for `intl`: `sr-Latn` keeps Serbian dates in Latin.
String intlLocale(BuildContext context) =>
    Localizations.localeOf(context).toLanguageTag();

String gigTypeLabel(AppLocalizations t, GigType type) => switch (type) {
  GigType.wedding => t.typeWedding,
  GigType.birthday => t.typeBirthday,
  GigType.kafana => t.typeKafana,
  GigType.company => t.typeCompany,
  GigType.concert => t.typeConcert,
  GigType.other => t.typeOther,
};

String moneyOf(BuildContext context, int minor, Currency currency) =>
    formatMoney(minor, currency, intlLocale(context));

/// The agreed price, or "Za bakšiš" for a gig played for tips alone.
String priceOf(BuildContext context, Gig g) => g.tipOnly
    ? AppLocalizations.of(context).tipOnlyPrice
    : moneyOf(context, g.priceMinor, g.currency);

/// "Wedding, Sala Kristal, Kraljevo": what the gig is, in one line.
String gigSummary(AppLocalizations t, Gig g) => [
  gigTypeLabel(t, g.type),
  if (g.draft.place.isNotEmpty) g.draft.place,
].join(', ');

/// "Tonight · 19:00", "In 6 days · 20:00", or for a past gig its date.
String gigWhen(BuildContext context, Gig g, DateTime now) {
  final t = AppLocalizations.of(context);
  final days = g.daysFrom(now);
  final time = g.draft.start;
  if (days == 0) {
    return (now.hour >= 15 ? t.tonightAt : t.todayAt)(time);
  }
  if (days > 0) return t.inDaysAt(days, time);
  return '${DateFormat.yMMMEd(intlLocale(context)).format(g.day)} · $time';
}

/// "Saturday, 14 November 2026 · 20:00–02:00".
String gigDateTime(BuildContext context, Gig g) {
  final date = DateFormat.yMMMMEEEEd(intlLocale(context)).format(g.day);
  final end = g.draft.end;
  return '$date · ${g.draft.start}${end.isEmpty ? '' : '–$end'}';
}

/// The three lines of the date block on a card: "SAT", "14", "NOV".
(String, String, String) dateBlock(BuildContext context, DateTime day) {
  final locale = intlLocale(context);
  String upper(String s) => s.replaceAll('.', '').toUpperCase();
  return (
    upper(DateFormat.E(locale).format(day)),
    day.day.toString().padLeft(2, '0'),
    upper(DateFormat.MMM(locale).format(day)),
  );
}
