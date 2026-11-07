import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/app_user.dart';
import '../models/gig.dart';
import '../money/money.dart';
import '../services/background_save.dart';
import '../services/gig_repository.dart';
import '../theme/app_colors.dart';
import 'gig_format.dart';

/// Asks for the tip of a played gig and saves it. Anyone in the band may.
/// With [player] (each their own), it is that player's amount, entered by
/// [me] for themselves or for someone without the app.
Future<void> showTipDialog(
  BuildContext context,
  Gig gig,
  AppUser me, {
  String? player,
  String playerName = '',
}) async {
  final t = AppLocalizations.of(context);
  final own = player;
  final amount = await showDialog<int>(
    context: context,
    builder: (_) => _TipDialog(
      gig: gig,
      title: own == null
          ? t.tipFor(gigSummary(t, gig))
          : t.tipForPlayer(playerName),
      current: own == null ? gig.tipMinor : gig.tips[own],
    ),
  );
  if (amount == null || !context.mounted) return;
  saveInBackground(
    context,
    () => own == null
        ? GigRepository.instance.enterTip(gig, amount, me.uid)
        : GigRepository.instance.enterOwnTip(gig, own, amount, me.uid),
  );
}

class _TipDialog extends StatefulWidget {
  const _TipDialog({required this.gig, required this.title, this.current});

  final Gig gig;
  final String title;

  /// The amount entered before, to change.
  final int? current;

  @override
  State<_TipDialog> createState() => _TipDialogState();
}

class _TipDialogState extends State<_TipDialog> {
  final _form = GlobalKey<FormState>();
  late final _amount = TextEditingController(
    text: widget.current == null ? '' : moneyToInput(widget.current!),
  );

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  /// No tip after all is a real answer: "0" is allowed, unlike a price.
  static int? _parse(String input) =>
      input.trim() == '0' ? 0 : parseMoney(input);

  void _save() {
    if (!_form.currentState!.validate()) return;
    Navigator.of(context).pop(_parse(_amount.text));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = context.colors;
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _form,
        child: TextFormField(
          controller: _amount,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: c.display(26, weight: FontWeight.w800),
          decoration: InputDecoration(
            labelText: t.tipAmount,
            suffixText: widget.gig.currency == Currency.eur ? '€' : 'RSD',
          ),
          validator: (v) => _parse(v ?? '') == null ? t.enterAmount : null,
          onFieldSubmitted: (_) => _save(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(96, 46)),
          onPressed: _save,
          child: Text(t.save),
        ),
      ],
    );
  }
}
