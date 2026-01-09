# Hızlı Ekle Ekranı — Kodlamaya Uygun Analiz

## 1) Görsel Hiyerarşi ve Bölümler
1. Üst Başlık
   - Üst küçük metin: Gerek yok.
   - Ana başlık: “Bugünkü hedeflerini tamamla.” (vurgu: “tamamla.” mavi)
2. Ana Aksiyon Kartları (2’li grid)
   - Sol kart: “Soru Ekle” (ikon + kısa açıklama)
   - Sağ kart: “Deneme Ekle” (ikon + kısa açıklama)
   - Koyu kart, yumuşak gölge, büyük köşe yuvarlaklığı
3. Hızlı Seçimler
   - Başlık: “Hızlı Seçimler” + sağda “Tümü” linki
   - Yatay kaydırmalı öneri kartları
   - Her kart: küçük görsel alan + etiket + başlık + alt açıklama + sağda “+” butonu
4. Bugün Listesi
   - Başlık: “Bugün”
   - Liste kartı: satırlar halinde (ikon + başlık + alt açıklama + sağda saat)
5. Alt Navigasyon
   - Sıra: Panel, Hızlı Ekle (aktif), Konular, Analiz
   - Ortadaki buton yükselmiş; ikon yıldırım olmalı (artı değil)

## 2) Kodlamaya Uygun Bileşen Haritası (Flutter)
- `WelcomeHeader`
  - Büyük başlık
  - Başlık içinde vurgu rengi (RichText)
- `QuickActionGrid`
  - 2 adet `ActionCard`
- `ActionCard`
  - İkon daire içinde, başlık + alt metin
- `QuickSelections`
  - `Row`: başlık + “Tümü”
  - `ListView.horizontal` öneri kartları
- `SuggestionCard`
  - Sol küçük görsel alan
  - Etiket, başlık, alt metin
  - Sağda yuvarlak + butonu
- `TodayLogList`
  - Kart içinde 2-3 satır log
- `BottomNav`
  - Panel, Hızlı Ekle (aktif), Konular, Analiz
  - Ortadaki FAB: yıldırım ikonu

## 3) Renk ve Tipografi
- Arka plan: çok koyu morumsu (#141121)
- Kart: koyu yüzey (#1E1C26)
- Vurgu rengi: mavi-mor (#3B19E6)
- Metin: beyaz + ikincil gri
- Tipografi: Space Grotesk (başlık), Noto Sans (gövde)

## 4) Kodlama İçin Prompt (Flutter Uygulama Üretimi)
Koyu temalı “Hızlı Ekle” ekranı tasarla. Üstte büyük başlık “Bugünkü hedeflerini tamamla.” olsun; “tamamla.” kelimesi mavi vurgulu. Altında 2’li grid olarak iki kart yerleştir: “Soru Ekle” ve “Deneme Ekle”. Kartlar koyu, büyük köşeli, ikonlar dairesel arka plan içinde, açıklama metinleri kısa.

Bir alt bölümde “Hızlı Seçimler” başlığı ve sağda “Tümü” linki olmalı. Yatay kaydırmalı öneri kartları: küçük görsel alan, etiket (örn. Son Çalışılan), başlık, alt açıklama ve sağda yuvarlak “+” butonu.

Alt kısımda “Bugün” başlığı altında liste kartı; her satırda ikon, başlık, alt açıklama ve sağda saat bilgisi bulunmalı.

Alt navigasyon sırası: Panel, Hızlı Ekle (aktif), Konular, Analiz. Ortadaki buton yükselmiş FAB görünümlü ve ikon yıldırım olmalı (artı değil). Koyu tema, Space Grotesk/Noto Sans tipografi, yumuşak gölge, yüksek kontrast.
