# Konular Ekranı — Kodlamaya Uygun Analiz

## 1) Görsel Hiyerarşi ve Bölümler
1. Üst Başlık
   - “Konular” büyük ve kalın başlık.
   - Sağ üstte bildirim ikonu kullanılmayacak.
2. Arama Çubuğu
   - Yer tutucu: “Konu, ders veya etiket ara...”
   - Sol tarafta arama ikonu.
3. Filtre ve Sıralama
   - “Sırala” butonu (ikon + metin).
   - Ders filtre çipleri: Tümü (aktif), Matematik, Türkçe, Genel Kültür.
   - Ek filtre çipleri: Zayıf, Uzun süre önce.
4. Konu Kartları (Liste)
   - Her kartta konu adı, ders etiketi.
   - Sağ üstte durum rozeti (başarı yüzdesi/uyarı).
   - Altında ilerleme çubuğu ve yüzde.
   - Durum çeşitleri: yüksek başarı, düşük başarı, tamamlandı, hiç çalışılmadı.
   - Sağa veya sola kaydırdığımızda çalışıldı vb. hızlı işlemler.
5. Alt Navigasyon
   - Sıra: Ana Sayfa, Konular (aktif), ortada Yıldırım, Analiz, Profil.
   - Ortadaki buton yükselmiş ve aksan renkli.

## 2) Kodlamaya Uygun Bileşen Haritası (Flutter)
- `TopicsHeader`
  - `Text('Konular')`
  - Bildirim ikonu yok.
- `SearchBar`
  - `TextField` + prefix icon.
- `FilterRow`
  - `SortButton` + yatay `ChoiceChip` listesi.
- `ContextFilters`
  - Küçük çipler (Zayıf, Uzun süre önce).
- `TopicCard`
  - Başlık, alt başlık.
  - Sağda durum rozeti (renk + ikon).
  - `LinearProgressIndicator` + yüzde.
- `BottomNav`
  - Ana Sayfa, Konular (aktif), Yıldırım (FAB), Analiz, Profil.

## 3) Veri Bağlama
- Konu listesi `topic_catalog.dart` içindeki gerçek konu listesinden beslenir.
- Filtreler:
  - Ders filtresi: konu `subject` alanına göre.
  - Arama: konu `title` + `subject` üzerinden.
- Durum rozeti ve ilerleme:
  - Eğer ilerleme verisi yoksa “Hiç çalışılmadı” ve %0.
  - Örnek durumlar: Yüksek başarı (yeşil), Düşük başarı (kırmızı), Tamamlandı (mor).

## 4) Kodlama İçin Prompt (Flutter Uygulama Üretimi)
Koyu temalı “Konular” ekranı tasarla. Üstte “Konular” başlığı olsun, sağ üstte bildirim ikonu olmasın. Başlık altında arama çubuğu (placeholder: “Konu, ders veya etiket ara...”) ve sol tarafta arama ikonu yer alsın. Altında “Sırala” butonu ve ders filtre çipleri (Tümü aktif, Matematik, Türkçe, Genel Kültür) bulunmalı. Bir alt satırda küçük filtre çipleri: “Zayıf” ve “Uzun süre önce”.

Liste bölümünde gerçek konu verilerini kullan: her kartta konu adı, ders etiketi, sağ üstte durum rozeti (yüzde + ikon), alt kısımda ilerleme çubuğu ve yüzde. Durum çeşitleri: yüksek başarı, düşük başarı, tamamlandı, hiç çalışılmadı. Kartlar koyu, yuvarlatılmış, yumuşak gölgeli ve yüksek kontrastlı olsun.

Alt navigasyon sırası: Ana Sayfa, Konular (aktif), ortada Yıldırım butonu (FAB), Analiz, Profil. Ortadaki ikon artı değil, yıldırım olmalı.
