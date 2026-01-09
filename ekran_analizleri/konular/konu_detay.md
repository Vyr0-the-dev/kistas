# Konu Detay Ekranı — Kodlamaya Uygun Analiz

## 1) Görsel Hiyerarşi ve Bölümler
1. Üst Bar
   - Sol: geri ok
   - Orta: ders adı (ör. “Matematik”)
   - Sağ: daha fazla menü (…)
2. Hero Bölümü
   - Etiket: “Konu Analizi”
   - Başlık: “Üslü Sayılar” (büyük)
   - Alt bilgi: “Son çalışma: 2 saat önce”
   - Sağda dairesel puan göstergesi (82 Puan)
3. KPI Bento
   - Toplam Soru
   - Doğruluk Oranı (%82)
   - Ortalama Süre (1.2 dk)
4. Performans Trendi
   - Başlık + kısa açıklama (son 7 günde artış)
   - Mini sekmeler: 1H / 1A
   - Çizgi grafik + alan dolgu, hafta günleri etiketleri
5. Yanlış Analizi
   - Başlık + “Tümünü Gör”
   - Etiket çipleri: İşlem Hatası, Dikkat, Bilgi Eksikliği + sayaç
6. Aksiyon Alanı
   - Birincil CTA: “Bu Konudan Soru Ekle”
   - İkincil: “Tekrar Planla” + sağda “Yarın” etiketi
7. Alt Navigasyon
   - Sıra: Panel, Hızlı Ekle, Konular (aktif), Analiz
   - Ortadaki ikon yıldırım olmalı (artı değil)

## 2) Kodlamaya Uygun Bileşen Haritası (Flutter)
- `TopicDetailHeader`
  - Geri butonu + ders adı + menü
- `TopicHero`
  - Etiket, başlık, alt bilgi
  - Sağda `CircularProgress` (puan)
- `TopicKpiRow`
  - 3 küçük kart (Toplam, Doğruluk, Süre)
- `TrendCard`
  - Başlık + metin
  - 1H/1A segment
  - `CustomPaint` çizgi grafik
- `MistakeChips`
  - Renkli çipler + sayaç
- `ActionButtons`
  - Büyük birincil CTA
  - İkincil buton + rozet
- `BottomNav`
  - Panel, Hızlı Ekle, Konular (aktif), Analiz
  - Ortada yıldırım FAB

## 3) Renk ve Tipografi
- Arka plan: çok koyu (#0A0A0A)
- Kartlar: koyu yüzey (#1A1A1A)
- Aksan: mor (#5E19E6)
- Vurgu: açık mor (#7C4DFF)
- Başlık: Space Grotesk

## 4) Kodlama İçin Prompt (Flutter Uygulama Üretimi)
Koyu temalı “Konu Detay” ekranı tasarla. Üstte geri ok, ortada ders adı (Matematik), sağda üç nokta menü olsun. Hero bölümünde “Konu Analizi” etiketi, büyük başlık “Üslü Sayılar”, alt metin “Son çalışma: 2 saat önce” ve sağda dairesel puan göstergesi (82). Altında 3 KPI kartı: Toplam Soru, Doğruluk Oranı, Ortalama Süre.

Performans Trendi kartı: başlık ve “son 7 günde +%5 artış” metni, 1H/1A mini sekme, mor çizgi grafik ve hafta günleri etiketleri. Yanlış Analizi alanı: “İşlem Hatası”, “Dikkat”, “Bilgi Eksikliği” çipleri ve sayaçları. Alt kısımda CTA butonları: “Bu Konudan Soru Ekle” (birincil mor), “Tekrar Planla” (ikincil) ve sağda “Yarın” etiketi.

Alt navigasyon sırası: Panel, Hızlı Ekle, Konular (aktif), Analiz. Ortadaki ikon artı değil, yıldırım olmalı. Koyu tema, yüksek kontrast, Space Grotesk tipografi ve yumuşak gölgeler kullan.
