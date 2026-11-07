import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/app_user.dart';
import '../models/gig.dart';
import '../services/live_data.dart';
import '../theme/app_colors.dart';
import 'gig_format.dart';
import 'skin_widgets.dart';
import 'tip_dialog.dart';

/// The tip of one gig: how it is shared, the band's total, and what each
/// player gets, with the way to enter it once the gig is played.
class GigTipCard extends StatelessWidget {
  const GigTipCard({
    super.key,
    required this.gig,
    required this.data,
    required this.profile,
    required this.played,
  });

  final Gig gig;
  final LiveData data;
  final AppUser profile;

  /// Today or before: the tip can be entered.
  final bool played;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = context.colors;
    final open = gig.hasTip && played && !gig.cancelled;
    final own = gig.tipSplit == TipSplit.own;
    final total = gig.tipTotal;
    String money(int minor) => moneyOf(context, minor, gig.currency);

    final status = !gig.hasTip
        ? t.noTipChip
        : total != null
        ? t.tipTotal(money(total))
        : (played ? t.tipWaiting : t.tipLater);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SkinCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.volunteer_activism_rounded, color: c.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionLabel(
                        gig.hasTip
                            ? '${t.tipLabel} · ${own ? t.tipSplitOwn : t.tipSplitEqual}'
                            : t.tipLabel,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        status,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (!own && gig.tipMinor != null && gig.tipBy.isNotEmpty)
                        Text(
                          t.tipBy(data.nameOf(gig.tipBy)),
                          style: TextStyle(color: c.muted, fontSize: 13),
                        ),
                    ],
                  ),
                ),
                if (open && !own)
                  TextButton.icon(
                    onPressed: () => showTipDialog(context, gig, profile),
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: Text(
                      gig.tipMinor == null ? t.enterTip : t.changeTip,
                    ),
                  ),
              ],
            ),
            if (gig.hasTip && gig.players.isNotEmpty) ...[
              const SizedBox(height: 8),
              for (final uid in _meFirst(gig.players))
                _PlayerLine(
                  name: uid == profile.uid
                      ? '${data.nameOf(uid)} ${t.youSuffix}'
                      : data.nameOf(uid),
                  amount: _amountOf(uid, money),
                  emptyText: own && !open ? t.tipNotEntered : '',
                  onEnter: own && open
                      ? () => showTipDialog(
                          context,
                          gig,
                          profile,
                          player: uid,
                          playerName: data.nameOf(uid),
                        )
                      : null,
                ),
            ],
          ],
        ),
      ),
    );
  }

  /// The signed-in member's line first, the rest as ticked.
  List<String> _meFirst(List<String> players) => [
    if (players.contains(profile.uid)) profile.uid,
    for (final p in players)
      if (p != profile.uid) p,
  ];

  /// Their share or their own entry; null while there is none.
  String? _amountOf(String uid, String Function(int) money) {
    final minor = gig.tipShares[uid];
    return minor == null ? null : money(minor);
  }
}

/// One player: the name, and their amount, or a way to enter it.
class _PlayerLine extends StatelessWidget {
  const _PlayerLine({
    required this.name,
    required this.amount,
    required this.emptyText,
    required this.onEnter,
  });

  final String name;
  final String? amount;
  final String emptyText;

  /// Each their own, once played: enter or change this player's amount.
  final VoidCallback? onEnter;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = context.colors;
    final shown = amount;
    final enter = onEnter;
    return Padding(
      padding: const EdgeInsets.only(left: 36, top: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: c.ink, fontWeight: FontWeight.w600),
            ),
          ),
          if (shown != null)
            Text(
              shown,
              style: TextStyle(color: c.tipText, fontWeight: FontWeight.w800),
            )
          else if (enter == null && emptyText.isNotEmpty)
            Text(emptyText, style: TextStyle(color: c.muted, fontSize: 13)),
          if (enter != null && shown == null)
            TextButton(onPressed: enter, child: Text(t.enterTipShort))
          else if (enter != null)
            IconButton(
              tooltip: t.changeTip,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.edit_rounded, size: 18),
              onPressed: enter,
            ),
        ],
      ),
    );
  }
}
