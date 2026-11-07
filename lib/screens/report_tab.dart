import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/app_user.dart';
import '../models/report.dart';
import '../money/money.dart';
import '../services/live_data.dart';
import '../theme/app_colors.dart';
import '../widgets/gig_format.dart';
import '../widgets/month_switcher.dart';
import '../widgets/skin_widgets.dart';
import '../widgets/tab_header.dart';

/// The month in numbers: what was agreed, the tips, and where it came from.
class ReportTab extends StatefulWidget {
  const ReportTab({super.key, required this.data, required this.profile});

  final LiveData data;
  final AppUser profile;

  @override
  State<ReportTab> createState() => _ReportTabState();
}

class _ReportTabState extends State<ReportTab> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = context.colors;
    final now = DateTime.now();
    final gigs = widget.data.gigs ?? const [];
    final r = MonthReport.of(gigs, _month, now);
    final locale = intlLocale(context);
    String sums(Amounts a) => formatSums(a, locale).join('\n');
    final nextMonth = DateTime(_month.year, _month.month + 1);
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          // The header keeps its own insets, the same on every tab.
          TabHeader(
            data: widget.data,
            profile: widget.profile,
            title: t.tabReport,
          ),
          for (final child in <Widget>[
            MonthSwitcher(
              month: _month,
              first: DateTime(now.year - 3),
              last: DateTime(now.year + 2, 12),
              onChanged: (m) => setState(() => _month = m),
            ),
            const SizedBox(height: 8),
            SkinCard(
              highlight: true,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionLabel(t.totalEarned, color: c.ink),
                  const SizedBox(height: 6),
                  for (final line in formatSums(r.total, locale))
                    HeroText(
                      line,
                      size: line == formatSums(r.total, locale).first ? 44 : 26,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    t.agreedPlusTips,
                    style: TextStyle(color: c.ink.withValues(alpha: 0.85)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _Tile(label: t.agreed, value: sums(r.agreed)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Tile(
                    label: t.tips,
                    value: sums(r.tips),
                    accent: c.tipText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _Tile(label: t.gigsLabel, value: '${r.gigs}'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Tile(
                    label: t.cancelledLabel,
                    value: '${r.cancelled}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Tile(
                    label: t.averageLabel,
                    value: r.gigs == 0 ? '—' : sums(r.average),
                  ),
                ),
              ],
            ),
            if (r.tipsPending > 0) ...[
              const SizedBox(height: 12),
              Text(
                t.tipsPending(r.tipsPending),
                style: TextStyle(color: c.tipText, fontWeight: FontWeight.w700),
              ),
            ],
            if (r.biggestTip != null) ...[
              const SizedBox(height: 12),
              SkinCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionLabel(t.biggestTip, color: c.tipText),
                          const SizedBox(height: 3),
                          Text(
                            gigSummary(t, r.biggestTip!),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            DateFormat.MMMEd(locale).format(r.biggestTip!.day),
                            style: TextStyle(color: c.muted),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      moneyOf(
                        context,
                        r.biggestTip!.tipTotal!,
                        r.biggestTip!.currency,
                      ),
                      style: c.display(22),
                    ),
                  ],
                ),
              ),
            ],
            if (r.tipsByMember.isNotEmpty) ...[
              const SizedBox(height: 22),
              Text(t.tipsByMember, style: c.display(18, color: c.primary)),
              const SizedBox(height: 10),
              SkinCard(
                child: Column(
                  children: [
                    for (final e in r.membersByTips)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.data.nameOf(e.key),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              sums(e.value),
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                color: c.tipText,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
            if (r.byType.isNotEmpty) ...[
              const SizedBox(height: 22),
              Text(t.byType, style: c.display(18, color: c.primary)),
              const SizedBox(height: 10),
              for (final row in r.byType)
                _TypeBar(row: row, max: r.byType.first),
            ],
            if (r.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  t.reportEmpty,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: c.muted),
                ),
              ),
            const SizedBox(height: 18),
            SkinCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionLabel(
                          t.alreadyBooked(
                            DateFormat.MMMM(locale).format(nextMonth),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(t.gigCount(r.nextGigs), style: c.display(18)),
                      ],
                    ),
                  ),
                  Text(
                    sums(r.nextAgreed),
                    textAlign: TextAlign.end,
                    style: c.display(20),
                  ),
                ],
              ),
            ),
            if ((r.total[Currency.rsd] ?? 0) > 0 &&
                (r.total[Currency.eur] ?? 0) > 0) ...[
              const SizedBox(height: 12),
              Text(
                t.dinarsApart,
                style: TextStyle(color: c.muted, fontSize: 13),
              ),
            ],
          ])
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: child,
            ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.label, required this.value, this.accent});

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

/// One kind of gig as a bar, scaled to the biggest.
class _TypeBar extends StatelessWidget {
  const _TypeBar({required this.row, required this.max});

  final TypeRow row;
  final TypeRow max;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = context.colors;
    double weight(TypeRow r) =>
        (r.total[Currency.eur] ?? 0) + (r.total[Currency.rsd] ?? 0) / 117;
    final top = weight(max);
    final share = top <= 0 ? 0.0 : (weight(row) / top).clamp(0.04, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${gigTypeLabel(t, row.type)} · ${row.count}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                formatSums(row.total, intlLocale(context)).join(' + '),
                style: c.display(15),
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
