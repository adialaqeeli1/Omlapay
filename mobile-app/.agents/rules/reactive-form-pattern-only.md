---
trigger: always_on
---

---
description: Enforce consistent reactive form patterns and disallow direct TextEditingController usage
alwaysApply: true
---

# Reactive Form Pattern Rule

- Maintain the same form creation pattern across the app.
- Do not create or manage form inputs with direct `TextEditingController` usage in feature UI code.
- Build forms using reactive form patterns, and use `ReactiveTextField` for text inputs.
- Keep validation rules in the reactive form model/configuration, not scattered across widget callbacks.
- Reuse common form field widgets/patterns when similar inputs appear in multiple places.
- For existing screens using `TextEditingController`, prefer refactoring to the reactive pattern when that screen is being modified.

## Example

```dart
// ❌ BAD
final emailController = TextEditingController();
TextField(controller: emailController);

// ✅ GOOD
ReactiveTextField<String>(
  formControlName: 'email',
);
```
