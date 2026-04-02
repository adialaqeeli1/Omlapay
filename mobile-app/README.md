# OmlaPay Mobile App

This is the mobile application for OmlaPay, built with Flutter. The app provides a smart payment solution with multi-language support, robust authentication, and a modern UI featuring advanced SVG rendering and fluid animations.

---

## 🚀 Key Features

-   **🔐 Robust Authentication** - Secure token-based auth with auto-refresh.
-   **🎨 Dynamic Theme System** - Light/Dark mode with a centralized `AppColors` design system.
-   **🖌️ Advanced SVG Rendering** - Custom `CustomSvgPainterWidget` with **Selective Color Inversion** (Smart Dark Mode adaptation).
-   **🌍 Multi-language Support** - English & Arabic (RTL) with async localization loading.
-   **💾 Reliable Persistence** - Users settings (Theme, Locale) persist correctly across restarts.
-   **🌊 Fluid UX** - "Breathing" splash animation and smooth onboarding flow.

---

## 🏗️ Architecture & Project Structure

We have migrated from a flat structure to a **Modular Architecture**. This structure is designed to separate global app logic (Core) from feature-specific logic (Modules).

### Why We Migrated?

-   **Scalability**: Grouping by **Features** (Modules) allows the app to scale indefinitely. A generic `screens` folder becomes unmanageable with 50+ screens.
-   **Maintainability**: Related code (Screen + Widget + Logic) lives together. If you touch Auth, you only open `modules/auth`.
-   **Clean separation**: `core/` contains strictly universal logic. `modules/` contains business features.

### File Structure

```
omlapay_mobile_app/
├── android/                 # 🤖 Android platform native code & configs
├── assets/                  # 🎨 Static Application Assets
│   ├── animations/          # 🎬 Rive/Lottie animation files
│   │   ├── splash_animation_dark.json      # Dark mode splash animation
│   │   └── ...                             # Other animation variants
│   ├── icons/               # 🖼️ SVG Icons used mainly with CustomSvgPainter
│   │   ├── Receive.svg                     # Icon for Receive action
│   │   ├── Stack-Of-Cryptocoins.svg        # Dashboard asset illustration
│   │   ├── empty-state.svg                 # Empty state placeholder
│   │   └── ...                             # Other app icons
│   ├── l10n/                # 🌍 Localization Source Files (ARB)
│   │   ├── app_ar.arb                      # Arabic translation keys
│   │   └── app_en.arb                      # English translation keys
│   └── logo/                # 🏷️ branding files
│       ├── logo-dark.png                   # App logo for dark mode
│       └── logo-light.png                  # App logo for light mode
├── ios/                     # 🍎 iOS platform native code & configs
├── lib/                     # 📱 Main Dart Application Code
│   ├── core/                # 🧠 CORE: Universal App Logic & Utilities
│   │   ├── constants/       # 📌 App-wide Constants
│   │   │   ├── constants.dart              # General constants (URLs, keys)
│   │   │   └── endpoints.dart              # API endpoint paths
│   │   ├── extentions/      # 🔗 Dart Extensions
│   │   │   ├── context_extensions.dart     # Context helpers (media query, theme)
│   │   │   └── string_extensions.dart      # String manipulation helpers
│   │   ├── l10n/            # 🗣️ Generated Localization Classes
│   │   │   ├── app_localizations.dart      # Abstract localization class
│   │   │   ├── app_localizations_ar.dart   # Arabic implementation
│   │   │   └── app_localizations_en.dart   # English implementation
│   │   ├── network/         # 🌐 Networking Layer
│   │   │   ├── network_client.dart         # Dio/Http client wrapper
│   │   │   ├── network_data_response.dart  # Generic API response model
│   │   │   ├── network_interceptor.dart    # Request/Response interceptors
│   │   │   └── network_token.dart          # Token management logic
│   │   ├── services/        # ⚙️ Core Services
│   │   │   ├── api_helper.dart             # API Helper service
│   │   │   └── storage_helper.dart         # Local storage service (SharedPreferences)
│   │   ├── theme/           # 🎨 Theme System
│   │   │   ├── colors.dart                 # AppColors palette definition
│   │   │   └── theme.dart                  # ThemeData configuration
│   │   └── utils/           # 🛠️ Utilities
│   │       ├── app_exception.dart          # Custom exception classes
│   │       ├── language_helper.dart        # Language switching logic
│   │       ├── path_helper.dart            # File path utilities
│   │       └── utility.dart                # Misc helper functions
│   ├── modules/             # 📦 MODULES: Feature-Specific Code
│   │   ├── auth/            # 🔐 Authentication Module
│   │   │   ├── services/
│   │   │   │   └── user_service.dart       # User auth API service
│   │   │   ├── enter_passcode_screen.dart  # PIN entry screen
│   │   │   ├── hard_login_screen.dart      # Full credential login screen
│   │   │   ├── login_screen.dart           # Initial login landing
│   │   │   └── soft_login_screen.dart      # Biometric/Quick login screen
│   │   ├── coin_details/    # 🪙 Coin Details & Transactions Module
│   │   │   ├── providers/
│   │   │   │   └── coin_details_provider.dart # State management for coin details
│   │   │   └── view/
│   │   │       └── coin_details_view.dart    # Main coin details UI
│   │   ├── dashboard/       # 📊 Main Dashboard Module
│   │   │   ├── history/     # 📜 Transaction History Sub-module
│   │   │   │   └── history_view.dart       # Transaction list screen
│   │   │   ├── home/        # 🏠 Home Tab Sub-module
│   │   │   │   ├── widgets/
│   │   │   │   │   └── currency_selection_dialog.dart # Currency picker
│   │   │   │   └── home_view.dart          # Main Home Dashboard UI
│   │   │   ├── profile/     # 👤 User Profile Sub-module
│   │   │   │   ├── about/
│   │   │   │   │   ├── about_view.dart            # About Us screen
│   │   │   │   │   ├── faqs_view.dart             # FAQ screen
│   │   │   │   │   ├── privacy_policy_view.dart   # Privacy Policy screen
│   │   │   │   │   └── terms_conditions_view.dart # Terms & Conditions screen
│   │   │   │   ├── help_center/
│   │   │   │   │   ├── help_center_view.dart      # Help Center landing
│   │   │   │   │   ├── past_requests_view.dart    # Support ticket history
│   │   │   │   │   └── send_request_view.dart     # Create support ticket
│   │   │   │   └── profile_view.dart       # Main Profile Menu UI
│   │   │   ├── widget/
│   │   │   │   └── bottom_navbar.dart      # Dashboard Bottom Navigation
│   │   │   └── dashboard_view.dart         # Dashboard Container (Holds Tabs)
│   │   ├── onboarding/      # 🚀 Onboarding Module
│   │   │   ├── provider/
│   │   │   │   └── onboarding_provider.dart # Onboarding state
│   │   │   ├── screens/
│   │   │   │   ├── choose_language.dart    # Language selection screen
│   │   │   │   └── onboarding_page.dart    # Individual onboarding step
│   │   │   └── onboarding_view.dart        # PageView controller for onboarding
│   │   ├── settings/        # ⚙️ Settings Module
│   │   │   ├── settings_view.dart          # General Settings UI
│   │   │   └── widgets/
│   │   │       ├── appearance_selection_widget.dart # Theme picker
│   │   │       └── language_selection_widget.dart   # Language picker
│   │   └── splash/          # 💦 Splash Screen Module
│   │       └── splash_view.dart            # Initial app launch screen
│   ├── providers/           # ⚡ STATE: Global App Providers
│   │   ├── auth_provider.dart              # Global authentication state
│   │   ├── global_provider.dart            # Global app state (Currency/Balance)
│   │   ├── locale_provider.dart            # Locale/Language state
│   │   └── theme_provider.dart             # ThemeMode state
│   ├── routes/              # 🧭 NAVIGATION: Routing Config
│   │   ├── middlewares/
│   │   │   └── auth_middleware.dart        # Route guard for authentication
│   │   ├── app_router.dart                 # GoRouter configuration
│   │   └── app_routes.dart                 # Route path string constants
│   ├── widgets/             # 🧩 SHARED: Reusable Atomic Widgets Library
│   │   ├── asset_card.dart                 # Crypto asset display card
│   │   ├── common_attachment_field.dart    # File attachment input widget
│   │   ├── common_back_button.dart         # Standard back button
│   │   ├── common_bottom_sheet.dart        # Reusable bottom sheet container
│   │   ├── common_button.dart              # Primary app button
│   │   ├── common_coin_icon.dart           # Crypto icon with fallback
│   │   ├── common_form_label.dart          # Label for form fields
│   │   ├── common_grid_bg_wrapper.dart     # Standard scaffold with grid background
│   │   ├── common_icon_button.dart         # Standard icon button
│   │   ├── common_loading_indicator.dart   # Centered circular loader
│   │   ├── common_text_field.dart          # Standard text input field
│   │   ├── common_transparent_card.dart    # Glassmorphism container
│   │   ├── custom_svg_painter.dart         # Smart SVG renderer
│   │   ├── custom_transitions.dart         # Page transition animations
│   │   ├── no_transactions_found.dart      # Empty state for transactions
│   │   ├── receive_send_swap_actions.dart  # Action buttons row
│   │   └── theme_aware_icon.dart           # Icon adapting to theme context
│   └── main.dart            # 🚀 Entry Point: App initialization
├── scripts/                 # 🛠️ HELPER SCRIPTS: Automation
│   ├── build_release_apk.sh # Bash: Full clean build pipeline for APK
│   ├── gen_icons.sh         # Bash: Generate launcher icons
│   ├── gen_l10n.sh          # Bash: Generate localization files
│   ├── gen_models.sh        # Bash: Run build_runner for models
│   ├── rename_app.sh        # Bash: Rename app package ID
│   └── run.sh               # Bash: Run app with config
├── pubspec.yaml             # 📦 Dependencies & Project Metadata
└── README.md                # 📖 Project Documentation (This file)
```

---

## 🛠️ Development Scripts

We provide helper scripts in the `scripts/` directory to automate repetitive tasks. **Run these from the root directory.**

### 1. Generate Icons
Update launcher icons for Android/iOS based on `flutter_launcher_icons.yaml`.
```bash
./scripts/gen_icons.sh
```

### 2. Generate Localization
Regenerate Dart localization classes from `app_en.arb` / `app_ar.arb`.
```bash
./scripts/gen_l10n.sh
```

### 3. Generate Models
Run `build_runner` to generate `toJson`/`fromJson` code (if using Freezed/JsonSerializable).
```bash
./scripts/gen_models.sh
```

### 4. Rename App
Rename the app package name and display name across Android and iOS.
```bash
./scripts/rename_app.sh "New App Name"
```

### 5. Run Helper
Launch the app with specific configurations (customizable).
```bash
./scripts/run.sh
```

### 6. Build Release APK
Full clean build pipeline that runs all generation steps before building the APK. Executes in order: `flutter clean` -> `flutter pub get` -> `gen_l10n.sh` -> `gen_models.sh` -> `gen_icons.sh` -> `rename_app.sh` -> `flutter build apk`.

```bash
# Release build (default)
./scripts/build_release_apk.sh

# Or explicitly pass --release
./scripts/build_release_apk.sh --release

# Debug build
./scripts/build_release_apk.sh --debug
```

---

## 📚 Developer "How-To" Guides

### How to Add a New Feature Module?
1.  **Create Directory**: `lib/modules/new_feature/`
2.  **Structure It**:
    ```
    modules/new_feature/
    ├── screens/
    ├── widgets/
    └── new_feature_view.dart (Main entry)
    ```
3.  **Register Route**: Add the path to `lib/routes/app_routes.dart` and register it in `lib/routes/app_router.dart`.

### How to Add a New Icon?
We use a **Custom SVG Painter** for full control over rendering and dark mode.

1.  **Add File**: Place `.svg` file in `assets/icons/`.
2.  **Use Widget**: Use `CustomSvgPainterWidget` instead of `SvgPicture`.
    ```dart
    CustomSvgPainterWidget(
      assetPath: 'assets/icons/my_icon.svg',
      width: 24, 
      colorToInvert: Colors.black, // Set this to the color you want to invert (e.g. Black -> White)
    )
    ```
    > **Tip**: `colorToInvert: Colors.black` will specifically find **Black** pixels and invert them to **White** (and vice versa), while keeping other colors (like Red/Green) untouched. This is perfect for Dark Mode.

### How to Add a New Color?
**Never hardcode colors.** Always use the Design System.

1.  **Open**: `lib/core/theme/app_colors.dart`.
2.  **Add Static Const**:
    ```dart
    static const Color myNewColor = Color(0xFF123456);
    ```
3.  **Use It**: `color: AppColors.myNewColor`.

### How to Add a New Translation?
1.  **Open ARB files**: `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`.
2.  **Add Key**:
    ```json
    "welcomeMessage": "Welcome Back"
    ```
3.  **Run Script**: `./scripts/gen_l10n.sh`
4.  **Use It**: `context.l10n!.welcomeMessage`

---

## 🐞 Troubleshooting & FAQs

### "My settings (Theme/Language) reset after restart!"
This was a known race condition. We fixed it by ensuring `StorageService` is initialized **before** the app runs.
If you see this again, ensure `main.dart` looks like this:
```dart
void main() async { // Must be async
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeApp(); // Must await this!
  runApp(const MyApp());
}
```

### "My icons look weird (Green became Red) in Dark Mode!"
You are likely using `ColorFilter.matrix` blindly.
**Solution**: Switch to `CustomSvgPainterWidget` with `colorToInvert: Colors.black`. It uses a smart `SelectiveColorMapper` that ONLY inverts black pixels.

---

## 🏁 Getting Started

### Prerequisites
-   Flutter SDK (3.10.3+)
-   Dart SDK

### Installation

1.  **Clone the repository**
    ```bash
    git clone https://github.com/marsdevs-com/omlapay-mobile-app.git
    cd omlapay-mobile-app
    ```

2.  **Install dependencies**
    ```bash
    flutter pub get
    ```

3.  **Run the app**
    ```bash
    flutter run
    ```

---

## 🧩 Common Widgets Library

We have a growing library of reusable widgets in `lib/widgets/`. Use them to ensure UI consistency.

### 1. `ReceiveSendSwapActions`
The standard action row for Receive, Send, and Swap operations.
- **Features**: Automatically detects context (e.g., changes button color if on Details page vs Home).
- **Usage**:
  ```dart
  const ReceiveSendSwapActions()
  ```

### 2. `AssetCard`
Displays a crypto asset with icon, balance, and value.
- **Usage**:
  ```dart
  AssetCard(
    symbol: 'USDT',
    name: 'Tether',
    amount: '100.00',
    valueInUsd: '≈ $100.00',
    icon: ..., 
    onTap: () => ...,
  )
  ```

### 3. `NoTransactionsFound`
Standard empty state for transaction lists.
- **Features**: Supports Hero transitions (defaults to 'no-transactions-found' tag). Pass `heroTag` for unique instances.
- **Usage**:
  ```dart
  const NoTransactionsFound(heroTag: 'unique-tag') // For multiple instances
  ```

### 4. `CommonCoinIcon`
Renders a crypto icon (from `crypto_font_icons` or fallback).
- **Usage**:
  ```dart
  CommonCoinIcon(symbol: 'BTC', radius: 16)
  ```

### 5. `CommonGridBgWrapper`
The primary layout scaffold for screens requiring the signature "Grid Background".
- **Features**: Sliver-based scrolling, Glassmorphism card support, collapsible headers.
- **Usage**: Wraps the entire screen body.

### 6. `CommonBottomSheet`
A consistent bottom sheet for prompts or selections.
- **Features**: Built-in close button, title, and optional dividers between children.

### 7. `CommonButton` & `CommonIconButton`
Standardized interactive buttons.
- `CommonButton`: Text-based button with predefined styling.
- `CommonIconButton`: SVG-based icon button with touch feedback.

### 8. `CommonTextField` & `CommonFormLabel`
Input components for forms.
- **Features**: Consistent borders, padding, and text styles matched to the theme.

### 9. `CommonBackButton`
Standard navigation back button.
- **Features**: Automatically handles `context.pop()` unless overridden.

### 10. `CommonLoadingIndicator`
Centralized activity indicator (CircularProgressIndicator) to ensure uniform loading states.

---

## 🔄 Recent Changes (v1.1)

-   **Global State**: `GlobalProvider` now manages `isBalanceVisible` and `selectedCurrency` app-wide.
-   **Coin Details**: Refactored `CoinDetailsView` to `StatelessWidget` using `CoinDetailsProvider`.
-   **Localization**: Added support for RTL (Arabic) and removed hardcoded strings in Coin Details.
-   **Navigation**: Updated `GoRouter` path handling in widgets for dynamic context awareness.
-   **API Error Handling**: Fixed `LoginProvider` to display actual API error messages (e.g., "This mobile number is already registered.") instead of a generic "An Unknown Error Occurred" for both registration and login flows.
-   **Build Script**: Added `build_release_apk.sh` — a full build pipeline that runs clean, pub get, localization, model generation, icon generation, app rename, and APK build in sequence. Supports `--release` (default) and `--debug` flags.