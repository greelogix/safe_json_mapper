# Changelog

## 0.1.5

- Add secure GitHub Actions CI and OIDC-based pub.dev publishing automation.
- Prevent duplicate drift diagnostics for missing required fields under the
  `logAndDefault` policy.

## 0.1.4

- Update the Maintained By section with the GreeLogix company description.

## 0.1.3

- Add a GreeLogix agency description and company contact details to the README.

## 0.1.2

- Remove the README maintainer section and personal contact details.

## 0.1.1

* Update analyzer, source_gen, and build constraints to support current stable releases.
* Require Dart 3.11 or later and remove the unnecessary Flutter SDK constraint.
* Migrate field discovery to the analyzer 14 API while excluding computed getters.
* Fix generated hash code computation for models with one or more than 20 fields.
* Correct generated-extension examples and add Greelogix maintainer details.
* Add end-to-end code generation regression tests, a runnable Dart example, and CI verification.

## 0.1.0

* **New Features**:
  * Generated `operator ==` and `hashCode` using deep equality for lists, maps, nested models, DateTime, and enums.
  * Generated `toString()` for readable model representations.
  * All features are available via a generated mixin (e.g., `$UserEqualityMixin`).
* **Improvements**:
  * Fixed `copyWith()` method: all parameters are now optional, and omitted values retain their original state.
  * Simplified generated extensions: only `copyWith()` and `toJson()` remain.

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
