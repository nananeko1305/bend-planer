import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/band_push.dart';

/// The title a band push carries, in the app's language. The same words as
/// the Android titles in `res/values*/strings.xml`.
String bandPushTitle(AppLocalizations t, BandPush push) => switch (push.kind) {
  PushKind.gigNew => t.pushGigNew(push.arg),
  PushKind.gigChanged => t.pushGigChanged(push.arg),
  PushKind.gigCancelled => t.pushGigCancelled(push.arg),
  PushKind.tip => t.pushTip(push.arg),
  PushKind.tomorrow => t.pushTomorrow,
  PushKind.today => t.pushToday,
  PushKind.tipReminder => t.pushTipReminder,
  PushKind.report => t.pushReport(push.arg),
  PushKind.memberAdded => t.pushMemberAdded,
  PushKind.memberRemoved => t.pushMemberRemoved,
  PushKind.feedback => t.pushFeedback,
};

/// What a band push says while the app is open, when Android shows nothing
/// by itself. `persist: false`: with an action, Flutter 3.47 would otherwise
/// keep it on screen until closed.
SnackBar bandPushSnackBar(
  AppLocalizations t,
  BandPush push, {
  VoidCallback? onOpen,
}) {
  return SnackBar(
    persist: false,
    duration: const Duration(seconds: 6),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          bandPushTitle(t, push),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        if (push.text.isNotEmpty)
          Text(push.text, maxLines: 4, overflow: TextOverflow.ellipsis),
      ],
    ),
    action: onOpen == null
        ? null
        : SnackBarAction(label: t.open, onPressed: onOpen),
  );
}
