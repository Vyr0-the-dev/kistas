# Plan

## 0) Ortam Hazirligi
- Flutter ve Android SDK yolunu kalici yapmak
- `flutter doctor` temiz calisacak hale getirmek

## 1) Temel Mimari
- Moduler klasor yapisi: `screens`, `widgets`, `theme`, `models`, `services`
- Tip guvenli ornek veri modelleri (Soru, Kitap, Deneme, Konu)
- Basit local depo (in-memory/mock) ile UI akisini tamamlama

## 2) Tasarim Sistemi
- Renk paleti, tipografi, kart, chip ve buton stili
- Ekranlar arasi ortak bosluk ve 8pt grid
- Hafif animasyonlar (fade-in, stagger)

## 3) Ekranlar (MVP)
- Ana ekran (tamamlandi, polish edilecek)
- Soru Gir (kitap + test + sonuc + sure)
- Deneme Ekle (net + sure + ders dagilimi)
- Konu Ozetleri (kisa anlatim + kritik notlar)

## 4) Analiz ve Tekrar
- Zayif konu hesaplama
- Yanlis/boş sorular icin tekrar kuyugu (3-7-14 gun)
- Haftalik hedef ve basari metriği

## 5) Dokumantasyon ve Teslim
- Kurulum/Calistirma adimlari
- Ekran akislari ve veri modeli notlari
