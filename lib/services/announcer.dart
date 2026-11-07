import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/gig.dart';
import 'worker_client.dart';

/// One record this phone should ask the worker to announce.
typedef Announcement = ({AnnounceKind kind, String id, String key});

/// What [me] still owes the band a push for, going by what the server has:
/// gigs this account changed that the worker has not caught up with, tips it
/// entered, and, for a leader, members it added or removed.
///
/// Going by the data and not by the save covers a change made offline, the
/// app closed before it reached the server, and the worker being down: each
/// is picked up on the next change or start. The key changes with every
/// revision, so a second edit is asked about even in the same session.
List<Announcement> pendingAnnouncements({
  required String me,
  required bool leader,
  required Iterable<Gig> gigs,
  required Iterable<AppUser> users,
}) => [
  for (final g in gigs)
    if (g.createdAt != null && g.updatedBy == me && g.pushRev < g.rev)
      (kind: AnnounceKind.gig, id: g.id, key: 'gig:${g.id}:${g.rev}'),
  for (final g in gigs)
    if (g.createdAt != null &&
        g.tipBy == me &&
        g.tipMinor != null &&
        !g.tipAnnounced)
      (kind: AnnounceKind.tip, id: g.id, key: 'tip:${g.id}:${g.tipMinor}'),
  if (leader)
    for (final u in users)
      if (!u.isOwner && !u.announced)
        (
          kind: AnnounceKind.member,
          id: u.uid,
          key: 'member:${u.uid}:${u.disabled}',
        ),
];

/// Watches the live data and asks the worker for each pending announcement,
/// once per key per session.
class Announcer {
  Announcer({
    required this._source,
    required this._pending,
    required this._announce,
  });

  final Listenable _source;
  final List<Announcement> Function() _pending;
  final Future<int> Function(AnnounceKind kind, String id) _announce;
  final Set<String> _asked = {};

  void start() {
    _source.addListener(_check);
    _check();
  }

  void dispose() => _source.removeListener(_check);

  void _check() {
    for (final a in _pending()) {
      if (_asked.add(a.key)) {
        _announce(a.kind, a.id).catchError((Object _) {
          // Offline, or the worker is down: asked again on the next start.
          return 0;
        });
      }
    }
  }
}
