import 'package:intl/intl.dart';

/// Gigs are agreed in euros or dinars, and the two are never added together.
enum Currency { eur, rsd }

Currency currencyFromCode(String? code) =>
    code == 'RSD' ? Currency.rsd : Currency.eur;

extension CurrencyCode on Currency {
  String get code => this == Currency.eur ? 'EUR' : 'RSD';
}

/// Formats an amount in minor units: 120000 EUR -> "1.200 €", 150050 RSD ->
/// "1.500,50 RSD". Decimals only when there are any; gig prices rarely have.
String formatMoney(int amountMinor, Currency currency, String locale) {
  final whole = amountMinor % 100 == 0;
  final number = NumberFormat.decimalPatternDigits(
    locale: locale,
    decimalDigits: whole ? 0 : 2,
  ).format(amountMinor / 100);
  return currency == Currency.eur ? '$number €' : '$number RSD';
}

/// One formatted line per currency, euros first; "0 €" when [sums] is empty,
/// so a card never shows nothing.
List<String> formatSums(Map<Currency, int> sums, String locale) {
  if (sums.values.every((v) => v == 0)) {
    return [formatMoney(0, Currency.eur, locale)];
  }
  return [
    for (final c in Currency.values)
      if ((sums[c] ?? 0) != 0) formatMoney(sums[c]!, c, locale),
  ];
}

/// Parses user input such as "1.500", "1500,5" or "12 345" into minor units.
/// Returns null when the input is not a positive amount.
int? parseMoney(String input) {
  var s = input.trim().replaceAll(' ', '').replaceAll('€', '');
  if (s.isEmpty) return null;
  final lastComma = s.lastIndexOf(',');
  final lastDot = s.lastIndexOf('.');
  if (lastComma >= 0 && lastDot >= 0) {
    // Both present: whichever comes last is the decimal separator.
    final decimal = lastComma > lastDot ? ',' : '.';
    final group = decimal == ',' ? '.' : ',';
    s = s.replaceAll(group, '').replaceAll(decimal, '.');
  } else if (lastComma >= 0 || lastDot >= 0) {
    final sep = lastComma >= 0 ? ',' : '.';
    final parts = s.split(sep);
    // "1.500" or "1.250.000" group thousands; "1500,5" is a decimal.
    final grouping =
        parts.length > 2 || (parts.last.length == 3 && parts.first.isNotEmpty);
    s = grouping ? parts.join() : parts.join('.');
  }
  final value = double.tryParse(s);
  if (value == null || value <= 0) return null;
  return (value * 100).round();
}

/// Minor units back to an editable string, e.g. 150050 -> "1500.50".
String moneyToInput(int amountMinor) {
  final whole = amountMinor ~/ 100;
  final fraction = amountMinor % 100;
  return fraction == 0
      ? '$whole'
      : '$whole.${fraction.toString().padLeft(2, '0')}';
}
