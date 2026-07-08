/// Policies for handling missing required fields or type mismatches.
enum SafeJsonModelErrorPolicy {
  /// Throws a [SafeJsonMappingException] if a required field is missing or drift occurs.
  throwError,

  /// Logs warnings and uses default fallback values.
  logAndDefault,

  /// Silently uses default fallback values without logging.
  silent,
}

/// Interface for custom type converters.
///
/// Use this to add support for custom types that aren't natively supported.
abstract class SafeJsonConverter<T> {
  const SafeJsonConverter();

  /// Converts a JSON value to type [T].
  T? fromJson(dynamic value);

  /// Converts a value of type [T] back to a JSON value.
  dynamic toJson(T? value);
}

/// Annotation to mark a class for SafeJsonMapper generation.
class SafeJson {
  final SafeJsonModelErrorPolicy? errorPolicy;
  final bool? strict;
  final bool? allowUnknownKeys;

  const SafeJson({
    this.errorPolicy,
    this.strict,
    this.allowUnknownKeys,
  });
}

/// Annotation to customize how a field is handled by SafeJsonMapper.
class SafeField {
  /// Whether this field is mandatory.
  /// If true and the field is missing in JSON, the error policy is triggered.
  final bool required;

  /// The default value to use typically when the field is missing or null.
  final dynamic defaultValue;

  /// The custom key name in the JSON map. If null, the Dart field name is used.
  final String? name;

  /// List of alternative keys to look for in JSON (in order of precedence).
  final List<String>? aliases;

  /// Path to nested value in JSON (e.g., "profile.address.city").
  final String? path;

  /// Whether to ignore this field entirely (both from and to JSON).
  final bool ignore;

  const SafeField({
    this.required = false,
    this.defaultValue,
    this.name,
    this.aliases,
    this.path,
    this.ignore = false,
  });
}

/// Specialized annotation for boolean fields to handle drift (e.g., 1/0 from backend).
class SafeBool extends SafeField {
  final bool fromInt;

  const SafeBool({
    super.required = false,
    super.defaultValue,
    super.name,
    super.aliases,
    super.path,
    super.ignore = false,
    this.fromInt = true,
  });
}

/// Specialized annotation for numeric fields to handle drift (int ↔ double ↔ num).
class SafeNum extends SafeField {
  const SafeNum({
    super.required = false,
    super.defaultValue,
    super.name,
    super.aliases,
    super.path,
    super.ignore = false,
  });
}

/// Annotation to set a default value for a field.
class SafeDefault {
  final dynamic value;

  const SafeDefault(this.value);
}

/// Annotation to ignore a field entirely (both from and to JSON).
class SafeIgnore {
  const SafeIgnore();
}

/// Annotation to ignore a field only during deserialization (from JSON).
class SafeIgnoreFromJson {
  const SafeIgnoreFromJson();
}

/// Annotation to ignore a field only during serialization (to JSON).
class SafeIgnoreToJson {
  const SafeIgnoreToJson();
}

/// Annotation to use a custom converter for a field.
class SafeConverter {
  final SafeJsonConverter converter;

  const SafeConverter(this.converter);
}
