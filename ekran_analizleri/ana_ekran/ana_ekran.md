# Ana Ekran (Dashboard) — Kodlamaya Uygun Analiz

## 1) Görsel Hiyerarşi ve Bölümler
1. Header
   - Üst bilgi: “Merhaba, Öğrenci” (küçük, uppercase)
   - Ana başlık: “Bugün, 24 Ekim” (büyük, kalın)
   - Sağda bildirim ikonu + kırmızı nokta
2. Zaman Segmenti (Tab)
   - “Bugün / 7 Gün / 30 Gün”
   - Seçili sekme dolu ve parlak
3. Konu Pusulası (Odak Kartı)
   - Arka plan: görsel doku + degrade
   - Etiket: “Konu Pusulası” + ikon
   - Başlık: “Matematik - Üslü Sayılar”
   - Öneri satırı + progress bar
   - CTA: “Başla” butonu
4. Performans Bölümü
   - Sol: Dairesel hedef yüzdesi (85)
   - Sağ: KPI kartları (Ortalama Net + artış, Doğruluk, Toplam)
5. Son Aktiviteler Zaman Çizgisi
   - Başlık + “Tümü” linki
   - Dikey çizgi + kartlı aktiviteler
6. Veri Yok Durumu
   - Ana ekranda içerik yoksa boş durum kartı göster
   - İllüstrasyon: grafik ikonu + küçük kart birleşimi
   - Başlık: “Henüz Veri Yok”
   - Açıklama: “Önce 3 deneme ekle — trendleri çıkarmak için buradan takip et.”
6. Alt Navigasyon
   - Sıra: Panel, Konular, (Yıldırım), Analiz, Profil
   - Ortadaki ikon “şinşek/yıldırım”

## 2) Kodlamaya Uygun Bileşen Haritası (Flutter)
- `HeaderSection`
  - `Row`: sol metinler + sağ bildirim ikonu
  - bildirim noktasını `Positioned` ile ekle
- `SegmentedControl`
  - `Container` + `Row` içinde 3 `GestureDetector`
  - seçili state renkleri
- `FocusCard`
  - `Stack` ile arka plan görsel + degrade overlay
  - içerik: etiket, başlık, öneri, progress, CTA
- `PerformanceSection`
  - `Row`: sol `GoalRingCard`, sağ `KpiColumn`
- `GoalRingCard`
  - `CustomPaint` veya `CircularProgressIndicator` ile yüzdelik ring
- `KpiCard`
  - küçük kartlar, sayısal değer + etiket
- `Timeline`
  - `Stack` ile dikey çizgi
  - her satır `TimelineItem`
- `EmptyState`
  - Ortalanmış kart: ikon + başlık + açıklama
  - Görsel: grafik ikonu + küçük kart birleşimi
- `BottomNav`
  - 5 ikon, ortada FAB benzeri yıldırım

## 3) Renk ve Tipografi (Kod Referansı)
- Arka plan: çok koyu (#0F1214)
- Kartlar: koyu gri (#1A1D21 / #23282E)
- Aksan: mavi (#2BADEE)
- İkincil metin: gri (#9DB0B9)
- Tipografi: Space Grotesk, başlıklarda 600-700 ağırlık

## 4) Kodlama İçin Prompt (Flutter Uygulama Üretimi)
Flutter ile tek sayfalık koyu temalı KPSS dashboard ekranı oluştur. Düzen şu şekilde olsun:

- Üst header: “Merhaba, Öğrenci” küçük uppercase metin; altında büyük başlık “Bugün, 24 Ekim”. Sağda bildirim ikonu ve küçük kırmızı nokta.
- Header altında segmentli kontrol: “Bugün / 7 Gün / 30 Gün”; seçili sekme dolu arka planlı ve parlak.
- Konu Pusulası kartı: arka planda düşük opaklıklı görsel + degrade overlay; sol üstte “Konu Pusulası” etiketi ve keşif ikonu; başlık “Matematik - Üslü Sayılar”; altında “Önerilen: 40 Soru Çöz”; ilerleme çubuğu; sağda “Başla” CTA butonu.
- Performans bölümü: sol tarafta dairesel hedef göstergesi (85) ve “Günlük Soru”; sağda 3 KPI kartı (Ortalama Net + artış rozeti, Doğruluk %, Toplam).
- Son Aktiviteler: başlık + “Tümü” linki; dikey çizgi boyunca 3 aktivite kartı (ikon, başlık, saat, etiket/rozet).
- Alt navigasyon: sıra “Panel, Konular, Yıldırım, Analiz, Profil” olacak; ortadaki buton FAB gibi yükselmiş ve ikon yıldırım (artı değil).

Eğer veri yoksa ana ekranda boş durum kartı göster: üstte ikonlu illüstrasyon (grafik ikonu + küçük kart), başlık “Henüz Veri Yok”, açıklama “Önce 3 deneme ekle — trendleri çıkarmak için buradan takip et.” Arkaplan görselini dikkate alma.

Stil: koyu arka plan, yumuşak gölge, yüksek kontrast, Space Grotesk, mavi aksan rengi. Kartlar yuvarlak köşeli, border hafif. Mobil genişliğe uygun tek kolon düzen.
