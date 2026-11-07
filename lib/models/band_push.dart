/// The kinds of push the worker sends. The names travel in `data.kind` and
/// must match `push_worker/src/message.js`.
enum PushKind {
  gigNew,
  gigChanged,
  gigCancelled,
  tip,
  tomorrow,
  today,
  tipReminder,
  report,
  memberAdded,
  memberRemoved,
  feedback,
}

/// A push from the worker, read from its data. Android shows it by itself
/// while the app is closed; while it is open, the app shows it instead.
class BandPush {
  const BandPush({
    required this.kind,
    this.gigId = '',
    this.arg = '',
    this.text = '',
  });

  final PushKind kind;

  /// The gig to open on a tap, or empty.
  final String gigId;

  /// The date or month in the title, as sent.
  final String arg;

  /// The body, as sent.
  final String text;

  /// Null for anything that is not a band push (a release, say).
  static BandPush? fromData(Map<String, dynamic> data) {
    if (data['type'] != 'band') return null;
    final name = data['kind'];
    for (final k in PushKind.values) {
      if (k.name == name) {
        return BandPush(
          kind: k,
          gigId: data['gigId'] as String? ?? '',
          arg: data['arg'] as String? ?? '',
          text: data['text'] as String? ?? '',
        );
      }
    }
    return null;
  }
}
