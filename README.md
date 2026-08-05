<p align="center">
  <img src="assets/images/app_icon.png" alt="Kıstas" width="120">
</p>

<h1 align="center">Kıstas</h1>

<p align="center">
  <b>KPSS P3 (ATC) adayları için yapay zeka destekli sınav takip ve çalışma planlama uygulaması</b>
  <br>
  Flutter ile geliştirilmiş, koyu temalı, glassmorphism arayüzlü mobil uygulama
</p>

<p align="center">
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white">
  <img alt="Dart" src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white">
  <img alt="License" src="https://img.shields.io/badge/License-MIT-yellow">
  <img alt="Platform" src="https://img.shields.io/badge/Platform-Android-3DDC84">
</p>

---

## 🎯 Nedir?

Kıstas, KPSS Lisans (P3 / ATC) hazırlık sürecini **gündelik takip** haline getiren bir uygulamadır:

- Çözdüğünüz soruları ders ve konu bazında kaydedin
- Denemelerdeki net ve süre performansınızı görün
- Gemini AI ile kişisel çalışma programı ve hedef önerileri alın
- Zayıf konularınızı AI analiziyle tespit edin
- Streak, rozet ve hatırlatıcılarla motivasyonunuzu yüksek tutun

## ✨ Özellikler

| Alan | Özellikler |
|---|---|
| 📝 **Soru Takibi** | 4 adımlı soru sihirbazı, hızlı ekleme, konu bazlı kayıt |
| 📊 **Analiz** | Haftalık/aylık trend grafikleri, son 10 deneme kıyaslama, net ortalaması |
| 🧠 **Gemini AI** | AI Mentor, AI Hedefler, Soru Avcısı, Sınav Stratejisti, haftalık bülten |
| ⏱️ **Odak** | Pomodoro zamanlayıcı, çalışma serisi (streak) ve ısı haritası |
| 🔔 **Bildirimler** | Günlük hedef hatırlatıcısı, haftalık plan bildirimi, yanlış tekrar hatırlatması |
| 🎨 **Tasarım** | Koyu tema, 10 renk teması, glassmorphism kartlar, animasyonlu splash |
| 💾 **Veri** | Yerel veritabanı (Isar), JSON yedekleme/dışa aktarma |

## 🖼️ Ekran Görüntüleri

Ekran görüntüleri uygulamanın kendisinden alınabilir. Arayüz görselleri `assets/images/` altında yer alır.

## 🚀 Kurulum

Gereksinimler: [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart 3.x)

```bash
# Bağımlılıkları yükle
flutter pub get

# Uygulamayı çalıştır
flutter run

# Testleri çalıştır
flutter test
```

### Gemini AI Kurulumu

Uygulama, Gemini API anahtarını **uygulama içinde** (Profil > Gemini) girmenizi ister; anahtar yalnızca cihazınızda saklanır, kaynak kodda yer almaz.

1. [Google AI Studio](https://aistudio.google.com/apikey)'dan ücretsiz bir API anahtarı alın
2. Uygulamada **Profil** sekmesinden anahtarı yapıştırın ve bir model seçin
3. AI özellikleri (mentor, hedef, analiz) hazır

## 📁 Proje Yapısı

```
lib/
├── core/
│   ├── data/          # Isar veritabanı, entity'ler, konu kataloğu
│   ├── models/        # Alan modelleri
│   ├── repositories/  # AppRepository (durum + iş mantığı)
│   ├── services/      # Gemini client, bildirim servisi
│   ├── theme/         # Renk paletleri, tema sistemi
│   └── widgets/       # Ortak bileşenler (glass panel, progress ring...)
└── features/
    ├── dashboard/     # Ana ekran, yol haritası, streak
    ├── questions/     # Sihirbaz, hızlı ekle, flashcard, zamanlayıcı
    ├── analysis/      # Analiz ekranı
    ├── mistakes/      # Yanlışlar galerisi ve çözüm
    └── settings/      # Profil ve ayarlar
```

## 🤝 Katkı

1. Repoyu fork edin
2. Yeni bir dal oluşturun (`git checkout -b feature/ozellik`)
3. Değişikliklerinizi commit edin
4. Pull request açın

## 📄 Lisans

Bu proje [MIT](LICENSE) lisansı ile lisanslanmıştır.

---

<p align="center">Türkiye'nin sınav yolculuğunda <b>Kıstas</b> ile istikrarlı kalın. 🇹🇷</p>
