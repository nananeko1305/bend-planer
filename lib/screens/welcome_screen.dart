import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/locale_controller.dart';
import '../theme/app_colors.dart';
import '../theme/skin_backdrop.dart';
import '../theme/theme_controller.dart';
import '../widgets/app_logo.dart';
import '../widgets/look_preview.dart';
import '../widgets/skin_widgets.dart';

/// The first start on a phone: pick the language, then the look, seeing the
/// app change as you choose. Both stay changeable in Settings.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _steps = PageController();
  int _step = 0;

  void _go(int step) {
    setState(() => _step = step);
    _steps.animateToPage(
      step,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _steps.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Back on the look step returns to the language, not out of the app.
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _go(0);
      },
      child: Scaffold(
        body: SkinBackdrop(
          child: SafeArea(
            child: PageView(
              controller: _steps,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _LanguageStep(onNext: () => _go(1)),
                _LookStep(onBack: () => _go(0), onDone: widget.onDone),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageStep extends StatelessWidget {
  const _LanguageStep({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = context.colors;
    // What the app shows now: the choice, or the phone's language until then.
    final current = Localizations.localeOf(context).languageCode;
    // Each language in its own name, with the other language's name below,
    // so both are readable before anything is chosen.
    Widget option(Locale locale, String code, String name, String hint) =>
        _LanguageCard(
          code: code,
          name: name,
          hint: hint,
          selected: current == locale.languageCode,
          onTap: () => localeController.select(locale),
        );
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                const Center(child: AppLogo(size: 96)),
                const SizedBox(height: 14),
                Text(
                  t.appTitle,
                  textAlign: TextAlign.center,
                  style: c.display(32),
                ),
                const SizedBox(height: 6),
                Text(
                  t.appTagline,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: c.muted),
                ),
                const Spacer(),
                SectionLabel(t.welcomeChooseLanguage),
                const SizedBox(height: 12),
                option(kSerbianLatin, 'SR', 'Srpski', 'Serbian (Latin)'),
                const SizedBox(height: 12),
                option(const Locale('en'), 'EN', 'English', 'Engleski'),
                const Spacer(),
                PrimaryPill(
                  label: t.welcomeNext,
                  icon: Icons.arrow_forward_rounded,
                  onPressed: onNext,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.code,
    required this.name,
    required this.hint,
    required this.selected,
    required this.onTap,
  });

  final String code;
  final String name;
  final String hint;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      selected: selected,
      button: true,
      child: SkinCard(
        highlight: selected,
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? c.primary : c.surfaceHigh,
              ),
              child: Text(
                code,
                style: c.display(16, color: selected ? c.onPrimary : c.ink),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: c.display(20)),
                  Text(hint, style: TextStyle(color: c.muted)),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: selected ? c.ink : c.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _LookStep extends StatefulWidget {
  const _LookStep({required this.onBack, required this.onDone});

  final VoidCallback onBack;
  final VoidCallback onDone;

  @override
  State<_LookStep> createState() => _LookStepState();
}

class _LookStepState extends State<_LookStep> {
  late final PageController _looks = PageController(
    viewportFraction: 0.74,
    initialPage: themeController.skin.index,
  );
  late int _page = themeController.skin.index;

  void _show(int page) {
    setState(() => _page = page);
    // The whole app takes the look in the middle, as it would after.
    themeController.select(SkinId.values[page]);
  }

  @override
  void dispose() {
    _looks.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = context.colors;
    final names = {
      SkinId.bina: (t.skinBina, t.skinBinaHint),
      SkinId.neon: (t.skinNeon, t.skinNeonHint),
      SkinId.zlato: (t.skinZlato, t.skinZlatoHint),
    };
    final shown = names[SkinId.values[_page]]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            icon: Icon(Icons.arrow_back_rounded, color: c.ink),
            onPressed: widget.onBack,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Text(
                t.welcomeLookTitle,
                textAlign: TextAlign.center,
                style: c.display(28),
              ),
              const SizedBox(height: 6),
              Text(
                t.welcomeLookHint,
                textAlign: TextAlign.center,
                style: TextStyle(color: c.muted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: PageView.builder(
            controller: _looks,
            // The chosen look glows past the carousel's edges.
            clipBehavior: Clip.none,
            itemCount: SkinId.values.length,
            onPageChanged: _show,
            itemBuilder: (context, i) => GestureDetector(
              // A look at the side comes to the middle when tapped.
              onTap: () => _looks.animateToPage(
                i,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              ),
              child: LookPreview(skin: SkinId.values[i], selected: i == _page),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(shown.$1, textAlign: TextAlign.center, style: c.display(24)),
        Text(
          shown.$2,
          textAlign: TextAlign.center,
          style: TextStyle(color: c.muted),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < SkinId.values.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == _page ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == _page ? c.primary : c.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          child: PrimaryPill(
            label: t.welcomeStart,
            icon: Icons.music_note_rounded,
            onPressed: widget.onDone,
          ),
        ),
      ],
    );
  }
}
