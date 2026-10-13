/// Western-only number formatting (design rule: numerals always 0-9,
/// overriding the Arabic-Indic variant once shown in wireframes).
library;

/// Formats an integer with thousands separators using Western digits.
String formatNumber(int value) {
  return _groupThousands(value);
}

/// Formats a double with an optional number of decimals using Western digits.
String formatDecimal(double value, {int decimals = 2}) {
  final fixed = value.toStringAsFixed(decimals);
  return _groupThousandsFixed(fixed);
}

String _groupThousands(int value) {
  final s = value.abs().toString();
  final grouped = _groupString(s);
  return value < 0 ? '-$grouped' : grouped;
}

String _groupThousandsFixed(String s) {
  final negative = s.startsWith('-');
  final unsigned = negative ? s.substring(1) : s;
  final dot = unsigned.indexOf('.');
  final intPart = dot == -1 ? unsigned : unsigned.substring(0, dot);
  final fracPart = dot == -1 ? '' : unsigned.substring(dot);
  final grouped = _groupString(intPart);
  return '${negative ? '-' : ''}$grouped$fracPart';
}

String _groupString(String s) {
  final buffer = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
    buffer.write(s[i]);
  }
  return buffer.toString();
}