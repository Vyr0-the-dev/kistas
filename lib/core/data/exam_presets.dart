import '../models/topic_summary.dart';

class PresetTopicSpec {
  const PresetTopicSpec(
    this.title, {
    this.importance = 3,
    this.summary = '',
  });

  final String title;
  final int importance;
  final String summary;
}

class ExamPreset {
  const ExamPreset({
    required this.id,
    required this.name,
    required this.category,
    required this.subtitle,
    required this.defaultWrongPenalty,
    required this.subjects,
  });

  final String id;
  final String name;
  final String category;
  final String subtitle;
  final double defaultWrongPenalty;
  final Map<String, List<PresetTopicSpec>> subjects;

  int get totalTopics =>
      subjects.values.fold<int>(0, (sum, list) => sum + list.length);

  List<TopicSummary> toTopicSummaries({Set<String>? selectedSubjects}) {
    final result = <TopicSummary>[];
    for (final entry in subjects.entries) {
      if (selectedSubjects != null && !selectedSubjects.contains(entry.key)) {
        continue;
      }
      final subjectSlug = _slugify(entry.key);
      for (final topic in entry.value) {
        final topicSlug = _slugify(topic.title);
        result.add(
          TopicSummary(
            id: '$id-$subjectSlug-$topicSlug',
            subject: entry.key,
            title: topic.title,
            nextReview: '',
            summary: topic.summary,
            importance: topic.importance,
            tag: name,
          ),
        );
      }
    }
    return result;
  }
}

String _slugify(String input) {
  final map = {
    'ç': 'c',
    'ğ': 'g',
    'ı': 'i',
    'İ': 'i',
    'ö': 'o',
    'ş': 's',
    'ü': 'u',
    'Ç': 'c',
    'Ğ': 'g',
    'Ö': 'o',
    'Ş': 's',
    'Ü': 'u',
  };
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    final ch = String.fromCharCode(rune);
    buffer.write(map[ch] ?? ch.toLowerCase());
  }
  return buffer
      .toString()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}

const Map<String, List<PresetTopicSpec>> _kpssGkGySubjects = {
  'Türkçe': [
    PresetTopicSpec('Sözcükte Anlam', importance: 4),
    PresetTopicSpec('Cümlede Anlam', importance: 4),
    PresetTopicSpec('Paragraf', importance: 5),
    PresetTopicSpec('Ses Bilgisi', importance: 3),
    PresetTopicSpec('Yazım Kuralları', importance: 4),
    PresetTopicSpec('Noktalama İşaretleri', importance: 4),
    PresetTopicSpec('Sözcükte Yapı ve Ekler', importance: 3),
    PresetTopicSpec('Sözcük Türleri', importance: 3),
    PresetTopicSpec('Cümlenin Ögeleri', importance: 3),
    PresetTopicSpec('Cümle Türleri', importance: 3),
    PresetTopicSpec('Anlatım Bozuklukları', importance: 2),
    PresetTopicSpec('Sözel Mantık', importance: 5),
  ],
  'Matematik': [
    PresetTopicSpec('Temel Kavramlar', importance: 4),
    PresetTopicSpec('Sayı Basamakları', importance: 3),
    PresetTopicSpec('Bölme ve Bölünebilme', importance: 3),
    PresetTopicSpec('EBOB - EKOK', importance: 3),
    PresetTopicSpec('Rasyonel Sayılar', importance: 4),
    PresetTopicSpec('Basit Eşitsizlikler', importance: 4),
    PresetTopicSpec('Mutlak Değer', importance: 4),
    PresetTopicSpec('Üslü Sayılar', importance: 4),
    PresetTopicSpec('Köklü Sayılar', importance: 4),
    PresetTopicSpec('Çarpanlara Ayırma', importance: 3),
    PresetTopicSpec('Oran - Orantı', importance: 4),
    PresetTopicSpec('Denklem Çözme', importance: 4),
    PresetTopicSpec('Sayı ve Kesir Problemleri', importance: 5),
    PresetTopicSpec('Yaş ve İşçi Problemleri', importance: 4),
    PresetTopicSpec('Hareket Problemleri', importance: 4),
    PresetTopicSpec('Yüzde, Kâr-Zarar ve Karışım Problemleri', importance: 5),
    PresetTopicSpec('Tablo ve Grafik Problemleri', importance: 4),
    PresetTopicSpec('Kümeler ve Fonksiyonlar', importance: 4),
    PresetTopicSpec('Permütasyon, Kombinasyon ve Olasılık', importance: 4),
    PresetTopicSpec('Sayısal Mantık', importance: 5),
  ],
  'Geometri': [
    PresetTopicSpec('Doğruda ve Üçgende Açılar', importance: 3),
    PresetTopicSpec('Üçgenler', importance: 4),
    PresetTopicSpec('Çokgenler ve Dörtgenler', importance: 4),
    PresetTopicSpec('Çember ve Daire', importance: 3),
    PresetTopicSpec('Analitik Geometri', importance: 4),
    PresetTopicSpec('Katı Cisimler', importance: 3),
  ],
  'Tarih': [
    PresetTopicSpec('İslamiyet Öncesi Türk Tarihi', importance: 3),
    PresetTopicSpec('İlk Türk-İslam Devletleri', importance: 4),
    PresetTopicSpec('Türkiye Tarihi', importance: 3),
    PresetTopicSpec('Osmanlı Kültür ve Medeniyeti', importance: 5),
    PresetTopicSpec('Osmanlı Kuruluş ve Yükselme', importance: 4),
    PresetTopicSpec('Osmanlı Duraklama, Gerileme ve Dağılma', importance: 4),
    PresetTopicSpec('20. Yüzyılda Osmanlı Devleti', importance: 4),
    PresetTopicSpec('Kurtuluş Savaşı Hazırlık ve Cepheler', importance: 5),
    PresetTopicSpec('Atatürk İlke ve İnkılapları', importance: 5),
    PresetTopicSpec('Atatürk Dönemi Dış Politika', importance: 4),
    PresetTopicSpec('Çağdaş Türk ve Dünya Tarihi', importance: 4),
  ],
  'Coğrafya': [
    PresetTopicSpec('Türkiye\'nin Coğrafi Konumu', importance: 4),
    PresetTopicSpec('Türkiye\'nin Yer Şekilleri', importance: 5),
    PresetTopicSpec('Türkiye\'nin İklimi ve Bitki Örtüsü', importance: 4),
    PresetTopicSpec('Türkiye\'de Nüfus ve Yerleşme', importance: 4),
    PresetTopicSpec('Tarım ve Hayvancılık', importance: 4),
    PresetTopicSpec('Madenler ve Enerji Kaynakları', importance: 4),
    PresetTopicSpec('Sanayi, Ticaret, Ulaşım ve Turizm', importance: 4),
    PresetTopicSpec('Bölgesel Kalkınma Projeleri', importance: 3),
  ],
  'Vatandaşlık': [
    PresetTopicSpec('Temel Hukuk Kavramları', importance: 4),
    PresetTopicSpec('Anayasa Tarihi ve 1982 Anayasası', importance: 5),
    PresetTopicSpec('Temel Hak ve Ödevler', importance: 4),
    PresetTopicSpec('Yasama', importance: 4),
    PresetTopicSpec('Yürütme', importance: 4),
    PresetTopicSpec('Yargı', importance: 4),
    PresetTopicSpec('İdare Hukuku', importance: 5),
    PresetTopicSpec('Uluslararası Kuruluşlar', importance: 3),
  ],
  'Güncel Bilgiler': [
    PresetTopicSpec('Güncel Olaylar ve Genel Kültür', importance: 4),
    PresetTopicSpec('Kültür, Sanat ve Bilim Gelişmeleri', importance: 3),
  ],
};

const Map<String, List<PresetTopicSpec>> _aytMathTopics = {
  'AYT Matematik': [
    PresetTopicSpec('Polinomlar', importance: 4),
    PresetTopicSpec('İkinci Dereceden Denklemler', importance: 4),
    PresetTopicSpec('Karmaşık Sayılar', importance: 3),
    PresetTopicSpec('Parabol', importance: 4),
    PresetTopicSpec('İkinci Dereceden Eşitsizlikler', importance: 4),
    PresetTopicSpec('Trigonometri', importance: 5),
    PresetTopicSpec('Logaritma', importance: 5),
    PresetTopicSpec('Diziler', importance: 4),
    PresetTopicSpec('Limit ve Süreklilik', importance: 5),
    PresetTopicSpec('Türev', importance: 5),
    PresetTopicSpec('İntegral', importance: 5),
  ],
};

const Map<String, List<PresetTopicSpec>> _aytLiteratureHistoryGeo = {
  'Türk Dili ve Edebiyatı': [
    PresetTopicSpec('Şiir Bilgisi ve Söz Sanatları', importance: 5),
    PresetTopicSpec('İslamiyet Öncesi ve Geçiş Dönemi', importance: 3),
    PresetTopicSpec('Halk Edebiyatı', importance: 4),
    PresetTopicSpec('Divan Edebiyatı', importance: 5),
    PresetTopicSpec('Tanzimat, Servetifünun ve Fecriati', importance: 5),
    PresetTopicSpec('Milli Edebiyat', importance: 4),
    PresetTopicSpec('Cumhuriyet Dönemi Şiir', importance: 5),
    PresetTopicSpec('Cumhuriyet Dönemi Roman ve Hikaye', importance: 5),
    PresetTopicSpec('Edebi Akımlar', importance: 4),
  ],
  'Tarih-1': [
    PresetTopicSpec('İlk ve Orta Çağlarda Türk Dünyası', importance: 3),
    PresetTopicSpec('İslam Tarihi ve Türk-İslam Devletleri', importance: 4),
    PresetTopicSpec('Osmanlı Siyasi ve Kültür Tarihi', importance: 5),
    PresetTopicSpec('Milli Mücadele Dönemi', importance: 5),
    PresetTopicSpec('Atatürkçülük ve Türk İnkılabı', importance: 5),
  ],
  'Coğrafya-1': [
    PresetTopicSpec('Biyoçeşitlilik ve Ekosistem', importance: 4),
    PresetTopicSpec('Nüfus Politikaları ve Şehirleşme', importance: 4),
    PresetTopicSpec('Türkiye Ekonomisi ve Kaynaklar', importance: 5),
    PresetTopicSpec('Küresel Ticaret ve Bölgeler', importance: 4),
    PresetTopicSpec('Çevre ve Toplum', importance: 3),
  ],
};

const List<ExamPreset> examCatalogPresets = [
  ExamPreset(
    id: 'kpss-lisans',
    name: 'KPSS Lisans',
    category: 'KPSS',
    subtitle: 'Genel Yetenek & Genel Kültür (7 ders)',
    defaultWrongPenalty: 0.25,
    subjects: _kpssGkGySubjects,
  ),
  ExamPreset(
    id: 'kpss-onlisans',
    name: 'KPSS Önlisans',
    category: 'KPSS',
    subtitle: 'Önlisans GK-GY tam müfredat (7 ders)',
    defaultWrongPenalty: 0.25,
    subjects: _kpssGkGySubjects,
  ),
  ExamPreset(
    id: 'kpss-ortaogretim',
    name: 'KPSS Ortaöğretim',
    category: 'KPSS',
    subtitle: 'Lise düzeyi GK-GY müfredatı (7 ders)',
    defaultWrongPenalty: 0.25,
    subjects: _kpssGkGySubjects,
  ),
  ExamPreset(
    id: 'kpss-egitim',
    name: 'KPSS Eğitim Bilimleri',
    category: 'KPSS',
    subtitle: 'Öğretmenlik Eğitim Bilimleri (6 ders)',
    defaultWrongPenalty: 0.25,
    subjects: {
      'Gelişim Psikolojisi': [
        PresetTopicSpec('Gelişimin Temel Kavramları ve İlkeleri', importance: 4),
        PresetTopicSpec('Bilişsel Gelişim (Piaget, Vygotsky)', importance: 5),
        PresetTopicSpec('Kişilik ve Psikososyal Gelişim (Freud, Erikson)', importance: 5),
        PresetTopicSpec('Ahlak ve Dil Gelişimi', importance: 4),
      ],
      'Öğrenme Psikolojisi': [
        PresetTopicSpec('Klasik ve Edimsel Koşullanma', importance: 5),
        PresetTopicSpec('Sosyal Öğrenme Kuramı', importance: 4),
        PresetTopicSpec('Bilişsel ve Bilgiyi İşleme Kuramları', importance: 5),
        PresetTopicSpec('Öğrenmeyi Etkileyen Faktörler', importance: 4),
      ],
      'Öğretim Yöntem ve Teknikleri': [
        PresetTopicSpec('Öğretim İlkeleri ve Stratejileri', importance: 4),
        PresetTopicSpec('Öğretim Modelleri ve Yaklaşımları', importance: 5),
        PresetTopicSpec('Öğretim Yöntem ve Teknikleri', importance: 5),
        PresetTopicSpec('Düşünme Becerileri', importance: 4),
      ],
      'Program Geliştirme': [
        PresetTopicSpec('Eğitim Programlarının Temelleri', importance: 4),
        PresetTopicSpec('Program Tasarım Yaklaşımları', importance: 5),
        PresetTopicSpec('İhtiyaç Belirleme ve Hedef Yazma', importance: 4),
        PresetTopicSpec('İçerik Düzenleme ve Değerlendirme', importance: 4),
      ],
      'Ölçme ve Değerlendirme': [
        PresetTopicSpec('Ölçme ve Değerlendirme Temel Kavramları', importance: 4),
        PresetTopicSpec('Güvenirlik, Geçerlik ve Kullanışlılık', importance: 5),
        PresetTopicSpec('Test ve Madde İstatistikleri', importance: 5),
        PresetTopicSpec('Ölçme Araçları ve Alternatif Değerlendirme', importance: 4),
      ],
      'Rehberlik ve Özel Eğitim': [
        PresetTopicSpec('Rehberlik Türleri ve Hizmet Alanları', importance: 5),
        PresetTopicSpec('Bireyi Tanıma Teknikleri', importance: 4),
        PresetTopicSpec('Örgütlenme ve Personel Görevleri', importance: 4),
        PresetTopicSpec('Özel Eğitim ve Kaynaştırma', importance: 5),
      ],
    },
  ),
  ExamPreset(
    id: 'tyt',
    name: 'TYT',
    category: 'YKS',
    subtitle: 'Temel Yeterlilik Testi (10 ders)',
    defaultWrongPenalty: 0.25,
    subjects: {
      'TYT Türkçe': [
        PresetTopicSpec('Sözcükte Anlam', importance: 4),
        PresetTopicSpec('Cümlede Anlam', importance: 4),
        PresetTopicSpec('Paragraf', importance: 5),
        PresetTopicSpec('Ses Bilgisi', importance: 4),
        PresetTopicSpec('Yazım Kuralları', importance: 5),
        PresetTopicSpec('Noktalama İşaretleri', importance: 5),
        PresetTopicSpec('Sözcükte Yapı', importance: 4),
        PresetTopicSpec('Sözcük Türleri', importance: 4),
        PresetTopicSpec('Fiiller ve Fiilimsiler', importance: 4),
        PresetTopicSpec('Cümlenin Ögeleri', importance: 4),
        PresetTopicSpec('Cümle Türleri ve Anlatım Bozukluğu', importance: 3),
      ],
      'TYT Matematik': [
        PresetTopicSpec('Temel Kavramlar ve Sayı Basamakları', importance: 4),
        PresetTopicSpec('Bölme, Bölünebilme ve EBOB-EKOK', importance: 4),
        PresetTopicSpec('Rasyonel Sayılar ve Basit Eşitsizlikler', importance: 4),
        PresetTopicSpec('Mutlak Değer, Üslü ve Köklü Sayılar', importance: 5),
        PresetTopicSpec('Oran-Orantı ve Denklem Çözme', importance: 4),
        PresetTopicSpec('Sayı, Kesir ve Yaş Problemleri', importance: 5),
        PresetTopicSpec('Yüzde, Kâr-Zarar, Hareket ve Karışım Problemleri', importance: 5),
        PresetTopicSpec('Kümeler ve Mantık', importance: 4),
        PresetTopicSpec('Fonksiyonlar', importance: 5),
        PresetTopicSpec('Polinomlar ve Veri-İstatistik', importance: 4),
        PresetTopicSpec('Permütasyon, Kombinasyon, Binom ve Olasılık', importance: 5),
      ],
      'TYT Geometri': [
        PresetTopicSpec('Doğruda ve Üçgende Açılar', importance: 4),
        PresetTopicSpec('Dik, İkizkenar ve Eşkenar Üçgen', importance: 5),
        PresetTopicSpec('Üçgende Benzerlik ve Alan', importance: 5),
        PresetTopicSpec('Çokgenler ve Özel Dörtgenler', importance: 5),
        PresetTopicSpec('Katı Cisimler (Prizma, Piramit)', importance: 4),
      ],
      'TYT Fizik': [
        PresetTopicSpec('Fizik Bilimine Giriş ve Madde Özellikleri', importance: 3),
        PresetTopicSpec('Hareket, Kuvvet ve Newton Yasaları', importance: 4),
        PresetTopicSpec('İş, Güç ve Enerji', importance: 4),
        PresetTopicSpec('Isı, Sıcaklık ve Genleşme', importance: 4),
        PresetTopicSpec('Basınç ve Kaldırma Kuvveti', importance: 5),
        PresetTopicSpec('Elektrik ve Manyetizma', importance: 5),
        PresetTopicSpec('Dalgalar', importance: 4),
        PresetTopicSpec('Optik', importance: 5),
      ],
      'TYT Kimya': [
        PresetTopicSpec('Kimya Bilimi ve Atom-Periyodik Sistem', importance: 4),
        PresetTopicSpec('Kimyasal Türler Arası Etkileşimler', importance: 5),
        PresetTopicSpec('Maddenin Halleri ve Doğa-Kimya', importance: 4),
        PresetTopicSpec('Kimyanın Temel Kanunları ve Mol', importance: 5),
        PresetTopicSpec('Karışımlar', importance: 4),
        PresetTopicSpec('Asitler, Bazlar ve Tuzlar', importance: 5),
        PresetTopicSpec('Kimya Her Yerde', importance: 3),
      ],
      'TYT Biyoloji': [
        PresetTopicSpec('Canlıların Ortak Özellikleri ve Temel Bileşenler', importance: 4),
        PresetTopicSpec('Hücre ve Organeller', importance: 5),
        PresetTopicSpec('Canlılar Dünyası ve Sınıflandırma', importance: 4),
        PresetTopicSpec('Hücre Bölünmeleri ve Üreme', importance: 5),
        PresetTopicSpec('Kalıtım', importance: 5),
        PresetTopicSpec('Ekosistem Ekolojisi', importance: 4),
      ],
      'TYT Tarih': [
        PresetTopicSpec('Tarih Bilimi ve İlk Uygarlıklar', importance: 3),
        PresetTopicSpec('İlk ve Orta Çağlarda Türk Dünyası', importance: 4),
        PresetTopicSpec('İslam Tarihi ve Türk-İslam Devletleri', importance: 4),
        PresetTopicSpec('Osmanlı Devleti Tarihi', importance: 5),
        PresetTopicSpec('Milli Mücadele ve İnkılap Tarihi', importance: 5),
      ],
      'TYT Coğrafya': [
        PresetTopicSpec('Doğa-İnsan ve Coğrafi Konum', importance: 4),
        PresetTopicSpec('Harita Bilgisi ve İklim', importance: 5),
        PresetTopicSpec('İç ve Dış Kuvvetler', importance: 4),
        PresetTopicSpec('Nüfus, Göç ve Yerleşme', importance: 5),
        PresetTopicSpec('Bölgeler ve Doğal Afetler', importance: 4),
      ],
      'TYT Felsefe': [
        PresetTopicSpec('Felsefeye Giriş ve Bilgi Felsefesi', importance: 4),
        PresetTopicSpec('Varlık, Ahlak ve Siyaset Felsefesi', importance: 4),
        PresetTopicSpec('Sanat, Din ve Bilim Felsefesi', importance: 4),
        PresetTopicSpec('Felsefe Tarihi Akımları', importance: 5),
      ],
      'TYT Din Kültürü': [
        PresetTopicSpec('Bilgi, İnanç ve İslam İbadetleri', importance: 4),
        PresetTopicSpec('Ahlak, Değerler ve Hz. Muhammed', importance: 4),
        PresetTopicSpec('İslam Düşüncesinde Yorumlar ve Dünya Dinleri', importance: 4),
      ],
    },
  ),
  ExamPreset(
    id: 'ayt-sayisal',
    name: 'AYT Sayısal',
    category: 'YKS',
    subtitle: 'Matematik, Geometri, Fizik, Kimya, Biyoloji',
    defaultWrongPenalty: 0.25,
    subjects: {
      ..._aytMathTopics,
      'AYT Geometri': [
        PresetTopicSpec('Analitik Geometri', importance: 5),
        PresetTopicSpec('Çember ve Daire', importance: 5),
        PresetTopicSpec('Çemberin Analitiği ve Dönüşümler', importance: 4),
        PresetTopicSpec('Katı Cisimler (Silindir, Koni, Küre)', importance: 4),
      ],
      'AYT Fizik': [
        PresetTopicSpec('Vektörler ve Bağıl Hareket', importance: 3),
        PresetTopicSpec('Newton Hareket Yasaları ve Atışlar', importance: 5),
        PresetTopicSpec('İtme ve Çizgisel Momentum', importance: 4),
        PresetTopicSpec('Tork, Denge ve Basit Makineler', importance: 4),
        PresetTopicSpec('Elektrik Alan, Potansiyel ve Sığa', importance: 5),
        PresetTopicSpec('Manyetizma ve Elektromanyetik İndüksiyon', importance: 5),
        PresetTopicSpec('Alternatif Akım ve Transformatörler', importance: 4),
        PresetTopicSpec('Çembersel Hareket ve Açısal Momentum', importance: 5),
        PresetTopicSpec('Basit Harmonik Hareket ve Dalga Mekaniği', importance: 5),
        PresetTopicSpec('Atom Fiziği ve Modern Fizik', importance: 5),
      ],
      'AYT Kimya': [
        PresetTopicSpec('Modern Atom Teorisi', importance: 4),
        PresetTopicSpec('Gazlar', importance: 5),
        PresetTopicSpec('Sıvı Çözeltiler ve Çözünürlük', importance: 5),
        PresetTopicSpec('Kimyasal Tepkimelerde Enerji ve Hız', importance: 5),
        PresetTopicSpec('Kimyasal Denge, Asit-Baz ve Kçç', importance: 5),
        PresetTopicSpec('Kimya ve Elektrik', importance: 5),
        PresetTopicSpec('Karbon Kimyasına Giriş ve Organik Bileşikler', importance: 5),
      ],
      'AYT Biyoloji': [
        PresetTopicSpec('Sinir, Endokrin ve Duyu Sistemleri', importance: 5),
        PresetTopicSpec('Destek-Hareket, Sindirim ve Dolaşım', importance: 5),
        PresetTopicSpec('Solunum, Boşaltım ve Üreme Sistemi', importance: 5),
        PresetTopicSpec('Komünite ve Popülasyon Ekolojisi', importance: 4),
        PresetTopicSpec('Genden Proteine (DNA, RNA, Protein Sentezi)', importance: 5),
        PresetTopicSpec('Fotosentez ve Hücresel Solunum', importance: 5),
        PresetTopicSpec('Bitki Biyolojisi', importance: 5),
      ],
    },
  ),
  ExamPreset(
    id: 'ayt-ea',
    name: 'AYT Eşit Ağırlık',
    category: 'YKS',
    subtitle: 'AYT Matematik, Edebiyat, Tarih-1, Coğrafya-1',
    defaultWrongPenalty: 0.25,
    subjects: {
      ..._aytMathTopics,
      ..._aytLiteratureHistoryGeo,
    },
  ),
  ExamPreset(
    id: 'ayt-sozel',
    name: 'AYT Sözel',
    category: 'YKS',
    subtitle: 'Edebiyat, Tarih 1-2, Coğrafya 1-2, Felsefe Grubu, Din',
    defaultWrongPenalty: 0.25,
    subjects: {
      ..._aytLiteratureHistoryGeo,
      'Tarih-2': [
        PresetTopicSpec('İlk ve Orta Çağ Dünya Tarihi', importance: 3),
        PresetTopicSpec('Osmanlı Diplomasi ve Islahatları', importance: 4),
        PresetTopicSpec('20. Yüzyıl Başlarında Dünya ve Kurtuluş Savaşı', importance: 5),
        PresetTopicSpec('Çağdaş Türk ve Dünya Tarihi', importance: 5),
      ],
      'Coğrafya-2': [
        PresetTopicSpec('Türkiye\'nin Ekonomik ve Bölgesel Politikaları', importance: 4),
        PresetTopicSpec('Ülkeler Coğrafyası ve Küresel Örgütler', importance: 5),
        PresetTopicSpec('Doğal Kaynaklar ve Sürdürülebilir Çevre', importance: 4),
      ],
      'Felsefe Grubu': [
        PresetTopicSpec('Felsefe Problemleri', importance: 4),
        PresetTopicSpec('Psikoloji Temel Süreçler', importance: 4),
        PresetTopicSpec('Sosyoloji ve Toplumsal Yapı', importance: 4),
        PresetTopicSpec('Klasik ve Sembolik Mantık', importance: 5),
      ],
      'AYT Din Kültürü': [
        PresetTopicSpec('İslam Düşüncesi, Mezhepler ve Tasavvuf', importance: 4),
        PresetTopicSpec('Yaşayan Dünya Dinleri', importance: 4),
      ],
    },
  ),
  ExamPreset(
    id: 'yds',
    name: 'YDS',
    category: 'Dil',
    subtitle: 'Yabancı Dil Sınavı (Cezasız net kuralı)',
    defaultWrongPenalty: 0.0,
    subjects: {
      'Vocabulary': [
        PresetTopicSpec('Academic Vocabulary (Verbs, Nouns, Adjectives)', importance: 5),
        PresetTopicSpec('Phrasal Verbs & Collocations', importance: 5),
      ],
      'Grammar': [
        PresetTopicSpec('Tenses & Modals', importance: 4),
        PresetTopicSpec('Passive Voice & Causatives', importance: 4),
        PresetTopicSpec('Conditionals & Wish Clauses', importance: 4),
        PresetTopicSpec('Relative & Noun Clauses & Reductions', importance: 5),
        PresetTopicSpec('Prepositions & Conjunctions', importance: 5),
      ],
      'Reading & Skills': [
        PresetTopicSpec('Cloze Test', importance: 4),
        PresetTopicSpec('Sentence Completion', importance: 5),
        PresetTopicSpec('Translation (EN-TR / TR-EN)', importance: 4),
        PresetTopicSpec('Reading Comprehension (Paragraf)', importance: 5),
        PresetTopicSpec('Dialogue Completion', importance: 4),
        PresetTopicSpec('Restatement (Yakın Anlam)', importance: 5),
        PresetTopicSpec('Paragraph Completion', importance: 4),
        PresetTopicSpec('Irrelevant Sentence (Anlamı Bozan)', importance: 4),
      ],
    },
  ),
  ExamPreset(
    id: 'ydt',
    name: 'YDT',
    category: 'Dil',
    subtitle: 'YKS Yabancı Dil Testi (4 yanlış 1 doğru)',
    defaultWrongPenalty: 0.25,
    subjects: {
      'YDT Dil Bilgisi & Kelime': [
        PresetTopicSpec('Vocabulary & Phrasal Verbs', importance: 5),
        PresetTopicSpec('Tenses, Modals & Passives', importance: 4),
        PresetTopicSpec('Prepositions & Conjunctions', importance: 5),
        PresetTopicSpec('Clauses & Reductions', importance: 5),
      ],
      'YDT Okuma & Beceriler': [
        PresetTopicSpec('Cloze Test', importance: 4),
        PresetTopicSpec('Cümle Tamamlama', importance: 5),
        PresetTopicSpec('Paragraf (Reading)', importance: 5),
        PresetTopicSpec('Duruma Uygun İfade', importance: 4),
        PresetTopicSpec('Diyalog Tamamlama', importance: 4),
        PresetTopicSpec('Yakın Anlam (Restatement)', importance: 5),
        PresetTopicSpec('Çeviri (EN-TR / TR-EN)', importance: 4),
        PresetTopicSpec('Paragraf Tamamlama ve Anlamı Bozan', importance: 4),
      ],
    },
  ),
  ExamPreset(
    id: 'dgs',
    name: 'DGS',
    category: 'Akademik',
    subtitle: 'Dikey Geçiş Sınavı (Sayısal & Sözel)',
    defaultWrongPenalty: 0.25,
    subjects: {
      'DGS Sayısal': [
        PresetTopicSpec('Temel Kavramlar, Sayılar ve Bölünebilme', importance: 4),
        PresetTopicSpec('Rasyonel, Üslü, Köklü ve Mutlak Değer', importance: 4),
        PresetTopicSpec('Denklem, Eşitsizlik ve Oran-Orantı', importance: 4),
        PresetTopicSpec('Problemler (Sayı, Kesir, Yüzde, Hareket, Grafik)', importance: 5),
        PresetTopicSpec('Kümeler, Fonksiyonlar ve Olasılık', importance: 4),
        PresetTopicSpec('Sayısal Mantık', importance: 5),
        PresetTopicSpec('Geometri (Üçgen, Dörtgen, Çember, Analitik)', importance: 4),
      ],
      'DGS Sözel': [
        PresetTopicSpec('Sözcükte ve Cümlede Anlam', importance: 4),
        PresetTopicSpec('Paragraf', importance: 5),
        PresetTopicSpec('Sözel Mantık', importance: 5),
      ],
    },
  ),
  ExamPreset(
    id: 'ales',
    name: 'ALES',
    category: 'Akademik',
    subtitle: 'Akademik Personel ve Lisansüstü Eğitimi Sınavı',
    defaultWrongPenalty: 0.25,
    subjects: {
      'ALES Sayısal': [
        PresetTopicSpec('Temel Matematik ve İşlem Yeteneği', importance: 4),
        PresetTopicSpec('Denklem, Eşitsizlik ve Oran-Orantı', importance: 4),
        PresetTopicSpec('Problemler ve Tablo-Grafik Yorumlama', importance: 5),
        PresetTopicSpec('Permütasyon, Kombinasyon ve Olasılık', importance: 4),
        PresetTopicSpec('Sayısal Mantık ve Akıl Yürütme', importance: 5),
        PresetTopicSpec('Geometri', importance: 4),
      ],
      'ALES Sözel': [
        PresetTopicSpec('Cümlede Anlam ve İlişkiler', importance: 4),
        PresetTopicSpec('Paragraf ve Çoklu Paragraf Soruları', importance: 5),
        PresetTopicSpec('Sözel Mantık ve Akıl Yürütme', importance: 5),
      ],
    },
  ),
  // --- TÜRKİYE YÜZYILI MAARİF MODELİ (YENİ MÜFREDAT) ---
  ExamPreset(
    id: 'tyt-maarif',
    name: 'TYT (Maarif Modeli)',
    category: 'Maarif',
    subtitle: 'Türkiye Yüzyılı Maarif Modeli 9-10. Sınıf beceri temelli TYT',
    defaultWrongPenalty: 0.25,
    subjects: {
      'Maarif Türkçe': [
        PresetTopicSpec('Sözcükte ve Cümlede Anlam', importance: 4),
        PresetTopicSpec('Paragraf ve Çoklu Metin Yorumlama', importance: 5),
        PresetTopicSpec('Metin İçi Dil Bilgisi ve Yapı', importance: 4),
        PresetTopicSpec('Ses Bilgisi, Yazım ve Noktalama', importance: 5),
        PresetTopicSpec('Sözcük Türleri ve Cümlenin Ögeleri', importance: 4),
        PresetTopicSpec('Anlatım Özellikleri ve Eleştirel Okuma', importance: 4),
      ],
      'Maarif TYT Matematik': [
        PresetTopicSpec('Sayılar (Gerçek Sayılar, Üslü-Köklü, Aralıklar)', importance: 5),
        PresetTopicSpec('Özdeşlikler ve Cebirsel Modelleme', importance: 4),
        PresetTopicSpec('Nicelikler ve Değişimler (Doğrusal ve Mutlak Değer Fonksiyonları)', importance: 5),
        PresetTopicSpec('Nicelikler ve Değişimler (Karesel, Karekök ve Rasyonel Fonksiyonlar)', importance: 5),
        PresetTopicSpec('Algoritma ve Bilişim (Mantık Bağlaçları ve Algoritmik Problemler)', importance: 4),
        PresetTopicSpec('Sayma Kuralları, Permütasyon, Kombinasyon ve Olasılık', importance: 5),
        PresetTopicSpec('İstatistiksel Araştırma Süreci ve Veriden Olasılığa', importance: 4),
        PresetTopicSpec('Gerçek Yaşam ve Modelleme Problemleri', importance: 5),
      ],
      'Maarif TYT Geometri': [
        PresetTopicSpec('Geometrik Şekiller (Üçgende Açı ve Kenar İlişkileri)', importance: 4),
        PresetTopicSpec('Eşlik, Benzerlik ve Geometrik Dönüşümler (Yansıma, Öteleme, Dönme)', importance: 5),
        PresetTopicSpec('Çokgenler ve Özel Dörtgenler', importance: 4),
        PresetTopicSpec('Analitik İnceleme (Nokta ve Doğru)', importance: 5),
      ],
      'Maarif TYT Fizik': [
        PresetTopicSpec('Fizik Bilimi ve Kariyer Keşfi', importance: 3),
        PresetTopicSpec('Kuvvet ve Hareket (9-10. Sınıf)', importance: 5),
        PresetTopicSpec('Akışkanlar (Basınç ve Kaldırma Kuvveti)', importance: 5),
        PresetTopicSpec('Enerji (İş, Güç, Isı ve Sıcaklık)', importance: 5),
        PresetTopicSpec('Elektrik (Devreler ve Akım)', importance: 5),
        PresetTopicSpec('Dalgalar (Temel Dalga Özellikleri)', importance: 4),
      ],
      'Maarif TYT Kimya': [
        PresetTopicSpec('Etkileşim: Kimya Hayattır ve Güvenlik', importance: 3),
        PresetTopicSpec('Etkileşim: Atomdan Periyodik Tabloya ve Türler Arası Etkileşimler', importance: 5),
        PresetTopicSpec('Çeşitlilik: Maddenin Halleri ve Karışımlar', importance: 4),
        PresetTopicSpec('Çeşitlilik: Mol Kavramı, Tepkimeler ve Kimyasal Hesaplamalar', importance: 5),
        PresetTopicSpec('Sürdürülebilirlik: Asit-Baz, Su, Çevre ve Yeşil Kimya', importance: 4),
      ],
      'Maarif TYT Biyoloji': [
        PresetTopicSpec('Yaşam (Canlıların Ortak Özellikleri ve Biyolojik Moleküller)', importance: 4),
        PresetTopicSpec('Organizasyon (Hücre, Organeller ve Madde Geçişleri)', importance: 5),
        PresetTopicSpec('Canlılar Dünyası ve Biyoçeşitlilik', importance: 4),
        PresetTopicSpec('Enerji Dönüşümleri ve Hücre Bölünmeleri (Mitoz-Mayoz)', importance: 5),
        PresetTopicSpec('Kalıtım ve Ekosistem Ekolojisi', importance: 5),
      ],
      'Maarif TYT Tarih': [
        PresetTopicSpec('Geçmişin İnşa Sürecinde Tarih', importance: 3),
        PresetTopicSpec('Eski Çağ Medeniyetleri', importance: 4),
        PresetTopicSpec('Orta Çağ Medeniyetleri', importance: 4),
        PresetTopicSpec('Türkistan\'dan Türkiye\'ye (1040-1299)', importance: 5),
        PresetTopicSpec('Beylikten Devlete Osmanlı (1299-1453)', importance: 4),
        PresetTopicSpec('Cihan Devleti Osmanlı (1453-1683)', importance: 5),
      ],
      'Maarif TYT Coğrafya': [
        PresetTopicSpec('Coğrafyanın Doğası', importance: 3),
        PresetTopicSpec('Mekânsal Bilgi Teknolojileri ve Harita Okuryazarlığı', importance: 5),
        PresetTopicSpec('Doğal Sistemler ve Süreçler (İklim ve Yer Şekilleri)', importance: 5),
        PresetTopicSpec('Beşerî Sistemler ve Süreçler (Nüfus ve Demografik Dönüşüm)', importance: 5),
        PresetTopicSpec('Ekonomik Faaliyetler ve Etkileri', importance: 4),
        PresetTopicSpec('Afetler ve Sürdürülebilir Çevre', importance: 4),
        PresetTopicSpec('Bölgeler, Ülkeler ve Küresel Bağlantılar', importance: 4),
      ],
      'Maarif TYT Felsefe': [
        PresetTopicSpec('Felsefeyi Tanıma ve Düşünme-Akıl Yürütme', importance: 4),
        PresetTopicSpec('Bilgi, Varlık ve Değer Felsefesi', importance: 4),
        PresetTopicSpec('Bilim, Siyaset, Din ve Sanat Felsefesi', importance: 4),
      ],
      'Maarif TYT Din Kültürü': [
        PresetTopicSpec('İnanç, İbadet ve Değerler', importance: 4),
        PresetTopicSpec('Hz. Muhammed ve İslam Düşüncesi', importance: 4),
      ],
    },
  ),
  ExamPreset(
    id: 'ayt-sayisal-maarif',
    name: 'AYT Sayısal (Maarif Modeli)',
    category: 'Maarif',
    subtitle: '11-12. Sınıf Maarif (İntegralsiz: Değişimin Matematiği, Limit-Türev)',
    defaultWrongPenalty: 0.25,
    subjects: {
      'Maarif AYT Matematik': [
        PresetTopicSpec('Nicelikler ve Değişimler: Trigonometrik Fonksiyonlar', importance: 5),
        PresetTopicSpec('Nicelikler ve Değişimler: Üstel ve Logaritmik Fonksiyonlar', importance: 5),
        PresetTopicSpec('Nicelikler ve Değişimler: Polinom ve Rasyonel Fonksiyon Sistemleri', importance: 5),
        PresetTopicSpec('İstatistik ve Veriden Olasılığa (Koşullu Olasılık)', importance: 4),
        PresetTopicSpec('Değişimin Matematiği 1: Limit, Belirsizlik ve Süreklilik', importance: 5),
        PresetTopicSpec('Değişimin Matematiği 2: Türev Tanımı ve Türev Kuralları', importance: 5),
        PresetTopicSpec('Değişimin Matematiği 3: Türev Uygulamaları ve Optimizasyon', importance: 5),
        PresetTopicSpec('Hazır Veriler Üzerinde Çalışma ve Modelleme', importance: 4),
      ],
      'Maarif AYT Geometri': [
        PresetTopicSpec('Çember, Daire ve Geometrik Yer Uygulamaları', importance: 5),
        PresetTopicSpec('Çemberin Analitik İncelenmesi', importance: 5),
        PresetTopicSpec('Geometrik Cisimler (Prizma, Silindir, Piramit, Koni, Küre)', importance: 4),
      ],
      'Maarif AYT Fizik': [
        PresetTopicSpec('Kuvvet ve Hareket (11-12: Vektör, İtme-Momentum, Çembersel, Basit Harmonik)', importance: 5),
        PresetTopicSpec('Elektrik ve Manyetizma (Alan, Potansiyel, İndüksiyon, AC)', importance: 5),
        PresetTopicSpec('Optik (11. Sınıf Maarif)', importance: 5),
        PresetTopicSpec('Enerji ve Dalgalar (Dalga Mekaniği ve Elektromanyetik Dalgalar)', importance: 5),
        PresetTopicSpec('Madde ve Doğası (Atom Fiziği ve Modern Fizik)', importance: 5),
      ],
      'Maarif AYT Kimya': [
        PresetTopicSpec('Etkileşim: Modern Atom Teorisi ve Gazlar', importance: 5),
        PresetTopicSpec('Çeşitlilik: Sıvı Çözeltiler ve Çözünürlük', importance: 5),
        PresetTopicSpec('Etkileşim: Kimyasal Enerji, Hız ve Kimyasal Denge', importance: 5),
        PresetTopicSpec('Sürdürülebilirlik: Asit-Baz Dengeleri ve Elektrokimya', importance: 5),
        PresetTopicSpec('Çeşitlilik: Karbon Kimyası ve Organik Bileşikler', importance: 5),
      ],
      'Maarif AYT Biyoloji': [
        PresetTopicSpec('İnsan Fizyolojisi: Sinir, Endokrin ve Duyu Sistemleri', importance: 5),
        PresetTopicSpec('İnsan Fizyolojisi: Destek-Hareket, Sindirim, Dolaşım, Solunum, Boşaltım', importance: 5),
        PresetTopicSpec('Genden Proteine ve Biyoteknoloji', importance: 5),
        PresetTopicSpec('Canlılarda Enerji Dönüşümleri (Fotosentez, Kemosentez, Solunum)', importance: 5),
        PresetTopicSpec('Bitki Biyolojisi ve Komünite-Popülasyon Ekolojisi', importance: 5),
      ],
    },
  ),
  ExamPreset(
    id: 'ayt-ea-maarif',
    name: 'AYT Eşit Ağırlık (Maarif Modeli)',
    category: 'Maarif',
    subtitle: 'Maarif AYT Matematik, Tema Odaklı Edebiyat, Tarih-1 ve Coğrafya-1',
    defaultWrongPenalty: 0.25,
    subjects: {
      'Maarif AYT Matematik': [
        PresetTopicSpec('Nicelikler ve Değişimler: Trigonometrik Fonksiyonlar', importance: 5),
        PresetTopicSpec('Nicelikler ve Değişimler: Üstel ve Logaritmik Fonksiyonlar', importance: 5),
        PresetTopicSpec('Nicelikler ve Değişimler: Polinom ve Rasyonel Fonksiyon Sistemleri', importance: 5),
        PresetTopicSpec('İstatistik ve Koşullu Olasılık', importance: 4),
        PresetTopicSpec('Değişimin Matematiği 1: Limit ve Süreklilik', importance: 5),
        PresetTopicSpec('Değişimin Matematiği 2-3: Türev ve Gerçek Yaşam Uygulamaları', importance: 5),
      ],
      'Maarif Edebiyat': [
        PresetTopicSpec('Sözün İnceliği ve Anlam Arayışı (Şiir, Deneme, Hikâye)', importance: 4),
        PresetTopicSpec('Sözün Ezgisi (İslamiyet Öncesi, Halk Edebiyatı, Masal)', importance: 5),
        PresetTopicSpec('Kelimelerin Ritmi (Divan Edebiyatı ve Saf Şiir)', importance: 5),
        PresetTopicSpec('Dünden Bugüne (Destan, Mesnevi, Halk Hikâyeleri)', importance: 4),
        PresetTopicSpec('Nesillerin Mirası (Dede Korkut, Tanzimat ve Millî Edebiyat)', importance: 5),
        PresetTopicSpec('Cumhuriyet Dönemi Şiir, Roman, Tiyatro ve Edebi Akımlar', importance: 5),
      ],
      'Maarif Tarih-1': [
        PresetTopicSpec('Türkistan\'dan Türkiye\'ye ve Beylikten Devlete Osmanlı', importance: 4),
        PresetTopicSpec('Cihan Devleti Osmanlı (1453-1683)', importance: 5),
        PresetTopicSpec('Değişen Dünyada Osmanlı (1683-1789)', importance: 4),
        PresetTopicSpec('Dönüşüm Sürecinde ve Savaşlar Sarmalında Osmanlı (1789-1918)', importance: 5),
        PresetTopicSpec('Modern Türk Devletinin Doğuşu ve Türk İnkılabı', importance: 5),
      ],
      'Maarif Coğrafya-1': [
        PresetTopicSpec('Doğal Sistemler, Biyoçeşitlilik ve İklim Değişikliği', importance: 4),
        PresetTopicSpec('Beşerî Sistemler ve Nüfus Politikaları', importance: 4),
        PresetTopicSpec('Mekânsal Sentez: Türkiye Ekonomisi ve Kalkınma Projeleri', importance: 5),
        PresetTopicSpec('Küresel Ortam: Uluslararası Ticaret ve Bölgeler', importance: 4),
      ],
    },
  ),
  ExamPreset(
    id: 'ayt-sozel-maarif',
    name: 'AYT Sözel (Maarif Modeli)',
    category: 'Maarif',
    subtitle: 'Tema Odaklı Edebiyat, Maarif Tarih 1-2, Coğrafya 1-2 ve Felsefe Grubu',
    defaultWrongPenalty: 0.25,
    subjects: {
      'Maarif Edebiyat': [
        PresetTopicSpec('Sözün İnceliği ve Dilin Zenginliği (Metin Türleri)', importance: 4),
        PresetTopicSpec('Sözün Ezgisi ve Kelimelerin Ritmi (Halk ve Divan Edebiyatı)', importance: 5),
        PresetTopicSpec('Dünden Bugüne ve Nesillerin Mirası (Tanzimat-Millî Edebiyat)', importance: 5),
        PresetTopicSpec('Cumhuriyet Dönemi Şiir, Roman, Hikâye ve Dünya Edebiyatı', importance: 5),
      ],
      'Maarif Tarih 1-2': [
        PresetTopicSpec('Eski Çağ ve Orta Çağ Medeniyetleri', importance: 4),
        PresetTopicSpec('Cihan Devleti ve Değişen Dünyada Osmanlı (1453-1789)', importance: 5),
        PresetTopicSpec('Dönüşüm ve Savaşlar Sarmalında Osmanlı (1789-1918)', importance: 5),
        PresetTopicSpec('Modern Türk Devletinin Doğuşu ve Türk İnkılabı', importance: 5),
        PresetTopicSpec('II. Dünya Savaşı\'ndan Küreselleşme Sürecine Türkiye ve Dünya', importance: 5),
      ],
      'Maarif Coğrafya 1-2': [
        PresetTopicSpec('Doğal Sistemler, Ekosistemler ve Afet Yönetimi', importance: 4),
        PresetTopicSpec('Türkiye\'nin Mekânsal Sentezi ve Ekonomik Politikaları', importance: 5),
        PresetTopicSpec('Küresel Bağlantılar, Jeopolitik Konum ve Uluslararası Örgütler', importance: 5),
        PresetTopicSpec('Sürdürülebilir Çevre ve Küresel İklim Krizi', importance: 4),
      ],
      'Maarif Felsefe Grubu': [
        PresetTopicSpec('Felsefe Problemleri ve Kavramsal Analiz', importance: 4),
        PresetTopicSpec('Psikoloji Temel Süreçleri', importance: 4),
        PresetTopicSpec('Sosyoloji ve Toplumsal Değişim', importance: 4),
        PresetTopicSpec('Klasik ve Sembolik Mantık', importance: 5),
      ],
      'Maarif Din Kültürü': [
        PresetTopicSpec('İslam Düşüncesinde Yorumlar ve Bilim Geleneği', importance: 4),
        PresetTopicSpec('Yaşayan Dünya Dinleri ve Değerler', importance: 4),
      ],
    },
  ),
];
