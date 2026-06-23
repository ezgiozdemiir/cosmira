enum LegalDocType { terms, privacy }

class LegalSection {
  final String title;
  final String body;
  const LegalSection({required this.title, required this.body});
}

abstract final class LegalDocuments {
  static List<LegalSection> get(LegalDocType type, String languageCode) {
    final isTr = languageCode == 'tr';
    return switch (type) {
      LegalDocType.terms => isTr ? _trTerms : _enTerms,
      LegalDocType.privacy => isTr ? _trPrivacy : _enPrivacy,
    };
  }

  static String docTitle(LegalDocType type, String languageCode) {
    final isTr = languageCode == 'tr';
    return switch (type) {
      LegalDocType.terms => isTr ? 'Kullanım Koşulları' : 'Terms of Service',
      LegalDocType.privacy => isTr ? 'Gizlilik Politikası' : 'Privacy Policy',
    };
  }

  static String effectiveDate(String languageCode) => languageCode == 'tr'
      ? 'Yürürlük tarihi: 23 Haziran 2026'
      : 'Effective date: June 23, 2026';

  // ─── English Terms of Service ─────────────────────────────────────────────
  static const List<LegalSection> _enTerms = [
    LegalSection(
      title: '1. Acceptance of Terms',
      body:
          'By accessing or using the Cosmira application and related services ("Services"), you agree to be bound by these Terms of Service ("Terms"). If you do not agree, please discontinue use immediately. These Terms constitute a legally binding agreement between you ("User") and Cosmira ("Company", "we", "us").',
    ),
    LegalSection(
      title: '2. Description of Services',
      body:
          'Cosmira is an AI-powered spiritual lifestyle platform providing personalised astrological readings, natal chart analysis, compatibility assessments, breathwork guidance, moon phase tracking, and numerology insights. All content is provided for entertainment and personal enrichment purposes only. Nothing within the Services constitutes professional psychological, medical, financial, or legal advice. Users should exercise their own judgement when making decisions based on astrological or numerological content.',
    ),
    LegalSection(
      title: '3. Eligibility',
      body:
          'You must be at least 18 years of age to use our Services. If you are between 16 and 18 years old, you may use the Services only with the explicit consent of a parent or legal guardian, as required under applicable law including the EU General Data Protection Regulation (GDPR). Our Services are not intended for individuals under the age of 13. By using the Services, you represent and warrant that you meet the applicable eligibility requirements.',
    ),
    LegalSection(
      title: '4. Account Registration',
      body:
          'Certain features require account creation via Google Sign-In or Sign in with Apple. You are solely responsible for maintaining the confidentiality of your account credentials and for all activities occurring under your account. You agree to provide accurate, current, and complete information and to update it promptly when it changes. You must notify us immediately at legal@cosmira.app of any unauthorised use of your account or any other security breach.',
    ),
    LegalSection(
      title: '5. Subscription Plans and Payments',
      body:
          'Cosmira offers free and premium subscription tiers. Premium subscriptions are billed on a recurring monthly or annual basis through the App Store (Apple Inc.) or Google Play (Google LLC). Subscription fees are charged at the beginning of each billing period. You may cancel your subscription at any time; cancellation takes effect at the end of the current billing period and no partial refunds are issued unless required by applicable mandatory law. We reserve the right to modify subscription pricing with at least 30 days\' prior notice. Refunds are governed by the refund policy of the applicable app store platform. These Services are offered in compliance with applicable consumer protection legislation.',
    ),
    LegalSection(
      title: '6. User Conduct and Prohibited Uses',
      body:
          'You agree not to:\n\n(a) Use the Services for any unlawful purpose or in violation of any local, national, or international law or regulation.\n(b) Reproduce, distribute, modify, translate, or create derivative works from any part of the Services without our prior written consent.\n(c) Reverse-engineer, decompile, disassemble, or attempt to derive the source code of any software component of the Services.\n(d) Transmit any content that is harmful, offensive, defamatory, obscene, or infringes any third-party intellectual property or privacy rights.\n(e) Interfere with or disrupt the integrity, security, or performance of the Services or any connected systems.\n(f) Attempt to gain unauthorised access to any system, network, server, or account connected to the Services.\n(g) Use automated scripts, bots, crawlers, or other means to access or scrape the Services without prior written permission.',
    ),
    LegalSection(
      title: '7. Intellectual Property Rights',
      body:
          'All content, trademarks, trade names, logos, graphics, user interface designs, and software comprising the Services are the exclusive property of Cosmira or its licensors and are protected under applicable Turkish and international intellectual property laws, including the Turkish Law on Intellectual and Artistic Works (Law No. 5846), the Turkish Industrial Property Law (Law No. 6769), and applicable EU intellectual property regulations. You are granted a limited, non-exclusive, non-transferable, revocable licence to access and use the Services for personal, non-commercial purposes only. No other licence or right is granted, express or implied.',
    ),
    LegalSection(
      title: '8. User-Provided Data',
      body:
          'You retain ownership of any personal information you submit, including birth data and personal preferences. By providing such information, you grant Cosmira a worldwide, royalty-free, non-exclusive licence to process and use that information solely to operate and improve the Services as described in our Privacy Policy. You represent that you have the right to submit such information and that doing so does not violate any third-party rights or applicable law.',
    ),
    LegalSection(
      title: '9. Third-Party Services',
      body:
          'The Services integrate with third-party providers including:\n\n• Google LLC — Firebase Authentication, Firebase Analytics, Firebase Crashlytics, Firebase Cloud Messaging\n• Apple Inc. — Sign in with Apple authentication\n• Supabase Inc. — cloud database infrastructure and authentication\n\nYour use of these third-party services is subject to their respective terms and privacy policies. We are not responsible for the data practices or conduct of third-party services. Links or integrations with third-party services do not imply endorsement by Cosmira.',
    ),
    LegalSection(
      title: '10. Disclaimer of Warranties',
      body:
          'THE SERVICES ARE PROVIDED "AS IS" AND "AS AVAILABLE" WITHOUT WARRANTIES OF ANY KIND, WHETHER EXPRESS, IMPLIED, STATUTORY, OR OTHERWISE, INCLUDING BUT NOT LIMITED TO IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, AND NON-INFRINGEMENT. WE DO NOT WARRANT THAT THE SERVICES WILL BE UNINTERRUPTED, TIMELY, SECURE, ERROR-FREE, OR FREE FROM VIRUSES OR OTHER HARMFUL COMPONENTS. ASTROLOGICAL AND NUMEROLOGICAL CONTENT IS PROVIDED FOR ENTERTAINMENT PURPOSES ONLY AND WE MAKE NO REPRESENTATIONS AS TO ITS ACCURACY OR SUITABILITY FOR ANY PURPOSE.',
    ),
    LegalSection(
      title: '11. Limitation of Liability',
      body:
          'TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, COSMIRA AND ITS AFFILIATES, OFFICERS, DIRECTORS, EMPLOYEES, AGENTS, AND LICENSORS SHALL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, EXEMPLARY, OR PUNITIVE DAMAGES ARISING FROM YOUR USE OF OR INABILITY TO USE THE SERVICES, INCLUDING LOSS OF PROFITS, DATA, GOODWILL, OR OTHER INTANGIBLE LOSSES, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.\n\nWHERE LIABILITY CANNOT BE FULLY EXCLUDED BY MANDATORY LAW (INCLUDING MANDATORY CONSUMER PROTECTION PROVISIONS APPLICABLE IN YOUR COUNTRY OF RESIDENCE), OUR TOTAL AGGREGATE LIABILITY SHALL NOT EXCEED THE GREATER OF (A) THE TOTAL FEES PAID BY YOU IN THE 12 MONTHS PRECEDING THE CLAIM OR (B) €100 (OR EQUIVALENT LOCAL CURRENCY).',
    ),
    LegalSection(
      title: '12. Indemnification',
      body:
          'You agree to indemnify, defend, and hold harmless Cosmira and its affiliates, officers, directors, employees, and agents from and against any claims, liabilities, damages, judgements, losses, costs, and expenses (including reasonable legal fees) arising out of or relating to: (a) your access to or use of the Services; (b) your violation of these Terms; (c) your infringement of any intellectual property, privacy, or other rights of any third party; or (d) any content you submit through the Services.',
    ),
    LegalSection(
      title: '13. Governing Law and Jurisdiction',
      body:
          'These Terms are governed by and construed in accordance with the laws of the Republic of Turkey, including the Turkish Code of Obligations (Law No. 6098), the Turkish Commercial Code (Law No. 6102), and the Consumer Protection Law (Law No. 6502), without regard to conflict of law principles.\n\nFor users residing in the European Economic Area (EEA) or the United Kingdom, the mandatory consumer protection provisions of your country of residence apply in addition to Turkish law where they provide greater protection.\n\nAny dispute, controversy, or claim arising out of or relating to these Terms shall be subject to the exclusive jurisdiction of the courts and enforcement offices of Istanbul (Çağlayan), Turkey. EEA and UK consumers also retain the right to bring proceedings before the competent courts of their country of residence.',
    ),
    LegalSection(
      title: '14. Changes to Terms',
      body:
          'We reserve the right to modify these Terms at any time. If we make material changes, we will provide at least 14 days\' prior notice through in-app notification or email before the changes take effect. Your continued use of the Services after the effective date of the revised Terms constitutes your acceptance of the changes. If you do not agree to the modified Terms, you must stop using the Services.',
    ),
    LegalSection(
      title: '15. Contact',
      body: 'For questions or concerns regarding these Terms of Service:\n\nEmail: legal@cosmira.app',
    ),
  ];

  // ─── English Privacy Policy ───────────────────────────────────────────────
  static const List<LegalSection> _enPrivacy = [
    LegalSection(
      title: '1. Data Controller and Scope',
      body:
          'Cosmira ("we", "us", "our") acts as the data controller for personal data processed through our Services. This Privacy Policy applies to all users of the Cosmira mobile and web application and is compliant with:\n\n• EU General Data Protection Regulation (GDPR — Regulation 2016/679/EU)\n• UK GDPR and the UK Data Protection Act 2018\n• Turkish Law on Protection of Personal Data (KVKK — Law No. 6698)\n\nFor all data protection enquiries, please contact us at: privacy@cosmira.app',
    ),
    LegalSection(
      title: '2. Personal Data We Collect',
      body:
          'We collect and process the following categories of personal data:\n\n• Identity Data: name, email address, profile photo (obtained via OAuth provider)\n• Astrological Data: birth date, birth time, birth city, geographic coordinates\n• Usage Data: app interactions, features used, session duration, in-app actions\n• Technical Data: device type, operating system version, IP address, browser type and version\n• Preference Data: notification settings, language preference, subscription tier\n• Payment Status: subscription tier and status (payment processing is handled exclusively by the App Store or Google Play; we do not store payment card details)\n\nWe collect data directly from you (when you register or use the Services) and automatically (through analytics and crash-reporting tools).',
    ),
    LegalSection(
      title: '3. Legal Basis for Processing (GDPR Article 6)',
      body:
          'We process your personal data under the following lawful bases:\n\n• Performance of contract (Art. 6(1)(b)): to create and manage your account and deliver the Services you have requested\n• Legitimate interests (Art. 6(1)(f)): to improve our Services, ensure platform security, and prevent fraud — where those interests are not overridden by your rights and freedoms\n• Consent (Art. 6(1)(a)): for marketing communications and analytics cookies — you may withdraw consent at any time without affecting prior processing\n• Legal obligation (Art. 6(1)(c)): to comply with applicable laws and regulations\n\nBirth date and time are processed on the basis of your explicit consent (Art. 9(2)(a)) for the purpose of generating astrological readings. You may withdraw this consent at any time by deleting your birth data from your profile.',
    ),
    LegalSection(
      title: '4. How We Use Your Data',
      body:
          'We use your personal data to:\n\n• Create, authenticate, and manage your account\n• Generate personalised astrological readings, natal chart calculations, compatibility assessments, and AI-powered spiritual content\n• Process and manage your subscription status via app store providers\n• Send push notifications and in-app alerts (where you have consented)\n• Improve and develop our Services through aggregated, anonymised analytics\n• Ensure the security, integrity, and availability of our platform\n• Detect, prevent, and investigate fraud, abuse, and security incidents\n• Resolve disputes, enforce our agreements, and comply with legal obligations\n• Communicate material changes to our policies',
    ),
    LegalSection(
      title: '5. Data Sharing and Third Parties',
      body:
          'We share personal data only where necessary with the following recipients:\n\n• Supabase Inc. (USA) — cloud infrastructure, PostgreSQL database hosting, and authentication services. Data is processed in EU and US data centres under GDPR-compliant Data Processing Agreements (DPAs).\n• Google LLC (USA) — Firebase Authentication, Firebase Analytics, Firebase Crashlytics, Firebase Cloud Messaging: for authentication, usage analytics, crash reporting, and push notifications.\n• Apple Inc. (USA) — Sign in with Apple authentication.\n\nWe do not sell, rent, or trade your personal data to any third party for marketing or commercial purposes. We may disclose personal data to law enforcement, regulatory authorities, or courts where required by applicable law or to protect the rights, property, or safety of Cosmira, our users, or others.',
    ),
    LegalSection(
      title: '6. Data Retention',
      body:
          'We retain personal data for as long as your account is active or as necessary to provide the Services:\n\n• Account and profile data: retained until account deletion, then deleted within 30 days\n• Usage and analytics data: anonymised and retained for up to 24 months\n• Crash reports: retained for up to 12 months\n• Financial and transaction records: retained for 10 years where required by Turkish tax law (Vergi Usul Kanunu) or applicable EU law\n\nUpon account deletion, we will delete or irreversibly anonymise your personal data within 30 days, unless a longer retention period is required or permitted by law.',
    ),
    LegalSection(
      title: '7. Your Rights',
      body:
          'Depending on your jurisdiction, you have the following rights regarding your personal data:\n\n• Right of access (Art. 15): obtain confirmation of whether we process your data and receive a copy\n• Right to rectification (Art. 16): correct inaccurate or incomplete data\n• Right to erasure (Art. 17): request deletion under certain conditions ("right to be forgotten")\n• Right to restriction (Art. 18): restrict processing in specific circumstances\n• Right to data portability (Art. 20): receive your data in a structured, machine-readable format\n• Right to object (Art. 21): object to processing based on legitimate interests or for direct marketing\n• Rights related to automated decision-making (Art. 22): not be subject to solely automated decisions that significantly affect you\n\nTo exercise your rights, contact privacy@cosmira.app. We will respond within 30 days (extendable by a further 2 months for complex or numerous requests, with prior notification). Requests are free of charge unless manifestly unfounded or excessive. You also have the right to lodge a complaint with your local data protection supervisory authority.',
    ),
    LegalSection(
      title: '8. International Data Transfers',
      body:
          'Your personal data may be transferred to and processed in countries outside the European Economic Area (EEA), including the United States and Turkey. We ensure that such transfers are subject to appropriate safeguards as required under GDPR Article 46, including:\n\n• Standard Contractual Clauses (SCCs) adopted by the European Commission\n• Data Processing Agreements (DPAs) incorporating appropriate technical and organisational measures\n• Where applicable, adequacy decisions issued by the European Commission\n\nFor transfers to Turkey specifically, we ensure compliance with KVKK Article 9 requirements. You may request further information about the safeguards applicable to any specific transfer by contacting privacy@cosmira.app.',
    ),
    LegalSection(
      title: '9. Cookies and Tracking Technologies',
      body:
          'Our web application uses the following types of cookies and similar technologies:\n\n• Essential cookies: strictly necessary for authentication, session management, and the delivery of core functionality. These cannot be disabled without impairing the Services.\n• Analytics cookies: deployed only with your prior consent, used to understand usage patterns and improve the Services (e.g., Firebase Analytics).\n\nYou may manage or withdraw consent for non-essential cookies at any time through your browser settings or our in-app preference controls. Withdrawing consent for analytics cookies will not affect your access to or use of the Services.',
    ),
    LegalSection(
      title: '10. Data Security',
      body:
          'We implement appropriate technical and organisational security measures to protect your personal data against unauthorised access, loss, destruction, alteration, or disclosure, including:\n\n• Transport Layer Security (TLS 1.2 or higher) for all data in transit\n• Encryption of sensitive data at rest\n• Role-based access controls and least-privilege access principles\n• Regular security assessments and penetration testing\n• Incident response and breach notification procedures\n\nIn the event of a personal data breach, we will notify the relevant supervisory authority within 72 hours where required by law, and will inform affected users without undue delay where the breach is likely to result in a high risk to their rights and freedoms.',
    ),
    LegalSection(
      title: '11. Children\'s Privacy',
      body:
          'Our Services are not directed to individuals under 13 years of age (or under the higher age of digital consent applicable in your EEA member state, which may be up to 16 years). We do not knowingly collect personal data from children below these age thresholds without verifiable parental consent. If we discover that we have inadvertently collected such data, we will delete it promptly. Parents or guardians who believe their child has provided personal data to us should contact privacy@cosmira.app.',
    ),
    LegalSection(
      title: '12. Changes to This Privacy Policy',
      body:
          'We may update this Privacy Policy from time to time to reflect changes in our practices, technology, legal requirements, or other factors. We will communicate material changes via in-app notification or email at least 14 days before they take effect. The "Effective Date" at the top of this document indicates when it was last revised. Your continued use of the Services after the effective date constitutes your acceptance of the updated Policy.',
    ),
    LegalSection(
      title: '13. Contact and Supervisory Authorities',
      body:
          'For data protection enquiries or to exercise your rights:\n\nEmail: privacy@cosmira.app\n\nEU/EEA users: You have the right to lodge a complaint with your national Data Protection Authority. A directory of EU DPAs is available at: edpb.europa.eu\n\nUK users: Information Commissioner\'s Office (ICO)\nWeb: ico.org.uk  |  Tel: 0303 123 1113',
    ),
  ];

  // ─── Turkish Terms of Service ─────────────────────────────────────────────
  static const List<LegalSection> _trTerms = [
    LegalSection(
      title: '1. Koşulların Kabulü',
      body:
          'Cosmira mobil uygulaması ve ilgili hizmetlere ("Hizmetler") erişerek veya bunları kullanarak bu Kullanım Koşullarını ("Koşullar") kabul etmiş olursunuz. Bu Koşulları kabul etmiyorsanız lütfen Hizmetleri kullanmayınız. Bu Koşullar, siz ("Kullanıcı") ile Cosmira ("Şirket", "biz") arasında hukuken bağlayıcı bir sözleşme niteliğindedir.',
    ),
    LegalSection(
      title: '2. Hizmetlerin Tanımı',
      body:
          'Cosmira; kişiselleştirilmiş astroloji yorumları, doğum haritası analizi, uyumluluk değerlendirmeleri, nefes çalışması rehberliği, ay fazı takibi ve numeroloji içgörüleri sunan yapay zeka destekli bir ruhsal yaşam tarzı platformudur. Sunulan tüm içerikler yalnızca eğlence ve kişisel gelişim amaçlı olup profesyonel psikolojik, tıbbi, finansal veya hukuki tavsiye niteliği taşımaz. Kullanıcılar, astrolojik veya numerolojik içeriklere dayanarak verdikleri kararlarda kendi değerlendirmelerini esas almalıdır.',
    ),
    LegalSection(
      title: '3. Kullanım Ehliyeti',
      body:
          'Hizmetleri kullanmak için en az 18 yaşında olmanız gerekmektedir. 16 ila 18 yaş arasındaysanız, yalnızca ebeveyn veya yasal vasinin açık onayıyla Hizmetleri kullanabilirsiniz. Hizmetler 13 yaşın altındaki bireyler için tasarlanmamıştır. Hizmetleri kullanarak geçerli yaş koşullarını karşıladığınızı beyan ve taahhüt edersiniz.',
    ),
    LegalSection(
      title: '4. Hesap Oluşturma',
      body:
          'Belirli özelliklere erişmek için Google veya Apple kimlik doğrulamasıyla hesap oluşturmanız gerekmektedir. Hesap bilgilerinizin gizliliğini ve hesabınız altında gerçekleştirilen tüm faaliyetlerin güvenliğini korumaktan siz sorumlusunuz. Doğru, güncel ve eksiksiz bilgi sağlamayı ve gerektiğinde güncellemeyi kabul edersiniz. Yetkisiz hesap kullanımını derhal legal@cosmira.app adresine bildirmeniz gerekmektedir.',
    ),
    LegalSection(
      title: '5. Abonelik Planları ve Ödemeler',
      body:
          'Cosmira ücretsiz ve premium abonelik kademesi sunmaktadır. Premium abonelikler App Store (Apple Inc.) veya Google Play (Google LLC) aracılığıyla aylık ya da yıllık olarak otomatik yenilenir. Abonelik ücretleri her fatura döneminin başında tahsil edilir. Aboneliğinizi istediğiniz zaman iptal edebilirsiniz; iptal, mevcut fatura dönemi sonunda geçerlilik kazanır ve zorunlu yasal hükümler dışında kısmi iade yapılmaz. Fiyat değişiklikleri en az 30 gün önceden bildirilir. İadeler ilgili uygulama mağazasının politikasına tabidir. Bu Hizmetler, 6502 sayılı Tüketicinin Korunması Hakkında Kanun kapsamında sunulmaktadır.',
    ),
    LegalSection(
      title: '6. Kullanıcı Yükümlülükleri ve Yasak Kullanımlar',
      body:
          'Aşağıdakileri yapmamayı kabul edersiniz:\n\n(a) Hizmetleri herhangi bir yasadışı amaçla ya da yürürlükteki yerel, ulusal veya uluslararası mevzuatı ihlal edecek şekilde kullanmak.\n(b) Yazılı iznimiz olmaksızın içerikleri kopyalamak, dağıtmak, değiştirmek veya türev eserler oluşturmak.\n(c) Hizmetlerin herhangi bir yazılım bileşenini tersine mühendislikle çözümlemeye, kaynak kodunu elde etmeye çalışmak.\n(d) Zararlı, rahatsız edici, karalayıcı, müstehcen veya üçüncü taraf haklarını ihlal eden içerik iletmek.\n(e) Hizmetlerin bütünlüğüne, güvenliğine veya performansına müdahale etmek.\n(f) Hizmetlere bağlı herhangi bir sisteme, sunucuya veya hesaba yetkisiz erişim girişiminde bulunmak.\n(g) Önceden yazılı izin almaksızın Hizmetlere otomatik araçlarla erişmek.',
    ),
    LegalSection(
      title: '7. Fikri Mülkiyet Hakları',
      body:
          'Hizmetleri oluşturan tüm içerik, marka, ticaret unvanı, logo, grafik, kullanıcı arayüzü tasarımı ve yazılımlar, Cosmira\'ya veya lisans verenlerine aittir ve 5846 sayılı Fikir ve Sanat Eserleri Kanunu, 6769 sayılı Sınai Mülkiyet Kanunu ile uluslararası fikri mülkiyet mevzuatı kapsamında korunmaktadır. Yalnızca kişisel ve ticari olmayan amaçlarla Hizmetlere erişmek için sınırlı, münhasır olmayan, devredilemez ve geri alınabilir bir lisans verilmektedir. Başka hiçbir hak veya lisans, açık ya da zımni olarak verilmemektedir.',
    ),
    LegalSection(
      title: '8. Kullanıcı Sağlanan Veriler',
      body:
          'Doğum bilgileri ve kişisel tercihler dahil olmak üzere sunduğunuz verilerin mülkiyeti size aittir. Bu bilgileri sağlayarak, söz konusu bilgileri yalnızca Hizmetlerin işletilmesi ve geliştirilmesi amacıyla kullanmak üzere Cosmira\'ya dünya genelinde geçerli, telifsiz ve münhasır olmayan bir lisans vermiş olursunuz. Bu bilgileri sunma hakkına sahip olduğunuzu ve bunun herhangi bir üçüncü taraf hakkını ihlal etmediğini beyan edersiniz.',
    ),
    LegalSection(
      title: '9. Üçüncü Taraf Hizmetleri',
      body:
          'Hizmetler aşağıdaki üçüncü taraf sağlayıcılarla entegre çalışmaktadır:\n\n• Google LLC — Firebase Authentication, Firebase Analytics, Firebase Crashlytics, Firebase Cloud Messaging\n• Apple Inc. — Sign in with Apple kimlik doğrulama\n• Supabase Inc. — Bulut veritabanı altyapısı ve kimlik doğrulama\n\nBu üçüncü taraf hizmetlerin kullanımı, ilgili tarafların kendi koşullarına tabidir. Söz konusu üçüncü tarafların veri uygulamalarından ve davranışlarından sorumluluğumuz bulunmamaktadır.',
    ),
    LegalSection(
      title: '10. Sorumluluk Reddi',
      body:
          'HİZMETLER, HERHANGİ BİR TÜRDE AÇIK VEYA ZIMNİ GARANTİ VERİLMEKSİZİN "OLDUĞU GİBİ" VE "MEVCUT HÂLDE" SUNULMAKTADIR. HİZMETLERİN KESİNTİSİZ, ZAMANINDA, GÜVENLİ VEYA HATASIZ OLACAĞINI YA DA VİRÜS VE DİĞER ZARARLI BİLEŞENLERDEN ARINDIRILMIŞ BULUNACAĞINI GARANTİ ETMİYORUZ. ASTROLOJİK VE NÜMEROLOJİK İÇERİKLER YALNIZCA EĞLENCE AMAÇLI OLUP DOĞRULUK YA DA BELİRLİ BİR AMACA UYGUNLUK KONUSUNDA HERHANGİ BİR TAAHHÜTTE BULUNULMAMAKTADIR.',
    ),
    LegalSection(
      title: '11. Sorumluluğun Sınırlandırılması',
      body:
          'YÜRÜRLÜKTE OLAN HUKUK KAPSAMINDA İZİN VERİLEN AZAMİ ÖLÇÜDE, COSMİRA VE İŞTİRAKLERİ, YÖNETİCİLERİ, ÇALIŞANLARI, TEMSİLCİLERİ VE LİSANS VERENLERİ; HİZMETLERİN KULLANIMI VEYA KULLANILAMAMASI SONUCUNDA ORTAYA ÇIKABİLECEK DOLAYLI, ARIZİ, ÖZEL, SONUÇSAL VEYA CEZAİ ZARARLARDAN SORUMLU TUTULAMAZ.\n\nSORUMLULUĞUN TAMAMEN SINIRLANDIRILMASININ ZORUNLU YASAL HÜKÜMLER GEREĞİ MÜMKÜN OLMADIĞI DURUMLARDA (ZORUNLU TÜKETİCİ KORUMA HÜKÜMLERİ DAHİL), TOPLAM SORUMLULUĞUMUZ, TALEBİN OLUŞTUĞU TARİHTEN ÖNCEKİ 12 AYLIK DÖNEMDE ÖDEDİĞİNİZ ÜCRETLE SINIRLI KALACAKTIR.',
    ),
    LegalSection(
      title: '12. Tazminat',
      body:
          'Hizmetleri kullanımınızdan, bu Koşulları ihlal etmenizden veya herhangi bir üçüncü tarafın fikri mülkiyet, gizlilik ya da diğer haklarını çiğnemenizden kaynaklanan tüm talep, yükümlülük, zarar, karar, kayıp, maliyet ve harcamalar (makul avukatlık ücretleri dahil) nedeniyle Cosmira\'yı, iştiraklerini, yöneticilerini, çalışanlarını ve temsilcilerini zararsız kılmayı ve savunmayı kabul edersiniz.',
    ),
    LegalSection(
      title: '13. Uygulanacak Hukuk ve Yetki',
      body:
          'Bu Koşullar; 6098 sayılı Türk Borçlar Kanunu, 6102 sayılı Türk Ticaret Kanunu ve 6502 sayılı Tüketicinin Korunması Hakkında Kanun dahil olmak üzere Türkiye Cumhuriyeti hukuku ile yönetilmekte ve bu hukuka göre yorumlanmaktadır.\n\nAvrupa Ekonomik Alanı (AEA) veya Birleşik Krallık\'ta ikamet eden kullanıcılar için, ikamet edilen ülkenin zorunlu tüketici koruma hükümleri daha fazla koruma sağladığı ölçüde bu Koşullara ek olarak uygulanır.\n\nBu Koşullardan veya Hizmetlerin kullanımından doğacak uyuşmazlıklar İstanbul (Çağlayan) mahkeme ve icra dairelerinin münhasır yargı yetkisine tabidir. AEA ve Birleşik Krallık tüketicileri, ikamet ettikleri ülkenin yetkili mahkemelerinde de dava açma hakkını saklı tutar.',
    ),
    LegalSection(
      title: '14. Koşullardaki Değişiklikler',
      body:
          'Bu Koşulları herhangi bir zamanda değiştirme hakkımızı saklı tutarız. Önemli değişiklikler, yürürlüğe girmeden en az 14 gün önce uygulama içi bildirim veya e-posta yoluyla duyurulacaktır. Revize edilmiş Koşulların yürürlük tarihinden sonra Hizmetleri kullanmaya devam etmeniz, söz konusu değişiklikleri kabul ettiğiniz anlamına gelir. Değiştirilmiş Koşulları kabul etmiyorsanız Hizmetleri kullanmayı bırakmanız gerekmektedir.',
    ),
    LegalSection(
      title: '15. İletişim',
      body: 'Bu Kullanım Koşullarıyla ilgili soru veya endişeleriniz için:\n\nE-posta: legal@cosmira.app',
    ),
  ];

  // ─── Turkish Privacy Policy ───────────────────────────────────────────────
  static const List<LegalSection> _trPrivacy = [
    LegalSection(
      title: '1. Veri Sorumlusu ve Kapsam',
      body:
          'Cosmira ("biz", "bize", "bizim"), aşağıdaki mevzuat kapsamında veri sorumlusu sıfatıyla kişisel verilerinizi işlemektedir:\n\n• 6698 sayılı Kişisel Verilerin Korunması Kanunu (KVKK)\n• AB Genel Veri Koruma Tüzüğü (GDPR — Tüzük 2016/679/AB)\n• Birleşik Krallık GDPR ve 2018 tarihli Veri Koruma Kanunu\n\nBu Gizlilik Politikası, Cosmira mobil ve web uygulamasının tüm kullanıcıları için geçerlidir. Tüm veri koruma başvurularınız için: privacy@cosmira.app',
    ),
    LegalSection(
      title: '2. Toplanan Kişisel Veriler',
      body:
          'Aşağıdaki kişisel veri kategorilerini toplamakta ve işlemekteyiz:\n\n• Kimlik Verileri: ad soyad, e-posta adresi, profil fotoğrafı (OAuth sağlayıcısı aracılığıyla alınan)\n• Astroloji Verileri: doğum tarihi, doğum saati, doğum şehri, coğrafi koordinatlar\n• Kullanım Verileri: uygulama etkileşimleri, kullanılan özellikler, oturum süresi, uygulama içi işlemler\n• Teknik Veriler: cihaz türü, işletim sistemi sürümü, IP adresi, tarayıcı türü ve sürümü\n• Tercih Verileri: bildirim ayarları, dil tercihi, abonelik kademesi\n• Ödeme Durumu: abonelik durumu (ödeme işlemi yalnızca App Store veya Google Play tarafından gerçekleştirilir; kart bilgileri tarafımızca saklanmaz)\n\nVeriler doğrudan sizden (kayıt ve kullanım sırasında) ve otomatik olarak (analitik ve kilitlenme raporlama araçları aracılığıyla) toplanmaktadır.',
    ),
    LegalSection(
      title: '3. Kişisel Verilerin İşlenmesinin Hukuki Dayanağı (KVKK Md. 5)',
      body:
          'Kişisel verilerinizi KVKK\'nın 5. maddesi kapsamında aşağıdaki hukuki dayanaklar çerçevesinde işlemekteyiz:\n\n• Sözleşmenin kurulması veya ifası (Md. 5/2-c): hesabınızı oluşturmak ve talep ettiğiniz Hizmetleri sunmak için\n• Meşru menfaat (Md. 5/2-f): Hizmetleri geliştirmek, güvenliği sağlamak ve dolandırıcılığı önlemek amacıyla — bu menfaatler haklarınızın ve özgürlüklerinizin önüne geçmediği ölçüde\n• Açık rıza (Md. 5/1): pazarlama iletişimleri ve analitik çerezler için — onayınızı istediğiniz zaman geri çekebilirsiniz\n• Hukuki yükümlülük (Md. 5/2-ç): yürürlükteki mevzuata uymak için\n\nDoğum tarih ve saati gibi astroloji verileri, yalnızca astroloji hizmetleri sunmak amacıyla açık rızanıza (KVKK Md. 5/1, GDPR Md. 9(2)(a)) dayalı olarak işlenmektedir. Bu onayı profilinizden doğum bilgilerinizi silerek istediğiniz zaman geri çekebilirsiniz.\n\nAB/AEA kullanıcıları için kişisel verilerin işlenmesi aynı zamanda GDPR\'ın 6. maddesi kapsamında yürütülmektedir.',
    ),
    LegalSection(
      title: '4. Kişisel Verilerin İşlenme Amaçları',
      body:
          'Kişisel verilerinizi aşağıdaki amaçlarla kullanmaktayız:\n\n• Hesabınızı oluşturmak, doğrulamak ve yönetmek\n• Kişiselleştirilmiş astroloji yorumları, doğum haritası hesaplamaları, uyumluluk analizleri ve yapay zeka destekli ruhsal içerik üretmek\n• Uygulama mağazaları aracılığıyla abonelik durumunu yönetmek\n• Onayınız doğrultusunda push bildirimleri ve uygulama içi uyarılar göndermek\n• Anonimleştirilmiş analizler aracılığıyla Hizmetleri geliştirmek\n• Platformun güvenliğini, bütünlüğünü ve sürekliliğini sağlamak\n• Dolandırıcılık, kötüye kullanım ve güvenlik olaylarını tespit etmek ve önlemek\n• Uyuşmazlıkları çözmek, anlaşmaları uygulamak ve yasal yükümlülüklere uymak',
    ),
    LegalSection(
      title: '5. Kişisel Verilerin Paylaşılması',
      body:
          'Kişisel verilerinizi yalnızca gerekli ölçüde ve aşağıdaki alıcılarla paylaşmaktayız:\n\n• Supabase Inc. (ABD) — bulut altyapısı, PostgreSQL veritabanı barındırma ve kimlik doğrulama hizmetleri. Veriler, GDPR uyumlu Veri İşleme Sözleşmeleri (DPA) kapsamında AB ve ABD veri merkezlerinde işlenmektedir.\n• Google LLC (ABD) — Firebase Authentication, Firebase Analytics, Firebase Crashlytics ve Firebase Cloud Messaging.\n• Apple Inc. (ABD) — Sign in with Apple kimlik doğrulama hizmeti.\n\nKişisel verilerinizi herhangi bir üçüncü tarafın pazarlama veya ticari amaçlarına yönelik olarak satmıyor, kiralamıyor veya devretmiyoruz. Yürürlükteki mevzuatın zorunlu kıldığı ya da Cosmira\'nın, kullanıcılarının veya üçüncü tarafların haklarını, mülkiyetini veya güvenliğini korumak için gerekli görülen hallerde yetkili makamlara bilgi sunulabilir.',
    ),
    LegalSection(
      title: '6. Kişisel Verilerin Saklanma Süreleri',
      body:
          'Kişisel verileriniz, hesabınız aktif olduğu veya Hizmetlerin sunulması için gerekli olduğu süre boyunca saklanmaktadır:\n\n• Hesap ve profil verileri: hesap silme talebine kadar, ardından 30 gün içinde silinir\n• Kullanım ve analitik verileri: anonimleştirilmiş olarak en fazla 24 ay süreyle saklanır\n• Kilitlenme raporları: en fazla 12 ay süreyle saklanır\n• Finansal ve işlem kayıtları: 213 sayılı Vergi Usul Kanunu ile ilgili AB mevzuatı gereği 10 yıl süreyle saklanır\n\nHesap silme talebinin ardından kişisel verileriniz 30 gün içinde silinir veya geri döndürülemez biçimde anonimleştirilir; ancak yasal yükümlülükler kapsamında daha uzun süre saklanması gereken veriler bu kuralın istisnasını oluşturur.',
    ),
    LegalSection(
      title: '7. Kişisel Veri Sahibi Hakları (KVKK Md. 11)',
      body:
          'KVKK\'nın 11. maddesi uyarınca aşağıdaki haklara sahipsiniz:\n\n• Kişisel verilerinizin işlenip işlenmediğini öğrenme\n• İşlenmişse buna ilişkin bilgi talep etme\n• Verilerin işlenme amacını ve amacına uygun kullanılıp kullanılmadığını öğrenme\n• Yurt içinde veya yurt dışında aktarıldığı üçüncü tarafları öğrenme\n• Eksik veya yanlış işlenen verilerin düzeltilmesini talep etme\n• KVKK\'nın 7. maddesi kapsamında silinmesini veya yok edilmesini talep etme\n• Düzeltme, silme veya yok etme işlemlerinin aktarılan taraflara bildirilmesini talep etme\n• Münhasıran otomatik sistemlerle analiz sonucunda aleyhinize çıkan kararları itiraz etme\n• Kanuna aykırı işleme nedeniyle oluşan zararın giderilmesini talep etme\n\nHaklarınızı kullanmak için privacy@cosmira.app adresine yazılı olarak başvurabilirsiniz. Başvurular 30 gün içinde (gerektiğinde 60 güne kadar uzatılabilir, önceden bildirim yapılmak koşuluyla) ücretsiz yanıtlanacaktır. Kişisel Verileri Koruma Kurumu\'na (KVKK) şikayette bulunma hakkınız da mevcuttur.',
    ),
    LegalSection(
      title: '8. Yurt Dışına Veri Aktarımı',
      body:
          'Kişisel verileriniz, Avrupa Ekonomik Alanı (AEA) dışındaki ülkelere, özellikle Amerika Birleşik Devletleri\'ne aktarılabilir. Bu aktarımlar:\n\n• KVKK\'nın 9. maddesi kapsamında yeterli koruma düzeyi güvencesiyle veya açık rızanıza dayalı olarak;\n• GDPR\'ın 46. maddesi kapsamında Avrupa Komisyonu tarafından kabul edilen Standart Sözleşme Maddeleri (SCC) ve Veri İşleme Sözleşmeleri (DPA) çerçevesinde gerçekleştirilmektedir.\n\nHerhangi bir aktarıma uygulanan güvenceler hakkında daha fazla bilgi almak için privacy@cosmira.app ile iletişime geçebilirsiniz.',
    ),
    LegalSection(
      title: '9. Çerezler ve İzleme Teknolojileri',
      body:
          'Web uygulamamız aşağıdaki çerez türlerini kullanmaktadır:\n\n• Zorunlu çerezler: kimlik doğrulama, oturum yönetimi ve temel işlevsellik için gereklidir; devre dışı bırakılması Hizmetlerin kullanımını olumsuz etkiler.\n• Analitik çerezler: yalnızca önceden onayınız alınarak kullanım örüntülerini anlamak ve Hizmetleri geliştirmek amacıyla kullanılır (ör. Firebase Analytics).\n\nZorunlu olmayan çerezlere verdiğiniz onayı tarayıcı ayarlarınız veya uygulama içi tercih kontrollerimiz aracılığıyla istediğiniz zaman geri alabilirsiniz.',
    ),
    LegalSection(
      title: '10. Veri Güvenliği',
      body:
          'Kişisel verilerinizi yetkisiz erişim, kayıp, imha, değiştirme veya ifşaya karşı korumak için uygun teknik ve idari güvenlik tedbirleri uygulanmaktadır:\n\n• İletim sırasında TLS 1.2 veya üzeri şifreleme\n• Hassas verilerin depolamada şifrelenmesi\n• Rol tabanlı erişim kontrolleri ve en az ayrıcalık ilkesi\n• Düzenli güvenlik değerlendirmeleri ve sızma testleri\n\nKişisel veri ihlali durumunda ilgili denetim makamı 72 saat içinde bilgilendirilecek; ihlal, etkilenen kullanıcıların hak ve özgürlükleri açısından yüksek risk oluşturuyorsa kullanıcılara da derhal bildirim yapılacaktır.',
    ),
    LegalSection(
      title: '11. Çocukların Gizliliği',
      body:
          'Hizmetlerimiz 13 yaşın altındaki bireyler için tasarlanmamıştır (AEA üye devletlerinde geçerli daha yüksek dijital rıza yaşı eşikleri, en fazla 16 yaşa kadar saklıdır). 13 yaşın altındaki çocuklardan ebeveyn onayı olmaksızın bilerek kişisel veri toplamıyoruz. Bu yaş sınırının altında veri toplandığını fark edersek söz konusu verileri derhal sileriz. Çocuklarının kişisel veri sağladığını düşünen ebeveyn veya vasiler privacy@cosmira.app adresinden bize ulaşabilir.',
    ),
    LegalSection(
      title: '12. Bu Politikadaki Değişiklikler',
      body:
          'Gizlilik Politikamızı uygulamalarımızdaki, teknolojideki, yasal gerekliliklerdeki veya diğer faktörlerdeki değişiklikleri yansıtmak amacıyla zaman zaman güncelleyebiliriz. Önemli değişiklikler, yürürlüğe girmeden en az 14 gün önce uygulama içi bildirim veya e-posta yoluyla duyurulacaktır. Güncellenen Politikanın yürürlük tarihinden sonra Hizmetleri kullanmaya devam etmeniz değişiklikleri kabul ettiğiniz anlamına gelir.',
    ),
    LegalSection(
      title: '13. İletişim ve Denetim Makamları',
      body:
          'Kişisel veri başvuruları ve veri koruma sorularınız için:\n\nE-posta: privacy@cosmira.app\n\nKişisel Verileri Koruma Kurumu (KVKK)\nWeb: kvkk.gov.tr\nE-posta: kvkk@kvkk.gov.tr\n\nAB/AEA kullanıcıları kendi ülkelerindeki Veri Koruma Otoritesine (DPA) başvurabilir. AB DPA dizinine edpb.europa.eu adresinden ulaşılabilir.',
    ),
  ];
}
