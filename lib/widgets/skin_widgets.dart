import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A big number in the look's display font: a gradient for Bina and Zlato, a
/// neon glow for Neon.
class HeroText extends StatelessWidget {
  const HeroText(this.text, {super.key, this.size = 50});

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final style = c.display(size, weight: FontWeight.w900);
    final label = Text(
      text,
      style: style,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    final gradient = c.heroGradient;
    if (gradient == null) return label;
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => LinearGradient(
        colors: gradient,
        begin: c.skin == SkinId.zlato
            ? Alignment.topCenter
            : Alignment.centerLeft,
        end: c.skin == SkinId.zlato
            ? Alignment.bottomCenter
            : Alignment.centerRight,
      ).createShader(bounds),
      child: label,
    );
  }
}

/// A card in the look's style. [highlight] marks the one that matters now:
/// tonight's gig.
class SkinCard extends StatelessWidget {
  const SkinCard({
    super.key,
    required this.child,
    this.highlight = false,
    this.accent,
    this.onTap,
    this.padding = const EdgeInsets.all(14),
  });

  final Widget child;
  final bool highlight;

  /// Border color for a card that is not highlighted, such as one waiting for
  /// a tip.
  final Color? accent;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final radius = BorderRadius.circular(c.radius);
    final border = highlight ? c.primary : (accent ?? c.border);
    final decoration = BoxDecoration(
      borderRadius: radius,
      color: highlight ? null : (accent?.withValues(alpha: 0.08) ?? c.surface),
      gradient: highlight
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.alphaBlend(c.primary.withValues(alpha: 0.2), c.surface),
                Color.alphaBlend(
                  c.secondary.withValues(alpha: 0.16),
                  c.surface,
                ),
              ],
            )
          : null,
      border: Border.all(
        color: border,
        width: highlight && c.skin == SkinId.neon ? 2 : 1,
      ),
      boxShadow: highlight
          ? [
              BoxShadow(
                color: c.primary.withValues(alpha: 0.32),
                blurRadius: c.skin == SkinId.zlato ? 20 : 26,
              ),
            ]
          : null,
    );
    return DecoratedBox(
      decoration: decoration,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// The main action of a screen, such as "+ Gig": a gradient pill.
class PrimaryPill extends StatelessWidget {
  const PrimaryPill({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 58,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        gradient: LinearGradient(colors: c.buttonGradient),
        boxShadow: [
          BoxShadow(
            color: c.primary.withValues(alpha: 0.45),
            blurRadius: 26,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(height / 2),
          onTap: onPressed,
          child: SizedBox(
            height: height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                // Centered when the button is stretched to full width.
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: c.onPrimary, size: 24),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: c.displayFont,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: c.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A small rounded tag such as "Tip" or "Deposit 300 €".
class SkinChip extends StatelessWidget {
  const SkinChip(this.label, {super.key, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tint = color ?? c.muted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
        border: c.skin == SkinId.bina
            ? null
            : Border.all(color: tint.withValues(alpha: 0.7)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: tint,
        ),
      ),
    );
  }
}

/// A small uppercase label above a group.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.6,
        color: color ?? c.muted,
      ),
    );
  }
}
