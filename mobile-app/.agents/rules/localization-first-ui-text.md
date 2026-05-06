---
trigger: always_on
---

---
description: Require localization files for all UI text and localization-aware UI behavior
alwaysApply: true
---

# Localization-First UI Rule

- Any new or updated user-facing UI text must be added only to:
  - `assets/l10n/app_en.arb`
  - `assets/l10n/app_ar.arb`
  before use in widgets.
- Do not hardcode display strings in UI code, including labels, button text, placeholders, validation text, snackbars, dialogs, empty states, and error messages.
- Do not add or use any other localization source files for app UI strings unless explicitly approved.
- Always consume localized strings through the project localization API (for example via `context.l10n` / generated localization classes).
- Keep localization keys clear, stable, and feature-scoped to avoid duplicates and ambiguity.
- Ensure UI is localization-aware:
  - Respect locale-driven direction (LTR/RTL).
  - Use alignment APIs that adapt to direction (for example start/end instead of left/right when appropriate).
  - Avoid layout assumptions that break with translated or longer text.

## Example

```dart
// ❌ BAD
Text('Continue');

// ✅ GOOD
Text(context.l10n.continueLabel);
```
