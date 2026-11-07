import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../models/app_user.dart';
import '../services/app_state_repository.dart';
import '../services/background_save.dart';
import '../services/live_data.dart';
import '../services/user_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/confirm_delete.dart';
import '../widgets/member_dialog.dart';
import '../widgets/skin_widgets.dart';
import '../widgets/tab_header.dart';

/// The band: who plays what and how to reach them. Leaders add, edit and
/// remove members here; the owner never shows up in it.
class BandTab extends StatelessWidget {
  const BandTab({
    super.key,
    required this.data,
    required this.profile,
    required this.appState,
  });

  final LiveData data;
  final AppUser profile;
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = context.colors;
    final leader = profile.isAdmin;
    final members = data.members;
    final removed = data.removedMembers;
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          // The header keeps its own insets, the same on every tab.
          TabHeader(data: data, profile: profile, title: t.bandTitle),
          for (final child in <Widget>[
            if (leader) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: PrimaryPill(
                  label: t.addMember,
                  icon: Icons.person_add_alt_1_rounded,
                  height: 50,
                  onPressed: () => showMemberDialog(context),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (data.ready && members.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  t.noMembers,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: c.muted),
                ),
              ),
            for (final m in members) ...[
              _MemberCard(member: m, me: profile),
              const SizedBox(height: 10),
            ],
            if (leader && removed.isNotEmpty) ...[
              const SizedBox(height: 16),
              SectionLabel(t.removedMembers),
              const SizedBox(height: 8),
              for (final m in removed) ...[
                _MemberCard(member: m, me: profile),
                const SizedBox(height: 10),
              ],
            ],
          ])
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: child,
            ),
        ],
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.member, required this.me});

  final AppUser member;
  final AppUser me;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = context.colors;
    final self = member.uid == me.uid;
    final subtitle = [
      if (member.instrument.isNotEmpty) member.instrument,
      if (member.role == UserRole.admin) t.roleAdmin,
    ].join(' · ');
    return Opacity(
      opacity: member.disabled ? 0.6 : 1,
      child: SkinCard(
        onTap: me.isAdmin && !self ? () => _actions(context) : null,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: c.soft,
              child: Text(
                member.displayName.characters.first.toUpperCase(),
                style: c
                    .display(17, color: c.primary)
                    .copyWith(shadows: const []),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    self
                        ? '${member.displayName} ${t.youSuffix}'
                        : member.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(subtitle, style: TextStyle(color: c.muted)),
                ],
              ),
            ),
            if (member.phone.isNotEmpty && !member.disabled)
              IconButton(
                tooltip: t.call,
                icon: Icon(Icons.call_rounded, color: c.primary),
                onPressed: () =>
                    launchUrl(Uri(scheme: 'tel', path: member.phone)),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _actions(BuildContext context) async {
    final t = AppLocalizations.of(context);
    final repo = UserRepository.instance;
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!member.disabled)
              ListTile(
                leading: const Icon(Icons.edit_rounded),
                title: Text(t.editMember),
                onTap: () => Navigator.pop(ctx, 'edit'),
              ),
            if (me.isOwner && !member.disabled)
              ListTile(
                leading: const Icon(Icons.star_rounded),
                title: Text(
                  member.role == UserRole.admin ? t.makeMember : t.makeAdmin,
                ),
                onTap: () => Navigator.pop(ctx, 'role'),
              ),
            ListTile(
              leading: Icon(
                member.disabled
                    ? Icons.person_add_rounded
                    : Icons.person_remove_rounded,
              ),
              title: Text(member.disabled ? t.restoreMember : t.removeMember),
              onTap: () => Navigator.pop(ctx, 'toggle'),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted) return;
    switch (choice) {
      case 'edit':
        await showMemberDialog(context, member: member);
      case 'role':
        final next = member.role == UserRole.admin
            ? UserRole.member
            : UserRole.admin;
        saveInBackground(context, () => repo.setRole(member.uid, next));
      case 'toggle':
        if (!member.disabled) {
          final ok = await confirmDelete(
            context,
            t.removeMemberConfirm(member.displayName),
            confirmLabel: t.removeMember,
          );
          if (!ok || !context.mounted) return;
        }
        saveInBackground(
          context,
          () => repo.setDisabled(member.uid, !member.disabled),
        );
    }
  }
}
