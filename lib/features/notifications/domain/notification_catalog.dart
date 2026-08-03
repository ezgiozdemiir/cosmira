/// Single source of truth for notification copy, in both supported
/// languages, keyed by the same `event_key` that gets stored on each
/// `notification_log` row.
///
/// Notification rows never bake a language into `title`/`body` — content is
/// rendered fresh from (type, event_key, created_at) against whatever
/// language is currently selected, so switching the app language instantly
/// re-renders the whole notification history, and re-running the generator
/// can never produce a second row in a different language for the same
/// event (see `NotificationService.checkAndCreate`).
class NotificationCatalog {
  const NotificationCatalog._();

  static final List<CosmicEvent> events = [
    CosmicEvent(
      key: 'mercury_retro_2026_jan',
      date: DateTime.utc(2026, 1, 9),
      titleEn: '☿ Mercury Retrograde Begins',
      bodyEn: 'Mercury turns retrograde in Capricorn. Review your goals, slow down decisions, and let clarity return before acting.',
      titleTr: '☿ Merkür Retrosu Başlıyor',
      bodyTr: 'Merkür Oğlak\'ta geriye dönüyor. Hedeflerini gözden geçir, kararlarını yavaşlat ve harekete geçmeden önce netliğin geri dönmesine izin ver.',
    ),
    CosmicEvent(
      key: 'eclipse_solar_annular_2026_feb',
      date: DateTime.utc(2026, 2, 17),
      titleEn: '🌑 Annular Solar Eclipse',
      bodyEn: 'A powerful Solar Eclipse opens a bold new chapter. Set intentions aligned with your highest path — the cosmos is listening.',
      titleTr: '🌑 Halka Güneş Tutulması',
      bodyTr: 'Güçlü bir Güneş Tutulması cesur yeni bir bölüm açıyor. En yüksek yolunla uyumlu niyetler belirle — kozmos seni dinliyor.',
    ),
    CosmicEvent(
      key: 'eclipse_lunar_total_2026_mar',
      date: DateTime.utc(2026, 3, 3),
      titleEn: '🌕 Total Lunar Eclipse',
      bodyEn: 'A Total Lunar Eclipse illuminates what has been hidden. What emotional truth are you ready to face and release?',
      titleTr: '🌕 Tam Ay Tutulması',
      bodyTr: 'Tam Ay Tutulması gizli kalmış olanı aydınlatıyor. Hangi duygusal gerçeği yüzleşmeye ve bırakmaya hazırsın?',
    ),
    CosmicEvent(
      key: 'equinox_spring_2026',
      date: DateTime.utc(2026, 3, 20),
      titleEn: '🌸 Spring Equinox',
      bodyEn: 'Day and night are equal — a powerful threshold of new beginnings. Plant your seeds of intention today.',
      titleTr: '🌸 İlkbahar Ekinoksu',
      bodyTr: 'Gün ve gece eşit — yeni başlangıçların güçlü eşiği. Bugün niyet tohumlarını ek.',
    ),
    CosmicEvent(
      key: 'mercury_retro_2026_may',
      date: DateTime.utc(2026, 5, 10),
      titleEn: '☿ Mercury Retrograde Begins',
      bodyEn: 'Mercury turns retrograde in Gemini. Back up files, revisit past projects, and communicate with extra care.',
      titleTr: '☿ Merkür Retrosu Başlıyor',
      bodyTr: 'Merkür İkizler\'de geriye dönüyor. Dosyalarını yedekle, geçmiş projeleri gözden geçir ve iletişimde ekstra dikkatli ol.',
    ),
    CosmicEvent(
      key: 'solstice_summer_2026',
      date: DateTime.utc(2026, 6, 21),
      titleEn: '☀️ Summer Solstice',
      bodyEn: 'The longest day of the year — the Sun at peak power. A potent time for manifestation, clarity, and bold action.',
      titleTr: '☀️ Yaz Gündönümü',
      bodyTr: 'Yılın en uzun günü — Güneş zirve gücünde. Tezahür, netlik ve cesur eylem için güçlü bir an.',
    ),
    CosmicEvent(
      key: 'eclipse_solar_total_2026_aug',
      date: DateTime.utc(2026, 8, 12),
      titleEn: '🌑 Total Solar Eclipse',
      bodyEn: 'A Total Solar Eclipse — one of the most powerful cosmic events — rewrites destiny paths. What new story begins for you?',
      titleTr: '🌑 Tam Güneş Tutulması',
      bodyTr: 'Tam Güneş Tutulması — en güçlü kozmik olaylardan biri — kader yollarını yeniden yazıyor. Senin için hangi yeni hikaye başlıyor?',
    ),
    CosmicEvent(
      key: 'eclipse_lunar_partial_2026_aug',
      date: DateTime.utc(2026, 8, 28),
      titleEn: '🌗 Partial Lunar Eclipse',
      bodyEn: 'A Partial Lunar Eclipse in Pisces heightens intuition and emotional sensitivity. Trust what arises from within.',
      titleTr: '🌗 Kısmi Ay Tutulması',
      bodyTr: 'Balık\'ta Kısmi Ay Tutulması sezgini ve duygusal hassasiyetini artırıyor. İçinden gelen şeye güven.',
    ),
    CosmicEvent(
      key: 'mercury_retro_2026_sep',
      date: DateTime.utc(2026, 9, 12),
      titleEn: '☿ Mercury Retrograde Begins',
      bodyEn: 'Mercury turns retrograde in Libra. Revisit relationships, reconnect with old friends, and pause before signing anything.',
      titleTr: '☿ Merkür Retrosu Başlıyor',
      bodyTr: 'Merkür Terazi\'de geriye dönüyor. İlişkileri gözden geçir, eski arkadaşlarla yeniden bağlan ve herhangi bir şey imzalamadan önce dur.',
    ),
    CosmicEvent(
      key: 'equinox_autumn_2026',
      date: DateTime.utc(2026, 9, 22),
      titleEn: '🍂 Autumn Equinox',
      bodyEn: 'Light and dark stand equal. As we turn inward, the universe calls for harvest, reflection, and grateful release.',
      titleTr: '🍂 Sonbahar Ekinoksu',
      bodyTr: 'Işık ve karanlık eşit. İçe dönerken evren hasat, yansıma ve minnetle bırakış için çağrı yapıyor.',
    ),
    CosmicEvent(
      key: 'solstice_winter_2026',
      date: DateTime.utc(2026, 12, 21),
      titleEn: '❄️ Winter Solstice',
      bodyEn: 'The year\'s longest night invites stillness and inner wisdom. From here, the light returns — rest before the rebirth.',
      titleTr: '❄️ Kış Gündönümü',
      bodyTr: 'Yılın en uzun gecesi hareketsizliğe ve iç bilgeliğe davet ediyor. Buradan ışık geri dönüyor — yeniden doğuştan önce dinlen.',
    ),
    CosmicEvent(
      key: 'mercury_retro_2026_dec',
      date: DateTime.utc(2026, 12, 30),
      titleEn: '☿ Mercury Retrograde Begins',
      bodyEn: 'Mercury turns retrograde as the year closes in Capricorn. Reflect on what you built this year before launching new plans.',
      titleTr: '☿ Merkür Retrosu Başlıyor',
      bodyTr: 'Merkür yıl kapanırken Oğlak\'ta geriye dönüyor. Yeni planlar başlatmadan önce bu yıl inşa ettiklerini yansıt.',
    ),
  ];

  static const Map<String, Map<String, String>> seasonSummaries = {
    'aries': {
      'en': 'Aries season charges the week with bold, initiating energy. Act on your instincts and begin what you\'ve been postponing.',
      'tr': 'Koç sezonu haftayı cesur, başlatıcı enerjiyle dolduruyor. İçgüdülerine göre hareket et ve ertelediğin şeyleri başlat.',
    },
    'taurus': {
      'en': 'Taurus season grounds this week\'s energy. Slow down, focus on what truly matters, and build something lasting.',
      'tr': 'Boğa sezonu bu haftanın enerjisini köklendiriyor. Yavaşla, gerçekten önemli olana odaklan ve kalıcı bir şey inşa et.',
    },
    'gemini': {
      'en': 'Gemini season sparks curiosity and connection. Let ideas flow freely and follow what genuinely lights you up.',
      'tr': 'İkizler sezonu merak ve bağlantı kıvılcımı çakıyor. Fikirlerin serbestçe akmasına izin ver ve seni gerçekten heyecanlandırana uyu.',
    },
    'cancer': {
      'en': 'Cancer season turns the week inward. Nurture your emotional world, honor your home, and trust what you feel.',
      'tr': 'Yengeç sezonu haftayı içe çeviriyor. Duygusal dünyanı besle, evinle onur duy ve hissettiklerine güven.',
    },
    'leo': {
      'en': 'Leo season calls you to shine. Express yourself boldly, lead with your heart, and let your light be seen.',
      'tr': 'Aslan sezonu seni parlamaya çağırıyor. Kendini cesurca ifade et, kalbinle liderlik et ve ışığının görülmesine izin ver.',
    },
    'virgo': {
      'en': 'Virgo season invites precision and care. Focus on health, refine your craft, and clear what no longer serves you.',
      'tr': 'Başak sezonu hassasiyet ve özen davet ediyor. Sağlığa odaklan, zanaatını rafine et ve artık sana hizmet etmeyeni temizle.',
    },
    'libra': {
      'en': 'Libra season calls for harmony and partnership. Seek balance in relationships and let beauty guide your choices.',
      'tr': 'Terazi sezonu uyum ve ortaklık için çağrı yapıyor. İlişkilerde denge ara ve güzelin seçimlerini yönlendirmesine izin ver.',
    },
    'scorpio': {
      'en': 'Scorpio season deepens everything. Dive into what is real, release what is done, and trust your transformation.',
      'tr': 'Akrep sezonu her şeyi derinleştiriyor. Gerçek olana dal, bitenini serbest bırak ve dönüşümüne güven.',
    },
    'sagittarius': {
      'en': 'Sagittarius season expands your horizons. Seek wisdom, embrace adventure, and let optimism guide the week.',
      'tr': 'Yay sezonu ufuklarını genişletiyor. Bilgelik ara, maceraya kucak aç ve iyimserliğin haftayı yönlendirmesine izin ver.',
    },
    'capricorn': {
      'en': 'Capricorn season calls for disciplined focus. Commit to long-term goals and take steady, meaningful steps forward.',
      'tr': 'Oğlak sezonu disiplinli odaklanma için çağrı yapıyor. Uzun vadeli hedeflere bağlan ve istikrarlı, anlamlı adımlar at.',
    },
    'aquarius': {
      'en': 'Aquarius season awakens vision and originality. Question conventions, innovate boldly, and connect with your community.',
      'tr': 'Kova sezonu vizyon ve özgünlüğü uyandırıyor. Gelenekleri sorgula, cesurca yenilik yap ve topluluğunla bağlan.',
    },
    'pisces': {
      'en': 'Pisces season deepens intuition and compassion. Rest when needed, listen to your dreams, and trust the invisible currents.',
      'tr': 'Balık sezonu sezgini ve şefkati derinleştiriyor. Gerektiğinde dinlen, rüyalarını dinle ve görünmez akıntılara güven.',
    },
  };

  static const Map<int, String> milestoneUnlockKeys = {
    100: 'astrocartography',
    200: 'birth_map',
    500: 'stardust_500',
  };

  /// Renders the (title, body) pair for a stored notification row in [lang]
  /// ('en' or 'tr'), given its `type`, `event_key` and `created_at`. Returns
  /// null for a type/key this catalog doesn't recognize, so the caller can
  /// fall back to whatever text was stored on the row itself.
  static ({String title, String body})? render({
    required String type,
    required String? eventKey,
    required DateTime createdAt,
    required String lang,
  }) {
    final isTr = lang == 'tr';
    switch (type) {
      case 'welcome':
        return (
          title: isTr ? '🌟 Cosmira\'ya Hoş Geldin!' : '🌟 Welcome to Cosmira!',
          body: isTr
              ? 'Kozmik yolculuğun başlıyor. Her gün giriş yaparak Yıldız Tozu kazan ve özelliklerini aç!'
              : 'Your cosmic journey begins. Sign in every day to earn Stardust and unlock features!',
        );

      case 'stardust':
        if (eventKey != 'daily_login_hint') return null;
        return (
          title: isTr ? '⭐ Günlük Yıldız Tozu Kazan' : '⭐ Earn Daily Stardust',
          body: isTr
              ? 'Her gün Yıldız Tozu Mağazası\'nı ziyaret ederek +1 Yıldız Tozu kazan. Çizgini koru, daha fazla kazan!'
              : 'Visit the Stardust Store every day to claim +1 Stardust. Keep your streak going!',
        );

      case 'cosmic_event':
        final event = eventKey == null ? null : _eventByKey(eventKey);
        if (event == null) return null;
        return (
          title: isTr ? event.titleTr : event.titleEn,
          body: isTr ? event.bodyTr : event.bodyEn,
        );

      case 'weekly_summary':
        final season = currentSeason(createdAt);
        final title = isTr ? '🔭 Haftanın Kozmik Enerjisi' : '🔭 This Week\'s Cosmic Energy';
        final body = seasonSummaries[season]?[isTr ? 'tr' : 'en'] ??
            (isTr
                ? 'Bu hafta kozmik enerjiler güçlü akıyor. Niyetlerinizi belirleyin ve akışa kapılın.'
                : 'Cosmic energies are flowing strongly this week. Set your intentions and ride the current.');
        return (title: title, body: body);

      case 'stardust_milestone':
        final threshold = _thresholdFromKey(eventKey);
        if (threshold == null) return null;
        final unlockKey = milestoneUnlockKeys[threshold];
        return (
          title: isTr ? '✨ Yeni Bir Şey Açabilirsin!' : '✨ You Can Unlock Something New!',
          body: milestoneBody(threshold, unlockKey, isTr ? 'tr' : 'en'),
        );

      case 'breathwork':
        return (
          title: isTr ? '🌬️ Bugün Nefes Zamanı' : '🌬️ Time to Breathe Today',
          body: isTr
              ? 'Birkaç dakika kendinize ayırın. Bir nefes seansı zihni temizler ve enerjinizi dengeler.'
              : 'Take a few minutes for yourself. A breathwork session clears the mind and restores your energy.',
        );

      default:
        return null;
    }
  }

  static CosmicEvent? _eventByKey(String key) {
    for (final event in events) {
      if (event.key == key) return event;
    }
    return null;
  }

  static int? _thresholdFromKey(String? eventKey) {
    if (eventKey == null || !eventKey.startsWith('stardust_milestone_')) return null;
    return int.tryParse(eventKey.substring('stardust_milestone_'.length));
  }

  static String milestoneBody(int threshold, String? unlockKey, String lang) {
    if (lang == 'tr') {
      switch (unlockKey) {
        case 'astrocartography':
          return '$threshold Yıldız Tozu biriktirdin! Artık Astrokartografi raporunu açabilirsin.';
        case 'birth_map':
          return '$threshold Yıldız Tozu biriktirdin! Doğum Haritanı açmak için hazırsın.';
        default:
          return '$threshold Yıldız Tozu biriktirdin! Kozmik yolculuğun harika ilerlemeye devam ediyor.';
      }
    } else {
      switch (unlockKey) {
        case 'astrocartography':
          return 'You\'ve collected $threshold Stardust! You can now unlock your Astrocartography report.';
        case 'birth_map':
          return 'You\'ve collected $threshold Stardust! You\'re ready to unlock your Birth Map.';
        default:
          return 'You\'ve collected $threshold Stardust! Your cosmic journey continues to grow.';
      }
    }
  }

  static String currentSeason(DateTime date) {
    final m = date.month;
    final d = date.day;
    if ((m == 3 && d >= 21) || (m == 4 && d <= 19)) return 'aries';
    if ((m == 4 && d >= 20) || (m == 5 && d <= 20)) return 'taurus';
    if ((m == 5 && d >= 21) || (m == 6 && d <= 20)) return 'gemini';
    if ((m == 6 && d >= 21) || (m == 7 && d <= 22)) return 'cancer';
    if ((m == 7 && d >= 23) || (m == 8 && d <= 22)) return 'leo';
    if ((m == 8 && d >= 23) || (m == 9 && d <= 22)) return 'virgo';
    if ((m == 9 && d >= 23) || (m == 10 && d <= 22)) return 'libra';
    if ((m == 10 && d >= 23) || (m == 11 && d <= 21)) return 'scorpio';
    if ((m == 11 && d >= 22) || (m == 12 && d <= 21)) return 'sagittarius';
    if ((m == 12 && d >= 22) || (m == 1 && d <= 19)) return 'capricorn';
    if ((m == 1 && d >= 20) || (m == 2 && d <= 18)) return 'aquarius';
    return 'pisces';
  }

  static int isoWeek(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    return ((dayOfYear - date.weekday + 10) ~/ 7);
  }
}

class CosmicEvent {
  final String key;
  final DateTime date;
  final String titleEn;
  final String bodyEn;
  final String titleTr;
  final String bodyTr;
  CosmicEvent({
    required this.key,
    required this.date,
    required this.titleEn,
    required this.bodyEn,
    required this.titleTr,
    required this.bodyTr,
  });
}
