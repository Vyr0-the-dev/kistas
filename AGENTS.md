# Road to ATC - Agent Kuralları

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
