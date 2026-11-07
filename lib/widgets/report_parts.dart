import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/report.dart';
import '../money/money.dart';
import '../services/live_data.dart';
import '../theme/app_colors.dart';
import 'gig_format.dart';
import 'skin_widgets.dart';

/// A small card with a label and one number.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.accent,
  });

  final String label;
  final String value;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SkinCard(
      accent: accent,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shrinks rather than breaks a long word ("OTKAZANO") on a narrow phone.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: SectionLabel(label, color: accent),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: c.display(20)),
          ),
        ],
      ),
    );
  }
}

/// A label, its amounts, and a bar sized against the biggest of its list.
class AmountBar extends StatelessWidget {
  const AmountBar({
    super.key,
    required this.label,
    required this.amounts,
    required this.max,
  });

  final String label;
  final Amounts amounts;

  /// The biggest in the list, on the same rough scale.
  final double max;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final value = MonthReport.weight(amounts);
    final share = max <= 0 || value <= 0 ? 0.0 : (value / max).clamp(0.04, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                value <= 0
                    ? '—'
                    : formatSums(amounts, intlLocale(context)).join(' + '),
                style: c.display(15, color: value <= 0 ? c.muted : null),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, box) => Container(
              height: 12,
              decoration: BoxDecoration(
                color: c.surfaceHigh,
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.centerLeft,
              child: Container(
                width: box.maxWidth * share,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: c.buttonGradient),
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One member's month or year: their part of the agreed prices plus their
/// tips, how many gigs, and per gig.
class MyEarningsView extends StatelessWidget {
  const MyEarningsView({super.key, required this.report, required this.uid});

  final MonthReport report;
  final String uid;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = context.colors;
    final locale = intlLocale(context);
    final m = report.mine(uid);
    String line(Amounts a) => formatSums(a, locale).join(' · ');
    if (m.gigs == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Text(
          t.notPlayingThisPeriod,
          textAlign: TextAlign.center,
          style: TextStyle(color: c.muted),
        ),
      );
    }
    final totals = formatSums(m.total, locale);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SkinCard(
          highlight: true,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel(t.earnedByMe, color: c.ink),
              const SizedBox(height: 6),
              for (final l in totals)
                HeroText(l, size: l == totals.first ? 44 : 26),
              const SizedBox(height: 4),
              Text(
                t.fromPriceAndTips(line(m.fromPrice), line(m.tips)),
                style: TextStyle(color: c.ink.withValues(alpha: 0.85)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatTile(label: t.gigsPlayed, value: '${m.gigs}'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatTile(
                label: t.perGig,
                value: formatSums(m.average, locale).join('\n'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// "Zarada po članu": each member's earnings, most first, tips below.
class MemberEarningsList extends StatelessWidget {
  const MemberEarningsList({
    super.key,
    required this.report,
    required this.data,
  });

  final MonthReport report;
  final LiveData data;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = context.colors;
    final locale = intlLocale(context);
    return SkinCard(
      child: Column(
        children: [
          for (final e in report.membersByEarnings)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      data.nameOf(e.key),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatSums(e.value, locale).join('\n'),
                        textAlign: TextAlign.end,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      if (report.tipsByMember[e.key]?.values.any(
                            (v) => v > 0,
                          ) ??
                          false)
                        Text(
                          t.tipsPart(
                            formatSums(
                              report.tipsByMember[e.key]!,
                              locale,
                            ).join(' · '),
                          ),
                          style: TextStyle(color: c.tipText, fontSize: 12.5),
                        ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// A year month by month: what each brought, January first.
class ByMonthBars extends StatelessWidget {
  const ByMonthBars({super.key, required this.report});

  final MonthReport report;

  @override
  Widget build(BuildContext context) {
    final locale = intlLocale(context);
    final top = report.byMonth
        .map(MonthReport.weight)
        .fold(0.0, (a, b) => a > b ? a : b);
    return Column(
      children: [
        for (var i = 0; i < 12; i++)
          AmountBar(
            label: toBeginningOfSentenceCase(
              DateFormat.LLLL(locale)
                  .format(DateTime(report.month.year, i + 1)),
              locale,
            ),
            amounts: report.byMonth[i],
            max: top,
          ),
      ],
    );
  }
}
