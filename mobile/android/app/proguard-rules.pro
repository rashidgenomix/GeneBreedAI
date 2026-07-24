# Flutter's own engine/embedding classes must survive R8 shrinking.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Play Core split-install classes referenced by Flutter's deferred-components support,
# even when this app doesn't use deferred components.
-dontwarn com.google.android.play.core.**
