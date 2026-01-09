# Soru/Deneme Ekle Ekranı — Kodlamaya Uygun Analiz

## 1) Ortak Görsel Hiyerarşi
1. Üst Bar
   - Sol: kapat (X)
   - Orta: ekran başlığı
   - Sağ: “Temizle”
2. İlerleme Adımları
   - 4 adım barı (1. adım aktif, diğerleri pasif)
3. Adım Kartları
   - Adım 1: Ders seç (kart grid)
   - Adım 2: Konu belirle (arama + çipler)
   - Adım 3: Sonuçlar (doğru/yanlış/boş + süre)
   - Adım 4: Detaylar (opsiyonel)
4. Alt Aksiyonlar
   - Birincil: “Kaydet”
   - İkincil: “Kaydet ve Bir Tane Daha Ekle”
5. Alt Navigasyon
   - Sıra: Panel, Ekle (aktif), Konular, Analiz
   - Ortadaki ikon yıldırım olmalı (artı değil)

## 2) Soru Ekle Varyantı (Mevcut Ekran)
- Başlık: “Soru Kaydı”
- Adım 1: Ders seç (Matematik, Türkçe, Tarih, Coğrafya, Hava Trafik, Diğer)
- Adım 2: Konu belirle (arama + son kullanılan çipler)
- Adım 3: Sonuçlar (Doğru, Yanlış, Boş + Süre)
- Adım 4: Detaylar
  - Zorluk seviyesi kaydırıcı
  - Notlar alanı

## 3) Deneme Ekle Varyantı (Aynı Şablon, Farklı İçerik)
- Başlık: “Deneme Kaydı”
- Adım 1: Deneme türü seç (Genel Deneme, Türkiye Geneli, Branş Denemesi vb.)
- Adım 2: Tarih seç (takvim alanı, elle yazım yok)
- Adım 3: Sonuçlar (Doğru, Yanlış, Boş + Net + Süre)
- Adım 4: Detaylar
  - Notlar (ders dağılımı / kısa analiz)

## 4) Kodlamaya Uygun Bileşen Haritası (Flutter)
- `AddEntryHeader`
  - Kapat + Başlık + Temizle
- `StepProgress`
  - 4 segment bar
- `StepSection`
  - Başlık + içerik
- `SubjectGrid` (Soru)
- `ExamTypeGrid` (Deneme)
- `TopicSearch` (Soru)
- `DatePickerField` (Deneme)
- `ResultsCounter`
  - Doğru / Yanlış / Boş
- `DurationPicker`
  - Süre seçimi
- `OptionalDetails`
  - Zorluk (Soru)
  - Notlar (Soru/Deneme)
- `BottomActions`
  - Kaydet + Kaydet ve Bir Tane Daha
- `BottomNav`
  - Panel, Ekle (aktif), Konular, Analiz
  - Ortada yıldırım FAB

## 5) Renk ve Tipografi
- Arka plan: çok koyu (#0A0A0C)
- Kartlar: koyu yüzey (#161022)
- Aksan: mor (#5B13EC)
- Tipografi: Space Grotesk + Noto Sans

## 6) Kodlama İçin Prompt (Flutter Uygulama Üretimi)
Koyu temalı çok adımlı bir “Ekle” ekranı tasarla. Üstte kapat (X), ortada başlık, sağda “Temizle” olsun. Altında 4 adımlı ilerleme barı göster. Ekran iki varyantta çalışacak:

### Soru Ekle Varyantı
- Başlık: “Soru Kaydı”
- Adım 1: Ders seç (kart grid)
- Adım 2: Konu belirle (arama + son kullanılan çipler)
- Adım 3: Sonuçlar (Doğru/Yanlış/Boş sayaçları + Süre)
- Adım 4: Detaylar (Zorluk kaydırıcı + Notlar)

### Deneme Ekle Varyantı
- Başlık: “Deneme Kaydı”
- Adım 1: Deneme türü seç (kart grid)
- Adım 2: Tarih seç (takvim alanı, elle yazım yok)
- Adım 3: Sonuçlar (Doğru/Yanlış/Boş + Net + Süre)
- Adım 4: Detaylar (Notlar + ders dağılımı)

Alt aksiyonlar sabit: büyük birincil “Kaydet” butonu ve altında “Kaydet ve Bir Tane Daha Ekle”. Alt navigasyon sırası Panel, Ekle (aktif), Konular, Analiz. Ortadaki ikon artı değil, yıldırım olmalı. Koyu tema, yumuşak gölge, yüksek kontrast, Space Grotesk/Noto Sans tipografi kullan.
