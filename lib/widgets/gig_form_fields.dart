import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/gig.dart';
import '../money/money.dart';
import '../theme/app_colors.dart';
import 'gig_format.dart';

/// A tappable box that shows a value and opens a picker, such as the date.
class TapField extends StatelessWidget {
  const TapField({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: c.muted),
          suffixIcon: onClear == null
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: onClear,
                ),
        ),
        child: Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

/// The kinds of gig as chips, one selected.
class GigTypePicker extends StatelessWidget {
  const GigTypePicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final GigType value;
  final ValueChanged<GigType> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final type in GigType.values)
          SkinChoice(
            label: gigTypeLabel(t, type),
            selected: type == value,
            onTap: () => onChanged(type),
          ),
      ],
    );
  }
}

/// EUR or RSD.
class CurrencyToggle extends StatelessWidget {
  const CurrencyToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final Currency value;
  final ValueChanged<Currency> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final c in Currency.values) ...[
          SkinChoice(
            label: c.code,
            selected: c == value,
            onTap: () => onChanged(c),
          ),
          const SizedBox(width: 6),
        ],
      ],
    );
  }
}

/// Two big buttons: tip / no tip.
class TipToggle extends StatelessWidget {
  const TipToggle({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = context.colors;
    Widget button(String label, bool on) {
      final selected = value == on;
      return Expanded(
        child: Semantics(
          selected: selected,
          button: true,
          child: InkWell(
            borderRadius: BorderRadius.circular(c.radius * 0.75),
            onTap: () => onChanged(on),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? (on ? c.tip : c.surfaceHigh) : c.surface,
                borderRadius: BorderRadius.circular(c.radius * 0.75),
                border: Border.all(
                  color: selected ? (on ? c.tip : c.ink) : c.border,
                  width: 2,
                ),
              ),
              child: Text(
                label,
                style: c
                    .display(16, color: selected && on ? c.background : c.ink)
                    .copyWith(shadows: const []),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        button(t.hasTip, true),
        const SizedBox(width: 10),
        button(t.noTip, false),
      ],
    );
  }
}

/// A rounded choice in the look's colors: filled when selected.
class SkinChoice extends StatelessWidget {
  const SkinChoice({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;

  /// Null for a choice shown but not changeable.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: selected
                ? LinearGradient(colors: c.buttonGradient)
                : null,
            color: selected ? null : c.surface,
            border: Border.all(color: selected ? c.primary : c.border),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: selected ? c.onPrimary : c.ink,
            ),
          ),
        ),
      ),
    );
  }
}
