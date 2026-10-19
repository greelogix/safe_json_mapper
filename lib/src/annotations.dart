/// Policies for handling missing required fields or type mismatches.
enum SafeJsonModelErrorPolicy {
  /// Throws a mapping exception if a required field is missing or drift occurs.
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
  /// Creates a converter for use in annotations or mapper registration.
  const SafeJsonConverter();

  /// Converts a JSON value to type [T].
  T? fromJson(dynamic value);

  /// Converts a value of type [T] back to a JSON value.
  dynamic toJson(T? value);
}

/// Annotation to mark a class for SafeJsonMapper generation.
class SafeJson {
  /// Reserved per-model policy option; configure SafeJsonMapper.errorPolicy globally.
  final SafeJsonModelErrorPolicy? errorPolicy;

  /// Reserved strict-mode option; currently not applied by the generator.
  final bool? strict;

  /// Reserved unknown-key option; unknown keys are currently ignored.
  final bool? allowUnknownKeys;

  /// Marks a model for provider and extension generation.
  const SafeJson({this.errorPolicy, this.strict, this.allowUnknownKeys});
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

  /// Configures JSON keys, required checks, and fallback values.
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
  /// Allows integer values and numeric or boolean strings as booleans.
  final bool fromInt;

  /// Configures boolean drift conversion.
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
  /// Configures numeric drift conversion.
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
  /// The fallback value used when a JSON field is missing.
  final dynamic value;

  /// Sets the fallback value for a field.
  const SafeDefault(this.value);
}

/// Annotation to ignore a field entirely (both from and to JSON).
class SafeIgnore {
  /// Excludes a field from reading and writing JSON.
  const SafeIgnore();
}

/// Annotation to ignore a field only during deserialization (from JSON).
class SafeIgnoreFromJson {
  /// Excludes a field when reading JSON.
  const SafeIgnoreFromJson();
}

/// Annotation to ignore a field only during serialization (to JSON).
class SafeIgnoreToJson {
  /// Excludes a field when writing JSON.
  const SafeIgnoreToJson();
}

/// Annotation to use a custom converter for a field.
class SafeConverter {
  /// The converter associated with the field.
  final SafeJsonConverter converter;

  /// Declares a field converter; currently reserved by the generator.
  /// Register converters with SafeJsonMapper.registerConverter for serialization.
  const SafeConverter(this.converter);
}
