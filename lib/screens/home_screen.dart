import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/goal_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/section_header.dart';
import '../widgets/stats_row.dart';
import '../widgets/topic_compass_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _Backdrop(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(),
                  const SizedBox(height: 24),
                  const GoalCard(
                    title: 'Bugunun Hedefi',
                    solved: 62,
                    target: 90,
                    focus: 'Turkce - Paragraf',
                  ),
                  const SizedBox(height: 24),
                  const SectionHeader(
                    title: 'Son 7 Gun Ozeti',
                    subtitle: 'Net trendi ve dogruluk oranin',
                  ),
                  const SizedBox(height: 12),
                  const StatsRow(
                    stats: [
                      StatItem(label: 'Ortalama Net', value: '68,4'),
                      StatItem(label: 'Dogru Orani', value: '%71'),
                      StatItem(label: 'Soru/Saat', value: '42'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const SectionHeader(
                    title: 'Hizli Ekle',
                    subtitle: 'Kitaptan cozduklerini 30 saniyede gir',
                  ),
                  const SizedBox(height: 12),
                  const QuickActions(),
                  const SizedBox(height: 24),
                  const SectionHeader(
                    title: 'Konu Pusulasi',
                    subtitle: 'Zayif konunu parlatma zamani',
                  ),
                  const SizedBox(height: 12),
                  const TopicCompassCard(
                    topic: 'Tarih - Islahat Fermanlari',
                    note: 'Cikmis sorularda en cok hata yapilan bolum.',
                  ),
                  const SizedBox(height: 24),
                  const SectionHeader(
                    title: 'Kritik Not',
                    subtitle: 'Bugun icin kisa hatirlatma',
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.line.withOpacity(0.6)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            color: AppColors.mustard,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: AppColors.deepTeal,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Vatandaslikta Anayasa degisikligi sorularinda yil/sure baglamini not al. '
                            'Yil ezberi yerine donem eslestir.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('P3 Rota', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 6),
            Text(
              'DHMI ATC icin sakin, planli ilerle.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.deepTeal,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.calendar_today, color: Colors.white),
        ),
      ],
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.sand, AppColors.mist],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -30,
            child: _BlurCircle(
              size: 180,
              color: AppColors.coral.withOpacity(0.16),
            ),
          ),
          Positioned(
            top: 140,
            left: -40,
            child: _BlurCircle(
              size: 160,
              color: AppColors.mustard.withOpacity(0.2),
            ),
          ),
          Positioned(
            bottom: -40,
            right: -20,
            child: _BlurCircle(
              size: 200,
              color: AppColors.deepTeal.withOpacity(0.12),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  const _BlurCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
