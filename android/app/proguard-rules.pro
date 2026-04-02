# ══════════════════════════════════════════════════════════════
# OnlinePDKS ProGuard Kuralları
# ══════════════════════════════════════════════════════════════

# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Dio / OkHttp
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# Geolocator
-keep class com.baseflow.geolocator.** { *; }

# Mobile Scanner (ML Kit Barcode)
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# Device Info Plus
-keep class dev.fluttercommunity.plus.device_info.** { *; }

# Permission Handler
-keep class com.baseflow.permissionhandler.** { *; }

# Connectivity Plus
-keep class dev.fluttercommunity.plus.connectivity.** { *; }

# Gson / JSON serialization
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.** { *; }

# Genel kurallar
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile