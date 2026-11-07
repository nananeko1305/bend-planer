import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/gig.dart';
import '../models/gig_draft.dart';

/// Reads and writes the band's gigs in `gigs/{id}`. Who may do what is in
/// `firestore.rules`; every write here matches one of its cases exactly.
class GigRepository {
  GigRepository._();
  static final GigRepository instance = GigRepository._();

  final CollectionReference<Map<String, dynamic>> _gigs = FirebaseFirestore
      .instance
      .collection('gigs');

  Stream<List<Gig>> watchAll() =>
      _gigs.snapshots().map((s) => s.docs.map(Gig.fromDoc).toList());

  /// The id is made here, so the caller has it before the server answers.
  String newId() => _gigs.doc().id;

  Future<void> create(String id, GigDraft draft, String uid) =>
      _gigs.doc(id).set(Gig.newDocMap(draft, uid));

  Future<void> update(Gig gig, GigDraft next, String uid) =>
      _gigs.doc(gig.id).update(gig.editMap(next, uid));

  Future<void> setCancelled(Gig gig, bool cancelled, String uid) =>
      _gigs.doc(gig.id).update(gig.cancelMap(cancelled, uid));

  Future<void> enterTip(Gig gig, int amountMinor, String uid) =>
      _gigs.doc(gig.id).update(Gig.tipMap(amountMinor, uid));

  /// For a gig entered by mistake; nobody is told.
  Future<void> delete(Gig gig) => _gigs.doc(gig.id).delete();
}
