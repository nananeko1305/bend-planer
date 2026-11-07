import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/day_key.dart';
import '../models/gig.dart';
import 'band_settings_repository.dart';
import 'gig_repository.dart';
import 'user_repository.dart';

/// Live snapshot of the band and its gigs. One instance per signed-in
/// session, owned by the home screen; every tab reads from it instead of
/// opening its own Firestore listeners.
class LiveData extends ChangeNotifier {
  LiveData({bool listen = true}) {
    if (!listen) return;
    _watch(UserRepository.instance.watchAll, (v) {
      users = v;
      _usersById = {for (final u in v) u.uid: u};
    });
    _watch(GigRepository.instance.watchAll, (v) => gigs = v);
    _watch(BandSettingsRepository.instance.watch, (v) => band = v);
  }

  static const _firstRetry = Duration(seconds: 5);
  static const _longestRetry = Duration(minutes: 1);

  final List<StreamSubscription<Object?>> _subs = [];
  final List<Timer> _retries = [];
  bool _disposed = false;

  List<AppUser>? users;
  List<Gig>? gigs;

  /// The band's defaults; the default itself until read.
  BandSettings band = const BandSettings();
  Object? error;
  Map<String, AppUser> _usersById = const {};

  bool get ready => users != null && gigs != null;

  /// "First Last" of a member, or "—" when unknown.
  String nameOf(String uid) => _usersById[uid]?.displayName ?? '—';

  AppUser? userById(String uid) => _usersById[uid];

  /// The band as the band sees it: the owner stays out of it.
  List<AppUser> get members => [
    for (final u in users ?? const <AppUser>[])
      if (!u.isOwner && !u.disabled) u,
  ];

  List<AppUser> get removedMembers => [
    for (final u in users ?? const <AppUser>[])
      if (!u.isOwner && u.disabled) u,
  ];

  Gig? gigById(String id) {
    for (final g in gigs ?? const <Gig>[]) {
      if (g.id == id) return g;
    }
    return null;
  }

  /// Today and later, not cancelled, soonest first.
  List<Gig> upcoming(DateTime now) =>
      _sorted((g) => g.statusOn(now) == GigStatus.upcoming, newestFirst: false);

  /// Before today, cancelled ones too, newest first.
  List<Gig> past(DateTime now) =>
      _sorted((g) => g.statusOn(now) != GigStatus.upcoming, newestFirst: true);

  /// Played gigs whose tip nobody has entered yet, oldest first.
  List<Gig> awaitingTip(DateTime now) => _sorted(
    (g) => g.statusOn(now) == GigStatus.awaitingTip,
    newestFirst: false,
  );

  /// The gigs on one day, by start time.
  List<Gig> on(DateTime day) {
    final key = dateKey(day);
    return _sorted((g) => g.date == key, newestFirst: false);
  }

  List<Gig> _sorted(bool Function(Gig) test, {required bool newestFirst}) {
    final list = [
      for (final g in gigs ?? const <Gig>[])
        if (test(g)) g,
    ];
    int order(Gig a, Gig b) {
      final byDay = a.date.compareTo(b.date);
      return byDay != 0 ? byDay : a.draft.start.compareTo(b.draft.start);
    }

    list.sort(newestFirst ? (a, b) => order(b, a) : order);
    return list;
  }

  /// Subscribes to a collection, and subscribes again after a failure.
  ///
  /// A Firestore listener that errors is finished: it never recovers on its
  /// own. Rules that have just been deployed, or a member brought back a
  /// moment ago, would otherwise leave the app waiting on data that never
  /// arrives until it is force-closed.
  void _watch<T>(
    Stream<T> Function() open,
    void Function(T) set, {
    Duration wait = _firstRetry,
  }) {
    late final StreamSubscription<T> sub;
    sub = open().listen(
      (value) {
        set(value);
        error = null;
        notifyListeners();
      },
      onError: (Object e) {
        error = e;
        notifyListeners();
        sub.cancel();
        _subs.remove(sub);
        _retryLater(open, set, wait);
      },
    );
    _subs.add(sub);
  }

  void _retryLater<T>(
    Stream<T> Function() open,
    void Function(T) set,
    Duration wait,
  ) {
    late final Timer timer;
    timer = Timer(wait, () {
      _retries.remove(timer);
      if (_disposed) return;
      // Backs off, so a collection nobody may read is not retried in a tight
      // loop for as long as the app is open.
      final next = wait * 2;
      _watch(open, set, wait: next > _longestRetry ? _longestRetry : next);
    });
    _retries.add(timer);
  }

  @override
  void dispose() {
    _disposed = true;
    for (final s in _subs) {
      s.cancel();
    }
    for (final t in _retries) {
      t.cancel();
    }
    super.dispose();
  }
}
