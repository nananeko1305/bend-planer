import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';
import '../models/app_user.dart';

/// Reads and manages the band's profiles in `users/{uid}`.
///
/// The very first account that signs in claims the owner role, once, guarded
/// by the `meta/owner` document and the Firestore rules. The owner then adds
/// the band leader, who adds everyone else.
class UserRepository {
  UserRepository._();
  static final UserRepository instance = UserRepository._();

  static const _creatorAppName = 'userCreator';

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');
  DocumentReference<Map<String, dynamic>> get _ownerMarker =>
      _db.doc('meta/owner');

  /// Emits null while the signed-in account has no profile yet.
  Stream<AppUser?> watchProfile(String uid) => _users
      .doc(uid)
      .snapshots()
      .map((doc) => doc.exists ? AppUser.fromDoc(doc) : null);

  /// Everyone, leaders first, then by name.
  Stream<List<AppUser>> watchAll() => _users.snapshots().map((snap) {
    final list = snap.docs.map(AppUser.fromDoc).toList();
    list.sort((a, b) {
      if (a.role != b.role) return a.role.index.compareTo(b.role.index);
      return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
    });
    return list;
  });

  /// True when nobody has claimed the owner role yet. Asks the server: the
  /// cache of a fresh install knows nothing.
  Future<bool> canClaimOwner() async {
    final marker = await _ownerMarker.get(
      const GetOptions(source: Source.server),
    );
    return !marker.exists;
  }

  /// Makes [user] the owner. Fails (permission denied) if already claimed.
  Future<void> claimOwner(User user) async {
    final profile = AppUser(
      uid: user.uid,
      email: user.email ?? '',
      role: UserRole.owner,
      disabled: false,
    );
    final batch = _db.batch()
      ..set(_users.doc(user.uid), profile.toNewDocMap())
      ..set(_ownerMarker, {'uid': user.uid});
    await batch.commit();
  }

  /// Creates a Firebase Auth account plus its profile, without signing the
  /// leader out: a secondary Firebase app does the sign-up, so the main app
  /// keeps its session. If the profile cannot be written, the new account is
  /// deleted again, or its email would stay taken with nobody behind it.
  Future<void> createMember({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String instrument,
    required String phone,
    UserRole role = UserRole.member,
  }) async {
    final app = await _creatorApp();
    final auth = FirebaseAuth.instanceFor(app: app);
    try {
      final cred = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final profile = AppUser(
        uid: cred.user!.uid,
        email: email.trim(),
        role: role,
        disabled: false,
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        instrument: instrument.trim(),
        phone: phone.trim(),
      );
      try {
        await _users.doc(profile.uid).set(profile.toNewDocMap());
      } catch (_) {
        await cred.user!.delete().catchError((Object _) {});
        rethrow;
      }
    } finally {
      await auth.signOut();
    }
  }

  Future<void> updateProfile(
    String uid, {
    required String firstName,
    required String lastName,
    required String instrument,
    required String phone,
  }) => _users.doc(uid).update({
    'firstName': firstName.trim(),
    'lastName': lastName.trim(),
    'instrument': instrument.trim(),
    'phone': phone.trim(),
  });

  /// Removing or bringing back a member. The worker tells the band once a
  /// member leaves: `announced` goes back to false with it.
  Future<void> setDisabled(String uid, bool disabled) =>
      _users.doc(uid).update({'disabled': disabled, 'announced': !disabled});

  /// Owner only: makes a member the band leader, or back.
  Future<void> setRole(String uid, UserRole role) =>
      _users.doc(uid).update({'role': role.name});

  Future<FirebaseApp> _creatorApp() async {
    for (final app in Firebase.apps) {
      if (app.name == _creatorAppName) return app;
    }
    return Firebase.initializeApp(
      name: _creatorAppName,
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
