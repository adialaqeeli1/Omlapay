# Workaround for R8 NPE compiling
# androidx/transition/CanvasUtils$Api29Impl during minifyReleaseWithR8.
# Tracked at https://issuetracker.google.com/issues/383443329
# Remove this block once R8 ships a fix and the build no longer requires it.
-keep class androidx.transition.** { *; }
-dontwarn androidx.transition.**

# Keep Flutter embedding entrypoints so reflection-based plugin lookup keeps
# working under R8 / shrinking.
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.** { *; }
