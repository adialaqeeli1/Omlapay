---
description: Prefer StatelessWidget and manage state updates through providers
alwaysApply: true
---

# Stateless + Provider First Rule

- Use `StatelessWidget` by default for UI screens/components.
- Use `StatefulWidget` only when there is a clear, unavoidable local widget lifecycle need.
- Keep state update logic out of widgets; manage it through providers used across the app.
- Do not place business/state mutation logic inside `build()` methods or local widget callbacks when it belongs in a provider.
- Keep widgets focused on rendering and user interaction wiring, while providers handle state transitions.
- Reuse existing provider patterns and structure already established in the project.

## Example

```dart
// ✅ Preferred direction
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Read/watch provider state and render UI
    return const SizedBox.shrink();
  }
}
```
