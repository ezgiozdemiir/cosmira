import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final faqs = lang == 'tr' ? _faqsTr : _faqsEn;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: AppColors.textPrimary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 4),
                    Text('help_title'.tr(),
                        style: AppTextStyles.headlineLarge),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: faqs.length,
                  itemBuilder: (context, index) => _FaqTile(
                    question: faqs[index].question,
                    answer: faqs[index].answer,
                  ).animate().fadeIn(delay: Duration(milliseconds: 60 * index)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem(this.question, this.answer);
}

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;
  const _FaqTile({required this.question, required this.answer});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _expanded
                  ? AppColors.accentGlow.withValues(alpha: 0.4)
                  : AppColors.cardBorder,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(widget.question,
                          style: AppTextStyles.titleMedium),
                    ),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppColors.accentGlow,
                      size: 22,
                    ),
                  ],
                ),
                if (_expanded) ...[
                  const SizedBox(height: 10),
                  Text(
                    widget.answer,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const _faqsEn = [
  _FaqItem(
    'What is Stardust?',
    'Stardust is Cosmira\'s in-app currency. You can earn it by signing in daily, and use it to unlock premium features like birth maps and compatibility reports.',
  ),
  _FaqItem(
    'How do I earn Stardust?',
    'Visit the Stardust Store every day and tap the Daily Login card to claim +1 Stardust. Keep your streak going to earn more over time.',
  ),
  _FaqItem(
    'What is the difference between Free and Premium?',
    'Free users get daily horoscopes, basic natal chart, moon calendar, and 2 compatibility partners. Premium unlocks unlimited breathwork, deep compatibility reports, yearly destiny reports, astrocartography, and priority AI insights.',
  ),
  _FaqItem(
    'How do I calculate my natal chart?',
    'Complete onboarding with your birth date, time, and city. Cosmira will automatically calculate your natal chart including Sun, Moon, Rising, and all house placements.',
  ),
  _FaqItem(
    'Can I change my birth information?',
    'Yes. Go to your Profile and tap Edit Profile to update your birth date, time, and city at any time.',
  ),
  _FaqItem(
    'How do I cancel my subscription?',
    'Subscriptions are managed through the App Store (iOS) or Google Play (Android). Go to your device\'s subscription settings and cancel from there.',
  ),
  _FaqItem(
    'Why is my horoscope not showing?',
    'Make sure your birth date is saved in your profile so your sun sign can be determined. Try pulling down to refresh the home screen.',
  ),
  _FaqItem(
    'Is my personal data safe?',
    'Yes. Cosmira stores your data securely with Supabase. We never sell your personal information. See our Privacy Policy for full details.',
  ),
  _FaqItem(
    'How do I contact support?',
    'Email us at support@cosmira.app and we\'ll get back to you within 24 hours.',
  ),
];

const _faqsTr = [
  _FaqItem(
    'Yıldız Tozu nedir?',
    'Yıldız Tozu, Cosmira\'nın uygulama içi para birimidir. Her gün giriş yaparak kazanabilir, doğum haritası ve uyumluluk raporları gibi özellikleri açmak için kullanabilirsiniz.',
  ),
  _FaqItem(
    'Yıldız Tozu nasıl kazanılır?',
    'Her gün Yıldız Tozu Mağazası\'nı ziyaret edin ve Günlük Giriş kartına dokunarak +1 Yıldız Tozu alın. Çizginizi koruyun ve zamanla daha fazla kazanın.',
  ),
  _FaqItem(
    'Ücretsiz ve Premium arasındaki fark nedir?',
    'Ücretsiz kullanıcılar günlük burç, temel doğum haritası, ay takvimi ve 2 uyumluluk ortağı alır. Premium; sınırsız nefes egzersizi, derin uyumluluk raporları, yıllık kader raporu, astrokartografi ve öncelikli yapay zeka içgörülerini açar.',
  ),
  _FaqItem(
    'Doğum haritamı nasıl hesaplatırım?',
    'Doğum tarihiniz, saatiniz ve şehrinizle kaydı tamamlayın. Cosmira, Güneş, Ay, Yükselen ve tüm ev yerleşimlerinizi içeren doğum haritanızı otomatik olarak hesaplar.',
  ),
  _FaqItem(
    'Doğum bilgilerimi değiştirebilir miyim?',
    'Evet. Profilinize gidin ve doğum tarihinizi, saatinizi ve şehrinizi istediğiniz zaman güncellemek için Profili Düzenle\'ye dokunun.',
  ),
  _FaqItem(
    'Aboneliğimi nasıl iptal ederim?',
    'Abonelikler App Store (iOS) veya Google Play (Android) üzerinden yönetilir. Cihazınızın abonelik ayarlarına giderek iptal edebilirsiniz.',
  ),
  _FaqItem(
    'Burcum neden görünmüyor?',
    'Güneş burçunuzun belirlenebilmesi için profilinizde doğum tarihinizin kaydedildiğinden emin olun. Ana ekranı aşağı çekerek yenilemeyi deneyin.',
  ),
  _FaqItem(
    'Kişisel verilerim güvende mi?',
    'Evet. Cosmira, verilerinizi Supabase ile güvenli bir şekilde saklar. Kişisel bilgilerinizi asla satmayız. Tüm detaylar için Gizlilik Politikamıza bakın.',
  ),
  _FaqItem(
    'Desteğe nasıl ulaşabilirim?',
    'support@cosmira.app adresine e-posta gönderin, 24 saat içinde geri dönüş yapacağız.',
  ),
];
