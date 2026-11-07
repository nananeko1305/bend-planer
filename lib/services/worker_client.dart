import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

/// The push worker (see push_worker/). Its address is no secret: without the
/// ID token of an active account it does nothing.
const pushWorkerUrl = 'https://bend-planer-push.bend-manager.workers.dev';

/// What the worker can announce. Must match `push_worker/src/index.js`.
enum AnnounceKind { gig, tip, member, feedback }

/// Asks the worker to tell the band about one record, as the signed-in
/// account, and returns the status it answered with. Which answer comes back
/// makes little difference: a record stays unannounced until the worker marks
/// it, so it is asked again on the next start.
Future<int> announce(AnnounceKind kind, String id) async {
  final token = await FirebaseAuth.instance.currentUser?.getIdToken();
  if (token == null) return HttpStatus.unauthorized;
  final response = await http
      .post(
        Uri.parse('$pushWorkerUrl/announce'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'kind': kind.name, 'id': id}),
      )
      .timeout(const Duration(seconds: 20));
  return response.statusCode;
}
