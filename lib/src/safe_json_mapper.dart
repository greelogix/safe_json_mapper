import 'dart:convert';

typedef JsonMap = Map<String, dynamic>;

/// Interface for generated providers that handle JSON mapping for a specific type [T].
abstract class SafeJsonModelProvider<T> {
  /// Converts a JSON map into an instance of [T].
  T fromJson(JsonMap json);
}

/// Policies for handling missing required fields or type mismatches.
enum SafeJsonModelErrorPolicy {
  /// Throws an exception if a required field is missing.
  throwError,

  /// Logs a warning and uses a default fallback value.
  logAndDefault,

  /// Silently uses a default fallback value without logging.
  silent
}

/// The central entry point for SafeJsonMapper mapping.
class SafeJsonMapper {
  /// The global error policy for the application.
  static SafeJsonModelErrorPolicy errorPolicy =
      SafeJsonModelErrorPolicy.logAndDefault;

  static final Map<Type, SafeJsonModelProvider> _providers = {};

  /// Internal storage for drift logs during the current parsing operation.
  static final List<Map<String, dynamic>> _currentLogs = [];

  /// Registers a provider for a specific type [T].
  /// Typical usage is calling `YourModel.register()` in the generated code.
  static void register<T>(SafeJsonModelProvider<T> provider) {
    _providers[T] = provider;
  }

  /// Safely maps a JSON object to type [T].
  /// Requires that a provider for [T] has been registered.
  static T fromJson<T>(dynamic json) {
    _currentLogs.clear();

    if (json == null) {
      if (errorPolicy == SafeJsonModelErrorPolicy.throwError) {
        throw Exception("Cannot parse null JSON for type $T");
      }
    }

    final provider = _providers[T];
    if (provider == null) {
      final registeredTypes = _providers.keys.join(', ');
      throw Exception("No SafeJsonMapper provider registered for type $T. \n"
          "Registered types: [$registeredTypes]. \n"
          "Did you call YourModel.register() or run build_runner?");
    }

    T result;
    if (json is! Map) {
      if (errorPolicy == SafeJsonModelErrorPolicy.throwError) {
        throw Exception("Expected Map for $T, but got ${json.runtimeType}");
      }
      result = provider.fromJson({}) as T;
    } else {
      result = provider.fromJson(Map<String, dynamic>.from(json)) as T;
    }

    if (_currentLogs.isNotEmpty) {
      _printDiagnosticLogs();
    }

    return result;
  }

  static void _printDiagnosticLogs() {
    final Map<String, dynamic> output = {};
    for (final log in _currentLogs) {
      output[log['field']] = {
        'expected': log['expected'],
        'received': log['received'],
      };
    }
    // ignore: avoid_print
    print("[SafeJsonMapper] Drift detected:");
    // ignore: avoid_print
    print(JsonEncoder.withIndent('  ').convert(output));
  }

  /// Internal utility to record a drift.
  static void _recordDrift(
      String field, String expected, dynamic receivedValue) {
    _currentLogs.add({
      'field': field,
      'expected': expected,
      'received': receivedValue?.toString() ?? 'null',
    });
  }

  static List<dynamic>? ensureList(dynamic value, String fieldName) {
    if (value == null) return null;
    if (value is List) return value;

    _recordDrift(fieldName, "List", value);
    return null;
  }

  static Map<String, dynamic>? ensureMap(dynamic value, String fieldName) {
    if (value == null) return null;
    if (value is Map) return Map<String, dynamic>.from(value);

    _recordDrift(fieldName, "Map", value);
    return null;
  }

  /// Utility for required field checking
  static T checkRequired<T>(
      T? value, String fieldName, String className, T fallback) {
    if (value == null) {
      final typeInfo = T.toString();
      _recordDrift(fieldName, "$typeInfo -> required", null);

      if (errorPolicy == SafeJsonModelErrorPolicy.throwError) {
        // Must print logs before throwing, otherwise they are lost
        if (_currentLogs.isNotEmpty) {
          _printDiagnosticLogs();
        }
        final message = "Required field '$fieldName' is missing in $className";
        throw Exception(message);
      }
      return fallback;
    }
    return value;
  }

  static int? toInt(dynamic value, String fieldName, {bool isRequired = false}) {
    if (value == null) return null;
    if (value is int) return value;

    final result = (value is String)
        ? int.tryParse(value)
        : (value is double)
            ? value.toInt()
            : null;

    if (result == null) {
      _recordDrift(fieldName, "int${isRequired ? ' -> required' : ''}", value);
    }
    return result;
  }

  static double? toDouble(dynamic value, String fieldName,
      {bool isRequired = false}) {
    if (value == null) return null;
    if (value is double) return value;

    final result = (value is int)
        ? value.toDouble()
        : (value is String)
            ? double.tryParse(value)
            : null;

    if (result == null) {
      _recordDrift(
          fieldName, "double${isRequired ? ' -> required' : ''}", value);
    }
    return result;
  }

  static num? toNum(dynamic value, String fieldName,
      {bool isRequired = false}) {
    if (value == null) return null;
    if (value is num) return value;

    final result = (value is String) ? num.tryParse(value) : null;

    if (result == null) {
      _recordDrift(fieldName, "num${isRequired ? ' -> required' : ''}", value);
    }
    return result;
  }

  static String? asString(dynamic value, String fieldName,
      {bool isRequired = false}) {
    if (value == null) return null;
    if (value is String) return value;

    _recordDrift(fieldName, "String${isRequired ? ' -> required' : ''}", value);
    return value.toString();
  }

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
}
