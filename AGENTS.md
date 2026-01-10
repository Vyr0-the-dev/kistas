# Kıstas - Agent Kuralları

## Amac
Bu repo sadece Android odaklı Flutter uygulamasıdır. Amaç, KPSS P3 (ATC) adaylarına
gündelik takip ve planlama kolaylığı sağlayan, koyu temalı ve hızlı bir uygulama sunmaktır.

## Calisma Prensipleri
- Mock veri kullanma. Veriler doğru ve gerçek kaynaklara dayanmalı.
- Türkçe içerik ve Türkçe karakter kullan.
- Tema koyu ve kontrastlı; kartlar ve aksan renkleriyle hiyerarşi kur.
- Tarih alanları elle yazılmaz, tarih seçici ile doldurulur.
- Konu listesi filtrelenebilir olmalı (arama + ders filtresi).
- Tasarım kararlarında internetten görsel referanslardan ilham al.

## MCP (Model Context Protocol) Yapılandırması
Bu proje için aşağıdaki MCP sunucularının aktif edilmesi önerilir:
- **Google Search MCP:** Güncel paket sürümleri ve Android standartları için.
- **Memory MCP:** Kullanıcı tercihlerini ve stil seçimlerini hatırlamak için.
- **Sequential Thinking MCP:** Mimari değişikliklerde adım adım güvenli ilerlemek için.
- **Filesystem MCP:** Dosya manipülasyonu ve asset yönetimi için.

## Context7 - Gelişmiş Ajan Kuralları
1. **Zihin Haritası:** Her büyük değişiklikten önce mimari bir plan sun.
2. **Hata Yakalama:** Native hataları (Gradle, Kotlin) anında analiz et ve çözüm üret.
3. **Kullanıcı Kontrolü:** Flutter komutlarını (`pub get`, `run`, `icons`) asla kendin çalıştırma, kullanıcıya bırak.
4. **Stil Sadakati:** Mevcut "Glassmorphism" ve koyu tema standartlarını her yeni bileşende koru.
5. **Veri Güvenliği:** API anahtarlarını asla loglama veya açıkça paylaşma.
6. **Dosya Düzeni:** Klasör yapısını (`core`, `features`, `models`) bozma, yeni eklemeleri uygun yere yap.
7. **Dil:** Uygulama içi içeriklerde ve kullanıcı etkileşiminde her zaman Türkçe kullan.

## Komutlar (Tercih Edilen)
- Flutter:
  - `flutter test`
  - `flutter run -d <device-id>`
  - `flutter doctor -v`
- Android cihaz (Docker icinden):
  - `ADB_SERVER_SOCKET=tcp:host.docker.internal:5037 adb devices -l`
  - `ADB_SERVER_SOCKET=tcp:host.docker.internal:5037 flutter run -d <device-id>`

## Dizinler
- Uygulama kodu: `lib/`
- Android ayarlari: `android/`
- Temalar: `lib/theme/`
- Ekranlar: `lib/screens/`

## Tasarım Dilinin Özeti
- Koyu arka plan (AppColors.sand/mist)
- Kartlar koyu ve sınırlı (AppColors.card/line)
- Metinlerde yüksek kontrast (AppColors.ink/muted)

## Yeni İşler
Yeni ekran eklerken:
- Erişilebilirlik kontrastını koru.
- Çok uzun listelerde filtre/arama sağla.
- Tarih ve sayısal girişleri uygun kontrolle sun.
