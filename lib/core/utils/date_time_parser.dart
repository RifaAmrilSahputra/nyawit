DateTime parseDateTimeSafely(dynamic value, {DateTime? fallback}) {
  final rawValue = value?.toString().trim();

  if (rawValue == null || rawValue.isEmpty) {
    return fallback ?? DateTime.now();
  }

  final direct = DateTime.tryParse(rawValue);
  if (direct != null) {
    return direct;
  }

  final withTSeparator = rawValue.replaceFirst(' ', 'T');
  final withT = DateTime.tryParse(withTSeparator);
  if (withT != null) {
    return withT;
  }

  final normalized = rawValue.replaceAll('/', '-');
  final normalizedParsed = DateTime.tryParse(normalized);
  if (normalizedParsed != null) {
    return normalizedParsed;
  }

  return fallback ?? DateTime.now();
}

DateTime? parseNullableDateTimeSafely(dynamic value) {
  if (value == null) {
    return null;
  }

  final rawValue = value.toString().trim();
  if (rawValue.isEmpty) {
    return null;
  }

  final direct = DateTime.tryParse(rawValue);
  if (direct != null) {
    return direct;
  }

  final withTSeparator = rawValue.replaceFirst(' ', 'T');
  final withT = DateTime.tryParse(withTSeparator);
  if (withT != null) {
    return withT;
  }

  final normalized = rawValue.replaceAll('/', '-');
  return DateTime.tryParse(normalized);
}
