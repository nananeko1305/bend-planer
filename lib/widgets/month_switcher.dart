import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';

/// "‹ October 2026 ›": steps one month back or forth, never past
/// [first] or [last] (both the first day of their month). With [yearly],
/// "‹ 2026 ›" and a year per step.
class MonthSwitcher extends StatelessWidget {
  const MonthSwitcher({
    super.key,
    required this.month,
    required this.first,
    required this.last,
    required this.onChanged,
    this.yearly = false,
  });

  final DateTime month;
  final DateTime first;
  final DateTime last;
  final ValueChanged<DateTime> onChanged;
  final bool yearly;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final label = yearly
        ? '${month.year}'
        : toBeginningOfSentenceCase(
            DateFormat.yMMMM(locale).format(month),
            locale,
          );
    DateTime step(int by) => yearly
        ? DateTime(month.year + by)
        : DateTime(month.year, month.month + by);
    return Row(
      children: [
        IconButton(
          tooltip: yearly ? t.previousYear : t.previousMonth,
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: step(-1).isBefore(first)
              ? null
              : () => onChanged(step(-1)),
        ),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ),
        IconButton(
          tooltip: yearly ? t.nextYear : t.nextMonth,
          icon: const Icon(Icons.chevron_right_rounded),
          onPressed: step(1).isAfter(last) ? null : () => onChanged(step(1)),
        ),
      ],
    );
  }
}
