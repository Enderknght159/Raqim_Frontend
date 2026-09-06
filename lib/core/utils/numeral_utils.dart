const _easternDigits = '٠١٢٣٤٥٦٧٨٩';
const _westernDigits = '0123456789';

/// Converts western digits to Arabic-Indic digits (optional per locale).
String toArabicNumerals(String input) {
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    final char = String.fromCharCode(rune);
    final index = _westernDigits.indexOf(char);
    if (index >= 0) {
      buffer.write(_easternDigits[index]);
    } else {
      buffer.write(char);
    }
  }
  return buffer.toString();
}

/// Formats an integer with optional thousands separators and Arabic digits.
String formatNumber(int value, {bool arabic = true}) {
  final grouped = _groupThousands(value);
  return arabic ? toArabicNumerals(grouped) : grouped;
}

String _groupThousands(int value) {
  final s = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
    buffer.write(s[i]);
  }
  final result = buffer.toString();
  return value < 0 ? '-$result' : result;
}