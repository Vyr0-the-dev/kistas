# Analiz Ekranı — Kodlamaya Uygun Analiz

## 1) Görsel Hiyerarşi ve Bölümler
1. Üst Bar
   - Sol: Geri ok ikonu
   - Başlık: “Performans Analizi”
   - Sağ: Paylaş ikonu
2. Zaman Aralığı Seçimi
   - Sekmeler: 7 Gün, 30 Gün (aktif), 90 Gün, Özel
   - Cam panel görünümü, seçili sekme dolu
3. Ana Metrik Kartı (Net Gidişatı)
   - Başlık: “Genel Net Gidişatı”
   - Büyük değer: “72.5 Net”
   - Rozet: “+2.1%” (yeşil)
   - Altında çizgi grafik (mor degrade + çizgi)
   - X ekseni: H1, H2, H3, H4
4. İkili Kartlar
   - Doğruluk Oranı: %84 + düşüş bilgisi (turuncu)
   - Soru Temposu: 145 + küçük bar grafik
5. Dikkat Gerektiren Konular
   - Başlık + “Tümünü Gör” bağlantısı
   - Liste satırları: konu adı, ders, çözülen, doğruluk yüzdesi ve aksiyon butonu
   - Örnek aksiyonlar: “Çalış”, “Planla”
6. Veri Yok Durumu
   - Sayfa ortasında boş durum kartı
   - İkonlu illüstrasyon (grafik + küçük kart)
   - Başlık: “Henüz Veri Yok”
   - Açıklama: “Önce 3 deneme ekle — trendleri çıkarmak için buradan takip et.”
7. Alt Navigasyon
   - Sıra: Panel, Konular, (Yıldırım), Analiz (aktif), Profil
   - Ortadaki ikon yıldırım olmalı (artı değil)

## 2) Kodlamaya Uygun Bileşen Haritası (Flutter)
- `AnalysisHeader`
  - `Row`: geri butonu + başlık + paylaş butonu
- `TimeRangeTabs`
  - `Container` içinde 4 `ChoiceChip` veya custom segment
- `NetTrendCard`
  - Büyük metrik + rozet + çizgi grafik (CustomPaint)
- `AccuracyCard`
  - %84 + düşüş metni + mini sparkline
- `TempoCard`
  - 145 + bar chart (Container dizisi)
- `WeakTopicsCard`
  - Liste satırları + CTA butonları
- `EmptyState`
  - Ortalanmış kart: ikon + başlık
  - Görsel: grafik ikonu + küçük kart birleşimi
- `BottomNav`
  - Panel, Konular, Yıldırım (FAB), Analiz (aktif), Profil

## 3) Renk ve Tipografi
- Arka plan: çok koyu (#0A0A0C)
- Kartlar: koyu (#131117)
- Aksan: mor (#6020DF)
- İkincil: mor açık (#8A5AE8)
- Yeşil vurgu: artış rozetleri
- Turuncu/mercana yakın: düşüş bilgileri
- Tipografi: Space Grotesk

## 4) Kodlama İçin Prompt (Flutter Uygulama Üretimi)
Koyu temalı “Analiz” ekranı tasarla. Üstte geri ok butonu, başlık “Performans Analizi” ve sağda paylaş ikonu olsun. Altında cam panel görünümlü zaman aralığı sekmeleri: 7 Gün, 30 Gün (aktif), 90 Gün, Özel.

Eğer veri yoksa ekran ortasında bir boş durum kartı göster: üstte ikonlu illüstrasyon (grafik ikonu + küçük kart), başlık “Henüz Veri Yok”

Veri varsa ana metrik kartı: başlık “Genel Net Gidişatı”, büyük değer “72.5 Net”, yanında yeşil “+2.1%” rozeti. Kart içinde mor degrade alan ve çizgi grafik yer alsın; x ekseninde H1–H4 etiketleri olsun.

Altında iki kart: “Doğruluk Oranı” (%84, turuncu düşüş metni ve küçük sparkline), “Soru Temposu” (145 ve küçük bar grafik). Son bölümde “Dikkat Gerektiren Konular” listesi: her satırda konu adı, ders, çözülen sayısı, doğruluk yüzdesi ve aksiyon butonu (Çalış/Planla).

Alt navigasyon sırası Panel, Konular, Yıldırım (FAB), Analiz (aktif), Profil. Ortadaki ikon artı değil, yıldırım olmalı. Koyu tema, yüksek kontrast, Space Grotesk tipografi ve yumuşak gölgeler kullan.
