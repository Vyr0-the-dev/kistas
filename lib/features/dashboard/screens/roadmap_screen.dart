import 'package:flutter/material.dart';
import '../../../core/repositories/app_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../questions/screens/topic_detail_screen.dart';

class RoadmapScreen extends StatelessWidget {
  const RoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = AppRepositoryScope.of(context);
    final progressList = repository.buildTopicProgress();
    
    // Konuları derslere göre gruplayalım
    final Map<String, List<TopicProgress>> groupedTopics = {};
    for (var p in progressList) {
      groupedTopics.putIfAbsent(p.topic.subject, () => []).add(p);
    }

    final subjects = groupedTopics.keys.toList();

    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    final subject = subjects[index];
                    final topics = groupedTopics[subject]!;
                    return _SubjectPath(
                      subject: subject,
                      topics: topics,
                      isLast: index == subjects.length - 1,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white70),
          ),
          const Text(
            'Konu Yol Haritası',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectPath extends StatelessWidget {
  const _SubjectPath({
    required this.subject,
    required this.topics,
    required this.isLast,
  });

  final String subject;
  final List<TopicProgress> topics;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubjectBadge(context),
        const SizedBox(height: 16),
        ...List.generate(topics.length, (index) {
          final isTopicLast = index == topics.length - 1;
          return _RoadmapNode(
            progress: topics[index],
            isLast: isTopicLast && isLast,
            showLine: true,
          );
        }),
        if (!isLast) const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSubjectBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.of(context).primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.of(context).primary.withOpacity(0.4)),
      ),
      child: Text(
        subject,
        style: TextStyle(
          color: AppColors.of(context).primaryLight,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _RoadmapNode extends StatelessWidget {
  const _RoadmapNode({
    required this.progress,
    required this.isLast,
    required this.showLine,
  });

  final TopicProgress progress;
  final bool isLast;
  final bool showLine;

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = progress.accuracy >= 0.8 && progress.totalQuestions > 50;
    final bool isStarted = progress.totalQuestions > 0;
    
    Color nodeColor = Colors.white10;
    IconData nodeIcon = Icons.radio_button_unchecked;
    
    if (isCompleted) {
      nodeColor = Colors.greenAccent;
      nodeIcon = Icons.check_circle;
    } else if (isStarted) {
      nodeColor = AppColors.of(context).primary;
      nodeIcon = Icons.play_circle_filled;
    }

    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: nodeColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: nodeColor, width: 2),
                ),
                child: Icon(nodeIcon, size: 16, color: nodeColor),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.white10,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TopicDetailScreen(topic: progress.topic),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      progress.topic.title,
                      style: TextStyle(
                        color: isStarted ? Colors.white : Colors.white38,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isStarted ? '%${progress.progressPercent} Tamamlandı' : 'Henüz başlanmadı',
                      style: TextStyle(
                        color: isStarted ? AppColors.of(context).primaryLight : Colors.white24,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
