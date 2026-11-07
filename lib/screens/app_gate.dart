import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../models/app_user.dart';
import '../services/app_state_repository.dart';
import '../services/update_checker.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import 'status_screen.dart';

/// Between the profile and the app: the owner's lock and the oldest build
/// still allowed, from `meta/app`. Watched live, so locking takes everyone
/// out at once and unlocking lets them back in. The owner is never locked
/// out, or nobody could unlock.
class AppGate extends StatefulWidget {
  const AppGate({super.key, required this.profile});

  final AppUser profile;

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  final Stream<AppState> _state = AppStateRepository.instance.watch();
  final Future<PackageInfo> _app = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: _app,
      builder: (context, app) {
        final build = int.tryParse(app.data?.buildNumber ?? '') ?? 0;
        return StreamBuilder<AppState>(
          stream: _state,
          builder: (context, snap) {
            // Until the state arrives (or if it cannot be read, as offline on
            // a first start), the app opens: the rules lock the data anyway.
            final state = snap.data ?? const AppState();
            final owner = widget.profile.isOwner;
            if (state.locked && !owner) {
              return _LockedScreen(leader: widget.profile.isAdmin);
            }
            if (build > 0 && build < state.minBuild && !owner) {
              return const _ForceUpdateScreen();
            }
            return HomeScreen(profile: widget.profile, appState: state);
          },
        );
      },
    );
  }
}

class _LockedScreen extends StatelessWidget {
  const _LockedScreen({required this.leader});

  /// The band leader is the one others ask, so is pointed further up.
  final bool leader;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = context.colors;
    return StatusScreen(
      icon: Icons.lock_rounded,
      title: t.lockedTitle,
      body: t.lockedBody,
      extra: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(c.radius),
              border: Border.all(color: c.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.lockedSafe,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(t.lockedSafeBody, style: TextStyle(color: c.muted)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            leader ? t.lockedContactLeader : t.lockedContact,
            textAlign: TextAlign.center,
            style: TextStyle(color: c.muted),
          ),
        ],
      ),
    );
  }
}

class _ForceUpdateScreen extends StatelessWidget {
  const _ForceUpdateScreen();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return StatusScreen(
      icon: Icons.system_update_rounded,
      title: t.forceUpdateTitle,
      body: t.forceUpdateBody,
      actionLabel: t.download,
      onAction: () => launchUrl(
        Uri.parse(kDownloadPageUrl),
        mode: LaunchMode.externalApplication,
      ),
    );
  }
}
