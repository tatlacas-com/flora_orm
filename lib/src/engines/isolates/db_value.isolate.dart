dynamic dbValue(dynamic value) {
  var result = value;
  if (value is bool) {
    result = value ? 1 : 0;
  } else if (value is DateTime) {
    result = value.toIso8601String();
  }
  return result;
}
