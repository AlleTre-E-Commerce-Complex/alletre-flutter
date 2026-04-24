# Preserve all Stripe SDK classes
-keep class com.stripe.** { *; }
-dontwarn com.stripe.**

# Preserve React Native Stripe SDK classes (Flutter + React bridge)
-keep class com.reactnativestripesdk.** { *; }
-dontwarn com.reactnativestripesdk.**

# Preserve Flutter plugin classes (safe fallback)
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Preserve activity result listener patterns
-keepclassmembers class * {
    void onActivityResult(...);
}

# Prevent removal of model classes used via reflection
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

# Prevent R8 from breaking internal crypto functions
-keep class javax.crypto.** { *; }
-keep class org.openssl.** { *; }
-dontwarn javax.crypto.**

# If you use flutter_secure_storage or biometric plugins
-keep class com.it_0.flutter_secure_storage.** { *; }

# 1. Keep all classes that are passed between Flutter and Native
-keep class io.flutter.plugin.common.** { *; }

# 2. Keep Firebase Messaging (if you use it for notifications)
-keep class com.google.firebase.messaging.** { *; }
-dontwarn com.google.firebase.messaging.**

# 3. Keep any 'Model' or 'Data' classes you created for notifications
# Replace 'com.your.package.models' with your actual model package
-keep class com.your.package.models.** { *; }

# 4. Keep GSON/Moshi/Kotlin Serialization if you use them to parse args
-keepattributes Signature, *Annotation*, InnerClasses
-keep class com.google.gson.** { *; }