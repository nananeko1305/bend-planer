import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/app_user.dart';
import '../screens/settings_screen.dart';
import '../services/live_data.dart';
import '../theme/app_colors.dart';
import 'app_logo.dart';

/// The top row of every tab: the logo or a title, and the way to Settings.
class TabHeader extends StatelessWidget {
  const TabHeader({
    super.key,
    required this.data,
    required this.profile,
    this.title,
  });

  final LiveData data;
  final AppUser profile;

  /// Null on the first tab, which shows the app's name with the logo.
  final String? title;

  /// The app's name next to the logo; Neon writes it in tube letters. Also
  /// used by the look previews on the welcome screen.
  static TextStyle appNameStyle(AppColors c) => c.skin == SkinId.neon
      ? TextStyle(
          fontFamily: 'Monoton',
          fontSize: 23,
          color: const Color(0xFFFFE1F7),
          shadows: c.glow,
        )
      : c.display(20);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 10, 6),
      child: Row(
        children: [
          if (title == null) ...[
            const AppLogo(size: 34),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              title ?? t.appTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: title == null ? appNameStyle(c) : c.display(24),
            ),
          ),
          IconButton(
            tooltip: t.settings,
            icon: Icon(Icons.settings_rounded, color: c.ink),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SettingsScreen(data: data, profile: profile),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
