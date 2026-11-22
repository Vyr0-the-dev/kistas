import 'package:flutter/material.dart';

/// Muted, low-fatigue academic color cues for courses/subjects.
/// Keeps cards calm and balanced in both Light and Dark themes.
@immutable
class SubjectColorStyle {
  const SubjectColorStyle({
    required this.accent,
    required this.tint,
    required this.border,
  });

  final Color accent;
  final Color tint;
  final Color border;
}

class SubjectColors {
  static const List<({Color lightAccent, Color darkAccent})> _swatches = [
    (lightAccent: Color(0xFF2F66D0), darkAccent: Color(0xFF6FA3F7)), // Calm Cobalt (Matematik)
    (lightAccent: Color(0xFFC24663), darkAccent: Color(0xFFF08CA3)), // Muted Rose (Türkçe/Edebiyat)
    (lightAccent: Color(0xFF6B54C6), darkAccent: Color(0xFFA996F2)), // Soft Slate-Violet (Fizik/Fen)
    (lightAccent: Color(0xFF0F7D8C), darkAccent: Color(0xFF4CC6D6)), // Calm Teal (Kimya/Bilişim)
    (lightAccent: Color(0xFF28825E), darkAccent: Color(0xFF56C99B)), // Sage Emerald (Biyoloji/Coğrafya)
    (lightAccent: Color(0xFFB8741E), darkAccent: Color(0xFFE9B363)), // Warm Ochre (Tarih/Vatandaşlık)
    (lightAccent: Color(0xFF8355A3), darkAccent: Color(0xFFC296E0)), // Dusty Plum (İngilizce/Dil)
    (lightAccent: Color(0xFF2B74A8), darkAccent: Color(0xFF67B1E6)), // Steel Blue (Felsefe/Eğitim)
  ];

  static SubjectColorStyle of(String subject, {required bool isDark}) {
    final index = _indexFor(subject);
    final swatch = _swatches[index];
    final accent = isDark ? swatch.darkAccent : swatch.lightAccent;
    return SubjectColorStyle(
      accent: accent,
      tint: accent.withValues(alpha: isDark ? 0.13 : 0.08),
      border: accent.withValues(alpha: isDark ? 0.25 : 0.18),
    );
  }

  static int _indexFor(String raw) {
    final s = raw.trim().toLowerCase();
    if (s.isEmpty) return 0;

    if (s.contains('mat') || s.contains('geom') || s.contains('sayısal')) {
      return 0;
    }
    if (s.contains('türk') ||
        s.contains('edeb') ||
        s.contains('paragraf') ||
        s.contains('sözel')) {
      return 1;
    }
    if (s.contains('fizik') || s.contains('fen')) {
      return 2;
    }
    if (s.contains('kimya') ||
        s.contains('bilişim') ||
        s.contains('algoritma') ||
        s.contains('yazılım')) {
      return 3;
    }
    if (s.contains('biyo') || s.contains('coğ') || s.contains('cog')) {
      return 4;
    }
    if (s.contains('tarih') ||
        s.contains('inkılap') ||
        s.contains('vatandaş') ||
        s.contains('güncel')) {
      return 5;
    }
    if (s.contains('ing') ||
        s.contains('dil') ||
        s.contains('yds') ||
        s.contains('ydt') ||
        s.contains('kelime') ||
        s.contains('reading')) {
      return 6;
    }
    if (s.contains('felsefe') ||
        s.contains('din') ||
        s.contains('eğitim') ||
        s.contains('psikoloji') ||
        s.contains('rehber')) {
      return 7;
    }

    var hash = 0;
    for (final code in s.codeUnits) {
      hash = (hash * 31 + code) & 0x7FFFFFFF;
    }
    return hash % _swatches.length;
  }
}
