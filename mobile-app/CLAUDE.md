# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Development Commands

```bash
# Run the app (handles codegen automatically)
./scripts/run.sh

# Setup without running
./scripts/run.sh --build-only

# Code generation (run after modifying Freezed models)
./scripts/gen_models.sh

# Localization generation (run after modifying ARB files)
./scripts/gen_l10n.sh

# App icon generation
./scripts/gen_icons.sh

# Release build (full pipeline: clean -> pub get -> codegen -> build)
./scripts/build_release_apk.sh --release
./scripts/build_release_apk.sh --debug

# Lint
flutter analyze

# Test
flutter test
```

## Architecture

OmlaPay is a Flutter mobile payment/crypto wallet app using **modular architecture** with **Provider** for state management and **GoRouter** for navigation.

### Structure

- `lib/core/` - Universal app logic: networking (Dio), storage (SharedPreferences), theme, constants, l10n, extensions, utils
- `lib/modules/` - Feature modules (auth, dashboard, coin_details, settings, onboarding, etc.). Each module contains its own screens, providers, services, and widgets
- `lib/providers/` - Global providers: AuthProvider, ThemeProvider, LocaleProvider, GlobalProvider, CoinsPricesProvider, NotificationProvider
- `lib/routes/` - GoRouter config (`app_router.dart`), route constants (`app_routes.dart`), auth middleware
- `lib/widgets/` - Shared reusable widgets (CommonButton, CommonTextField, CommonBottomSheet, AssetCard, CustomSvgPainterWidget, etc.)
- `scripts/` - Build automation shell scripts

### Key Patterns

- **State management**: Provider with `context.read<T>()` / `context.watch<T>()`. Global providers in `lib/providers/`, module-specific providers colocated with their feature.
- **Networking**: Custom `NetworkClient` wrapping Dio with token refresh interceptor. API calls go through `ApiHelper` service. Base URL: `https://api.omlapay.xyz`
- **Routing**: GoRouter with named routes. Route guards via `AuthMiddleware`. Route constants in `app_routes.dart`.
- **Models**: All models use **Freezed** with `@freezed` annotation. Run `./scripts/gen_models.sh` after changes.
- **Error handling**: `AppException` with `messageKey` for localized error messages.

## Coding Rules

These rules are enforced across the project (from `.cursor/rules/`):

1. **Localization-first**: Never hardcode UI strings. Add to both `assets/l10n/app_en.arb` AND `assets/l10n/app_ar.arb`, then use `context.l10n!.keyName`. Use snakeCase for keys; avoid reserved keywords (e.g., use `continueAction` not `continue`). Support RTL: use `start`/`end` alignment, not `left`/`right`.

2. **Freezed models only**: Every new model must use `@freezed`. No mutable plain Dart model classes.

3. **StatelessWidget + Provider first**: Default to `StatelessWidget`. Use `StatefulWidget` only for unavoidable local widget lifecycle needs. Business logic belongs in providers, not in `build()` methods.

4. **Reactive forms**: Use `ReactiveTextField` with `reactive_forms` package. Do not use `TextEditingController` directly.

5. **Theme-driven styling**: Never hardcode colors or visual values. Use `AppColors` from `lib/core/theme/colors.dart` and `Theme.of(context)`. New visual tokens go in the shared theme system (`lib/core/theme/theme.dart`). All components must support light and dark mode.

6. **SVG icons**: Use `CustomSvgPainterWidget` instead of `SvgPicture` for dark mode support. It selectively inverts specified colors (e.g., black to white) while preserving others.

7. **Reuse existing code**: Check `lib/widgets/`, `lib/core/extentions/`, and existing modules before creating new utilities. Use `context_extensions.dart` and `string_extensions.dart`.

8. **Module structure**: New features go in `lib/modules/<feature>/` with subdirectories for screens, providers, services, widgets as needed. Register routes in `app_routes.dart` + `app_router.dart`.
