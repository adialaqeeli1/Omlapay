---
trigger: always_on
---

---
description: Enforce existing project structure and freezed-based models
alwaysApply: true
---

# Project Structure and Model Rules

## Follow Existing Project Structure

- Place new code in the same feature/module structure already used in this project.
- Keep screens/views, services, providers, widgets, routes, and models in their existing layer boundaries.
- Do not introduce a new folder pattern when an equivalent existing pattern already exists.

## Models Must Use `freezed`

- Every new model must be implemented with `freezed` (`@freezed` annotation).
- Model files must include generated parts:
  - `part '<file_name>.freezed.dart';`
  - `part '<file_name>.g.dart';` when JSON serialization is needed.
- Prefer immutable value objects and generated helpers (`copyWith`, equality, serialization) from `freezed`.
- Do not create mutable plain Dart model classes when `freezed` can be used.

## Example

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sample_model.freezed.dart';
part 'sample_model.g.dart';

@freezed
class SampleModel with _$SampleModel {
  const factory SampleModel({
    required String id,
    required String name,
  }) = _SampleModel;

  factory SampleModel.fromJson(Map<String, dynamic> json) =>
      _$SampleModelFromJson(json);
}
```
