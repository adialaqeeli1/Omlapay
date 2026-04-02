---
trigger: always_on
---

---
description: Enforce global app-wide light and dark theming consistency
alwaysApply: true
---

# Global Light/Dark Theming Rule

- Maintain light/dark theming globally across the entire app, not per-screen ad-hoc.
- Define and update theme behavior in `lib/core/theme/theme.dart` as the central source of truth.
- Use theme-driven values (`Theme.of(context)`, color scheme, text theme, and shared theme tokens) instead of hardcoded visual values.
- Any new UI component must support both light and dark modes by default.
- Do not introduce local-only theme overrides unless there is a clear, approved product requirement.
- If a new visual token is needed, add it to the shared theme system and use it consistently app-wide.

## Example

```dart
// ❌ BAD
Container(color: Colors.white);

// ✅ GOOD
Container(color: Theme.of(context).colorScheme.surface);
```
