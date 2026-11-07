import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/skins.dart';
import '../theme/theme_controller.dart';

/// The three looks as small previews; tapping one switches at once.
class SkinPicker extends StatelessWidget {
  const SkinPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final names = {
      SkinId.bina: (t.skinBina, t.skinBinaHint),
      SkinId.neon: (t.skinNeon, t.skinNeonHint),
      SkinId.zlato: (t.skinZlato, t.skinZlatoHint),
    };
    // Listens itself: a const SkinPicker is not rebuilt by its parent, so the
    // check would stay on the old look.
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) => Row(
        children: [
          for (final id in SkinId.values) ...[
            Expanded(
              child: _Preview(
                skin: kSkins[id]!,
                name: names[id]!.$1,
                hint: names[id]!.$2,
                selected: themeController.skin == id,
                onTap: () => themeController.select(id),
              ),
            ),
            if (id != SkinId.values.last) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

/// A look drawn in its own colors and font, whatever look is active.
class _Preview extends StatelessWidget {
  const _Preview({
    required this.skin,
    required this.name,
    required this.hint,
    required this.selected,
    required this.onTap,
  });

  final AppColors skin;
  final String name;
  final String hint;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = context.colors;
    return Semantics(
      selected: selected,
      button: true,
      label: name,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: skin.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? active.primary : skin.border,
              width: selected ? 2.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(skin.radius * 0.5),
                  gradient: LinearGradient(
                    colors: skin.heroGradient ?? skin.buttonGradient,
                  ),
                  boxShadow: skin.glow == null
                      ? null
                      : [BoxShadow(color: skin.primary, blurRadius: 12)],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: skin.display(15),
              ),
              Text(
                hint,
                maxLines: 2,
                style: TextStyle(
                  fontFamily: skin.bodyFont,
                  fontSize: 11.5,
                  color: skin.muted,
                ),
              ),
              const SizedBox(height: 4),
              Icon(
                selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                size: 20,
                color: selected ? active.primary : skin.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
