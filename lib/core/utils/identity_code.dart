/// Mosque-scoped identity rules (BR-624/625/707).
///
/// Every identifier a mosque owns — usernames and student barcodes — starts
/// with the mosque's immutable code (for example `aby`). There are no
/// role/type prefixes such as `st`, `tch` or `usr`; the mosque code is the only
/// prefix, and it can never be edited by a mosque account.
library;

/// Joins the mosque code and a suffix with the single allowed separator.
String mosqueScopedCode(String mosqueCode, Object suffix) {
  final code = mosqueCode.trim();
  final value = suffix.toString().trim();
  if (code.isEmpty) return value;
  if (value.isEmpty) return '$code-';
  return '$code-$value';
}

/// Normalises a username so it always starts with `{mosqueCode}-`.
///
/// Accepts a full username (`aby-ali`), a suffix (`ali`) or a stray prefix
/// (`st532`) and returns a mosque-scoped identifier. Empty input stays empty so
/// the server can generate the username.
String ensureMosqueUsername(String mosqueCode, String value) {
  final code = mosqueCode.trim();
  final input = value.trim();
  if (code.isEmpty || input.isEmpty) return input;
  final prefix = '${code.toLowerCase()}-';
  final lower = input.toLowerCase();
  if (lower == code.toLowerCase()) return '$code-';
  if (lower.startsWith(prefix)) return input;
  // Strip a previous non-mosque prefix (`st-532`, `tch_7`, ...) before applying
  // the only allowed one.
  final suffix = input.replaceFirst(RegExp(r'^[A-Za-z]+[-_]'), '').trim();
  return mosqueScopedCode(code, suffix);
}

/// True when [value] already carries the mosque prefix.
bool hasMosquePrefix(String mosqueCode, String value) {
  final code = mosqueCode.trim().toLowerCase();
  if (code.isEmpty) return true;
  return value.trim().toLowerCase().startsWith('$code-') ||
      value.trim().toLowerCase() == code;
}
