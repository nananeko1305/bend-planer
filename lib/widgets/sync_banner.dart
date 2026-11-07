import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/sync_status.dart';
import '../theme/app_colors.dart';

/// A small pill floating just below the status bar while a save syncs, then
/// a check when done. It sits over the content instead of pushing it down,
/// never covers the status bar, and lets taps through to what is under it.
class SyncBanner extends StatelessWidget {
  const SyncBanner({super.key});

  static const _green = Color(0xFF2FBF71);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: ValueListenableBuilder<SyncPhase>(
              valueListenable: syncController,
              builder: (context, phase, _) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0, -0.4),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: phase == SyncPhase.idle
                    ? const SizedBox.shrink(key: ValueKey('idle'))
                    : _Pill(
                        key: ValueKey(phase),
                        syncing: phase == SyncPhase.syncing,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({super.key, required this.syncing});

  final bool syncing;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = context.colors;
    // The look's raised surface with its ink, so it reads the same in every
    // look; only the icon carries the color.
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 14),
      decoration: BoxDecoration(
        color: c.surfaceHigh,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: syncing ? c.border : SyncBanner._green),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (syncing)
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: c.primary,
              ),
            )
          else
            const Icon(
              Icons.check_circle_rounded,
              size: 17,
              color: SyncBanner._green,
            ),
          const SizedBox(width: 8),
          Text(
            syncing ? t.syncing : t.synced,
            style: TextStyle(
              color: c.ink,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
