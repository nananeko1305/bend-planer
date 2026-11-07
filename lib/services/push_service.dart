import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/band_push.dart';
import 'push_token_repository.dart';

/// Notifications over Firebase Cloud Messaging: new releases and everything
/// that happens in the band.
///
/// Every install subscribes to the [releasesTopic]; CI sends one message to it
/// after publishing a new APK. Band pushes name gigs, venues and money, so they
/// never go to a topic: the push worker (see push_worker/) sends them to the
/// phones of active members one by one, which is why [registerToken] exists.
///
/// While the app is closed or in the background, Android shows a notification
/// itself. In the foreground it shows nothing, so [onPush] fires and the UI
/// shows it instead. Tapping one that names a gig fires [onOpen].
class PushService {
  PushService._();
  static final PushService instance = PushService._();

  static const releasesTopic = 'releases';
  static const _timeout = Duration(seconds: 2);

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final StreamController<void> _releases = StreamController.broadcast();
  final StreamController<BandPush> _pushes = StreamController.broadcast();
  final StreamController<String> _opens = StreamController.broadcast();
  bool _listening = false;
  bool _started = false;

  /// Emits whenever a release notification was received or opened.
  Stream<void> get onRelease => _releases.stream;

  /// Emits a band push received while the app is open.
  Stream<BandPush> get onPush => _pushes.stream;

  /// Emits the id of the gig whose push was tapped.
  Stream<String> get onOpen => _opens.stream;

  /// Idempotent; safe to call on every visit to the home screen, so a push
  /// tapped while signed out is handled once someone has signed in. Failures
  /// (no Play services, offline) are swallowed.
  Future<void> start() async {
    if (_started) return;
    _started = true;
    _listen();
    try {
      // Android 13+ shows the system permission prompt once.
      await _fcm.requestPermission();
      final initial = await _fcm.getInitialMessage();
      if (initial != null) _onOpened(initial);
    } catch (_) {
      // Retried automatically on the next app start.
      _started = false;
    }
  }

  /// Once per process, however many times [start] is retried.
  void _listen() {
    if (_listening) return;
    _listening = true;
    FirebaseMessaging.onMessage.listen(_onForeground);
    FirebaseMessaging.onMessageOpenedApp.listen(_onOpened);
    _fcm.onTokenRefresh.listen(_saveToken);
  }

  /// Ties this phone to the signed-in account. Not part of [start], which runs
  /// once: another account can sign in without the process ending, and signing
  /// out deletes the token, which takes the topic subscription with it.
  Future<void> registerToken() async {
    try {
      final token = await _fcm.getToken();
      if (token != null) await _saveToken(token);
      await _fcm.subscribeToTopic(releasesTopic);
    } catch (_) {
      // Retried automatically on the next visit to the home screen.
    }
  }

  /// Unties this phone from the account. Needs the sign-in, so it comes before
  /// signing out. Asks for the token instead of remembering it, because the
  /// process may be younger than the sign-in. Waits only briefly: offline the
  /// delete never answers, and nothing may stand in the way of signing out.
  Future<void> forgetToken() async {
    try {
      final token = await _fcm.getToken().timeout(_timeout);
      if (token == null) return;
      await PushTokenRepository.instance.delete(token).timeout(_timeout);
    } catch (_) {
      // [dropToken] still stops the pushes when there is a network.
    }
  }

  /// Makes FCM forget this phone's token, so that nothing still tied to it can
  /// reach the phone. Comes after signing out: FCM may mint the next token at
  /// once, and with nobody signed in [_saveToken] ignores it.
  Future<void> dropToken() async {
    try {
      await _fcm.deleteToken().timeout(_timeout);
    } catch (_) {
      // Offline: pushes can still reach this phone until the queued delete in
      // [forgetToken] runs, which is the next time this account signs in here.
    }
  }

  Future<void> _saveToken(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await PushTokenRepository.instance.save(token, uid);
    } catch (_) {
      // Retried automatically on the next visit to the home screen.
    }
  }

  void _onForeground(RemoteMessage message) {
    if (message.data['type'] == 'release') _releases.add(null);
    final push = BandPush.fromData(message.data);
    if (push != null) _pushes.add(push);
  }

  void _onOpened(RemoteMessage message) {
    if (message.data['type'] == 'release') _releases.add(null);
    final push = BandPush.fromData(message.data);
    if (push != null && push.gigId.isNotEmpty) _opens.add(push.gigId);
  }
}
