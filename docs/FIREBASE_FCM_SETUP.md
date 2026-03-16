# إعداد Firebase و FCM في التطبيق

## ما تم تنفيذه في التطبيق

- **الطلبات والعروض مربوطة بالـ API:**
  - قائمة الطلبات: `GET /home/orders`
  - قائمة العروض على طلب: `GET /home/orders/:orderId/proposals`
  - تقديم عرض: `POST /home/orders/:orderId/proposals` (message، image)
  - قبول عرض: `POST /home/orders/:orderId/proposals/:proposalId/accept`

- **إشعارات FCM:** عند النقر على إشعار (من الخلفية أو بعد إغلاق التطبيق) يُفتح التطبيق ويُنتقل إلى **تبويب الطلبات**. إن أرسل السيرفر `order_id` و `order_title` في بيانات الإشعار يُفتح تفاصيل الطلب مباشرة.
- **نغمة مميزة:** الإشعارات تستخدم نغمة مخصصة (انظر "النغمة المميزة" أدناه).
- **تسجيل التوكن تلقائياً:** بعد تسجيل الدخول (مستخدم أو شركة) وعند فتح التطبيق يُرسل توكن FCM إلى السيرفر عبر `POST /profile/me/fcm-token` حتى يصله الإشعار عند **قبول عرضه** (للمستخدم) أو عند **وصول عرض جديد على طلبه** (للشركة).

---

## خطوات ربط التطبيق بـ Firebase (أنت تنفذها)

### 1) إنشاء مشروع Firebase

1. ادخل إلى [Firebase Console](https://console.firebase.google.com).
2. أنشئ مشروعاً جديداً أو اختر مشروعك.
3. أضف تطبيق **Android** (وحسب الحاجة **iOS**).

### 2) Android

1. نزّل ملف **google-services.json** من لوحة Firebase (إعدادات المشروع ← التطبيقات ← تطبيق Android).
2. ضعه داخل المجلد:
   ```
   android/app/google-services.json
   ```
3. تأكد أن في `android/build.gradle` يوجد:
   ```gradle
   dependencies {
       classpath 'com.google.gms:google-services:4.4.2'
   }
   ```
4. وفي `android/app/build.gradle` في آخر الملف:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

### 3) iOS (اختياري)

1. نزّل **GoogleService-Info.plist** من Firebase.
2. أضفه إلى مشروع Xcode داخل `ios/Runner`.

### 4) تسجيل توكن FCM على السيرفر (مطلوب للإشعارات)

التطبيق يرسل التوكن تلقائياً بعد تسجيل الدخول وعند فتح الصفحة الرئيسية.

- **المسار في الباكند:** `POST /profile/me/fcm-token`
- **Body (JSON):** `{ "fcm_token": "التوكن من الجهاز" }`
- **Auth:** `Authorization: Bearer <token>`

يجب على السيرفر حفظ التوكن مرتبطاً بالمستخدم الحالي (سواء مستخدم أو شركة). عند **قبول عرض** يُرسل السيرفر إشعار FCM للحساب الذي قُبل عرضه (`proposal_accepted`). عند **عرض جديد على طلب** يُرسل إشعار لصاحب الطلب (الشركة).

### 5) النغمة المميزة

- **Android:** ضع ملف نغمة باسم `notification_sound.mp3` داخل:
  ```
  android/app/src/main/res/raw/
  ```
  (المجلد `raw` موجود؛ راجع `raw/README_ADD_SOUND.txt`).
- **iOS:** أضف ملفاً باسم `notification_sound.aiff` في مشروع Xcode ضمن Runner.
- إن لم تضف الملف، قد يستخدم الجهاز النغمة الافتراضية أو يظهر تحذير؛ لإلغاء النغمة المخصصة علّق السطرين `sound: RawResourceAndroidNotificationSound(...)` و `sound: 'notification_sound.aiff'` في `lib/core/services/fcm_service.dart`.

---

## شكل إشعار FCM من السيرفر (للفتح على الطلبات)

لكي يفتح التطبيق على **تبويب الطلبات** أو على **تفاصيل طلب معين**، أرسل في **data** payload مثلاً:

```json
{
  "type": "proposal_accepted",
  "order_id": "29",
  "order_title": "مشروع"
}
```

- **title** و **body**: للنص الظاهر في الإشعار.
- **data**: التطبيق يقرأ `order_id` و `order_title` وينتقل لتفاصيل الطلب إن وُجدتا، وإلا يفتح تبويب الطلبات فقط.

بعد إضافة **google-services.json** (وإن أردت iOS الـ plist) وتشغيل التطبيق، الإشعارات وفتح التطبيق عند النقر تعمل حسب ما سبق.
