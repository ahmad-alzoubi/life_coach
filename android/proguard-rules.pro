-keep class com.hiennv.flutter_callkit_incoming.** { *; }
# Keep AndroidX Window classes
-keep class androidx.window.** { *; }
-dontwarn androidx.window.**

# Keep AppsFlyer SDK
-keep class com.appsflyer.** { *; }
-dontwarn com.appsflyer.**

# Keep Sidecar classes
-keep class androidx.window.sidecar.** { *; }
-dontwarn androidx.window.sidecar.**
