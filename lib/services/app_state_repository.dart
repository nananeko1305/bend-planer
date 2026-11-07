import 'package:cloud_firestore/cloud_firestore.dart';

/// `meta/app`: whether the owner has locked the app, and the oldest build
/// still allowed. Every signed-in account may read it; only the owner writes.
class AppState {
  const AppState({this.locked = false, this.minBuild = 0});

  final bool locked;
  final int minBuild;

  factory AppState.fromData(Map<String, dynamic>? d) => AppState(
    locked: d?['locked'] as bool? ?? false,
    minBuild: (d?['minBuild'] as num?)?.toInt() ?? 0,
  );
}

class AppStateRepository {
  AppStateRepository._();
  static final AppStateRepository instance = AppStateRepository._();

  final DocumentReference<Map<String, dynamic>> _doc = FirebaseFirestore
      .instance
      .doc('meta/app');

  /// A missing document means unlocked, any version.
  Stream<AppState> watch() =>
      _doc.snapshots().map((s) => AppState.fromData(s.data()));

  Future<void> setLocked(bool locked) =>
      _doc.set({'locked': locked}, SetOptions(merge: true));

  Future<void> setMinBuild(int build) =>
      _doc.set({'minBuild': build}, SetOptions(merge: true));
}
