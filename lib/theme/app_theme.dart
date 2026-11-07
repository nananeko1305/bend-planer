import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'theme_controller.dart';

/// Turns a look into component styling. Widgets read colors through
/// `context.colors`, never from statics, so they repaint when the look changes.
class AppTheme {
  /// Theme for the look picked on this phone (used by MaterialApp).
  static ThemeData get current => build(themeController.colors);

  static ThemeData build(AppColors c) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: c.primary,
          brightness: Brightness.dark,
        ).copyWith(
          primary: c.primary,
          secondary: c.secondary,
          surface: c.background,
          // Date and time pickers, menus and the like draw on these; left to the
          // seed they come out brown-grey instead of the look's own surfaces.
          surfaceContainerLowest: c.background,
          surfaceContainerLow: c.surface,
          surfaceContainer: c.surface,
          surfaceContainerHigh: c.surfaceHigh,
          surfaceContainerHighest: c.surfaceHigh,
          surfaceTint: Colors.transparent,
          onSurface: c.ink,
          onSurfaceVariant: c.muted,
          outline: c.border,
          error: const Color(0xFFFF6B6B),
        );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: c.bodyFont,
    );
    // Standalone text styles in the theme do not pick up `fontFamily`, so
    // each one names it again.
    TextStyle body(double size, FontWeight weight, Color color) => TextStyle(
      fontFamily: c.bodyFont,
      fontSize: size,
      fontWeight: weight,
      color: color,
    );

    return base.copyWith(
      extensions: [c],
      scaffoldBackgroundColor: c.background,
      textTheme: base.textTheme.apply(
        bodyColor: c.ink,
        displayColor: c.ink,
        fontFamily: c.bodyFont,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: c.ink,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: overlayFor(c),
        titleTextStyle: c.display(21),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(c.radius),
          side: BorderSide(color: c.border),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(color: c.border, space: 1),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surfaceHigh,
        titleTextStyle: c.display(19),
        contentTextStyle: body(15, FontWeight.w500, c.ink),
      ),
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: c.surfaceHigh),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        labelStyle: body(15, FontWeight.w600, c.muted),
        floatingLabelStyle: body(15, FontWeight.w700, c.primary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: _border(c.border, c.radius),
        enabledBorder: _border(c.border, c.radius),
        focusedBorder: _border(c.primary, c.radius, width: 2),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          minimumSize: const Size.fromHeight(54),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(c.radius),
          ),
          textStyle: body(16, FontWeight.w800, c.onPrimary),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.ink,
          minimumSize: const Size.fromHeight(50),
          side: BorderSide(color: c.border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(c.radius),
          ),
          textStyle: body(15, FontWeight.w700, c.ink),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.primary,
          textStyle: body(15, FontWeight.w700, c.primary),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.onPrimary : c.muted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.primary : c.surfaceHigh,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.surfaceHigh,
        contentTextStyle: body(14, FontWeight.w600, c.ink),
        actionTextColor: c.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: c.border),
        ),
      ),
    );
  }

  /// Light status and navigation bar icons: every look is dark. Phones that
  /// do not draw under the navigation bar (Android 14 and older) paint it in
  /// the look's background, the same as the bottom tabs.
  static SystemUiOverlayStyle overlayFor(AppColors c) =>
      SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: c.background,
        systemNavigationBarDividerColor: c.background,
      );

  static OutlineInputBorder _border(
    Color color,
    double radius, {
    double width = 1.5,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius.clamp(10, 16)),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
