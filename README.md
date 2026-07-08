# SafeJsonMapper

## 🎬 Demo
![Safe JSON Mapper Demo](https://raw.githubusercontent.com/greelogix/quick_popup_manager-video/main/safe_json_mapper_demo.gif)

A robust, reflection-free Flutter/Dart package for safe JSON mapping. Handles backend inconsistencies, type drift, nested models, and more using code generation.


## Key Features

- **Safe Type Conversion**: Handles drift between String, int, double, and bool.
- **Boolean Drift Handling**: Converts 1/0 or "true"/"false" strings to boolean values.
- **Nested Models & Collections**: Recursively parses nested objects, lists, and maps.
- **Required Fields & Default Values**: Configurable behavior for missing fields with easy defaults.
- **Field Aliases**: Specify multiple JSON keys for a single Dart field.
- **Nested JSON Paths**: Extract values from deep within JSON using dot-separated paths.
- **Custom Converters**: Plug in your own logic for types like Duration, Uri, or BigInt.
- **Detailed Diagnostics**: Structured logs of all type mismatches and missing fields.
- **Error Policies**: Choose to throw, log, or silently ignore issues.
- **Generated Extensions**: Includes `copyWith` and `toJson`.
- **Generated Equality & String**: Mixin for `operator ==`, `hashCode`, and `toString()`.


## Installation

Add these dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  safe_json_mapper: ^0.1.0

dev_dependencies:
  build_runner: ^2.4.0
```


## Quick Start

### 1. Define Your Model

```dart
import 'package:safe_json_mapper/safe_json_mapper.dart';

part 'user.g.dart';

@SafeJson()
class User with $UserEqualityMixin {
  @SafeField(required: true)
  final int id;

  @SafeField(name: 'full_name')
  final String? name;

  @SafeBool(fromInt: true)
  final bool isActive;

  final Profile? profile;

  final List<String> tags;

  User({
    required this.id,
    this.name,
    required this.isActive,
    this.profile,
    required this.tags,
  });
}

@SafeJson()
class Profile with $ProfileEqualityMixin {
  @SafeField(required: true, defaultValue: 18)
  final int age;

  final String? bio;

  Profile({
    required this.age,
    this.bio,
  });
}
```


### 2. Generate Code

```bash
dart run build_runner build --delete-conflicting-outputs
```


### 3. Use the Mapper

```dart
import 'package:safe_json_mapper/safe_json_mapper.dart';
import 'user.dart';

void main() {
  // Register models
  registerUser();
  registerProfile();

  // Example JSON with type drift
  final json = {
    "id": "123",          // String → int
    "isActive": 1,        // int → bool
    "full_name": "John Doe",
    "tags": ["developer", "flutter"],
    "profile": {
      "age": 30,
      "bio": "Software Engineer"
    }
  };

  // Parse JSON safely
  final user = SafeJsonMapper.fromJson<User>(json);
  print(user.id);             // 123
  print(user.name);           // John Doe
  print(user.isActive);       // true
  print(user.tags);           // [developer, flutter]
  print(user.profile?.age);   // 30
  print(user.toString());     // User(id: 123, name: John Doe, isActive: true, profile: Profile(age: 30, bio: Software Engineer), tags: [developer, flutter])

  // Use copyWith
  final updatedUser = user.copyWith(name: "Jane Doe");
  print(updatedUser.name);    // Jane Doe

  // Check equality
  final sameUser = User(
    id: 123,
    name: "John Doe",
    isActive: true,
    tags: ["developer", "flutter"],
    profile: Profile(age: 30, bio: "Software Engineer"),
  );
  print(user == sameUser);    // true

  // Serialize back to JSON
  final backToJson = SafeJsonMapper.toJson(user);
  print(backToJson);
}
```


## Annotations

### Class Annotation
| Annotation | Description |
|------------|-------------|
| `@SafeJson()` | Marks a class for code generation. |


### Field Annotations
| Annotation | Description |
|------------|-------------|
| `@SafeField()` | Customize mapping with: `name` (custom key), `aliases` (multiple keys), `path` (nested path), `required` (mark as required), `defaultValue` (fallback value), `ignore` (skip JSON). |
| `@SafeBool()` | Boolean-specific options: `fromInt` (converts 1→true, 0→false and string equivalents). |
| `@SafeNum()` | Number-specific options (extends SafeField). |
| `@SafeDefault()` | Sets a default value for a field. |
| `@SafeIgnore()` | Excludes a field from both serialization and deserialization. |
| `@SafeIgnoreFromJson()` | Excludes a field only when reading from JSON. |
| `@SafeIgnoreToJson()` | Excludes a field only when writing to JSON. |


## Error Policies

Configure how issues are handled:

```dart
// Log issues and use defaults (default behavior)
SafeJsonMapper.errorPolicy = SafeJsonModelErrorPolicy.logAndDefault;

// Throw an exception immediately
SafeJsonMapper.errorPolicy = SafeJsonModelErrorPolicy.throwError;

// Use defaults without logging
SafeJsonMapper.errorPolicy = SafeJsonModelErrorPolicy.silent;
```


## Diagnostics

Access drift information after parsing:

```dart
final user = SafeJsonMapper.fromJson<User>(json);
final drifts = SafeJsonMapper.lastDrifts;
print(drifts);
```


## Built-in Converters

Use these for common types:

| Converter | Description |
|-----------|-------------|
| `SafeDurationConverter` | Converts Duration to/from milliseconds (int). |
| `SafeUriConverter` | Converts Uri to/from string. |
| `SafeBigIntConverter` | Converts BigInt to/from string or int. |

Example:
```dart
void main() {
  SafeJsonMapper.registerConverter<Duration>(const SafeDurationConverter());
  SafeJsonMapper.registerConverter<Uri>(const SafeUriConverter());
  SafeJsonMapper.registerConverter<BigInt>(const SafeBigIntConverter());
  // Register models...
}
```


## Best Practices

- **Add the Generated Mixin**: Use `with $ModelNameEqualityMixin` for `operator==`, `hashCode`, and `toString()`.
- **Register All Models**: Call `register<ModelName>()` for all your models once (e.g., in `main()`).
- **Use `@SafeField(name: "...")`**: For fields that map to a different JSON key.
- **Use Aliases**: (`@SafeField(aliases: ["key1", "key2"])`) when supporting multiple key names.


## Troubleshooting

### Build Issues
Try:
```bash
dart pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### Missing Generated Files
- Verify you added `part '<filename>.g.dart';`
- Make sure your model has `@SafeJson()`
- Run `dart analyze` to check for issues


## License

MIT
