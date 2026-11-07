import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/app_user.dart';
import '../models/band_push.dart';
import '../services/announcer.dart';
import '../services/app_state_repository.dart';
import '../services/live_data.dart';
import '../services/push_service.dart';
import '../services/update_checker.dart';
import '../services/worker_client.dart';
import '../widgets/band_push_snack_bar.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/skin_widgets.dart';
import '../widgets/sync_banner.dart';
import '../widgets/update_dialog.dart';
import 'band_tab.dart';
import 'calendar_tab.dart';
import 'gig_detail_screen.dart';
import 'gig_form_screen.dart';
import 'gigs_tab.dart';
import 'report_tab.dart';

/// Signed-in shell: four tabs (gigs, calendar, report, band) over one
/// [LiveData], plus pushes, announcements and the update check.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.profile, required this.appState});

  final AppUser profile;
  final AppState appState;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LiveData _data = LiveData();
  int _tab = 0;
  bool _updateDialogOpen = false;
  late final StreamSubscription<void> _releaseSub;
  late final StreamSubscription<BandPush> _pushSub;
  late final StreamSubscription<String> _openSub;
  late final Announcer _announcer = Announcer(
    source: _data,
    pending: () => pendingAnnouncements(
      me: widget.profile.uid,
      leader: widget.profile.isAdmin,
      gigs: _data.gigs ?? const [],
      users: _data.users ?? const [],
    ),
    announce: announce,
  );

  @override
  void initState() {
    super.initState();
    _checkForUpdate();
    // A release push (received in the foreground or tapped) re-runs the same
    // check, which then shows the download dialog.
    final push = PushService.instance;
    _releaseSub = push.onRelease.listen((_) => _checkForUpdate());
    _pushSub = push.onPush.listen(_showPush);
    _openSub = push.onOpen.listen(_openGig);
    push.start();
    push.registerToken();
    _announcer.start();
  }

  @override
  void dispose() {
    _releaseSub.cancel();
    _pushSub.cancel();
    _openSub.cancel();
    _announcer.dispose();
    _data.dispose();
    super.dispose();
  }

  void _showPush(BandPush push) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      bandPushSnackBar(
        AppLocalizations.of(context),
        push,
        onOpen: push.gigId.isEmpty ? null : () => _openGig(push.gigId),
      ),
    );
  }

  void _openGig(String id) {
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            GigDetailScreen(data: _data, profile: widget.profile, gigId: id),
      ),
    );
  }

  /// On app start and on release pushes; silent when offline or already up
  /// to date, and never stacks a second dialog on an open one.
  Future<void> _checkForUpdate() async {
    if (_updateDialogOpen) return;
    final result = await UpdateChecker.instance.check();
    if (!mounted || result is! UpdateAvailable || _updateDialogOpen) return;
    _updateDialogOpen = true;
    await showUpdateDialog(context, result);
    _updateDialogOpen = false;
  }

  void _addGig([DateTime? day]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            GigFormScreen(data: _data, profile: widget.profile, day: day),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final profile = widget.profile;
    return Scaffold(
      // The banner floats over the tabs: pushing them down would leave each
      // tab's own status-bar inset under a banner that already sits below it.
      body: Stack(
        children: [
          Positioned.fill(
            child: ListenableBuilder(
              listenable: _data,
              builder: (context, _) => IndexedStack(
                index: _tab,
                children: [
                  GigsTab(data: _data, profile: profile),
                  CalendarTab(data: _data, profile: profile, onAdd: _addGig),
                  ReportTab(data: _data, profile: profile),
                  BandTab(
                    data: _data,
                    profile: profile,
                    appState: widget.appState,
                  ),
                ],
              ),
            ),
          ),
          const SyncBanner(),
        ],
      ),
      floatingActionButton: _tab <= 1
          ? PrimaryPill(
              label: t.addGig,
              icon: Icons.add_rounded,
              onPressed: _addGig,
            )
          : null,
      bottomNavigationBar: BottomNav(
        index: _tab,
        onSelect: (i) => setState(() => _tab = i),
      ),
    );
  }
}
