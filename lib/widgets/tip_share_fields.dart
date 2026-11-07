import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/gig.dart';
import '../theme/app_colors.dart';
import 'gig_form_fields.dart';

/// "Shared equally" or "Each their own", with what the choice means below.
class TipSplitToggle extends StatelessWidget {
  const TipSplitToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final TipSplit value;

  /// Null shows the choice without letting it change.
  final ValueChanged<TipSplit>? onChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = context.colors;
    final change = onChanged;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (split, label) in [
              (TipSplit.equal, t.tipSplitEqual),
              (TipSplit.own, t.tipSplitOwn),
            ])
              SkinChoice(
                label: label,
                selected: split == value,
                onTap: change == null ? null : () => change(split),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value == TipSplit.equal ? t.tipSplitEqualHint : t.tipSplitOwnHint,
          style: TextStyle(color: c.muted, fontSize: 13.5),
        ),
      ],
    );
  }
}

/// Who plays a gig: a chip per member, ticked ones share the tip.
class PlayersPicker extends StatelessWidget {
  const PlayersPicker({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.error = false,
  });

  /// uid and name, in the order to show and to store.
  final List<(String, String)> options;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;

  /// Nobody ticked on a save attempt.
  final bool error;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (uid, name) in options)
              FilterChip(
                label: Text(name),
                selected: selected.contains(uid),
                showCheckmark: true,
                checkmarkColor: c.onPrimary,
                selectedColor: c.primary,
                backgroundColor: c.surface,
                side: BorderSide(
                  color: selected.contains(uid) ? c.primary : c.border,
                ),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: selected.contains(uid) ? c.onPrimary : c.ink,
                ),
                onSelected: (on) => onChanged(
                  on ? {...selected, uid} : ({...selected}..remove(uid)),
                ),
              ),
          ],
        ),
        if (error)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              t.pickPlayers,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }
}
