import 'package:flutter/material.dart';

class AppColors {
  // --- Curated Modern Student Palettes ---

  // 1. Ferah (Crisp Porcelain + Calm Deep Teal) - Varsayılan
  static const paper = AppPalette(
    key: 'paper',
    name: 'Ferah',
    subtitle: 'Sade açık & deniz yeşili',
    brightness: Brightness.light,
    background: Color(0xFFF5F7FA),
    backgroundAlt: Color(0xFFEAEFF5),
    surface: Color(0xFFFFFFFF),
    surfaceLight: Color(0xFFEEF2F7),
    primary: Color(0xFF0F766E),
    primaryLight: Color(0xFF14B8A6),
    primaryDark: Color(0xFF115E59),
    onPrimary: Color(0xFFFFFFFF),
    glass: Color(0xFFFFFFFF),
    glassBorder: Color(0xFFE5EAF1),
    border: Color(0xFFE5EAF1),
    divider: Color(0xFFEDF1F6),
    subtleFill: Color(0xFFF1F4F9),
    cardShadow: Color(0x0A0F172A),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    textMuted: Color(0xFF94A3B8),
    success: Color(0xFF16A34A),
    warning: Color(0xFFD97706),
    danger: Color(0xFFDC2626),
  );

  // 2. Saf Mavi (Crisp White + Clean Cobalt Blue)
  static const sage = AppPalette(
    key: 'sage',
    name: 'Saf Mavi',
    subtitle: 'Temiz mavi & beyaz',
    brightness: Brightness.light,
    background: Color(0xFFF6F8FC),
    backgroundAlt: Color(0xFFEAF0FA),
    surface: Color(0xFFFFFFFF),
    surfaceLight: Color(0xFFEEF2FA),
    primary: Color(0xFF2563EB),
    primaryLight: Color(0xFF3B82F6),
    primaryDark: Color(0xFF1D4ED8),
    onPrimary: Color(0xFFFFFFFF),
    glass: Color(0xFFFFFFFF),
    glassBorder: Color(0xFFE2E8F4),
    border: Color(0xFFE2E8F4),
    divider: Color(0xFFEBF0F8),
    subtleFill: Color(0xFFF1F5FC),
    cardShadow: Color(0x0A0F172A),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    textMuted: Color(0xFF94A3B8),
    success: Color(0xFF16A34A),
    warning: Color(0xFFD97706),
    danger: Color(0xFFDC2626),
  );

  // 3. Kömür (Ultra-Minimal Monochrome Light)
  static const lavender = AppPalette(
    key: 'lavender',
    name: 'Kömür',
    subtitle: 'Minimal siyah-beyaz',
    brightness: Brightness.light,
    background: Color(0xFFF7F7F8),
    backgroundAlt: Color(0xFFECECEF),
    surface: Color(0xFFFFFFFF),
    surfaceLight: Color(0xFFEFEFF1),
    primary: Color(0xFF18181B),
    primaryLight: Color(0xFF3F3F46),
    primaryDark: Color(0xFF09090B),
    onPrimary: Color(0xFFFFFFFF),
    glass: Color(0xFFFFFFFF),
    glassBorder: Color(0xFFE4E4E7),
    border: Color(0xFFE4E4E7),
    divider: Color(0xFFECECEF),
    subtleFill: Color(0xFFF2F2F4),
    cardShadow: Color(0x0A18181B),
    textPrimary: Color(0xFF18181B),
    textSecondary: Color(0xFF52525B),
    textMuted: Color(0xFFA1A1AA),
    success: Color(0xFF16A34A),
    warning: Color(0xFFD97706),
    danger: Color(0xFFDC2626),
  );

  // 4. Gece (Crisp Charcoal Dark + Calm Teal)
  static const night = AppPalette(
    key: 'night',
    name: 'Gece',
    subtitle: 'Koyu arduvaz & turkuaz',
    brightness: Brightness.dark,
    background: Color(0xFF0D1117),
    backgroundAlt: Color(0xFF090C10),
    surface: Color(0xFF161B22),
    surfaceLight: Color(0xFF21262D),
    primary: Color(0xFF2DD4BF),
    primaryLight: Color(0xFF5EEAD4),
    primaryDark: Color(0xFF14B8A6),
    onPrimary: Color(0xFF062420),
    glass: Color(0xFF161B22),
    glassBorder: Color(0xFF2B313B),
    border: Color(0xFF2B313B),
    divider: Color(0xFF242A33),
    subtleFill: Color(0xFF1C2128),
    cardShadow: Color(0x00000000),
    textPrimary: Color(0xFFF0F6FC),
    textSecondary: Color(0xFF8B949E),
    textMuted: Color(0xFF6E7681),
    success: Color(0xFF34D399),
    warning: Color(0xFFFBBF24),
    danger: Color(0xFFF87171),
  );

  // 5. Gece Mavi (Deep Slate Dark + Soft Sky Blue)
  static const forestDark = AppPalette(
    key: 'forest_dark',
    name: 'Gece Mavi',
    subtitle: 'Derin lacivert & gök',
    brightness: Brightness.dark,
    background: Color(0xFF0B1120),
    backgroundAlt: Color(0xFF070B14),
    surface: Color(0xFF131C31),
    surfaceLight: Color(0xFF1E293B),
    primary: Color(0xFF60A5FA),
    primaryLight: Color(0xFF93C5FD),
    primaryDark: Color(0xFF3B82F6),
    onPrimary: Color(0xFF081730),
    glass: Color(0xFF131C31),
    glassBorder: Color(0xFF26344E),
    border: Color(0xFF26344E),
    divider: Color(0xFF1F2C44),
    subtleFill: Color(0xFF172238),
    cardShadow: Color(0x00000000),
    textPrimary: Color(0xFFF1F5F9),
    textSecondary: Color(0xFF94A3B8),
    textMuted: Color(0xFF64748B),
    success: Color(0xFF34D399),
    warning: Color(0xFFFBBF24),
    danger: Color(0xFFF87171),
  );

  // 6. Gece Siyah (Pure Minimal AMOLED Monochrome Dark)
  static const oceanDark = AppPalette(
    key: 'ocean_dark',
    name: 'Gece Siyah',
    subtitle: 'Minimal AMOLED koyu',
    brightness: Brightness.dark,
    background: Color(0xFF09090B),
    backgroundAlt: Color(0xFF000000),
    surface: Color(0xFF141417),
    surfaceLight: Color(0xFF1F1F24),
    primary: Color(0xFFF4F4F5),
    primaryLight: Color(0xFFFFFFFF),
    primaryDark: Color(0xFFD4D4D8),
    onPrimary: Color(0xFF09090B),
    glass: Color(0xFF141417),
    glassBorder: Color(0xFF27272D),
    border: Color(0xFF27272D),
    divider: Color(0xFF212126),
    subtleFill: Color(0xFF1A1A1F),
    cardShadow: Color(0x00000000),
    textPrimary: Color(0xFFFAFAFA),
    textSecondary: Color(0xFFA1A1AA),
    textMuted: Color(0xFF71717A),
    success: Color(0xFF34D399),
    warning: Color(0xFFFBBF24),
    danger: Color(0xFFF87171),
  );

  // Legacy aliases for backward compatibility with older code/tests.
  static const midnight = night;
  static const ocean = forestDark;
  static const forest = night;
  static const graphite = oceanDark;

  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF475569);
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFD97706);
  static const danger = Color(0xFFDC2626);

  static const String defaultThemeKey = 'paper';

  static const Map<String, AppPalette> palettes = {
    'paper': paper,
    'sage': sage,
    'lavender': lavender,
    'night': night,
    'forest_dark': forestDark,
    'ocean_dark': oceanDark,
  };

  static const Map<String, String> _legacyMapping = {
    'midnight': 'night',
    'graphite': 'ocean_dark',
    'volcanic': 'night',
    'crimson': 'night',
    'amber': 'night',
    'sunset': 'night',
    'royal': 'forest_dark',
    'forest': 'night',
    'ocean': 'forest_dark',
    'glacier': 'forest_dark',
  };

  static String resolveKey(String rawKey) {
    if (palettes.containsKey(rawKey)) return rawKey;
    return _legacyMapping[rawKey] ?? defaultThemeKey;
  }

  static AppPalette resolvePalette(String rawKey) {
    return palettes[resolveKey(rawKey)] ?? paper;
  }

  static String toggleLightDarkKey(String currentKey) {
    final resolved = resolveKey(currentKey);
    switch (resolved) {
      case 'paper':
        return 'night';
      case 'sage':
        return 'forest_dark';
      case 'lavender':
        return 'ocean_dark';
      case 'night':
        return 'paper';
      case 'forest_dark':
        return 'sage';
      case 'ocean_dark':
        return 'lavender';
      default:
        return 'paper';
    }
  }

  static AppColorsExtension of(BuildContext context) {
    return Theme.of(context).extension<AppColorsExtension>()!;
  }
}

class AppPalette {
  const AppPalette({
    required this.key,
    required this.name,
    required this.subtitle,
    required this.brightness,
    required this.background,
    required this.backgroundAlt,
    required this.surface,
    required this.surfaceLight,
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.onPrimary,
    required this.glass,
    required this.glassBorder,
    required this.border,
    required this.divider,
    required this.subtleFill,
    required this.cardShadow,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.success,
    required this.warning,
    required this.danger,
  });

  final String key;
  final String name;
  final String subtitle;
  final Brightness brightness;
  final Color background;
  final Color backgroundAlt;
  final Color surface;
  final Color surfaceLight;
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color onPrimary;
  final Color glass;
  final Color glassBorder;
  final Color border;
  final Color divider;
  final Color subtleFill;
  final Color cardShadow;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color success;
  final Color warning;
  final Color danger;

  bool get isDark => brightness == Brightness.dark;
}

@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.brightness,
    required this.background,
    required this.backgroundAlt,
    required this.surface,
    required this.surfaceLight,
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.glass,
    required this.glassBorder,
    required this.border,
    required this.divider,
    required this.subtleFill,
    required this.cardShadow,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.success,
    required this.warning,
    required this.danger,
    required this.onPrimary,
  });

  final Brightness brightness;
  final Color background;
  final Color backgroundAlt;
  final Color surface;
  final Color surfaceLight;
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color glass;
  final Color glassBorder;
  final Color border;
  final Color divider;
  final Color subtleFill;
  final Color cardShadow;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color success;
  final Color warning;
  final Color danger;
  final Color onPrimary;

  bool get isDark => brightness == Brightness.dark;

  factory AppColorsExtension.fromPalette(AppPalette palette) {
    return AppColorsExtension(
      brightness: palette.brightness,
      background: palette.background,
      backgroundAlt: palette.backgroundAlt,
      surface: palette.surface,
      surfaceLight: palette.surfaceLight,
      primary: palette.primary,
      primaryLight: palette.primaryLight,
      primaryDark: palette.primaryDark,
      glass: palette.glass,
      glassBorder: palette.glassBorder,
      border: palette.border,
      divider: palette.divider,
      subtleFill: palette.subtleFill,
      cardShadow: palette.cardShadow,
      textPrimary: palette.textPrimary,
      textSecondary: palette.textSecondary,
      textMuted: palette.textMuted,
      success: palette.success,
      warning: palette.warning,
      danger: palette.danger,
      onPrimary: palette.onPrimary,
    );
  }

  @override
  AppColorsExtension copyWith({
    Brightness? brightness,
    Color? background,
    Color? backgroundAlt,
    Color? surface,
    Color? surfaceLight,
    Color? primary,
    Color? primaryLight,
    Color? primaryDark,
    Color? glass,
    Color? glassBorder,
    Color? border,
    Color? divider,
    Color? subtleFill,
    Color? cardShadow,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? success,
    Color? warning,
    Color? danger,
    Color? onPrimary,
  }) {
    return AppColorsExtension(
      brightness: brightness ?? this.brightness,
      background: background ?? this.background,
      backgroundAlt: backgroundAlt ?? this.backgroundAlt,
      surface: surface ?? this.surface,
      surfaceLight: surfaceLight ?? this.surfaceLight,
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryDark: primaryDark ?? this.primaryDark,
      glass: glass ?? this.glass,
      glassBorder: glassBorder ?? this.glassBorder,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      subtleFill: subtleFill ?? this.subtleFill,
      cardShadow: cardShadow ?? this.cardShadow,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      onPrimary: onPrimary ?? this.onPrimary,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      brightness: t < 0.5 ? brightness : other.brightness,
      background: Color.lerp(background, other.background, t)!,
      backgroundAlt: Color.lerp(backgroundAlt, other.backgroundAlt, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceLight: Color.lerp(surfaceLight, other.surfaceLight, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      glass: Color.lerp(glass, other.glass, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      subtleFill: Color.lerp(subtleFill, other.subtleFill, t)!,
      cardShadow: Color.lerp(cardShadow, other.cardShadow, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
    );
  }
}
