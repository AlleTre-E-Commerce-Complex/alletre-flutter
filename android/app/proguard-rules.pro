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
