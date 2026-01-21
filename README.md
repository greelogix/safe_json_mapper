# SafeJsonMapper


## 🎬 Demo
![Safe JSON Mapper Demo](https://raw.githubusercontent.com/greelogix/quick_popup_manager-video/main/safe_json_mapper_demo.gif)

A Flutter/Dart package for safe JSON mapping that handles backend inconsistencies, type drift, and
nested models with detailed diagnostic logging.

## Features

- **Safe Type Conversion**: Automatically handles drift between `String`, `int`, `double`, and
  `bool`.
- **Boolean Drift**: Converts `1/0` or `"true"/"false"` strings to boolean values.
- **Nested Models & Lists**: Recursively parses nested objects and lists of primitives or models
  safely.
- **Required Fields & Defaults**: Configurable behavior for missing fields and easy default values.
- **Detailed Diagnostic Logging**: Automatically logs all type mismatches, missing required fields,
  and invalid casts in a structured format during parsing.
- **Custom Mapping**: Map JSON keys to different Dart field names using
  `@SafeField(name: 'backend_key')`.

## Performance

SafeJsonMapper is built for production environments where performance is critical. It is safe,
robust, and lightweight:

- **No runtime reflection**: Uses code generation so there's no runtime overhead (reflection-free).
- **No heavy computation**: Only performs direct mapping and necessary type conversions.
- **Negligible memory cost**: Memory footprint is identical to manual JSON parsing.
- **Scales well**: Efficiently handles extremely large JSON payloads without blocking the UI thread.

## Getting Started

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  safe_json_mapper: any

dev_dependencies:
  build_runner: ^2.4.0
  safe_model: any # Needed for the builder
```

## Usage

Define your models using `@SafeJson()` and `@SafeField()` annotations:

```dart
import 'package:safe_json_mapper/safe_json_mapper.dart';

part 'user.g.dart';

@SafeJson()
class User {
  @SafeField(required: true)
  final int id;

  final String? name;

  @SafeBool(fromInt: true)
  final bool isActive;

  final Profile? profile;

  User({required this.id, this.name, required this.isActive, this.profile});

  static void register() => _registerUser();
}
```

Run the build generator:

```bash
dart run build_runner build
```

Initialize and use the mapper:

```dart
void main() {
  // Register your models (generated function)
  User.register();

  final json = {
    "id": "123", // String instead of int
    "isActive": 1, // int instead of bool
    "name": "John Doe"
  };

  // Uses SafeJsonMapper to parse
  final user = SafeJsonMapper.fromJson<User>(json);
  print(user.id); // 123
  print(user.isActive); // true
}
```

### Diagnostic Logging

When `SafeJsonMapper` encounters data drift (e.g., a String provided where an int was expected, or a
missing required field), it collects these events and prints a consolidated diagnostic log to the
console.

**Example Log Output:**

```json
[SafeJsonMapper] Drift detected:
{
  "id": {
    "expected": "int -> required",
    "received": "null"
  },
  "isActive": {
    "expected": "bool",
    "received": "invalid_string"
  }
}
```

This helps you quickly identify backend API issues or schema mismatches during development.

## Error Policies

You can globally configure how `SafeJsonMapper` handles missing required fields and type mismatches
via `SafeJsonMapper.errorPolicy`.

```dart
// Options:
// 1. logAndDefault (Default): Logs a warning to console and uses default values.
// 2. throwError: Throws an exception immediately if a required field is missing (logs are printed first).
// 3. silent: Uses default values without logging.

SafeJsonMapper.errorPolicy = SafeJsonModelErrorPolicy.throwError; 
```

## License

MIT
