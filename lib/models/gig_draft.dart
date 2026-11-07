import '../money/money.dart';
import 'gig.dart';

/// The fields of a gig that the form edits. Separate from [Gig] so the form
/// can build one up and the repository writes it the same way on create and
/// on edit.
class GigDraft {
  const GigDraft({
    required this.date,
    required this.start,
    this.end = '',
    this.type = GigType.wedding,
    this.venue = '',
    this.city = '',
    this.address = '',
    this.clientName = '',
    this.clientPhone = '',
    required this.priceMinor,
    this.currency = Currency.eur,
    this.depositMinor = 0,
    this.depositHolder = '',
    this.hasTip = true,
    this.notes = '',
    this.tipSplit = TipSplit.equal,
    this.players = const [],
  });

  /// `yyyy-MM-dd`, see `day_key.dart`.
  final String date;

  /// `HH:mm`; [end] may be empty.
  final String start;
  final String end;
  final GigType type;
  final String venue;
  final String city;
  final String address;
  final String clientName;
  final String clientPhone;
  final int priceMinor;
  final Currency currency;

  /// 0 = no deposit.
  final int depositMinor;

  /// uid of the member holding the deposit, or empty.
  final String depositHolder;
  final bool hasTip;
  final String notes;

  /// How the tip is shared; the band's default for a new gig.
  final TipSplit tipSplit;

  /// uids of who plays; the tip is shared over them, or entered by them.
  final List<String> players;

  /// No agreed price: the band plays for tips alone (the rules allow a price
  /// of 0 only with a tip).
  bool get tipOnly => priceMinor == 0;

  /// "Sala Kristal, Kraljevo", leaving out what is empty.
  String get place => [venue, city].where((s) => s.isNotEmpty).join(', ');

  Map<String, dynamic> toMap() => {
    'date': date,
    'start': start,
    'end': end,
    'type': type.name,
    'venue': venue,
    'city': city,
    'address': address,
    'clientName': clientName,
    'clientPhone': clientPhone,
    'priceMinor': priceMinor,
    'currency': currency.code,
    'depositMinor': depositMinor,
    'depositHolder': depositMinor > 0 ? depositHolder : '',
    'hasTip': hasTip,
    'notes': notes,
    'tipSplit': tipSplit.name,
    'players': players,
  };
}
