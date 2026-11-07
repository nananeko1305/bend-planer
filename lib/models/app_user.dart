import 'package:cloud_firestore/cloud_firestore.dart';

/// owner: the person who sells and maintains the app; hidden from the band,
/// can lock it. admin: the band leader, manages members. member: everyone else.
enum UserRole { owner, admin, member }

UserRole roleFromName(String? name) => switch (name) {
  'owner' => UserRole.owner,
  'admin' => UserRole.admin,
  _ => UserRole.member,
};

/// Profile stored in `users/{uid}`. Decides who may use the app and who may
/// manage the band.
class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.role,
    required this.disabled,
    this.firstName = '',
    this.lastName = '',
    this.instrument = '',
    this.phone = '',
    this.announced = true,
  });

  final String uid;
  final String email;
  final UserRole role;

  /// Removed from the band: cannot sign in to anything, records stay.
  final bool disabled;
  final String firstName;
  final String lastName;
  final String instrument;
  final String phone;

  /// False until the push worker has told the band this member joined or
  /// left.
  final bool announced;

  bool get isOwner => role == UserRole.owner;

  /// Manages members and may change any gig. The owner can do all of it.
  bool get isAdmin => role == UserRole.admin || isOwner;

  /// Gigs may be changed or cancelled only by their author or a leader.
  bool canEdit(String authorId) => isAdmin || uid == authorId;

  /// "First Last", or the email while no name is set.
  String get displayName {
    final full = '$firstName $lastName'.trim();
    return full.isEmpty ? email : full;
  }

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return AppUser(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      role: roleFromName(data['role'] as String?),
      disabled: data['disabled'] as bool? ?? false,
      firstName: data['firstName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
      instrument: data['instrument'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      announced: data['announced'] as bool? ?? true,
    );
  }

  /// A new profile: the fields `firestore.rules` require on create, no more.
  Map<String, dynamic> toNewDocMap() => {
    'email': email,
    'role': role.name,
    'disabled': false,
    'firstName': firstName,
    'lastName': lastName,
    'instrument': instrument,
    'phone': phone,
    'announced': false,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
