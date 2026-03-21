# استكشاف أخطاء بناء APK (Release)

## المشكلة
التطبيق يعمل في وضع الديبق (Debug) ولكن يظهر خطأ عند بناء أو تشغيل APK.

---

## 1. خطأ أثناء البناء (`flutter build apk --release`)

### إذا ظهر خطأ في Gradle:
- تأكد من اتصال الإنترنت (Gradle يحمّل التبعيات)
- نفّذ: `flutter clean` ثم `flutter pub get`
- ثم: `flutter build apk --release`

### إذا ظهر خطأ في التوقيع (Signing):
- أضف `keystore` في `android/app/build.gradle.kts`:
```kotlin
signingConfigs {
    create("release") {
        storeFile = file("your-keystore.jks")
        storePassword = "your-password"
        keyAlias = "your-alias"
        keyPassword = "your-password"
    }
}
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
    }
}
```

---

## 2. التطبيق يعمل بعد التثبيت ثم يتوقف (Crash)

### السبب الشائع: ProGuard/R8
في وضع Release، Android يقلّص الكود (minification) مما قد يسبب أخطاء مع GetX و Dio.

**الحل: تعطيل التصغير مؤقتاً**

في `android/app/build.gradle.kts`:
```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("debug")
        isMinifyEnabled = false   // أضف هذا السطر
        isShrinkResources = false // أضف هذا السطر
    }
}
```

### إن كان التصغير مطلوباً:
استخدم ملف `proguard-rules.pro` الموجود في `android/app/` وأضف في `build.gradle.kts`:
```kotlin
release {
    isMinifyEnabled = true
    isShrinkResources = true
    proguardFiles(
        getDefaultProguardFile("proguard-android-optimize.txt"),
        "proguard-rules.pro"
    )
}
```

---

## 3. خطأ GetX: "improper use of GetX"
في وضع Release، GetX قد يكتشف استخداماً غير صحيح لـ `Obx`.

**الحل:** تأكد من استخدام `.value` عند تمرير متغير `Rx`:
```dart
// خطأ
Obx(() => Text(controller.name))

// صحيح
Obx(() => Text(controller.name.value))
```

---

## 4. الحصول على تفاصيل الخطأ
لتشخيص التوقف عند التشغيل:
```bash
flutter run --release
```
ثم ربط الجهاز ومراقبة `logcat` أو `flutter run` في الطرفية.

---

## 5. بناء APK للتجربة
```bash
flutter clean
flutter pub get
flutter build apk --release
```
الملف الناتج: `build/app/outputs/flutter-apk/app-release.apk`
