import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../models/app_user.dart';
import '../models/gig.dart';
import '../services/background_save.dart';
import '../services/gig_repository.dart';
import '../services/live_data.dart';
import '../theme/app_colors.dart';
import '../widgets/confirm_delete.dart';
import '../widgets/gig_card.dart';
import '../widgets/gig_format.dart';
import '../widgets/skin_widgets.dart';
import '../widgets/tip_dialog.dart';
import 'gig_form_screen.dart';

/// Everything about one gig, and what this member may do with it. Follows the
/// live data, so a change by someone else shows at once.
class GigDetailScreen extends StatelessWidget {
  const GigDetailScreen({
    super.key,
    required this.data,
    required this.profile,
    required this.gigId,
  });

  final LiveData data;
  final AppUser profile;
  final String gigId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: data,
      builder: (context, _) {
        final gig = data.gigById(gigId);
        final t = AppLocalizations.of(context);
        if (gig == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: data.ready
                  ? Text(t.gigGone)
                  : const CircularProgressIndicator(),
            ),
          );
        }
        return _Detail(data: data, profile: profile, gig: gig);
      },
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.data, required this.profile, required this.gig});

  final LiveData data;
  final AppUser profile;
  final Gig gig;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = context.colors;
    final now = DateTime.now();
    final d = gig.draft;
    final canEdit = profile.canEdit(gig.ownerId);
    final played = gig.daysFrom(now) <= 0;
    final mapQuery = [
      d.venue,
      d.address,
      d.city,
    ].where((s) => s.isNotEmpty).join(', ');
    return Scaffold(
      appBar: AppBar(
        title: Text(gigTypeLabel(t, gig.type)),
        actions: [
          if (canEdit)
            IconButton(
              tooltip: t.edit,
              icon: const Icon(Icons.edit_rounded),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      GigFormScreen(data: data, profile: profile, gig: gig),
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          SkinCard(
            highlight: gig.daysFrom(now) == 0 && !gig.cancelled,
            child: Row(
              children: [
                DateBlock(day: gig.day, highlight: gig.daysFrom(now) == 0),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (gig.cancelled)
                        SkinChip(t.cancelledChip, color: c.muted),
                      Text(
                        gigDateTime(context, gig),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      HeroText(priceOf(context, gig), size: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Row(
            icon: Icons.place_rounded,
            label: t.whereLabel,
            value: [
              d.venue,
              d.address,
              d.city,
            ].where((s) => s.isNotEmpty).join('\n'),
            action: mapQuery.isEmpty
                ? null
                : _Action(
                    t.openMap,
                    Icons.map_rounded,
                    () => _launch(
                      Uri(
                        scheme: 'geo',
                        path: '0,0',
                        queryParameters: {'q': mapQuery},
                      ),
                    ),
                  ),
          ),
          if (d.clientName.isNotEmpty || d.clientPhone.isNotEmpty)
            _Row(
              icon: Icons.person_rounded,
              label: t.clientLabel,
              value: [
                d.clientName,
                d.clientPhone,
              ].where((s) => s.isNotEmpty).join('\n'),
              action: d.clientPhone.isEmpty
                  ? null
                  : _Action(
                      t.call,
                      Icons.call_rounded,
                      () => _launch(Uri(scheme: 'tel', path: d.clientPhone)),
                    ),
            ),
          if (d.depositMinor > 0)
            _Row(
              icon: Icons.savings_rounded,
              label: t.depositLabel,
              value: [
                moneyOf(context, d.depositMinor, gig.currency),
                if (d.depositHolder.isNotEmpty) data.nameOf(d.depositHolder),
              ].join(' · '),
            ),
          _Row(
            icon: Icons.volunteer_activism_rounded,
            label: t.tipLabel,
            value: !gig.hasTip
                ? t.noTipChip
                : gig.tipMinor != null
                ? '${moneyOf(context, gig.tipMinor!, gig.currency)}\n${t.tipBy(data.nameOf(gig.tipBy))}'
                : (played ? t.tipWaiting : t.tipLater),
            action: gig.hasTip && played && !gig.cancelled
                ? _Action(
                    gig.tipMinor == null ? t.enterTip : t.changeTip,
                    Icons.edit_rounded,
                    () => showTipDialog(context, gig, profile),
                  )
                : null,
          ),
          if (d.notes.isNotEmpty)
            _Row(
              icon: Icons.notes_rounded,
              label: t.notesLabel,
              value: d.notes,
            ),
          const SizedBox(height: 8),
          Text(
            t.addedBy(data.nameOf(gig.ownerId)),
            style: TextStyle(color: c.muted),
          ),
          if (canEdit) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              icon: Icon(
                gig.cancelled
                    ? Icons.restore_rounded
                    : Icons.event_busy_rounded,
              ),
              label: Text(gig.cancelled ? t.restoreGig : t.cancelGig),
              onPressed: () => _toggleCancel(context),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              icon: const Icon(Icons.delete_outline_rounded),
              label: Text(t.deleteGig),
              onPressed: () => _delete(context),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _launch(Uri uri) async {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _toggleCancel(BuildContext context) async {
    final t = AppLocalizations.of(context);
    if (!gig.cancelled) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(t.cancelGigConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(t.keepGig),
            ),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(96, 46)),
              onPressed: () => Navigator.pop(context, true),
              child: Text(t.cancelGig),
            ),
          ],
        ),
      );
      if (ok != true || !context.mounted) return;
    }
    saveInBackground(
      context,
      () =>
          GigRepository.instance.setCancelled(gig, !gig.cancelled, profile.uid),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final t = AppLocalizations.of(context);
    final ok = await confirmDelete(context, t.deleteGigConfirm);
    if (!ok || !context.mounted) return;
    saveInBackground(context, () => GigRepository.instance.delete(gig));
    Navigator.of(context).pop();
  }
}

class _Action {
  const _Action(this.label, this.icon, this.onTap);
  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    required this.value,
    this.action,
  });

  final IconData icon;
  final String label;
  final String value;
  final _Action? action;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final a = action;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SkinCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: c.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionLabel(label),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (a != null)
              TextButton.icon(
                onPressed: a.onTap,
                icon: Icon(a.icon, size: 18),
                label: Text(a.label),
              ),
          ],
        ),
      ),
    );
  }
}
