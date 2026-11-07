import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/app_user.dart';
import '../models/report.dart';
import '../money/money.dart';
import '../services/live_data.dart';
import '../theme/app_colors.dart';
import '../widgets/gig_form_fields.dart';
import '../widgets/gig_format.dart';
import '../widgets/month_switcher.dart';
import '../widgets/report_parts.dart';
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
  bool _yearly = false;

  /// Members see their own earnings first; the owner is not in the band.
  late bool _mine = !widget.profile.isOwner;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = context.colors;
    final now = DateTime.now();
    final gigs = widget.data.gigs ?? const [];
    // Gigs from before "Ko svira" count as played by the band as it is now.
    final band = [for (final m in widget.data.members) m.uid];
    final r = _yearly
        ? MonthReport.ofYear(gigs, _month.year, now, band: band)
        : MonthReport.of(gigs, _month, now, band: band);
    final owner = widget.profile.isOwner;
    final mine = _mine && !owner;
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
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 8,
              runSpacing: 8,
              children: [
                _Pair(
                  left: (t.periodMonth, !_yearly),
                  right: (t.periodYear, _yearly),
                  onPick: (year) => setState(() => _yearly = year),
                ),
                if (!owner)
                  _Pair(
                    left: (t.myEarnings, _mine),
                    right: (t.bandView, !_mine),
                    onPick: (band) => setState(() => _mine = !band),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            MonthSwitcher(
              month: _month,
              yearly: _yearly,
              first: DateTime(now.year - 3),
              last: DateTime(now.year + 2, 12),
              // A year keeps the month picked, for going back to months.
              onChanged: (m) => setState(
                () => _month = _yearly ? DateTime(m.year, _month.month) : m,
              ),
            ),
            if (mine) ...[
              const SizedBox(height: 8),
              MyEarningsView(report: r, uid: widget.profile.uid),
            ] else ...[
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
                        size: line == formatSums(r.total, locale).first
                            ? 44
                            : 26,
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
                    child: StatTile(label: t.agreed, value: sums(r.agreed)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatTile(
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
                    child: StatTile(label: t.gigsLabel, value: '${r.gigs}'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatTile(
                      label: t.cancelledLabel,
                      value: '${r.cancelled}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatTile(
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
                  style: TextStyle(
                    color: c.tipText,
                    fontWeight: FontWeight.w700,
                  ),
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
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              DateFormat.MMMEd(locale)
                                  .format(r.biggestTip!.day),
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
              if (r.earningsByMember.isNotEmpty) ...[
                const SizedBox(height: 22),
                Text(
                  t.earningsByMember,
                  style: c.display(18, color: c.primary),
                ),
                const SizedBox(height: 10),
                MemberEarningsList(report: r, data: widget.data),
              ],
              if (_yearly && !r.isEmpty) ...[
                const SizedBox(height: 22),
                Text(t.byMonth, style: c.display(18, color: c.primary)),
                const SizedBox(height: 10),
                ByMonthBars(report: r),
              ],
              if (r.byType.isNotEmpty) ...[
                const SizedBox(height: 22),
                Text(t.byType, style: c.display(18, color: c.primary)),
                const SizedBox(height: 10),
                for (final row in r.byType)
                  AmountBar(
                    label: '${gigTypeLabel(t, row.type)} · ${row.count}',
                    amounts: row.total,
                    max: MonthReport.weight(r.byType.first.total),
                  ),
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
            ],
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
                            _yearly
                                ? '${_month.year + 1}'
                                : DateFormat.MMMM(locale).format(nextMonth),
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
            if (!mine &&
                (r.total[Currency.rsd] ?? 0) > 0 &&
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

/// Two choices side by side, one of them picked: month or year, mine or
/// the band's.
class _Pair extends StatelessWidget {
  const _Pair({required this.left, required this.right, required this.onPick});

  final (String, bool) left;
  final (String, bool) right;

  /// Called with true when the right one is picked.
  final ValueChanged<bool> onPick;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SkinChoice(label: left.$1, selected: left.$2, onTap: () => onPick(false)),
      const SizedBox(width: 6),
      SkinChoice(
        label: right.$1,
        selected: right.$2,
        onTap: () => onPick(true),
      ),
    ],
  );
}
