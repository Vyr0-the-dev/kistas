import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.title,
    required this.solved,
    required this.target,
    required this.focus,
  });

  final String title;
  final int solved;
  final int target;
  final String focus;

  @override
  Widget build(BuildContext context) {
    final progress = solved / target;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.line.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.deepTeal,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$solved / $target',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.line.withOpacity(0.5),
              valueColor: const AlwaysStoppedAnimation(AppColors.coral),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.center_focus_strong, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Odak: $focus',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
