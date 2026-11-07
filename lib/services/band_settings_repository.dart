import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/gig.dart';

/// `meta/band`: how the band shares tips unless a gig says otherwise. Every
/// signed-in account reads it; a leader writes it.
class BandSettings {
  const BandSettings({this.tipSplit = TipSplit.equal});

  final TipSplit tipSplit;

  factory BandSettings.fromData(Map<String, dynamic>? d) =>
      BandSettings(tipSplit: tipSplitFromName(d?['tipSplit'] as String?));
}

class BandSettingsRepository {
  BandSettingsRepository._();
  static final BandSettingsRepository instance = BandSettingsRepository._();

  final DocumentReference<Map<String, dynamic>> _doc = FirebaseFirestore
      .instance
      .doc('meta/band');

  /// A missing document means the default: shared equally.
  Stream<BandSettings> watch() =>
      _doc.snapshots().map((s) => BandSettings.fromData(s.data()));

  Future<void> setTipSplit(TipSplit split) =>
      _doc.set({'tipSplit': split.name});
}
