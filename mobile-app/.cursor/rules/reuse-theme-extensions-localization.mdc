---
description: Enforce code reuse, theme source-of-truth, extensions, and localization/alignment consistency
alwaysApply: true
---

# Reuse, Theme, Extensions, and Localization Rules

- Avoid duplicate logic/UI. If code is similar or commonly used in multiple places, extract and reuse via shared widget, helper, extension, or service.
- Before adding new code, check existing modules/utilities and reuse them when possible.
- Use `lib/core/theme/colors.dart` as the single source of truth for colors. Do not hardcode color values in feature widgets.
- If visual styling or app theme behavior must change, update `lib/core/theme/theme.dart` (and related theme definitions) instead of ad-hoc local styling.
- Prefer `BuildContext` extensions from `lib/core/extentions/context_extensions.dart` for context-based access patterns.
- Prefer string helpers from `lib/core/extentions/string_extensions.dart` for common string operations.
- All user-facing text must use localization keys/resources. Do not hardcode visible strings in UI.
- Ensure UI alignment and layout direction are localization-aware (for example, LTR/RTL behavior and proper text alignment).

## Example

```dart
// ❌ BAD
Text('Send', style: TextStyle(color: Color(0xFF0066FF)));

// ✅ GOOD
Text(
  context.l10n.send,
  style: TextStyle(color: AppColors.primary),
  textAlign: TextAlign.start,
);
```
