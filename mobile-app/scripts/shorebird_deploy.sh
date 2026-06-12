#!/bin/bash
#
# 🐦 OmlaPay — Shorebird Deploy & Patch Pipeline
# ------------------------------------------------------------
# Usage:
#   ./scripts/shorebird_deploy.sh <release|patch> [options]
#
# Options:
#   --version=<x.y.z | x.y.z+build>   Version name (build auto-bumped) or full version.
#   --patch-version=<x.y.z+build>     (patch only) Which existing release to patch.
#   --platforms=<ios,android>         Narrow the OS-derived platform list (cannot widen it).
#
# Examples:
#   ./scripts/shorebird_deploy.sh release
#   ./scripts/shorebird_deploy.sh release --version=1.0.1
#   ./scripts/shorebird_deploy.sh patch
#   ./scripts/shorebird_deploy.sh patch --patch-version=1.0.0+36 --platforms=android
#
# NOTE: On Windows, run this from Git Bash or WSL (it is a bash script).
# ------------------------------------------------------------

# Navigate to project root (parent of scripts/)
cd "$(dirname "$0")/.." || exit 1
PROJECT_ROOT="$(pwd)"
SCRIPT_DIR="$PROJECT_ROOT/scripts"
PUBSPEC="$PROJECT_ROOT/pubspec.yaml"

# ============================================================
# 🎨 Pretty logging helpers
# ============================================================
log()      { echo "$@"; }
banner()   { echo ""; echo "════════════════════════════════════════════════════════════"; echo "$@"; echo "════════════════════════════════════════════════════════════"; }
step()     { echo ""; echo "👉 $*"; }
info()     { echo "ℹ️  $*"; }
ok()       { echo "✅ $*"; }
warn()     { echo "⚠️  $*"; }
fail()     { echo "❌ $*" >&2; }
die()      { echo ""; echo "❌ $*" >&2; echo "🛑 Aborting." >&2; exit 1; }

# Run a step and die with a friendly message if it fails.
run_step() {
    local label="$1"; shift
    step "$label"
    if "$@"; then
        ok "$label — done"
    else
        die "$label failed."
    fi
}

# ============================================================
# 🧾 Argument parsing
# ============================================================
ACTION=""
VERSION_ARG=""
PATCH_VERSION_ARG=""
PLATFORMS_ARG=""

print_usage() {
    cat <<'USAGE'
🐦 OmlaPay Shorebird Deploy

Usage:
  ./scripts/shorebird_deploy.sh <release|patch> [--version=x.y.z] [--release-version=x.y.z+build] [--platforms=ios,android]

Required:
  release | patch        The Shorebird action to perform.

Options:
  --version=...          Version name (build auto-bumped) or full version (x.y.z+build).
  --patch-version=...    (patch only) Existing release to patch. Defaults to current pubspec version.
  --platforms=...        Narrow the OS-derived platform list, e.g. --platforms=android
USAGE
}

for arg in "$@"; do
    case $arg in
        release|patch)
            ACTION="$arg"
            ;;
        --version=*)
            VERSION_ARG="${arg#*=}"
            ;;
        --patch-version=*)
            PATCH_VERSION_ARG="${arg#*=}"
            ;;
        --platforms=*)
            PLATFORMS_ARG="${arg#*=}"
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            fail "Unknown argument: $arg"
            print_usage
            exit 1
            ;;
    esac
done

if [ -z "$ACTION" ]; then
    fail "Missing required action argument (release | patch)."
    print_usage
    exit 1
fi

banner "🐦 OmlaPay Shorebird Pipeline — 🚀 ACTION: $(echo "$ACTION" | tr '[:lower:]' '[:upper:]')"

# ============================================================
# 🖥️  Step 0a — Detect OS & derive target platforms
# ============================================================
step "🖥️  Detecting operating system"
OS_NAME="$(uname -s)"
case "$OS_NAME" in
    Darwin)
        OS_LABEL="macOS"
        TARGET_PLATFORMS=("ios" "android")
        ;;
    Linux)
        OS_LABEL="Linux"
        TARGET_PLATFORMS=("android")
        ;;
    MINGW*|MSYS*|CYGWIN*)
        OS_LABEL="Windows (bash)"
        TARGET_PLATFORMS=("android")
        ;;
    *)
        OS_LABEL="$OS_NAME (unknown)"
        TARGET_PLATFORMS=("android")
        ;;
esac
ok "OS: $OS_LABEL → default platforms: ${TARGET_PLATFORMS[*]}"

# Narrow platforms if --platforms was provided (intersection only; can't widen).
if [ -n "$PLATFORMS_ARG" ]; then
    info "Narrowing platforms with --platforms=$PLATFORMS_ARG"
    IFS=',' read -r -a REQUESTED <<< "$PLATFORMS_ARG"
    NARROWED=()
    for want in "${REQUESTED[@]}"; do
        want="$(echo "$want" | tr '[:upper:]' '[:lower:]' | xargs)"
        for have in "${TARGET_PLATFORMS[@]}"; do
            if [ "$want" = "$have" ]; then
                NARROWED+=("$have")
            fi
        done
        # Tell the user if they asked for something this OS can't do.
        case " ${TARGET_PLATFORMS[*]} " in
            *" $want "*) ;;
            *) warn "'$want' is not buildable on $OS_LABEL — ignoring." ;;
        esac
    done
    if [ ${#NARROWED[@]} -eq 0 ]; then
        die "No requested platform is buildable on $OS_LABEL."
    fi
    TARGET_PLATFORMS=("${NARROWED[@]}")
    ok "Target platforms after narrowing: ${TARGET_PLATFORMS[*]}"
fi

# ============================================================
# 🦋 Step 0b — Ensure Flutter is installed
# ============================================================
FLUTTER_INSTALL_DIR="$HOME/development/flutter"
SHELL_RC="$HOME/.zshrc"
[ -n "$ZSH_VERSION" ] || [ "$(basename "${SHELL:-}")" = "zsh" ] || SHELL_RC="$HOME/.bashrc"

step "🦋 Checking Flutter installation"
if command -v flutter >/dev/null 2>&1; then
    ok "Flutter found: $(flutter --version 2>/dev/null | head -n 1)"
else
    warn "Flutter not found — attempting to install it."
    if ! command -v git >/dev/null 2>&1; then
        die "git is required to install Flutter but was not found. Install git and re-run."
    fi
    info "📥 Cloning Flutter (stable) into $FLUTTER_INSTALL_DIR ..."
    mkdir -p "$HOME/development" || die "Could not create $HOME/development"
    if [ ! -d "$FLUTTER_INSTALL_DIR" ]; then
        git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_INSTALL_DIR" \
            || die "Flutter clone failed."
    else
        warn "$FLUTTER_INSTALL_DIR already exists — reusing it."
    fi

    # Persist PATH for future shells.
    PATH_LINE='export PATH="$PATH:'"$FLUTTER_INSTALL_DIR"'/bin"'
    if ! grep -qF "$FLUTTER_INSTALL_DIR/bin" "$SHELL_RC" 2>/dev/null; then
        echo "" >> "$SHELL_RC"
        echo "# Added by OmlaPay shorebird_deploy.sh" >> "$SHELL_RC"
        echo "$PATH_LINE" >> "$SHELL_RC"
        ok "Added Flutter to PATH in $SHELL_RC"
    fi
    export PATH="$PATH:$FLUTTER_INSTALL_DIR/bin"

    info "🩺 Running flutter doctor (first run may download the Dart SDK)..."
    flutter doctor || warn "flutter doctor reported issues — review them above."

    banner "🔁 Flutter was just installed. Please restart your terminal (or run: source $SHELL_RC) and re-run this script."
    exit 0
fi

# Surface doctor status (non-fatal) so the user sees toolchain health.
step "🩺 Running flutter doctor"
flutter doctor || warn "flutter doctor reported issues — review them above (continuing)."

# ============================================================
# 🐦 Step 0c — Ensure Shorebird CLI is installed
# ============================================================
step "🐦 Checking Shorebird CLI installation"
if command -v shorebird >/dev/null 2>&1; then
    ok "Shorebird found: $(shorebird --version 2>/dev/null | head -n 1)"
else
    warn "Shorebird CLI not found — installing it."
    if ! command -v curl >/dev/null 2>&1; then
        die "curl is required to install Shorebird but was not found."
    fi
    info "📥 Installing Shorebird via official installer..."
    curl --proto '=https' --tlsv1.2 https://raw.githubusercontent.com/shorebirdtech/install/main/install.sh -sSf | bash \
        || die "Shorebird installation failed."

    # The installer adds ~/.shorebird/bin to PATH for future shells; export for this run.
    export PATH="$PATH:$HOME/.shorebird/bin"
    if ! command -v shorebird >/dev/null 2>&1; then
        banner "🔁 Shorebird was installed. Please restart your terminal (or run: source $SHELL_RC) and re-run this script."
        exit 0
    fi
    ok "Shorebird installed: $(shorebird --version 2>/dev/null | head -n 1)"
fi

# ============================================================
# 🔐 Step 0d — Ensure Shorebird login (waits for browser)
# ============================================================
step "🔐 Verifying Shorebird authentication"
# Probe with an authenticated command. If it fails, we (likely) need to log in.
if shorebird releases list >/dev/null 2>&1; then
    ok "Already authenticated with Shorebird."
else
    warn "Not authenticated (or unable to reach Shorebird). Starting login..."
    info "🌐 A browser window will open. Complete the login, then return here."
    shorebird login || die "Shorebird login failed."
    # Re-verify after login.
    if shorebird releases list >/dev/null 2>&1; then
        ok "Logged in to Shorebird."
    else
        die "Still unable to query Shorebird after login. Check your network/account."
    fi
fi

# ============================================================
# 🧰 Step 0e — Platform SDK preflight (Xcode / Android SDK)
# ============================================================
# Returns 0 if the SDK for the given platform is ready, 1 otherwise (with guidance).
check_platform_sdk() {
    local platform="$1"
    case "$platform" in
        ios)
            if ! command -v xcodebuild >/dev/null 2>&1; then
                warn "iOS skipped — Xcode is not installed."
                info "   👉 Install Xcode from the App Store, then run:"
                info "      sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
                info "      sudo xcodebuild -license accept"
                return 1
            fi
            if ! xcodebuild -version >/dev/null 2>&1; then
                warn "iOS skipped — Xcode is present but not usable (license or command-line tools)."
                info "   👉 Run: sudo xcodebuild -license accept"
                info "      And: sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
                return 1
            fi
            ok "Xcode ready: $(xcodebuild -version 2>/dev/null | head -n 1)"
            return 0
            ;;
        android)
            local sdk_root="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}"
            if [ -z "$sdk_root" ] && ! command -v sdkmanager >/dev/null 2>&1; then
                # Fall back to common default location.
                if [ -d "$HOME/Library/Android/sdk" ]; then
                    sdk_root="$HOME/Library/Android/sdk"
                elif [ -d "$HOME/Android/Sdk" ]; then
                    sdk_root="$HOME/Android/Sdk"
                fi
            fi
            if [ -z "$sdk_root" ] && ! command -v sdkmanager >/dev/null 2>&1; then
                warn "Android skipped — Android SDK not found (ANDROID_HOME unset, no default SDK)."
                info "   👉 Install Android Studio, open it once to install the SDK, then set:"
                info "      export ANDROID_HOME=\"\$HOME/Library/Android/sdk\"   # macOS"
                info "      export ANDROID_HOME=\"\$HOME/Android/Sdk\"            # Linux"
                return 1
            fi
            [ -n "$sdk_root" ] && export ANDROID_HOME="$sdk_root"
            ok "Android SDK ready${ANDROID_HOME:+: $ANDROID_HOME}"
            return 0
            ;;
        *)
            warn "Unknown platform '$platform' — skipping."
            return 1
            ;;
    esac
}

step "🧰 Verifying platform SDKs for: ${TARGET_PLATFORMS[*]}"
BUILDABLE_PLATFORMS=()
for platform in "${TARGET_PLATFORMS[@]}"; do
    if check_platform_sdk "$platform"; then
        BUILDABLE_PLATFORMS+=("$platform")
    fi
done

if [ ${#BUILDABLE_PLATFORMS[@]} -eq 0 ]; then
    die "No platform has a ready SDK. Install the required tooling (see guidance above) and re-run."
fi
ok "Buildable platforms: ${BUILDABLE_PLATFORMS[*]}"

# ============================================================
# 🧹 Step 1 — Build prep (clean → deps → codegen → rename)
# ============================================================
banner "🧹 Preparing build"
run_step "🧽 flutter clean"            flutter clean
run_step "📦 flutter pub get"          flutter pub get
run_step "🎨 Generating app icons"     bash "$SCRIPT_DIR/gen_icons.sh"
run_step "🌍 Generating localizations" bash "$SCRIPT_DIR/gen_l10n.sh"
run_step "❄️  Generating models"        bash "$SCRIPT_DIR/gen_models.sh"
run_step "🏷️  Renaming app"             bash "$SCRIPT_DIR/rename_app.sh"

# ============================================================
# 🔢 Step 2 — Version handling
# ============================================================
read_pubspec_version() {
    grep -E '^version:' "$PUBSPEC" | head -n 1 | sed 's/version:[[:space:]]*//' | tr -d '[:space:]'
}

# Highest build number currently published on Shorebird (0 if none/parse fails).
shorebird_max_build() {
    local max=0 b
    while read -r b; do
        if [ -n "$b" ] && [ "$b" -gt "$max" ] 2>/dev/null; then
            max="$b"
        fi
    done < <(shorebird releases list 2>/dev/null \
                | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+' \
                | sed 's/.*+//')
    echo "$max"
}

CURRENT_VERSION="$(read_pubspec_version)"
CURRENT_NAME="$(echo "$CURRENT_VERSION" | cut -d'+' -f1)"
CURRENT_BUILD="$(echo "$CURRENT_VERSION" | cut -d'+' -f2)"
info "📄 Current pubspec version: $CURRENT_VERSION"

DEPLOY_VERSION="$CURRENT_VERSION"   # version reported to the user
RELEASE_VERSION_TARGET=""           # used by patch

if [ "$ACTION" = "release" ]; then
    banner "🔢 Resolving release version"

    # Case 1: full version provided (contains '+') → use verbatim.
    if [ -n "$VERSION_ARG" ] && echo "$VERSION_ARG" | grep -q '+'; then
        NEW_VERSION="$VERSION_ARG"
        info "Using full --version verbatim: $NEW_VERSION"
    else
        SB_MAX="$(shorebird_max_build)"
        info "🐦 Highest build on Shorebird: $SB_MAX"
        info "📄 pubspec build: $CURRENT_BUILD"

        # NEW_BUILD: keep pubspec build if it's already ahead, else Shorebird max + 1.
        if [ "$CURRENT_BUILD" -gt "$SB_MAX" ] 2>/dev/null; then
            NEW_BUILD="$CURRENT_BUILD"
            info "pubspec build is ahead of Shorebird — keeping +$NEW_BUILD."
        else
            NEW_BUILD=$((SB_MAX + 1))
            info "Current build already released — bumping to +$NEW_BUILD."
        fi

        # Name: from --version (name-only) if given, else current pubspec name.
        if [ -n "$VERSION_ARG" ]; then
            NAME="$VERSION_ARG"
        else
            NAME="$CURRENT_NAME"
        fi
        NEW_VERSION="${NAME}+${NEW_BUILD}"
    fi

    if [ "$NEW_VERSION" != "$CURRENT_VERSION" ]; then
        sed -i.bak "s/^version: .*/version: ${NEW_VERSION}/" "$PUBSPEC" && rm -f "$PUBSPEC.bak"
        ok "📝 pubspec.yaml updated: $CURRENT_VERSION → $NEW_VERSION"
    else
        ok "📝 Version unchanged (already up to date): $NEW_VERSION"
    fi
    DEPLOY_VERSION="$NEW_VERSION"
else
    # PATCH: never bump. Resolve which release to patch.
    # If no version is provided, leave RELEASE_VERSION_TARGET empty so Shorebird
    # prompts interactively with its own list of available releases.
    banner "🔢 Resolving patch target release"
    if [ -n "$PATCH_VERSION_ARG" ]; then
        RELEASE_VERSION_TARGET="$PATCH_VERSION_ARG"
    elif [ -n "$VERSION_ARG" ]; then
        RELEASE_VERSION_TARGET="$VERSION_ARG"
    fi

    if [ -n "$RELEASE_VERSION_TARGET" ]; then
        DEPLOY_VERSION="$RELEASE_VERSION_TARGET"
        ok "🎯 Patching release version: $RELEASE_VERSION_TARGET"
    else
        DEPLOY_VERSION="(interactive)"
        info "🤝 No --patch-version given — Shorebird will prompt you to pick the release version."
    fi
fi

# ============================================================
# 🚀 Step 3 — Deploy (iOS first, then Android)
# ============================================================
banner "🚀 Running Shorebird $ACTION → ${BUILDABLE_PLATFORMS[*]} (v$DEPLOY_VERSION)"

# Order platforms: iOS first, then Android (only those that are buildable).
ORDERED_PLATFORMS=()
for p in ios android; do
    for b in "${BUILDABLE_PLATFORMS[@]}"; do
        [ "$p" = "$b" ] && ORDERED_PLATFORMS+=("$p")
    done
done

SUCCEEDED=()
FAILED=()

for platform in "${ORDERED_PLATFORMS[@]}"; do
    case "$platform" in
        ios)     EMOJI="🍎" ;;
        android) EMOJI="🤖" ;;
        *)       EMOJI="📦" ;;
    esac

    banner "$EMOJI Shorebird $ACTION — $platform"
    if [ "$ACTION" = "release" ]; then
        if shorebird release "$platform"; then
            ok "$EMOJI $platform release completed."
            SUCCEEDED+=("$platform")
        else
            fail "$EMOJI $platform release failed."
            FAILED+=("$platform")
        fi
    else
        # Build the patch command; only pin --release-version when one was provided,
        # otherwise let Shorebird prompt interactively with its release list.
        PATCH_CMD=(shorebird patch --platforms="$platform")
        if [ -n "$RELEASE_VERSION_TARGET" ]; then
            PATCH_CMD+=(--release-version="$RELEASE_VERSION_TARGET")
        fi
        if "${PATCH_CMD[@]}"; then
            ok "$EMOJI $platform patch completed."
            SUCCEEDED+=("$platform")
        else
            fail "$EMOJI $platform patch failed."
            FAILED+=("$platform")
        fi
    fi
done

# ============================================================
# 📊 Summary
# ============================================================
banner "📊 Summary — Shorebird $ACTION (v$DEPLOY_VERSION)"
if [ ${#SUCCEEDED[@]} -gt 0 ]; then
    ok "Succeeded: ${SUCCEEDED[*]}"
fi
if [ ${#FAILED[@]} -gt 0 ]; then
    fail "Failed: ${FAILED[*]}"
    echo ""
    die "One or more platforms failed. See logs above."
fi

echo ""
ok "🎉 All done! Shorebird $ACTION succeeded for: ${SUCCEEDED[*]} (v$DEPLOY_VERSION)"
