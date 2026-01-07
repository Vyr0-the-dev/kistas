import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class TopicCompassCard extends StatelessWidget {
  const TopicCompassCard({super.key, required this.topic, required this.note});

  final String topic;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.line.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.deepTeal,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.explore, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(topic, style: Theme.of(context).textTheme.titleMedium),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(note, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.mustard,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  'Tekrar Plani',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: AppColors.deepTeal),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '3-7-14 gun',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
