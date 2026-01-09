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

  // 4. Forest (Green/Dark Green) - Doğa
  static const forest = AppPalette(
    background: Color(0xFF051C10), 
    backgroundAlt: Color(0xFF010F06),
    surface: Color(0xFF0D3321),
    surfaceLight: Color(0xFF164D33),
    primary: Color(0xFF4ADE80), // Emerald 400
    primaryLight: Color(0xFF86EFAC), // Emerald 300
    primaryDark: Color(0xFF22C55E), // Emerald 500
    glass: Color(0x1A0D3321),
    glassBorder: Color(0x1F4ADE80),
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