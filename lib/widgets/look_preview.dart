import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/day_key.dart';
import '../models/gig.dart';
import '../models/gig_draft.dart';
import '../money/money.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/skin_backdrop.dart';
import '../theme/skins.dart';
import 'app_logo.dart';
import 'bottom_nav.dart';
import 'gig_card.dart';
import 'gig_format.dart';
import 'skin_widgets.dart';
import 'tab_header.dart';

/// The home screen drawn small in one look, from the real widgets, so the
/// welcome shows exactly what the app will look like.
class LookPreview extends StatelessWidget {
  const LookPreview({super.key, required this.skin, required this.selected});

  final SkinId skin;
  final bool selected;

  // The phone the preview is laid out on, then scaled into the frame.
  static const _canvas = Size(360, 600);

  @override
  Widget build(BuildContext context) {
    final c = kSkins[skin]!;
    return AnimatedScale(
      scale: selected ? 1 : 0.88,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: Center(
        child: AspectRatio(
          aspectRatio: _canvas.width / _canvas.height,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: selected ? c.primary : c.border,
                width: selected ? 3 : 1.5,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: c.primary.withValues(alpha: 0.45),
                        blurRadius: 28,
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: IgnorePointer(
                child: Theme(
                  data: AppTheme.build(c),
                  child: FittedBox(
                    child: SizedBox.fromSize(
                      size: _canvas,
                      child: const _MiniHome(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniHome extends StatelessWidget {
  const _MiniHome();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = context.colors;
    final locale = intlLocale(context);
    final now = DateTime.now();
    Gig sample(int days, GigType type, int eur, {int deposit = 0}) => Gig(
      id: 'preview$days',
      ownerId: '',
      draft: GigDraft(
        date: dateKey(now.add(Duration(days: days))),
        start: '20:00',
        type: type,
        venue: t.welcomeSampleVenue,
        city: t.welcomeSampleCity,
        priceMinor: eur * 100,
        currency: Currency.eur,
        depositMinor: deposit * 100,
        hasTip: true,
      ),
      createdAt: now,
    );
    return Material(
      color: c.background,
      child: Column(
        children: [
          Expanded(
            child: SkinBackdrop(
              // A screen cut off at the bottom, as on a phone: what does not fit
              // is clipped rather than squeezed.
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const AppLogo(size: 34),
                        const SizedBox(width: 10),
                        Text(t.appTitle, style: TabHeader.appNameStyle(c)),
                      ],
                    ),
                    const SizedBox(height: 30),
                    SectionLabel(
                      DateFormat.yMMMM(locale).format(now),
                      color: c.ink,
                    ),
                    const SizedBox(height: 4),
                    HeroText(
                      formatMoney(240000, Currency.eur, locale),
                      size: 48,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${t.gigCount(2)} · ${t.contractedSoFar}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: c.ink,
                      ),
                    ),
                    const SizedBox(height: 26),
                    GigCard(
                      gig: sample(1, GigType.wedding, 1500, deposit: 300),
                      now: now,
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    GigCard(
                      gig: sample(6, GigType.birthday, 900),
                      now: now,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
          // The real tabs, without the phone's own bottom inset.
          MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            child: BottomNav(index: 0, onSelect: (_) {}),
          ),
        ],
      ),
    );
  }
}
