import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/gig.dart';
import '../theme/app_colors.dart';
import 'gig_format.dart';
import 'skin_widgets.dart';

/// One gig in a list: date block, what and where, price. Tonight's gig is
/// highlighted; a cancelled one is struck through.
class GigCard extends StatelessWidget {
  const GigCard({
    super.key,
    required this.gig,
    required this.now,
    required this.onTap,
  });

  final Gig gig;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = context.colors;
    final status = gig.statusOn(now);
    final today = gig.daysFrom(now) == 0 && status == GigStatus.upcoming;
    final cancelled = status == GigStatus.cancelled;
    final strike = cancelled ? TextDecoration.lineThrough : null;
    return Opacity(
      opacity: cancelled ? 0.6 : 1,
      child: SkinCard(
        highlight: today,
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DateBlock(day: gig.day, highlight: today),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gigWhen(context, gig, now),
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: today ? c.primary : c.muted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    gigTypeLabel(t, gig.type),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: c
                        .display(today ? 19 : 17, weight: FontWeight.w800)
                        .copyWith(decoration: strike),
                  ),
                  if (gig.draft.place.isNotEmpty)
                    Text(
                      gig.draft.place,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: c.muted),
                    ),
                  const SizedBox(height: 6),
                  Wrap(spacing: 6, runSpacing: 4, children: _chips(context)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Align(
              alignment: Alignment.topRight,
              child: Text(
                priceOf(context, gig),
                style: c
                    .display(17, weight: FontWeight.w800)
                    .copyWith(decoration: strike),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _chips(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = context.colors;
    if (gig.cancelled) return [SkinChip(t.cancelledChip, color: c.muted)];
    return [
      if (gig.hasTip && gig.tipTotal != null)
        SkinChip(
          t.tipAmountChip(moneyOf(context, gig.tipTotal!, gig.currency)),
          color: c.tipText,
        )
      else if (gig.hasTip)
        SkinChip(t.tipChip, color: c.tipText)
      else
        SkinChip(t.noTipChip),
      if (gig.draft.depositMinor > 0)
        SkinChip(
          t.depositChip(moneyOf(context, gig.draft.depositMinor, gig.currency)),
        ),
    ];
  }
}

/// "SAT / 14 / NOV": the day of a gig at a glance.
class DateBlock extends StatelessWidget {
  const DateBlock({
    super.key,
    required this.day,
    this.highlight = false,
    this.color,
  });

  final DateTime day;
  final bool highlight;

  /// Fill for a block that is not highlighted, such as a tip waiting.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (weekday, date, month) = dateBlock(context, day);
    final filled = highlight || color != null;
    final ink = highlight
        ? c.onPrimary
        : (color != null ? c.background : c.ink);
    final small = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w800,
      letterSpacing: 1,
      color: filled ? ink : c.muted,
    );
    return Container(
      width: 58,
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(c.radius * 0.75),
        gradient: highlight
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: c.buttonGradient,
              )
            : null,
        color: highlight ? null : (color ?? c.surfaceHigh),
      ),
      child: Column(
        children: [
          Text(weekday, style: small),
          Text(
            date,
            style: c
                .display(24, weight: FontWeight.w900, color: ink)
                .copyWith(shadows: filled ? const [] : c.glow),
          ),
          Text(month, style: small),
        ],
      ),
    );
  }
}
