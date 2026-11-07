import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/locale_controller.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/live_data.dart';
import '../services/reminder_health.dart';
import '../theme/app_colors.dart';
import '../theme/theme_controller.dart';
import '../widgets/change_password_dialog.dart';
import '../widgets/member_dialog.dart';
import '../widgets/owner_section.dart';
import '../widgets/skin_picker.dart';
import '../widgets/skin_widgets.dart';
import '../widgets/update_tiles.dart';
import 'feedback_screen.dart';
import 'share_app_screen.dart';

/// The member's own things: profile, look, language, notifications, and for
/// the owner the lock.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.data, required this.profile});

  final LiveData data;
  final AppUser profile;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    const gap = SizedBox(height: 22);
    void open(Widget screen) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    return Scaffold(
      appBar: AppBar(title: Text(t.settings)),
      body: ListenableBuilder(
        listenable: Listenable.merge([data, themeController, localeController]),
        builder: (context, _) {
          final me = data.userById(profile.uid) ?? profile;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
            children: [
              SectionLabel(t.profile),
              const SizedBox(height: 8),
              SkinCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_rounded),
                      title: Text(
                        me.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      // Without a name the title already is the email.
                      subtitle: me.displayName == me.email
                          ? null
                          : Text(
                              me.email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                      trailing: const Icon(Icons.edit_rounded),
                      onTap: () => showMemberDialog(context, member: me),
                    ),
                    ListTile(
                      leading: const Icon(Icons.password_rounded),
                      title: Text(t.changePassword),
                      onTap: () => showChangePasswordDialog(context),
                    ),
                  ],
                ),
              ),
              gap,
              SectionLabel(t.look),
              const SizedBox(height: 8),
              const SkinPicker(),
              gap,
              SectionLabel(t.language),
              const SizedBox(height: 8),
              const _LanguagePicker(),
              gap,
              SkinCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.notifications_rounded),
                      title: Text(t.notifications),
                      subtitle: Text(t.notificationsHint),
                      onTap: ReminderHealth.instance.openNotificationSettings,
                    ),
                    ListTile(
                      leading: const Icon(Icons.qr_code_rounded),
                      title: Text(t.shareApp),
                      onTap: () => open(const ShareAppScreen()),
                    ),
                    ListTile(
                      leading: const Icon(Icons.lightbulb_rounded),
                      title: Text(t.sendFeedback),
                      onTap: () => open(FeedbackScreen(profile: me)),
                    ),
                    const UpdateTiles(),
                  ],
                ),
              ),
              if (me.isOwner) ...[
                gap,
                SectionLabel(t.ownerSection, color: context.colors.primary),
                const SizedBox(height: 8),
                OwnerSection(data: data),
              ],
              gap,
              OutlinedButton.icon(
                icon: const Icon(Icons.logout_rounded),
                label: Text(t.signOut),
                onPressed: () {
                  Navigator.of(context).popUntil((r) => r.isFirst);
                  AuthService.instance.signOut();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final current = localeController.locale?.languageCode;
    final options = <(String?, String)>[
      (null, t.languagePhone),
      ('sr', 'Srpski'),
      ('en', 'English'),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (code, label) in options)
          ChoiceChip(
            label: Text(label),
            selected: current == code,
            onSelected: (_) => localeController.select(
              code == null
                  ? null
                  : (code == 'sr' ? kSerbianLatin : const Locale('en')),
            ),
          ),
      ],
    );
  }
}
