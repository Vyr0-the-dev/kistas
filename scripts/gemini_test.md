# Gemini API Hızlı Test (Uygulama Dışı)

Bu test, API anahtarının çalışıp çalışmadığını uygulama dışında doğrulamak içindir.

## 1) Anahtarı tanımla

```bash
export GEMINI_API_KEY="API_ANAHTARIN"
```

## 2) Modeli seç (gerekirse)

Model adı değişebiliyor. Kullanılabilir modelleri görmek için:

```bash
curl -sS "https://generativelanguage.googleapis.com/v1beta/models?key=${GEMINI_API_KEY}" | sed -n '1,200p'
```

Bir model seçmek için:

```bash
export GEMINI_MODEL="gemini-2.5-flash"
```

## 3) Testi çalıştır

```bash
bash scripts/gemini_test.sh
```

## 4) Özel bir istek at

```bash
bash scripts/gemini_test.sh "KPSS için 2 günlük kısa çalışma planı yaz. Türkçe olmalı."
```

## Beklenen sonuç

JSON çıktısı içinde `candidates[0].content.parts[0].text` alanında Türkçe yanıt görmelisin.
