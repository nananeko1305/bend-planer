import 'package:flutter/material.dart';

/// The three looks a member can pick in Settings. Bina is the default and the
/// one the launcher icon belongs to.
enum SkinId { bina, neon, zlato }

/// Everything that changes between the looks, carried by the [ThemeData] so
/// that every widget reading `context.colors` rebuilds when the look changes.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.skin,
    required this.primary,
    required this.secondary,
    required this.tip,
    required this.tipText,
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.border,
    required this.ink,
    required this.muted,
    required this.onPrimary,
    required this.buttonGradient,
    required this.heroGradient,
    required this.displayFont,
    required this.bodyFont,
    required this.radius,
    this.glow,
  });

  final SkinId skin;

  /// Accent: the selected tab, today's gig, the main button.
  final Color primary;
  final Color secondary;

  /// Everything about tips, and warnings.
  final Color tip;

  /// [tip] lightened enough to be read as small text on [surface].
  final Color tipText;
  final Color background;
  final Color surface;
  final Color surfaceHigh;
  final Color border;

  /// Main text color.
  final Color ink;

  /// Secondary text; passes 4.5:1 on [surface].
  final Color muted;

  /// Text and icons on [buttonGradient].
  final Color onPrimary;
  final List<Color> buttonGradient;

  /// The big amount on the home screen and the report; null = [glow] instead.
  final List<Color>? heroGradient;
  final String displayFont;
  final String bodyFont;
  final double radius;

  /// Neon only: the glow around display text.
  final List<Shadow>? glow;

  /// Tinted background for avatars and highlights.
  Color get soft => primary.withValues(alpha: 0.16);

  /// Full-screen pages without the home backdrop (login, notices).
  BoxDecoration get softGradient => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color.lerp(background, secondary, 0.22)!, background],
    ),
  );

  /// A display-font style, with the look's glow when it has one.
  TextStyle display(double size, {FontWeight? weight, Color? color}) =>
      TextStyle(
        fontFamily: displayFont,
        fontSize: size,
        fontWeight: weight ?? FontWeight.w800,
        color: color ?? ink,
        height: 1.1,
        shadows: glow,
      );

  @override
  AppColors copyWith() => this;

  /// Looks switch at once; there is nothing sensible between two of them.
  @override
  AppColors lerp(AppColors? other, double t) =>
      t < 0.5 || other == null ? this : other;
}

extension AppColorsX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
