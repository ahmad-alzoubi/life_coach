-keep class com.hiennv.flutter_callkit_incoming.** { *; }
-dontwarn com.hiennv.flutter_callkit_incoming.**

##########################
# 2- conditions to solve R8 (Jackson / Payment SDK)
##########################

# Igonre errors
-dontwarn java.beans.**
-dontwarn org.w3c.dom.bootstrap.**

# set code of Jackson 
-keep class com.fasterxml.jackson.** { *; }
-dontwarn com.fasterxml.jackson.databind.ext.**

# save with Annotations and Signatures
-keepattributes *Annotation*,Signature

-keep class com.tiktok.** { *; }
-keep class com.android.billingclient.api.** { *; }
-keep class androidx.lifecycle.** { *; }

