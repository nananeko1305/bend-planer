import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/app_user.dart';
import '../models/gig.dart';
import '../models/report.dart';
import '../money/money.dart';
import '../services/live_data.dart';
import '../theme/app_colors.dart';
import '../theme/skin_backdrop.dart';
import '../widgets/gig_card.dart';
import '../widgets/gig_format.dart';
import '../widgets/reminder_banner.dart';
import '../widgets/skin_widgets.dart';
import '../widgets/tab_header.dart';
import '../widgets/tip_dialog.dart';
import 'gig_detail_screen.dart';

/// The first tab: this month at a glance, gigs waiting for a tip, then the
/// upcoming or the past gigs.
class GigsTab extends StatefulWidget {
  const GigsTab({super.key, required this.data, required this.profile});

  final LiveData data;
  final AppUser profile;

  @override
  State<GigsTab> createState() => _GigsTabState();
}

class _GigsTabState extends State<GigsTab> {
  bool _past = false;

  void _open(Gig g) => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => GigDetailScreen(
        data: widget.data,
        profile: widget.profile,
        gigId: g.id,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final data = widget.data;
    final now = DateTime.now();
    if (!data.ready) {
      return const Center(child: CircularProgressIndicator());
    }
    final waiting = data.awaitingTip(now);
    final list = _past ? data.past(now) : data.upcoming(now);
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SkinBackdrop(
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TabHeader(data: data, profile: widget.profile),
                  _MonthHero(report: MonthReport.of(data.gigs!, now, now)),
                ],
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: ReminderBanner()),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
          sliver: SliverList.list(
            children: [
              for (final g in waiting) ...[
                _AwaitingTipCard(
                  gig: g,
                  profile: widget.profile,
                  onOpen: _open,
                ),
                const SizedBox(height: 12),
              ],
              _Tabs(
                past: _past,
                upcomingCount: data.upcoming(now).length,
                onChanged: (v) => setState(() => _past = v),
              ),
              const SizedBox(height: 14),
              if (list.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    _past ? t.noPast : t.noUpcoming,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: context.colors.muted),
                  ),
                ),
              for (final g in list) ...[
                GigCard(gig: g, now: now, onTap: () => _open(g)),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// "November 2026 / 4.700 € / 5 gigs": agreed so far this month.
class _MonthHero extends StatelessWidget {
  const _MonthHero({required this.report});

  final MonthReport report;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = context.colors;
    final locale = intlLocale(context);
    final sums = formatSums(report.agreed, locale);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(
            DateFormat.yMMMM(locale).format(report.month),
            color: c.ink.withValues(alpha: 0.85),
          ),
          const SizedBox(height: 4),
          HeroText(sums.first, size: 48),
          for (final more in sums.skip(1)) HeroText(more, size: 26),
          const SizedBox(height: 4),
          Text(
            '${t.gigCount(report.gigs)} · ${t.contractedSoFar}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: c.ink.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _AwaitingTipCard extends StatelessWidget {
  const _AwaitingTipCard({
    required this.gig,
    required this.profile,
    required this.onOpen,
  });

  final Gig gig;
  final AppUser profile;
  final void Function(Gig) onOpen;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = context.colors;
    return SkinCard(
      accent: c.tip,
      onTap: () => onOpen(gig),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          DateBlock(day: gig.day, color: c.tip),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionLabel(t.awaitingTip, color: c.tipText),
                const SizedBox(height: 2),
                Text(
                  gigSummary(t, gig),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: c.tip,
              foregroundColor: c.background,
              minimumSize: const Size(64, 44),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: () => showTipDialog(context, gig, profile),
            child: Text(t.enterTipShort),
          ),
        ],
      ),
    );
  }
}

/// Upcoming / Past.
class _Tabs extends StatelessWidget {
  const _Tabs({
    required this.past,
    required this.upcomingCount,
    required this.onChanged,
  });

  final bool past;
  final int upcomingCount;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = context.colors;
    Widget tab(String label, bool selected, bool value) => Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        child: InkWell(
          borderRadius: BorderRadius.circular(c.radius * 0.6),
          onTap: () => onChanged(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(c.radius * 0.6),
              gradient: selected
                  ? LinearGradient(colors: c.buttonGradient)
                  : null,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: selected ? c.onPrimary : c.muted,
              ),
            ),
          ),
        ),
      ),
    );
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(c.radius * 0.75),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          tab('${t.upcoming} · $upcomingCount', !past, false),
          const SizedBox(width: 4),
          tab(t.past, past, true),
        ],
      ),
    );
  }
}
