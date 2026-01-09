import 'package:flutter/material.dart';

class AppColors {
  // --- Palettes ---

  // 1. Midnight Pro (Slate/Indigo) - Varsayılan
  static const midnight = AppPalette(
    background: Color(0xFF0F172A),
    backgroundAlt: Color(0xFF020617),
    surface: Color(0xFF1E293B),
    surfaceLight: Color(0xFF334155),
    primary: Color(0xFF818CF8),
    primaryLight: Color(0xFFA5B4FC),
    primaryDark: Color(0xFF6366F1),
    glass: Color(0x1A1E293B),
    glassBorder: Color(0x1FFFFFFF),
  );

  // 2. Deep Ocean (Navy/Teal) - Okyanus
  static const ocean = AppPalette(
    background: Color(0xFF05111A),
    backgroundAlt: Color(0xFF02080D),
    surface: Color(0xFF0D2137),
    surfaceLight: Color(0xFF163252),
    primary: Color(0xFF2DD4BF), // Teal 400
    primaryLight: Color(0xFF5EEAD4), // Teal 300
    primaryDark: Color(0xFF14B8A6), // Teal 500
    glass: Color(0x1A0D2137),
    glassBorder: Color(0x1F2DD4BF),
  );

  // 3. Volcanic Ash (Charcoal/Orange) - Sıcak
  static const volcanic = AppPalette(
    background: Color(0xFF18181B), // Zinc 900
    backgroundAlt: Color(0xFF09090B), // Zinc 950
    surface: Color(0xFF27272A), // Zinc 800
    surfaceLight: Color(0xFF3F3F46), // Zinc 700
    primary: Color(0xFFFB923C), // Orange 400
    primaryLight: Color(0xFFFDBA74), // Orange 300
    primaryDark: Color(0xFFF97316), // Orange 500
    glass: Color(0x1A27272A),
    glassBorder: Color(0x1FFB923C),
  );

  // 4. Forest (Green/Dark Green) - Neon Orman
  static const forest = AppPalette(
    background: Color(0xFF020A05), // Very Dark Green Black
    backgroundAlt: Color(0xFF000000),
    surface: Color(0xFF0A1F12), // Deep Green Surface
    surfaceLight: Color(0xFF143320),
    primary: Color(0xFF39EF7B), // Neon Green
    primaryLight: Color(0xFF86EFAC), // Lighter Green
    primaryDark: Color(0xFF22C55E), // Emerald 500
    glass: Color(0x1A0A1F12),
    glassBorder: Color(0x1F39EF7B),
    onPrimary: Color(0xFF000000), // Black text on Neon Green
  );

  // 5. Royal (Purple/Violet) - Asil
  static const royal = AppPalette(
    background: Color(0xFF0B0515), // Deep Purple Black
    backgroundAlt: Color(0xFF05020A),
    surface: Color(0xFF1A102E), // Deep Violet
    surfaceLight: Color(0xFF2D1B4E),
    primary: Color(0xFFA855F7), // Purple 500
    primaryLight: Color(0xFFC084FC), // Purple 400
    primaryDark: Color(0xFF9333EA), // Purple 600
    glass: Color(0x1A1A102E),
    glassBorder: Color(0x1FA855F7),
  );

  // 6. Sunset (Rose/Pink) - Günbatımı
  static const sunset = AppPalette(
    background: Color(0xFF120306), // Deep Rose Black
    backgroundAlt: Color(0xFF0A0103),
    surface: Color(0xFF240A12), // Deep Rose
    surfaceLight: Color(0xFF3D121F),
    primary: Color(0xFFFB7185), // Rose 400
    primaryLight: Color(0xFFFDA4AF), // Rose 300
    primaryDark: Color(0xFFF43F5E), // Rose 500
    glass: Color(0x1A240A12),
    glassBorder: Color(0x1FFB7185),
  );

  // 7. Glacier (Cyan/Ice) - Buzul
  static const glacier = AppPalette(
    background: Color(0xFF041016), // Dark Cyan Black
    backgroundAlt: Color(0xFF010608),
    surface: Color(0xFF0B222C), // Dark Cyan Surface
    surfaceLight: Color(0xFF153847),
    primary: Color(0xFF22D3EE), // Cyan 400
    primaryLight: Color(0xFF67E8F9), // Cyan 300
    primaryDark: Color(0xFF06B6D4), // Cyan 500
    glass: Color(0x1A0B222C),
    glassBorder: Color(0x1F22D3EE),
  );

  // 8. Crimson (Red/Dark Red) - Lal
  static const crimson = AppPalette(
    background: Color(0xFF170505), // Dark Red Black
    backgroundAlt: Color(0xFF0A0101),
    surface: Color(0xFF2D0B0B), // Dark Red Surface
    surfaceLight: Color(0xFF4A1212),
    primary: Color(0xFFEF4444), // Red 500
    primaryLight: Color(0xFFF87171), // Red 400
    primaryDark: Color(0xFFDC2626), // Red 600
    glass: Color(0x1A2D0B0B),
    glassBorder: Color(0x1FEF4444),
  );

  // 9. Amber (Yellow/Gold) - Kehribar
  static const amber = AppPalette(
    background: Color(0xFF160E02), // Dark Amber Black
    backgroundAlt: Color(0xFF080500),
    surface: Color(0xFF2B1C05), // Dark Amber Surface
    surfaceLight: Color(0xFF452D0A),
    primary: Color(0xFFFBBF24), // Amber 400
    primaryLight: Color(0xFFFCD34D), // Amber 300
    primaryDark: Color(0xFFF59E0B), // Amber 500
    glass: Color(0x1A2B1C05),
    glassBorder: Color(0x1FFBBF24),
  );

  // 10. Graphite (Grey/Silver) - Grafit (Monokrom)
  static const graphite = AppPalette(
    background: Color(0xFF0A0A0A), // Near Black
    backgroundAlt: Color(0xFF000000),
    surface: Color(0xFF171717), // Neutral 900
    surfaceLight: Color(0xFF262626), // Neutral 800
    primary: Color(0xFFE5E5E5), // Neutral 200
    primaryLight: Color(0xFFFFFFFF), // White
    primaryDark: Color(0xFFA3A3A3), // Neutral 400
    glass: Color(0x1A171717),
    glassBorder: Color(0x1FE5E5E5),
    onPrimary: Color(0xFF000000),
  );

  // Common Text & Status Colors
  static const textPrimary = Color(0xFFF8FAFC);
  static const textSecondary = Color(0xFF94A3B8);
  static const success = Color(0xFF34D399);
  static const warning = Color(0xFFFBBF24);
  static const danger = Color(0xFFF87171);

  static const Map<String, AppPalette> palettes = {
    'midnight': midnight,
    'ocean': ocean,
    'volcanic': volcanic,
    'forest': forest,
    'royal': royal,
    'sunset': sunset,
    'glacier': glacier,
    'crimson': crimson,
    'amber': amber,
    'graphite': graphite,
  };

  // Helper to access colors from context
  static AppColorsExtension of(BuildContext context) {
    return Theme.of(context).extension<AppColorsExtension>()!;
  }
}

class AppPalette {
  const AppPalette({
    required this.background,
    required this.backgroundAlt,
    required this.surface,
    required this.surfaceLight,
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.glass,
    required this.glassBorder,
    this.onPrimary = Colors.white,
  });

  final Color background;
  final Color backgroundAlt;
  final Color surface;
  final Color surfaceLight;
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color glass;
  final Color glassBorder;
  final Color onPrimary;
}

@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.background,
    required this.backgroundAlt,
    required this.surface,
    required this.surfaceLight,
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.glass,
    required this.glassBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.success,
    required this.warning,
    required this.danger,
  });

  final Color background;
  final Color backgroundAlt;
  final Color surface;
  final Color surfaceLight;
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color glass;
  final Color glassBorder;
  final Color textPrimary;
  final Color textSecondary;
  final Color success;
  final Color warning;
  final Color danger;

  factory AppColorsExtension.fromPalette(AppPalette palette) {
    return AppColorsExtension(
      background: palette.background,
      backgroundAlt: palette.backgroundAlt,
      surface: palette.surface,
      surfaceLight: palette.surfaceLight,
      primary: palette.primary,
      primaryLight: palette.primaryLight,
      primaryDark: palette.primaryDark,
      glass: palette.glass,
      glassBorder: palette.glassBorder,
      textPrimary: AppColors.textPrimary,
      textSecondary: AppColors.textSecondary,
      success: AppColors.success,
      warning: AppColors.warning,
      danger: AppColors.danger,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? background,
    Color? backgroundAlt,
    Color? surface,
    Color? surfaceLight,
    Color? primary,
    Color? primaryLight,
    Color? primaryDark,
    Color? glass,
    Color? glassBorder,
    Color? textPrimary,
    Color? textSecondary,
    Color? success,
    Color? warning,
    Color? danger,
  }) {
    return AppColorsExtension(
      background: background ?? this.background,
      backgroundAlt: backgroundAlt ?? this.backgroundAlt,
      surface: surface ?? this.surface,
      surfaceLight: surfaceLight ?? this.surfaceLight,
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryDark: primaryDark ?? this.primaryDark,
      glass: glass ?? this.glass,
      glassBorder: glassBorder ?? this.glassBorder,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
    covariant ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) {
      return this;
    }
    return AppColorsExtension(
      background: Color.lerp(background, other.background, t)!,
      backgroundAlt: Color.lerp(backgroundAlt, other.backgroundAlt, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceLight: Color.lerp(surfaceLight, other.surfaceLight, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      glass: Color.lerp(glass, other.glass, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}