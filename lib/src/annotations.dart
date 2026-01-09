
/// Annotation to mark a class for SafeJsonMapper generation.
class SafeJson {
  const SafeJson();
}

/// Annotation to customize how a field is handled by SafeJsonMapper.
class SafeField {
  /// Whether this field is mandatory.
  /// If true and the field is missing in JSON, the error policy is triggered.
  final bool required;

  /// The default value to use tipically when the field is missing or null.
  final dynamic defaultValue;

  /// The custom key name in the JSON map. If null, the Dart field name is used.
  final String? name;

  const SafeField({
    this.required = false,
    this.defaultValue,
    this.name,
  });
}

/// Specialized annotation for boolean fields to handle drift (e.g., 1/0 from backend).
class SafeBool extends SafeField {
  final bool fromInt;

  const SafeBool({
    super.required = false,
    super.defaultValue,
    super.name,
    this.fromInt = true,
  });
}

/// Specialized annotation for numeric fields to handle drift (int ↔ double ↔ num).
class SafeNum extends SafeField {
  const SafeNum({
    super.required = false,
    super.defaultValue,
    super.name,
  });
}
