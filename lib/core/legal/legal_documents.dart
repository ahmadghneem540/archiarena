/// نصوص سياسة الخصوصية وشروط الاستخدام للعرض داخل التطبيق (متطلبات متاجر التطبيقات).
/// يُنصح بمراجعة قانونية وتحديث بيانات الاتصال والكيان المشغّل.
class LegalDocuments {
  LegalDocuments._();

  static String _lang(String? code) {
    switch (code) {
      case 'ar':
        return 'ar';
      case 'de':
        return 'de';
      default:
        return 'en';
    }
  }

  static String privacyPolicy([String? languageCode]) {
    switch (_lang(languageCode)) {
      case 'ar':
        return _privacyAr;
      case 'de':
        return _privacyDe;
      default:
        return _privacyEn;
    }
  }

  static String termsOfService([String? languageCode]) {
    switch (_lang(languageCode)) {
      case 'ar':
        return _termsAr;
      case 'de':
        return _termsDe;
      default:
        return _termsEn;
    }
  }

  static const String _privacyEn = '''
Privacy Policy — archiarena

Last updated: April 2026

1. Introduction
archiarena ("we", "us", "the App") provides a mobile platform for architectural and design-related content, projects, social features, messaging, and related services. This Privacy Policy explains how we collect, use, store, and protect personal information when you use our application.

2. Data we collect
• Account data: name, email address, phone number (if provided), profile photo, professional information you choose to add, and account credentials.
• Content you submit: posts, images, files (e.g. PDF plans), comments, messages, proposals, and other materials you upload or send through the App.
• Usage and device data: app interactions, approximate diagnostics, device type, operating system, language preference, and similar technical data needed to operate and secure the service.
• Communications: content of in-app messages and support requests you send to us.

3. How we use your data
We use personal data to: create and manage your account; provide, maintain, and improve the App; personalize your experience; enable messaging and social features; send service-related notifications (including push notifications if you allow them); detect abuse, fraud, and security issues; and comply with legal obligations.

4. Legal bases (where applicable)
Depending on your region, we rely on performance of a contract, legitimate interests (e.g. security and service improvement), consent (where required, e.g. certain notifications), and legal obligation.

5. Sharing of information
We do not sell your personal data. We may share data with: service providers who assist us (e.g. hosting, cloud infrastructure, analytics, push notification providers) under strict terms; authorities when required by law or to protect rights and safety; and other users only as you choose through public profile content, posts, or messaging features.

6. Retention
We retain information as long as your account is active or as needed to provide the service, comply with law, resolve disputes, and enforce our agreements. You may request deletion of your account subject to applicable law.

7. Security
We implement appropriate technical and organizational measures to protect personal data. No method of transmission over the internet is 100% secure.

8. Your rights
Depending on applicable law, you may have rights to access, correct, delete, restrict processing, object, or port your data, and to withdraw consent where processing is consent-based. Contact us using the details below to exercise these rights.

9. Children
The App is not directed at children under 13 (or the minimum age required in your jurisdiction). We do not knowingly collect personal data from children. If you believe we have, please contact us to remove it.

10. International transfers
If we transfer data across borders, we do so with appropriate safeguards as required by law.

11. Changes
We may update this Privacy Policy. We will notify you of material changes through the App or other reasonable means. Continued use after changes constitutes acceptance where permitted by law.

12. Contact
For privacy questions or requests: use the in-app support or feedback options, or contact us at the email address published in the App Store / Google Play listing (update this address in your store metadata and here to match your legal entity).
''';

  static const String _termsEn = '''
Terms of Service — archiarena

Last updated: April 2026

1. Agreement
By creating an account or using archiarena ("the Service"), you agree to these Terms of Service and our Privacy Policy. If you do not agree, do not use the Service.

2. Eligibility
You must be legally able to enter a binding contract in your jurisdiction and meet any minimum age required by Apple, Google, and local law (typically at least 13, or higher where required).

3. Description of the Service
archiarena offers features such as feeds, profiles, posts, project-related content, plans and attachments, comments, chat, notifications, and related functionality. Features may change over time.

4. Your account
You are responsible for accurate registration information and for safeguarding your credentials. You are responsible for activity under your account. Notify us promptly of unauthorized use.

5. User content
You retain ownership of content you upload. You grant us a worldwide, non-exclusive, royalty-free license to host, store, reproduce, display, and distribute your content solely to operate, promote, and improve the Service as intended by the App’s features. You represent that you have the rights to grant this license. We may remove content that violates law or these Terms.

6. Acceptable use
You agree not to: violate laws; infringe intellectual property or privacy of others; harass, threaten, or harm users; distribute malware; scrape or overload the Service; impersonate others; or use the Service for unauthorized commercial solicitation outside what the App permits.

7. Intellectual property
The App, branding, and software are protected by intellectual property laws. Except for your content, you may not copy or exploit our materials without permission.

8. Third-party services
The Service may integrate third-party services (e.g. push notifications). Their terms and privacy policies also apply where relevant.

9. Disclaimers
The Service is provided "as is" and "as available" without warranties of any kind to the fullest extent permitted by law. We do not guarantee uninterrupted or error-free operation.

10. Limitation of liability
To the maximum extent permitted by law, we are not liable for indirect, incidental, special, consequential, or punitive damages, or for loss of profits, data, or goodwill. Our total liability for claims relating to the Service is limited to the greater of amounts you paid us in the past twelve months for the Service or zero if the Service is free.

11. Indemnification
You agree to indemnify and hold us harmless from claims arising from your content or misuse of the Service, subject to applicable law.

12. Suspension and termination
We may suspend or terminate access for violations of these Terms or legal requirements. You may stop using the Service and request account deletion where available.

13. Governing law
These Terms are governed by the laws applicable to the operating entity named in the store listing, without regard to conflict-of-law rules, unless mandatory consumer protections in your country say otherwise.

14. Changes
We may modify these Terms. Material changes will be communicated through the App or other reasonable means. Continued use may constitute acceptance where permitted.

15. Contact
For questions about these Terms, use in-app support or the contact method provided in the App Store / Google Play listing.
''';

  static const String _privacyAr = '''
سياسة الخصوصية — أركي أرينا

آخر تحديث: أبريل 2026

1. المقدمة
يقدّم تطبيق أركي أرينا ("نحن"، "التطبيق") منصة للمحتوى المعماري والتصميم والمشاريع والمراسلة والميزات الاجتماعية. توضّح هذه السياسة كيفية جمع واستخدام وحماية المعلومات الشخصية عند استخدامك للتطبيق.

2. البيانات التي نجمعها
• بيانات الحساب: الاسم، البريد الإلكتروني، رقم الهاتف (إن وُجد)، صورة الملف الشخصي، المعلومات المهنية التي تضيفها، وبيانات تسجيل الدخول.
• المحتوى الذي تقدمه: المنشورات، الصور، الملفات (مثل مخططات PDF)، التعليقات، الرسائل، العروض، وغيرها.
• بيانات الاستخدام والجهاز: تفاعلات مع التطبيق، نوع الجهاز، نظام التشغيل، تفضيل اللغة، وبيانات فنية لأغراض التشغيل والأمان.
• المراسلات: محتوى المحادثات داخل التطبيق وطلبات الدعم.

3. كيف نستخدم البيانات
نستخدم البيانات لإنشاء حسابك وتشغيل التطبيق وتحسينه، وتخصيص التجربة، وتمكين المراسلة والميزات الاجتماعية، وإرسال إشعارات متعلقة بالخدمة (بما فيها الإشعارات الفورية إذا سمحت)، واكتشاف الإساءة والاحتيال، والامتثال للقوانين.

4. مشاركة المعلومات
لا نبيع بياناتك الشخصية. قد نشارك البيانات مع مزوّدي خدمات (استضافة، بنية سحابية، إشعارات) بضوابط تعاقدية، ومع الجهات عند الوجوب القانوني، ومع المستخدمين الآخرين ضمن ما تختار عرضه علناً أو عبر المراسلة.

5. الاحتفاظ والأمان
نحتفظ بالبيانات ما دام الحساب نشطاً أو حسب الحاجة للخدمة والقانون. نطبّق إجراءات تقنية وتنظيمية مناسبة؛ لا يوجد أمان مطلق على الإنترنت.

6. حقوقك
قد يحق لك حسب القانون المعمول: الوصول، التصحيح، الحذف، تقييد المعالجة، الاعتراض، أو نقل البيانات. تواصل معنا عبر قنوات الدعم في التطبيق.

7. الأطفال
التطبيق غير موجّه لمن دون 13 عاماً (أو الحد الأدنى في بلدك). إذا ظننت أننا جمعنا بيانات طفل، راسلنا لحذفها.

8. التحديثات
قد نحدّث هذه السياسة. سنُعلمك بالتغييرات الجوهرية عبر التطبيق أو وسائل مناسبة.

9. الاتصال
للاستفسارات المتعلقة بالخصوصية: استخدم الدعم أو الملاحظات داخل التطبيق، أو البريد المذكور في صفحة التطبيق على متجر آبل أو جوجل (حدّث العنوان ليتوافق مع كيانك القانوني).
''';

  static const String _termsAr = '''
شروط الاستخدام — أركي أرينا

آخر تحديث: أبريل 2026

1. القبول
بإنشاء حساب أو استخدام أركي أرينا ("الخدمة") فإنك توافق على شروط الاستخدام هذه وسياسة الخصوصية. إذا لا توافق، لا تستخدم الخدمة.

2. الأهلية
يجب أن تكون قادراً قانونياً على إبرام عقد وأن تبلغ الحد الأدنى للسن وفقاً لمتاجر آبل وجوجل والقانون المحلي.

3. وصف الخدمة
يوفّر التطبيق خلاصة منشورات، ملفات شخصية، مشاريع، مرفقات ومخططات، تعليقات، محادثات، إشعارات، وقد تتغيّر الميزات مع الوقت.

4. الحساب
أنت مسؤول عن صحة بيانات التسجيل وحماية كلمة المرور وعن النشاط على حسابك. أبلغنا فوراً عن أي استخدام غير مصرح.

5. المحتوى
تحتفظ بملكية ما ترفعه، وتمنحنا ترخيصاً عالمياً غير حصري لاستضافة وعرض وتوزيع محتواك لتشغيل الخدمة فقط. لا ترفع محتوى تنتهك حقوق الغير أو القانون.

6. الاستخدام المقبول
يُمنع انتهاك القوانين، مضايقة المستخدمين، نشر برمجيات ضارة، انتحال الهوية، أو إساءة استخدام الخدمة.

7. الملكية الفكرية
العلامات والبرمجيات محمية. لا تنسخ أو تستغل موادنا دون إذن بخلاف ما تسمح به الخدمة.

8. إخلاء المسؤولية
الخدمة تُقدَّم "كما هي" دون ضمانات صريحة قدر ما يسمح القانون.

9. حدود المسؤولية
إلى أقصى حد يسمح به القانون، لا نتحمل أضراراً غير مباشرة أو خسارة أرباح أو بيانات. قد يقتصر إجمالي مسؤوليتنا على المبالغ التي دفعتها لنا خلال اثني عشر شهراً أو صفراً إن كانت الخدمة مجانية.

10. الإنهاء
قد نعلق أو ننهي الحساب عند مخالفة الشروط أو القانون. يمكنك التوقف عن الاستخدام وطلب حذف الحساب حيث يتوفر.

11. القانون الحاكم
تخضع الشروط للقوانين المعمول بها على الكيان المشغّل كما يظهر في المتجر، مع مراعاة حقوق المستهلك الإلزامية في بلدك.

12. التواصل
للأسئلة استخدم الدعم داخل التطبيق أو بيانات الاتصال في صفحة المتجر.
''';

  static const String _privacyDe = '''
Datenschutzerklärung — archiarena

Stand: April 2026

1. Einleitung
archiarena („wir“, „die App“) ist eine mobile Plattform für architektonische Inhalte, Projekte, soziale Funktionen, Nachrichten und verwandte Dienste. Diese Erklärung beschreibt, wie wir personenbezogene Daten erheben, nutzen und schützen.

2. Erhobene Daten
• Kontodaten: Name, E-Mail, Telefonnummer (falls angegeben), Profilbild, von Ihnen ergänzte berufliche Angaben, Anmeldedaten.
• Von Ihnen eingestellte Inhalte: Beiträge, Bilder, Dateien (z. B. PDF-Pläne), Kommentare, Nachrichten, Angebote.
• Nutzungs- und Gerätedaten: App-Nutzung, Gerätetyp, Betriebssystem, Sprache, technische Daten für Betrieb und Sicherheit.
• Kommunikation: Inhalte von In-App-Nachrichten und Support-Anfragen.

3. Zweck der Verarbeitung
Wir verarbeiten Daten zur Bereitstellung und Verbesserung der App, Personalisierung, Nachrichtenfunktionen, Sicherheit, Missbrauchsbekämpfung, Erfüllung gesetzlicher Pflichten und – sofern Sie zustimmen – für Push-Benachrichtigungen.

4. Weitergabe
Wir verkaufen keine personenbezogenen Daten. Eine Weitergabe erfolgt an Auftragsverarbeiter (Hosting, Cloud, Analyse, Push-Dienste) vertraglich gebunden, an Behörden bei gesetzlicher Pflicht sowie an andere Nutzer nur, soweit Sie Inhalte öffentlich stellen oder Nachrichten senden.

5. Speicherung und Sicherheit
Wir speichern Daten, solange Ihr Konto besteht oder es zur Diensterbringung und Rechtskonformität erforderlich ist. Wir setzen angemessene technische und organisatorische Maßnahmen ein; eine absolute Sicherheit gibt es nicht.

6. Ihre Rechte
Je nach anwendbarem Recht haben Sie Rechte auf Auskunft, Berichtigung, Löschung, Einschränkung, Widerspruch und Datenübertragbarkeit. Kontaktieren Sie uns über die In-App-Supportfunktion.

7. Kinder
Die App richtet sich nicht an Kinder unter 13 Jahren (oder dem jeweiligen Mindestalter). Wenn Sie der Annahme sind, dass wir Daten eines Kindes erfasst haben, kontaktieren Sie uns.

8. Änderungen
Wir können diese Datenschutzerklärung aktualisieren. Wesentliche Änderungen teilen wir über die App oder andere angemessene Wege mit.

9. Kontakt
Für Datenschutzanfragen nutzen Sie den In-App-Support oder die in Google Play / App Store angegebene E-Mail-Adresse (bitte mit Ihrem rechtlichen Unternehmen abstimmen).
''';

  static const String _termsDe = '''
Nutzungsbedingungen — archiarena

Stand: April 2026

1. Vertragsschluss
Mit Kontoerstellung oder Nutzung von archiarena („Dienst“) akzeptieren Sie diese Bedingungen und unsere Datenschutzerklärung. Wenn Sie nicht einverstanden sind, nutzen Sie den Dienst nicht.

2. Teilnahmeberechtigung
Sie müssen geschäftsfähig sein und das von Apple, Google und lokalem Recht geforderte Mindestalter erreicht haben.

3. Leistungsbeschreibung
archiarena bietet u. a. Feeds, Profile, Beiträge, Projektinhalte, Pläne und Anhänge, Kommentare, Chat und Benachrichtigungen. Funktionen können sich ändern.

4. Konto
Sie sind für richtige Angaben und die Geheimhaltung Ihrer Zugangsdaten verantwortlich und für Aktivitäten unter Ihrem Konto. Melden Sie Missbrauch unverzüglich.

5. Nutzerinhalte
Sie behalten die Rechte an Ihren Inhalten und gewähren uns eine weltweite, nicht ausschließliche Lizenz zur Speicherung und Anzeige, soweit zur Bereitstellung des Dienstes erforderlich. Sie versichern, dass Sie dazu berechtigt sind.

6. Erlaubte Nutzung
Verboten sind u. a. Gesetzesverstöße, Rechtsverletzungen, Belästigung, Schadsoftware, Identitätsmissbrauch und missbräuchliche Automatisierung.

7. Urheberrechte
App, Marken und Software sind geschützt. Eine Vervielfältigung ohne Erlaubnis ist untersagt.

8. Haftungsausschluss
Der Dienst wird „wie besehen“ bereitgestellt; gesetzliche Gewährleistungsrechte bleiben unberührt, soweit zwingend.

9. Haftungsbeschränkung
Soweit gesetzlich zulässig, haften wir nicht für indirekte Schäden oder entgangenen Gewinn. Die Gesamthaftung ist auf die in den letzten 12 Monaten gezahlten Beträge begrenzt bzw. null bei kostenlosem Dienst.

10. Kündigung
Wir können Zugänge bei Verstößen sperren oder beenden. Sie können die Nutzung beenden und ggf. Löschung des Kontos beantragen.

11. Anwendbares Recht
Es gilt das Recht des in den Stores genannten Betreibers, vorbehaltlich zwingenden Verbraucherschutzrechts in Ihrem Land.

12. Änderungen
Wir können die Bedingungen ändern und werden über wesentliche Änderungen informieren.

13. Kontakt
Fragen über In-App-Support oder die im Store angegebene Kontaktadresse.
''';
}
