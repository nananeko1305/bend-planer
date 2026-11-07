import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/error_text.dart';
import '../models/app_user.dart';
import '../services/user_repository.dart';
import 'app_gate.dart';
import 'status_screen.dart';

/// Decides what a signed-in account sees, from its `users/{uid}` profile:
/// the app, a "removed" notice, or the one-time owner claim. Watched live, so
/// removing someone throws them out at once.
class ProfileGate extends StatefulWidget {
  const ProfileGate({super.key, required this.user});

  final User user;

  @override
  State<ProfileGate> createState() => _ProfileGateState();
}

class _ProfileGateState extends State<ProfileGate> {
  final _users = UserRepository.instance;
  late final Stream<AppUser?> _profile = _users.watchProfile(widget.user.uid);
  late Future<bool> _canClaim = _users.canClaimOwner();
  bool _claiming = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return StreamBuilder<AppUser?>(
      stream: _profile,
      builder: (context, snap) {
        if (snap.hasError) {
          return StatusScreen(
            icon: Icons.cloud_off_rounded,
            title: t.errGeneric,
            body: errorText(t, snap.error!),
          );
        }
        if (!snap.hasData && snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final profile = snap.data;
        if (profile == null) return _noProfile(t);
        if (profile.disabled) {
          return StatusScreen(
            icon: Icons.person_off_rounded,
            title: t.removedTitle,
            body: t.removedBody,
          );
        }
        return AppGate(profile: profile);
      },
    );
  }

  Widget _noProfile(AppLocalizations t) {
    return FutureBuilder<bool>(
      future: _canClaim,
      builder: (context, snap) {
        if (snap.hasError) {
          // A fresh install offline cannot ask the server; let it try again.
          return StatusScreen(
            icon: Icons.cloud_off_rounded,
            title: t.errGeneric,
            body: errorText(t, snap.error!),
            actionLabel: t.tryAgain,
            onAction: () => setState(() => _canClaim = _users.canClaimOwner()),
          );
        }
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.data == true) {
          return StatusScreen(
            icon: Icons.mic_rounded,
            title: t.claimOwnerTitle,
            body: t.claimOwnerBody,
            actionLabel: t.claimOwnerButton,
            loading: _claiming,
            onAction: _claiming ? null : () => _claim(t),
          );
        }
        return StatusScreen(
          icon: Icons.lock_outline_rounded,
          title: t.noAccessTitle,
          body: t.noAccessBody,
        );
      },
    );
  }

  /// Awaited, unlike other writes: nothing else can happen before it.
  Future<void> _claim(AppLocalizations t) async {
    setState(() => _claiming = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _users.claimOwner(widget.user);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(errorText(t, e))));
      if (mounted) {
        setState(() {
          _claiming = false;
          _canClaim = _users.canClaimOwner();
        });
      }
    }
  }
}
