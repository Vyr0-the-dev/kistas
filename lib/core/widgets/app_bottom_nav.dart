import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.activeIndex,
    required this.onSelect,
  });

  final int activeIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return SafeArea(
      top: false,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(
                top: BorderSide(color: colors.border),
              ),
              boxShadow: colors.isDark
                  ? const []
                  : [
                      BoxShadow(
                        color: colors.cardShadow,
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavItem(
                  label: 'Panel',
                  icon: Icons.home_rounded,
                  outlinedIcon: Icons.home_outlined,
                  active: activeIndex == 0,
                  onTap: () => onSelect(0),
                ),
                _NavItem(
                  label: 'Konular',
                  icon: Icons.menu_book_rounded,
                  outlinedIcon: Icons.menu_book_outlined,
                  active: activeIndex == 1,
                  onTap: () => onSelect(1),
                ),
                const SizedBox(width: 64),
                _NavItem(
                  label: 'Analiz',
                  icon: Icons.insights_rounded,
                  outlinedIcon: Icons.insights_outlined,
                  active: activeIndex == 3,
                  onTap: () => onSelect(3),
                ),
                _NavItem(
                  label: 'Profil',
                  icon: Icons.person_rounded,
                  outlinedIcon: Icons.person_outline_rounded,
                  active: activeIndex == 4,
                  onTap: () => onSelect(4),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 12,
            child: _CenterAction(
              active: activeIndex == 2,
              onTap: () => onSelect(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.outlinedIcon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData outlinedIcon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final color = active ? colors.primary : colors.textMuted;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: active
                    ? colors.primary.withValues(alpha: colors.isDark ? 0.18 : 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                active ? icon : outlinedIcon,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterAction extends StatelessWidget {
  const _CenterAction({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primary,
              border: Border.all(
                color: colors.surface,
                width: 3.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: colors.isDark ? 0.35 : 0.28),
                  blurRadius: 16,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              Icons.add_rounded,
              size: 28,
              color: colors.onPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Ekle',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: active ? colors.primary : colors.textMuted,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
