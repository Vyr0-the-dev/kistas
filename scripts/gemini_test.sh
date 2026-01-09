#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${GEMINI_API_KEY:-}" ]]; then
  echo "Hata: GEMINI_API_KEY tanımlı değil."
  echo "Örnek: export GEMINI_API_KEY=\"AIza...\""
  exit 1
fi

MODEL="${GEMINI_MODEL:-gemini-2.5-flash}"
PROMPT="${1:-Merhaba! Bana 3 maddelik kısa bir çalışma motivasyon mesajı yaz. Türkçe olmalı.}"

curl -sS "https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent?key=${GEMINI_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "{
    \"contents\": [
      {
        \"parts\": [
          {\"text\": \"${PROMPT}\"}
        ]
      }
    ]
  }" | sed -n '1,200p'
