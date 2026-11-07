import 'package:bend_planer/l10n/app_localizations.dart';
import 'package:bend_planer/l10n/locale_controller.dart';
import 'package:bend_planer/models/app_user.dart';
import 'package:bend_planer/models/gig.dart';
import 'package:bend_planer/models/gig_draft.dart';
import 'package:bend_planer/money/money.dart';
import 'package:bend_planer/services/live_data.dart';
import 'package:bend_planer/theme/app_colors.dart';
import 'package:bend_planer/theme/app_theme.dart';
import 'package:bend_planer/theme/skins.dart';
import 'package:flutter/material.dart';

/// [child] in the app's theme and language, as the real app shows it.
Widget inApp(Widget child, {SkinId skin = SkinId.bina, Locale? locale}) =>
    MaterialApp(
      theme: AppTheme.build(kSkins[skin]!),
      locale: locale ?? kSerbianLatin,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: kSupportedLocales,
      home: Scaffold(body: child),
    );

const me = AppUser(
  uid: 'ana',
  email: 'ana@x.rs',
  role: UserRole.member,
  disabled: false,
  firstName: 'Ana',
  lastName: 'Ilić',
  instrument: 'Vokal',
);

Gig gigOn(
  String date, {
  String id = 'g',
  int price = 150000,
  Currency currency = Currency.eur,
  bool hasTip = true,
  int? tip,
  bool cancelled = false,
  GigType type = GigType.wedding,
}) => Gig(
  id: id,
  ownerId: 'ana',
  draft: GigDraft(
    date: date,
    start: '20:00',
    type: type,
    venue: 'Sala Kristal',
    city: 'Kraljevo',
    priceMinor: price,
    currency: currency,
    depositMinor: 30000,
    hasTip: hasTip,
  ),
  tipMinor: tip,
  cancelled: cancelled,
  createdAt: DateTime(2026),
);

/// Live data that never touches Firestore.
LiveData fakeData(List<Gig> gigs, {List<AppUser> users = const [me]}) =>
    LiveData(listen: false)
      ..gigs = gigs
      ..users = users;
