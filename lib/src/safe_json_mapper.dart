import 'dart:convert';
import 'annotations.dart';

/// A type alias for a JSON object (map of strings to dynamic values).
typedef JsonMap = Map<String, dynamic>;

/// Represents a single drift (type mismatch, missing field, etc.) during JSON parsing.
///
/// A drift occurs when the JSON value received doesn't match the expected type
/// or when a required field is missing.
class SafeJsonDrift {
  /// The name of the field where the drift occurred.
  final String field;

  /// A description of the expected type or constraint.
  final String expected;

  /// The actual value received (as a string representation).
  final String received;

  /// Creates a new drift record.
  const SafeJsonDrift({
    required this.field,
    required this.expected,
    required this.received,
  });

  /// Converts this drift to a JSON map for easy logging or debugging.
  Map<String, String> toJson() => {
        'field': field,
        'expected': expected,
        'received': received,
      };

  @override
  String toString() =>
      'SafeJsonDrift(field: $field, expected: $expected, received: $received)';
}

/// Exception thrown when parsing fails with [SafeJsonModelErrorPolicy.throwError].
///
/// This exception contains a message describing the failure and a list of
/// drifts that occurred during parsing.
class SafeJsonMappingException implements Exception {
  /// A message describing the error.
  final String message;

  /// The list of drifts that occurred during parsing.
  final List<SafeJsonDrift> drifts;

  /// Creates a new mapping exception.
  SafeJsonMappingException(this.message, this.drifts);

  @override
  String toString() {
    final buffer = StringBuffer('SafeJsonMappingException: $message');
    if (drifts.isNotEmpty) {
      buffer.writeln('\nDrifts:');
      for (final drift in drifts) {
        buffer.writeln('  - $drift');
      }
    }
    return buffer.toString();
  }
}

/// Interface for generated providers that handle JSON mapping for a specific type [T].
///
/// The code generator creates a concrete implementation of this interface
/// for each class annotated with [SafeJson].
abstract class SafeJsonModelProvider<T> {
  /// Converts a JSON map into an instance of [T].
  T fromJson(JsonMap json);

  /// Converts an instance of [T] back to a JSON map.
  JsonMap toJson(T instance);
}

/// The central entry point for SafeJsonMapper mapping.
///
/// Use this class to:
/// - Configure the global error policy
/// - Register model providers and custom converters
/// - Parse JSON into objects
/// - Serialize objects back to JSON
/// - Access drift information from the last parse
class SafeJsonMapper {
  /// The global error policy for the application.
  ///
  /// Determines how the mapper behaves when drifts are detected:
  /// - [SafeJsonModelErrorPolicy.logAndDefault]: Log drifts and use defaults
  /// - [SafeJsonModelErrorPolicy.throwError]: Throw an exception immediately
  /// - [SafeJsonModelErrorPolicy.silent]: Use defaults without logging
  static SafeJsonModelErrorPolicy errorPolicy =
      SafeJsonModelErrorPolicy.logAndDefault;

  static final Map<Type, SafeJsonModelProvider> _providers = {};
  static final Map<Type, SafeJsonConverter> _converters = {};

  /// Internal storage for drift logs during the current parsing operation.
  static final List<SafeJsonDrift> _currentDrifts = [];

  /// Initializes all generated providers automatically.
  ///
  /// Call this once in your app's initialization code (e.g., `main()`)
  /// instead of calling individual `register<ModelName>()` functions manually.
  ///
  /// You can optionally pass [additionalInitializers] to run custom
  /// initialization logic after the providers are registered.
  static void initialize([void Function()? additionalInitializers]) {
    additionalInitializers?.call();
  }

  /// Registers a provider for a specific type [T].
  ///
  /// Typical usage is calling the generated `register<ModelName>()` functions
  /// for each of your models. You should not need to call this directly.
  static void register<T>(SafeJsonModelProvider<T> provider) {
    _providers[T] = provider;
  }

  /// Registers a custom converter for a specific type [T].
  ///
  /// Use this to provide custom JSON conversion logic for types that aren't
  /// natively supported by SafeJsonMapper.
  ///
  /// Example:
  /// ```dart
  /// SafeJsonMapper.registerConverter<Duration>(SafeDurationConverter());
  /// ```
  static void registerConverter<T>(SafeJsonConverter<T> converter) {
    _converters[T] = converter;
  }

  /// Safely maps a JSON object to type [T].
  ///
  /// Requires that a provider for [T] has been registered (typically via
  /// `initialize()` or calling `register<ModelName>()`).
  ///
  /// Example:
  /// ```dart
  /// final user = SafeJsonMapper.fromJson<User>(json);
  /// ```
  ///
  /// Throws [SafeJsonMappingException] if:
  /// - No provider is registered for [T]
  /// - [errorPolicy] is [SafeJsonModelErrorPolicy.throwError] and drifts occur
  static T fromJson<T>(dynamic json) {
    _currentDrifts.clear();

    if (json == null) {
      if (errorPolicy == SafeJsonModelErrorPolicy.throwError) {
        throw SafeJsonMappingException(
          "Cannot parse null JSON for type $T",
          [],
        );
      }
    }

    final provider = _providers[T];
    if (provider == null) {
      final registeredTypes =
          _providers.keys.map((t) => t.toString()).join(', ');
      throw SafeJsonMappingException(
        "No SafeJsonMapper provider registered for type $T. \n"
        "Registered types: [$registeredTypes]. \n"
        "Did you call SafeJsonMapper.initialize() or run build_runner?",
        [],
      );
    }

    T result;
    if (json is! Map) {
      _recordDrift('root', 'Map', json);
      if (errorPolicy == SafeJsonModelErrorPolicy.throwError) {
        _throwIfNeeded();
      }
      result = provider.fromJson({}) as T;
    } else {
      result = provider.fromJson(Map<String, dynamic>.from(json)) as T;
    }

    _logDriftsIfNeeded();
    _throwIfNeeded();

    return result;
  }

  /// Returns the list of drifts from the most recent parsing operation.
  ///
  /// The list is unmodifiable and cleared before each new parsing operation.
  static List<SafeJsonDrift> get lastDrifts =>
      List.unmodifiable(_currentDrifts);

  /// Clears the current list of drifts.
  static void clearDrifts() {
    _currentDrifts.clear();
  }

  static void _recordDrift(
      String field, String expected, dynamic receivedValue) {
    _currentDrifts.add(SafeJsonDrift(
      field: field,
      expected: expected,
      received: receivedValue?.toString() ?? 'null',
    ));
  }

  static void _logDriftsIfNeeded() {
    if (_currentDrifts.isNotEmpty &&
        errorPolicy != SafeJsonModelErrorPolicy.silent) {
      _printDiagnosticLogs();
    }
  }

  static void _throwIfNeeded() {
    if (errorPolicy == SafeJsonModelErrorPolicy.throwError &&
        _currentDrifts.isNotEmpty) {
      throw SafeJsonMappingException(
        'JSON parsing failed with ${_currentDrifts.length} drift(s)',
        List.unmodifiable(_currentDrifts),
      );
    }
  }

  static void _printDiagnosticLogs() {
    final Map<String, List<Map<String, String>>> output = {};
    for (final drift in _currentDrifts) {
      if (!output.containsKey(drift.field)) {
        output[drift.field] = [];
      }
      output[drift.field]!.add(drift.toJson());
    }
    // ignore: avoid_print
    print('[SafeJsonMapper] Drift detected:');
    // ignore: avoid_print
    print(JsonEncoder.withIndent('  ').convert(output));
  }

  // ===== List utilities =====
  static List<T>? _mapList<T>(
    dynamic value,
    String fieldName,
    T? Function(dynamic) mapper,
  ) {
    if (value == null) return null;
    if (value is! List) {
      _recordDrift(fieldName, 'List', value);
      return null;
    }
    return value.map(mapper).whereType<T>().toList();
  }

  /// Ensures a value is a list, recording a drift if it isn't.
  ///
  /// Returns the list if it is one, otherwise null.
  static List<dynamic>? ensureList(dynamic value, String fieldName) {
    if (value == null) return null;
    if (value is List) return value;
    _recordDrift(fieldName, 'List', value);
    return null;
  }

  // ===== Map utilities =====
  /// Ensures a value is a map, recording a drift if it isn't.
  ///
  /// Returns the map if it is one, otherwise null.
  static Map<String, dynamic>? ensureMap(dynamic value, String fieldName) {
    if (value == null) return null;
    if (value is Map) return Map<String, dynamic>.from(value);
    _recordDrift(fieldName, 'Map', value);
    return null;
  }

  static Map<String, V>? _mapMap<V>(
    dynamic value,
    String fieldName,
    V? Function(dynamic) valueMapper,
  ) {
    if (value == null) return null;
    if (value is! Map) {
      _recordDrift(fieldName, 'Map', value);
      return null;
    }
    final result = <String, V>{};
    for (final entry in value.entries) {
      final key =
          entry.key is String ? entry.key as String : entry.key.toString();
      final mappedValue = valueMapper(entry.value);
      if (mappedValue != null) {
        result[key] = mappedValue;
      }
    }
    return result;
  }

  // ===== Required field checking =====
  /// Checks that a required field is not null, providing a fallback if it is.
  ///
  /// If [value] is null, records a drift and uses [fallback].
  static T checkRequired<T>(
    T? value,
    String fieldName,
    String className,
    T fallback,
  ) {
    if (value == null) {
      final typeInfo = T.toString();
      _recordDrift(fieldName, '$typeInfo -> required', null);
      _logDriftsIfNeeded();
      _throwIfNeeded();
      return fallback;
    }
    return value;
  }

  // ===== Primitive type converters =====

  /// Safely converts a value to an int.
  ///
  /// Supports conversion from:
  /// - int (direct)
  /// - String (via parsing)
  /// - double (via truncation)
  ///
  /// Returns null if conversion fails, recording a drift.
  static int? toInt(dynamic value, String fieldName,
      {bool isRequired = false}) {
    if (value == null) return null;
    if (value is int) return value;

    int? result;
    if (value is String) {
      result = int.tryParse(value);
    } else if (value is double) {
      result = value.toInt();
    } else if (value is num) {
      result = value.toInt();
    }

    if (result == null) {
      _recordDrift(fieldName, "int${isRequired ? ' -> required' : ''}", value);
    }
    return result;
  }

  /// Safely converts a value to a double.
  ///
  /// Supports conversion from:
  /// - double (direct)
  /// - int (via promotion)
  /// - String (via parsing)
  ///
  /// Returns null if conversion fails, recording a drift.
  static double? toDouble(dynamic value, String fieldName,
      {bool isRequired = false}) {
    if (value == null) return null;
    if (value is double) return value;

    double? result;
    if (value is int) {
      result = value.toDouble();
    } else if (value is String) {
      result = double.tryParse(value);
    } else if (value is num) {
      result = value.toDouble();
    }

    if (result == null) {
      _recordDrift(
        fieldName,
        "double${isRequired ? ' -> required' : ''}",
        value,
      );
    }
    return result;
  }

  /// Safely converts a value to a num.
  ///
  /// Supports conversion from:
  /// - num (direct)
  /// - String (via parsing)
  ///
  /// Returns null if conversion fails, recording a drift.
  static num? toNum(dynamic value, String fieldName,
      {bool isRequired = false}) {
    if (value == null) return null;
    if (value is num) return value;

    num? result;
    if (value is String) {
      result = num.tryParse(value);
    }

    if (result == null) {
      _recordDrift(fieldName, "num${isRequired ? ' -> required' : ''}", value);
    }
    return result;
  }

  /// Safely converts a value to a string.
  ///
  /// Always succeeds by calling `toString()` on the value.
  static String? asString(dynamic value, String fieldName,
      {bool isRequired = false}) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  /// Safely converts a value to a bool.
  ///
  /// If [fromInt] is true, also converts:
  /// - int: 0 → false, any other value → true
  /// - String: parses as int first, or checks for "true"/"false"
  ///
  /// Returns null if conversion fails, recording a drift.
  static bool? toBool(dynamic value, String fieldName,
      {bool fromInt = false, bool isRequired = false}) {
    if (value == null) return null;
    if (value is bool) return value;

    bool? result;
    if (fromInt) {
      if (value is int) {
        result = value != 0;
      } else if (value is String) {
        final i = int.tryParse(value);
        if (i != null) {
          result = i != 0;
        } else if (value.toLowerCase() == 'true') {
          result = true;
        } else if (value.toLowerCase() == 'false') {
          result = false;
        }
      }
    }

    if (result == null) {
      _recordDrift(fieldName, "bool${isRequired ? ' -> required' : ''}", value);
    }
    return result;
  }

  // ===== DateTime converter =====
  /// Safely converts a value to a DateTime.
  ///
  /// Supports conversion from:
  /// - DateTime (direct)
  /// - String (parsed via [DateTime.tryParse])
  /// - int (milliseconds since epoch)
  /// - double (seconds since epoch with decimal milliseconds)
  ///
  /// Returns null if conversion fails, recording a drift.
  static DateTime? toDateTime(dynamic value, String fieldName,
      {bool isRequired = false}) {
    if (value == null) return null;
    if (value is DateTime) return value;

    DateTime? result;
    if (value is String) {
      result = DateTime.tryParse(value);
    } else if (value is int) {
      // Assume milliseconds since epoch
      result = DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is double) {
      // Assume seconds since epoch with decimal milliseconds
      final seconds = value.truncate();
      final milliseconds = ((value - seconds) * 1000).round();
      result = DateTime.fromMillisecondsSinceEpoch(
        seconds * 1000 + milliseconds,
      );
    }

    if (result == null) {
      _recordDrift(
        fieldName,
        "DateTime${isRequired ? ' -> required' : ''}",
        value,
      );
    }
    return result;
  }

  // ===== Enum converter =====
  /// Safely converts a value to an enum of type [T].
  ///
  /// Supports conversion from:
  /// - String: matches by name (case-insensitive)
  /// - int: matches by index
  ///
  /// If [unknownValue] is provided, it is used when no match is found.
  /// Otherwise, the first enum value is used as a fallback.
  ///
  /// Returns null if conversion fails, recording a drift.
  static T? toEnum<T extends Enum>(
    dynamic value,
    String fieldName,
    List<T> values, {
    bool isRequired = false,
    T? unknownValue,
  }) {
    if (value == null) return null;

    T? result;
    if (value is String) {
      // Try by name (case-insensitive)
      final lowerValue = value.toLowerCase();
      result = values.firstWhere(
        (e) => e.name.toLowerCase() == lowerValue,
        orElse: () => unknownValue ?? values.first,
      );
    } else if (value is int) {
      // Try by index
      if (value >= 0 && value < values.length) {
        result = values[value];
      } else if (unknownValue != null) {
        result = unknownValue;
      }
    }

    if (result == null) {
      _recordDrift(
        fieldName,
        "Enum<${T.toString()}>${isRequired ? ' -> required' : ''}",
        value,
      );
    }
    return result;
  }

  // ===== List converters =====
  /// Safely converts a list of values to a list of ints.
  static List<int>? toIntList(dynamic value, String fieldName) {
    return _mapList<int>(value, fieldName, (e) => toInt(e, fieldName));
  }

  /// Safely converts a list of values to a list of doubles.
  static List<double>? toDoubleList(dynamic value, String fieldName) {
    return _mapList<double>(value, fieldName, (e) => toDouble(e, fieldName));
  }

  /// Safely converts a list of values to a list of nums.
  static List<num>? toNumList(dynamic value, String fieldName) {
    return _mapList<num>(value, fieldName, (e) => toNum(e, fieldName));
  }

  /// Safely converts a list of values to a list of strings.
  static List<String>? toStringList(dynamic value, String fieldName) {
    return _mapList<String>(value, fieldName, (e) => asString(e, fieldName));
  }

  /// Safely converts a list of values to a list of bools.
  static List<bool>? toBoolList(dynamic value, String fieldName,
      {bool fromInt = false}) {
    return _mapList<bool>(
      value,
      fieldName,
      (e) => toBool(e, fieldName, fromInt: fromInt),
    );
  }

  /// Safely converts a list of values to a list of DateTimes.
  static List<DateTime>? toDateTimeList(dynamic value, String fieldName) {
    return _mapList<DateTime>(
      value,
      fieldName,
      (e) => toDateTime(e, fieldName),
    );
  }

  /// Safely converts a list of values to a list of enums.
  static List<T>? toEnumList<T extends Enum>(
    dynamic value,
    String fieldName,
    List<T> values, {
    T? unknownValue,
  }) {
    return _mapList<T>(
      value,
      fieldName,
      (e) => toEnum<T>(e, fieldName, values, unknownValue: unknownValue),
    );
  }

  /// Safely converts a list of values to a list of models of type [T].
  static List<T>? toModelList<T>(dynamic value, String fieldName) {
    return _mapList<T>(
      value,
      fieldName,
      (e) => (e is Map) ? SafeJsonMapper.fromJson<T>(e) : null,
    );
  }

  // ===== Map converters =====
  /// Safely converts a map of values to a map of strings to ints.
  static Map<String, int>? toIntMap(dynamic value, String fieldName) {
    return _mapMap<int>(value, fieldName, (v) => toInt(v, fieldName));
  }

  /// Safely converts a map of values to a map of strings to doubles.
  static Map<String, double>? toDoubleMap(dynamic value, String fieldName) {
    return _mapMap<double>(value, fieldName, (v) => toDouble(v, fieldName));
  }

  /// Safely converts a map of values to a map of strings to nums.
  static Map<String, num>? toNumMap(dynamic value, String fieldName) {
    return _mapMap<num>(value, fieldName, (v) => toNum(v, fieldName));
  }

  /// Safely converts a map of values to a map of strings to strings.
  static Map<String, String>? toStringMap(dynamic value, String fieldName) {
    return _mapMap<String>(value, fieldName, (v) => asString(v, fieldName));
  }

  /// Safely converts a map of values to a map of strings to bools.
  static Map<String, bool>? toBoolMap(dynamic value, String fieldName,
      {bool fromInt = false}) {
    return _mapMap<bool>(
      value,
      fieldName,
      (v) => toBool(v, fieldName, fromInt: fromInt),
    );
  }

  /// Safely converts a map of values to a map of strings to DateTimes.
  static Map<String, DateTime>? toDateTimeMap(dynamic value, String fieldName) {
    return _mapMap<DateTime>(
      value,
      fieldName,
      (v) => toDateTime(v, fieldName),
    );
  }

  /// Safely converts a map of values to a map of strings to enums.
  static Map<String, T>? toEnumMap<T extends Enum>(
    dynamic value,
    String fieldName,
    List<T> values, {
    T? unknownValue,
  }) {
    return _mapMap<T>(
      value,
      fieldName,
      (v) => toEnum<T>(v, fieldName, values, unknownValue: unknownValue),
    );
  }

  /// Safely converts a map of values to a map of strings to models of type [T].
  static Map<String, T>? toModelMap<T>(dynamic value, String fieldName) {
    return _mapMap<T>(
      value,
      fieldName,
      (v) => (v is Map) ? SafeJsonMapper.fromJson<T>(v) : null,
    );
  }

  // ===== Serialization utilities =====

  /// Converts an instance of type [T] to a JSON map.
  ///
  /// Requires that a provider for [T] has been registered.
  ///
  /// Example:
  /// ```dart
  /// final json = SafeJsonMapper.toJson(user);
  /// ```
  static JsonMap toJson<T>(T instance) {
    final provider = _providers[T];
    if (provider == null) {
      final registeredTypes =
          _providers.keys.map((t) => t.toString()).join(', ');
      throw SafeJsonMappingException(
        "No SafeJsonMapper provider registered for type $T. \n"
        "Registered types: [$registeredTypes]. \n"
        "Did you call SafeJsonMapper.initialize() or YourModel.register()?",
        [],
      );
    }
    return provider.toJson(instance);
  }

  /// Helper to serialize a value to JSON-compatible type.
  static dynamic _serializeValue(dynamic value) {
    if (value == null) return null;

    // Check converters first
    final converter = _converters[value.runtimeType];
    if (converter != null) {
      // We need to cast to the correct type
      return converter.toJson(value);
    }

    if (value is int ||
        value is double ||
        value is num ||
        value is bool ||
        value is String) {
      return value;
    }

    if (value is DateTime) {
      return value.toIso8601String();
    }

    if (value is Enum) {
      return value.name;
    }

    if (value is List) {
      return value.map(_serializeValue).toList();
    }

    if (value is Map) {
      final result = <String, dynamic>{};
      for (final entry in value.entries) {
        final key =
            entry.key is String ? entry.key as String : entry.key.toString();
        result[key] = _serializeValue(entry.value);
      }
      return result;
    }

    // Check if it's a registered model type
    try {
      // Use a hack to check if provider exists - but maybe better to pass type?
      // Wait, the provider is registered by Type, but we have value.runtimeType.
      // Let's check _providers for value.runtimeType
      final provider = _providers[value.runtimeType];
      if (provider != null) {
        return provider.toJson(value);
      }
    } catch (_) {
      // Ignore
    }

    // Fallback to toString
    return value.toString();
  }

  /// Helper method to serialize a value - public for generated code use.
  static dynamic serializeValue(dynamic value) => _serializeValue(value);

  /// Deep equality check for two values.
  ///
  /// Recursively compares lists and maps for equality.
  static bool deepEquals(dynamic a, dynamic b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return false;
    if (a.runtimeType != b.runtimeType) return false;

    if (a is List) {
      if (a.length != b.length) return false;
      for (int i = 0; i < a.length; i++) {
        if (!deepEquals(a[i], b[i])) return false;
      }
      return true;
    }

    if (a is Map) {
      if (a.length != b.length) return false;
      for (final key in a.keys) {
        if (!b.containsKey(key)) return false;
        if (!deepEquals(a[key], b[key])) return false;
      }
      return true;
    }

    return a == b;
  }

  /// Computes a deep hash code for a value.
  ///
  /// Recursively computes hash codes for lists and maps. Map keys are sorted
  /// to ensure consistent hash codes regardless of insertion order.
  static int deepHash(dynamic value) {
    if (value == null) return 0;

    if (value is List) {
      return Object.hashAll(value.map(deepHash));
    }

    if (value is Map) {
      final entries = value.entries.toList()
        ..sort((a, b) => a.key.toString().compareTo(b.key.toString()));
      return Object.hashAll(
          entries.map((e) => Object.hash(deepHash(e.key), deepHash(e.value))));
    }

    return value.hashCode;
  }

  /// Helper to get a nested value from a JSON map using a dot-separated path.
  ///
  /// Example:
  /// ```dart
  /// final city = SafeJsonMapper.getNestedValue(json, 'profile.address.city');
  /// ```
  ///
  /// Also supports list indices in the path (e.g., `users.0.name`).
  static dynamic getNestedValue(Map<String, dynamic> json, String path) {
    dynamic current = json;
    for (final part in path.split('.')) {
      if (current is Map<String, dynamic>) {
        current = current[part];
      } else if (current is List && int.tryParse(part) != null) {
        final index = int.parse(part);
        if (index >= 0 && index < current.length) {
          current = current[index];
        } else {
          current = null;
        }
      } else {
        current = null;
      }
      if (current == null) break;
    }
    return current;
  }
}

/// Built-in converter for Duration (converts from/to milliseconds).
class SafeDurationConverter implements SafeJsonConverter<Duration> {
  const SafeDurationConverter();

  @override
  Duration? fromJson(dynamic value) {
    if (value == null) return null;
    if (value is int) return Duration(milliseconds: value);
    if (value is num) return Duration(milliseconds: value.round());
    return null;
  }

  @override
  dynamic toJson(Duration? value) {
    if (value == null) return null;
    return value.inMilliseconds;
  }
}

/// Built-in converter for Uri.
class SafeUriConverter implements SafeJsonConverter<Uri> {
  const SafeUriConverter();

  @override
  Uri? fromJson(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      try {
        return Uri.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  dynamic toJson(Uri? value) {
    if (value == null) return null;
    return value.toString();
  }
}

/// Built-in converter for BigInt.
class SafeBigIntConverter implements SafeJsonConverter<BigInt> {
  const SafeBigIntConverter();

  @override
  BigInt? fromJson(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      try {
        return BigInt.parse(value);
      } catch (_) {
        return null;
      }
    }
    if (value is int) return BigInt.from(value);
    return null;
  }

  @override
  dynamic toJson(BigInt? value) {
    if (value == null) return null;
    return value.toString();
  }
}
