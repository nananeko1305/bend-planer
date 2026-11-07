import 'package:cloud_firestore/cloud_firestore.dart';

import '../money/money.dart';
import 'day_key.dart';
import 'gig_draft.dart';

enum GigType { wedding, birthday, kafana, company, concert, other }

GigType gigTypeFromName(String? name) => GigType.values.firstWhere(
  (t) => t.name == name,
  orElse: () => GigType.other,
);

/// Where a gig stands, worked out from its date and fields; never stored.
enum GigStatus { upcoming, awaitingTip, done, cancelled }

/// One booked gig, stored in `gigs/{id}`. Everyone in the band sees it;
/// [ownerId] is who entered it.
class Gig {
  const Gig({
    required this.id,
    required this.ownerId,
    required this.draft,
    this.tipMinor,
    this.tipBy = '',
    this.cancelled = false,
    this.rev = 1,
    this.pushRev = 0,
    this.tipAnnounced = false,
    this.updatedBy = '',
    this.createdAt,
  });

  final String id;
  final String ownerId;

  /// Everything a member types in the form.
  final GigDraft draft;

  /// Entered after the gig; null until then.
  final int? tipMinor;
  final String tipBy;
  final bool cancelled;

  /// Bumped by every edit; the push worker announces until [pushRev] catches
  /// up, so an edit made offline still reaches the band.
  final int rev;
  final int pushRev;
  final bool tipAnnounced;
  final String updatedBy;

  /// Null while the gig exists only on this phone.
  final DateTime? createdAt;

  String get date => draft.date;
  DateTime get day => parseDateKey(draft.date) ?? DateTime(1970);
  GigType get type => draft.type;
  Currency get currency => draft.currency;
  int get priceMinor => draft.priceMinor;
  bool get hasTip => draft.hasTip;

  GigStatus statusOn(DateTime now) {
    if (cancelled) return GigStatus.cancelled;
    if (!day.isBefore(dayOf(now))) return GigStatus.upcoming;
    if (hasTip && tipMinor == null) return GigStatus.awaitingTip;
    return GigStatus.done;
  }

  /// Days from today to the gig: 0 today, 1 tomorrow, negative when past.
  int daysFrom(DateTime now) => daysBetween(now, day);

  /// Agreed price plus the tip, once entered.
  int get totalMinor => priceMinor + (tipMinor ?? 0);

  factory Gig.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    int intOf(String key) => (d[key] as num?)?.toInt() ?? 0;
    String str(String key) => d[key] as String? ?? '';
    return Gig(
      id: doc.id,
      ownerId: str('ownerId'),
      draft: GigDraft(
        date: str('date'),
        start: str('start'),
        end: str('end'),
        type: gigTypeFromName(d['type'] as String?),
        venue: str('venue'),
        city: str('city'),
        address: str('address'),
        clientName: str('clientName'),
        clientPhone: str('clientPhone'),
        priceMinor: intOf('priceMinor'),
        currency: currencyFromCode(d['currency'] as String?),
        depositMinor: intOf('depositMinor'),
        depositHolder: str('depositHolder'),
        hasTip: d['hasTip'] as bool? ?? false,
        notes: str('notes'),
      ),
      tipMinor: (d['tipMinor'] as num?)?.toInt(),
      tipBy: str('tipBy'),
      cancelled: d['cancelled'] as bool? ?? false,
      rev: (d['rev'] as num?)?.toInt() ?? 1,
      pushRev: intOf('pushRev'),
      tipAnnounced: d['tipAnnounced'] as bool? ?? false,
      updatedBy: str('updatedBy'),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// A new gig: exactly the fields `firestore.rules` require on create.
  static Map<String, dynamic> newDocMap(GigDraft draft, String uid) => {
    ...draft.toMap(),
    'ownerId': uid,
    'tipMinor': null,
    'tipBy': '',
    'cancelled': false,
    'rev': 1,
    'updatedBy': uid,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  /// An edit by [uid]: the form fields, plus the bump that makes the worker
  /// tell the band. A gig that loses its tip loses the tip amount too.
  Map<String, dynamic> editMap(GigDraft next, String uid) => {
    ...next.toMap(),
    if (!next.hasTip) 'tipMinor': null,
    'rev': rev + 1,
    'updatedBy': uid,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  /// Cancelling or restoring; announced like an edit.
  Map<String, dynamic> cancelMap(bool value, String uid) => {
    'cancelled': value,
    'rev': rev + 1,
    'updatedBy': uid,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  /// Entering or changing the tip. Anyone in the band may, so it touches
  /// nothing else; `tipAnnounced` goes back so the band hears the new amount.
  static Map<String, dynamic> tipMap(int amountMinor, String uid) => {
    'tipMinor': amountMinor,
    'tipBy': uid,
    'tipAnnounced': false,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
