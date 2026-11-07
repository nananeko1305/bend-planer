import 'package:cloud_firestore/cloud_firestore.dart';

import 'worker_client.dart';

/// One message from a member to the owner, in `feedback/{id}`.
class FeedbackItem {
  const FeedbackItem({
    required this.id,
    required this.uid,
    required this.text,
    this.createdAt,
  });

  final String id;
  final String uid;
  final String text;
  final DateTime? createdAt;

  factory FeedbackItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return FeedbackItem(
      id: doc.id,
      uid: d['uid'] as String? ?? '',
      text: d['text'] as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

/// Members write feedback; only the owner reads it. The worker pushes each
/// one to the owner's phones.
class FeedbackRepository {
  FeedbackRepository._();
  static final FeedbackRepository instance = FeedbackRepository._();

  static const maxLength = 2000;

  final CollectionReference<Map<String, dynamic>> _items = FirebaseFirestore
      .instance
      .collection('feedback');

  /// Members cannot read feedback back, so nothing on their phone can notice
  /// it later: the worker is asked as soon as the write reaches the server.
  /// If that fails, the owner still finds it in the list.
  Future<void> send(String uid, String text) {
    final ref = _items.doc();
    final write = ref.set({
      'uid': uid,
      'text': text.trim(),
      'announced': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    write
        .then((_) => announce(AnnounceKind.feedback, ref.id))
        .catchError((Object _) => 0);
    return write;
  }

  /// Newest first. Owner only; the rules refuse anyone else.
  Stream<List<FeedbackItem>> watchAll() => _items.snapshots().map((s) {
    final list = s.docs.map(FeedbackItem.fromDoc).toList();
    list.sort(
      (a, b) => (b.createdAt ?? DateTime(9999)).compareTo(
        a.createdAt ?? DateTime(9999),
      ),
    );
    return list;
  });
}
