/// Converts a [DateTime] to a 24h `HH:MM` string.
String formatTime(DateTime time) {
  final h = time.hour.toString().padLeft(2, '0');
  final m = time.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

/// Converts a [DateTime] to an ISO `YYYY-MM-DD` string.
String formatDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// Compact `dd/mm` used in compact card meta lines.
String formatShortDate(DateTime date) {
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$d/$m';
}

/// Parses an ISO `YYYY-MM-DD` or `YYYY-MM-DDTHH:MM:SS` string to [DateTime].
DateTime? parseDateTime(String? value) {
  if (value == null || value.isEmpty) return null;
  return DateTime.tryParse(value);
}
