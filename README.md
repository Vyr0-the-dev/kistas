<div align="center">

<img src="assets/images/app_icon.png" alt="Kıstas" width="112">

# Kıstas

*Sınav takibi ve çalışma planlaması için yapay zeka destekli Android uygulaması.*

[![Lisans: MIT](https://img.shields.io/badge/Lisans-MIT-green)][license]
![Flutter 3.44](https://img.shields.io/badge/Flutter-3.44-02569B?logo=flutter&logoColor=white)
![Dart 3.10](https://img.shields.io/badge/Dart-3.10-0175C2?logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)
![Sürüm 1.0.1](https://img.shields.io/badge/Sürüm-1.0.1-blue)

![Isar](https://img.shields.io/badge/DB-Isar-1B1B2F?logo=isar&logoColor=white)
![Gemini AI](https://img.shields.io/badge/AI-Gemini-88619A)
![Local-first](https://img.shields.io/badge/Veri-Local--first-303030)

</div>

<p align="center" style="border-bottom: 3px solid #7c5cff; width: 100%;"></p>

KPSS adaylarına yönelik; soru çözümlerini ders ve konu bazında kaydeden, performansı grafiklerle analiz eden ve Gemini yapay zekasıyla kişisel çalışma önerileri üreten bir sınav takip uygulamasıdır.

Flutter ile geliştirilmiş olup Android cihazlarda çalışır. Koyu glassmorphism arayüz, 10 renk teması ve tamamen cihaz içi veri saklama ile tasarlanmıştır.

---

<p style="border-left: 4px solid #7c5cff; padding-left: 12px; font-size: 20px; font-weight: 700; margin-bottom: 8px;">Özellikler</p>

<table align="center">
  <tr>
    <td width="50%" align="left">
      <b>📚 Soru takibi</b><br>
      <span style="color: #888;">Ders ve konu bazında soru girişi, hızlı ekleme, deneme ve net kaydı.</span>
    </td>
    <td width="50%" align="left">
      <b>📈 Analiz</b><br>
      <span style="color: #888;">Haftalık ve aylık trend grafikleri, net ortalaması, doğruluk takibi.</span>
    </td>
  </tr>
  <tr>
    <td width="50%" align="left">
      <b>✨ Gemini AI</b><br>
      <span style="color: #888;">Zayıf konu analizi, hedef önerileri, haftalık çalışma bülteni.</span>
    </td>
    <td width="50%" align="left">
      <b>⏱️ Odak araçları</b><br>
      <span style="color: #888;">Pomodoro zamanlayıcı, çalışma serisi, ısı haritası, rozetler.</span>
    </td>
  </tr>
  <tr>
    <td width="50%" align="left">
      <b>🔔 Bildirimler</b><br>
      <span style="color: #888;">Günlük hedef hatırlatıcıları ve haftalık plan bildirimleri.</span>
    </td>
    <td width="50%" align="left">
      <b>🎨 Tema</b><br>
      <span style="color: #888;">10 renk teması, koyu glassmorphism tasarım.</span>
    </td>
  </tr>
  <tr>
    <td width="50%" align="left">
      <b>💾 Veri</b><br>
      <span style="color: #888;">Isar yerel veritabanı, JSON yedekleme ve dışa aktarma.</span>
    </td>
    <td width="50%" align="left">
      <b>🔒 Gizlilik</b><br>
      <span style="color: #888;">Tüm veriler cihazda saklanır; buluta veri gönderilmez.</span>
    </td>
  </tr>
</table>

---

<p style="border-left: 4px solid #7c5cff; padding-left: 12px; font-size: 20px; font-weight: 700; margin-bottom: 8px;">Ekran Görüntüleri</p>

<div align="center">

| Ana ekran | Konular | Hızlı ekle | Analiz |
|:---------:|:-------:|:----------:|:------:|
| <img src="screenshots/ana_ekran.png" width="210"> | <img src="screenshots/konular.png" width="210"> | <img src="screenshots/hizli_ekle.png" width="210"> | <img src="screenshots/analiz.png" width="210"> |

</div>

---

<p style="border-left: 4px solid #7c5cff; padding-left: 12px; font-size: 20px; font-weight: 700; margin-bottom: 8px;">Teknolojiler</p>

| Kategori | Paketler |
|---|---|
| Veritabanı | [Isar](https://isar.dev) |
| Yapay zeka | Gemini API |
| Bildirimler | flutter_local_notifications, timezone |
| Depolama | path_provider, shared_preferences, file_picker |
| Arayüz | google_fonts, flutter_svg, flutter_animate |
| Diğer | http, share_plus, image_picker, url_launcher, package_info_plus |

---

<p style="border-left: 4px solid #7c5cff; padding-left: 12px; font-size: 20px; font-weight: 700; margin-bottom: 8px;">Başlangıç</p>

**Gereksinimler:** [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.44 veya üzeri (Dart 3.10+)

```bash
# 1. Bağımlılıkları kur
flutter pub get

# 2. Geliştirme modunda çalıştır
flutter run

# 3. Testleri çalıştır
flutter test

# 4. Release APK üret
flutter build apk --release
```

Çıktılar `build/app/outputs/` altında yer alır.

> **Gemini AI:** AI özellikleri için [Google AI Studio](https://aistudio.google.com/apikey)'dan ücretsiz bir API anahtarı alın ve uygulamanın **Profil** sekmesinden girin. Anahtar yalnızca cihazda saklanır, kaynak kodda yer almaz.

---

<p style="border-left: 4px solid #7c5cff; padding-left: 12px; font-size: 20px; font-weight: 700; margin-bottom: 8px;">Ortam Değişkenleri</p>

Bu projede `.env` dosyası kullanılmaz. Uygulama yapılandırması (tema ve API anahtarı) uygulama içi ayarlardan yönetilir; API anahtarı kullanıcı tarafından **Profil** sekmesinde girilir ve cihazda tutulur.

---

<p style="border-left: 4px solid #7c5cff; padding-left: 12px; font-size: 20px; font-weight: 700; margin-bottom: 8px;">Proje Yapısı</p>

<details>
<summary>lib/ dizin ağacı</summary>

```text
lib/
├── core/
│   ├── data/          # Isar veritabanı, entity'ler, konu kataloğu
│   ├── models/        # Alan modelleri
│   ├── repositories/  # Durum ve iş mantığı
│   ├── services/      # Gemini istemcisi, bildirim servisi
│   ├── theme/         # Renk paletleri, tema sistemi
│   └── widgets/       # Ortak bileşenler
└── features/
    ├── dashboard/     # Ana ekran, yol haritası, streak
    ├── questions/     # Sihirbaz, hızlı ekle, flashcard, zamanlayıcı
    ├── analysis/      # Analiz ekranı
    ├── mistakes/      # Yanlışlar galerisi ve çözüm
    └── settings/      # Profil ve ayarlar
```

</details>

---

<div align="center">

## Lisans

[MIT](LICENSE) — © 2026 Vyr0

</div>

[license]: LICENSE
