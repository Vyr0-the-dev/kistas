import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class StatItem {
  const StatItem({required this.label, required this.value});

  final String label;
  final String value;
}

class StatsRow extends StatelessWidget {
  const StatsRow({super.key, required this.stats});

  final List<StatItem> stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(stats.length, (index) {
        final stat = stats[index];
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index == stats.length - 1 ? 0 : 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.line.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stat.value, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(stat.label, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        );
      }),
    );
  }
}
