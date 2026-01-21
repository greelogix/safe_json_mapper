# Changelog

## 0.0.5

* **Metadata & Documentation**:
    * Improved library documentation to follow Dart conventions.
    * Fixed repository and issue tracker URLs in `pubspec.yaml`.
    * Synchronized versioning across all files.

## 0.0.4

* **Maintenance**:
    * Internal improvements and code cleanup.
    * Updated example projects.

## 0.0.3

* **Bug Fixes**:
    * Minor fixes in code generation logic.

## 0.0.2

* **Visual & API Improvements**:
    * Improved diagnostic logging: JSON drift is now logged in a structured format.
    * Renamed annotations for brevity: `SafeJsonField` -> `@SafeField`, `SafeJsonBool` -> `@SafeBool`.
    * Added `SafeJsonMapper.errorPolicy` global configuration.

## 0.0.1

* Initial release of SafeJsonMapper.
* Support for safe type conversion (String, int, double, bool).
* Support for boolean drift (1/0, "true"/"false").
* Support for nested models and recursive list mapping.
* Support for custom field mapping via `@SafeField(name: '...')`.
* Configurable error policies (Throw, Log & Default, Silent).
* Fully reflection-free code generation using `build_runner`.
