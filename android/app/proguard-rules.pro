# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# GetX - منع تعطيل الـ reflection
-keep class com.get.** { *; }
-keepclassmembers class * {
    @com.get.Get *;
}

# Dio - شبكة HTTP
-keep class com.squareup.okhttp3.** { *; }
-dontwarn com.squareup.okhttp3.**
-dontwarn okio.**
-keep class io.flutter.plugins.** { *; }

# Gson / JSON إن وُجد
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}

# حفظ نماذج البيانات
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
