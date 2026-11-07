import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/error_text.dart';
import '../services/app_state_repository.dart';
import '../services/background_save.dart';
import '../services/feedback_repository.dart';
import '../services/live_data.dart';
import '../services/update_checker.dart';
import '../theme/app_colors.dart';
import 'confirm_delete.dart';
import 'skin_widgets.dart';

/// Only the owner sees this: the lock, the required version and the band's
/// feedback.
class OwnerSection extends StatelessWidget {
  const OwnerSection({super.key, required this.data});

  final LiveData data;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = context.colors;
    final repo = AppStateRepository.instance;
    return StreamBuilder<AppState>(
      stream: repo.watch(),
      builder: (context, snap) {
        final state = snap.data ?? const AppState();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SkinCard(
              accent: state.locked ? c.tip : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        state.locked
                            ? Icons.lock_rounded
                            : Icons.lock_open_rounded,
                        color: state.locked ? c.tipText : c.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          state.locked ? t.appLocked : t.appUnlocked,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    icon: Icon(
                      state.locked
                          ? Icons.lock_open_rounded
                          : Icons.lock_rounded,
                    ),
                    label: Text(state.locked ? t.unlockApp : t.lockApp),
                    onPressed: () => _toggleLock(context, state.locked),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SkinCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionLabel(t.requiredVersion),
                  const SizedBox(height: 4),
                  Text(
                    state.minBuild == 0
                        ? t.anyVersion
                        : t.versionRequired(state.minBuild),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _RequireLatestButton(),
                      if (state.minBuild > 0)
                        TextButton(
                          onPressed: () => saveInBackground(
                            context,
                            () => repo.setMinBuild(0),
                          ),
                          child: Text(t.allowAnyVersion),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _FeedbackList(data: data),
          ],
        );
      },
    );
  }

  Future<void> _toggleLock(BuildContext context, bool locked) async {
    final t = AppLocalizations.of(context);
    if (!locked) {
      final ok = await confirmDelete(
        context,
        t.lockConfirm,
        confirmLabel: t.lockApp,
      );
      if (!ok || !context.mounted) return;
    }
    saveInBackground(
      context,
      () => AppStateRepository.instance.setLocked(!locked),
    );
  }
}

/// Reads the newest release and requires its build from everyone.
class _RequireLatestButton extends StatefulWidget {
  @override
  State<_RequireLatestButton> createState() => _RequireLatestButtonState();
}

class _RequireLatestButtonState extends State<_RequireLatestButton> {
  late final Future<ReleaseInfo> _latest = UpdateChecker.instance.latest();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return FutureBuilder<ReleaseInfo>(
      future: _latest,
      builder: (context, snap) {
        final release = snap.data;
        if (snap.hasError) return Text(errorText(t, snap.error!));
        return OutlinedButton(
          onPressed: release == null
              ? null
              : () => saveInBackground(
                  context,
                  () => AppStateRepository.instance.setMinBuild(release.build),
                ),
          child: Text(t.requireLatest(release?.version ?? '…')),
        );
      },
    );
  }
}

class _FeedbackList extends StatelessWidget {
  const _FeedbackList({required this.data});

  final LiveData data;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = context.colors;
    return SkinCard(
      child: StreamBuilder<List<FeedbackItem>>(
        stream: FeedbackRepository.instance.watchAll(),
        builder: (context, snap) {
          final items = snap.data ?? const <FeedbackItem>[];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel(t.feedbackList),
              const SizedBox(height: 6),
              if (items.isEmpty)
                Text(t.noFeedback, style: TextStyle(color: c.muted)),
              for (final f in items.take(30))
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.nameOf(f.uid),
                        style: TextStyle(color: c.muted, fontSize: 12.5),
                      ),
                      Text(f.text),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
