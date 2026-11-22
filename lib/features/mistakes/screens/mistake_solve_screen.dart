import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kistas/core/models/question_entry.dart';
import 'package:kistas/core/repositories/app_repository.dart';
import 'package:kistas/core/theme/app_colors.dart';
import 'package:kistas/core/widgets/delete_helpers.dart';
import 'package:kistas/core/widgets/glass_panel.dart';

class MistakeSolveScreen extends StatefulWidget {
  const MistakeSolveScreen({super.key});

  @override
  State<MistakeSolveScreen> createState() => _MistakeSolveScreenState();
}

class _MistakeSolveScreenState extends State<MistakeSolveScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = AppRepositoryScope.of(context);

    return ValueListenableBuilder<List<QuestionEntry>>(
      valueListenable: repository.questionEntries,
      builder: (context, entries, _) {
        final unsolvedMistakes = entries
            .where((e) => e.imagePaths.isNotEmpty && !e.isSolved)
            .toList();
        final safeIndex = unsolvedMistakes.isEmpty
            ? 0
            : _currentIndex.clamp(0, unsolvedMistakes.length - 1);

        return Scaffold(
          backgroundColor: AppColors.of(context).background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: const Text('Hata Çöz Modu'),
            centerTitle: true,
            actions: [
              if (unsolvedMistakes.isNotEmpty)
                IconButton(
                  tooltip: 'Hata Kaydını Sil',
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: () => _deleteMistake(
                    unsolvedMistakes[safeIndex],
                    unsolvedMistakes.length,
                  ),
                ),
            ],
          ),
          body: unsolvedMistakes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 80,
                        color: Colors.greenAccent,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Tebrikler! Tüm hataları çözdün.',
                        style: TextStyle(color: AppColors.of(context).textPrimary, fontSize: 18),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Geri Dön'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: LinearProgressIndicator(
                        value: (safeIndex + 1) / unsolvedMistakes.length,
                        backgroundColor: AppColors.of(context).subtleFill,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.of(context).primary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) =>
                            setState(() => _currentIndex = index),
                        itemCount: unsolvedMistakes.length,
                        itemBuilder: (context, index) {
                          final entry = unsolvedMistakes[index];
                          return _MistakeCard(entry: entry);
                        },
                      ),
                    ),
                    _buildActions(unsolvedMistakes, safeIndex),
                  ],
                ),
        );
      },
    );
  }

  Future<void> _deleteMistake(QuestionEntry entry, int remainingBefore) async {
    final deleted = await deleteQuestionEntryWithUndo(context, entry);
    if (deleted && mounted && _currentIndex >= remainingBefore - 1 && _currentIndex > 0) {
      setState(() => _currentIndex = remainingBefore - 2);
    }
  }

  Widget _buildActions(List<QuestionEntry> mistakes, int safeIndex) {
    final entry = mistakes[safeIndex];
    final isLast = safeIndex >= mistakes.length - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                if (isLast) {
                  _pageController.animateToPage(0, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                } else {
                  _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                }
              },
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56), side: BorderSide(color: AppColors.of(context).border)),
              child: Text(isLast ? 'Başa Dön' : 'Atla', style: TextStyle(color: AppColors.of(context).textSecondary)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _markSolved(entry, mistakes.length),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(56), backgroundColor: Colors.greenAccent, foregroundColor: Colors.black),
              child: const Text('Çözdüm!', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _markSolved(QuestionEntry entry, int remainingBefore) async {
    final repository = AppRepositoryScope.of(context);
    if (_currentIndex >= remainingBefore - 1 && _currentIndex > 0) {
      setState(() => _currentIndex = remainingBefore - 2);
    }
    await repository.markQuestionAsSolved(entry.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        ApiResponseSnackBar(message: 'Harika! Bir hata daha eksildi.'),
      );
    }
  }
}

class _MistakeCard extends StatelessWidget {
  const _MistakeCard({required this.entry});
  final QuestionEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GlassPanel(
        padding: const EdgeInsets.all(16),
        radius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(entry.subject, style: TextStyle(color: AppColors.of(context).primaryLight, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(entry.topic, style: TextStyle(color: AppColors.of(context).textSecondary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: InteractiveViewer(
                  child: Image.file(
                    File(entry.imagePaths.first),
                    fit: BoxFit.contain,
                    cacheWidth: 800,
                    errorBuilder: (_, __, ___) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.broken_image_outlined, size: 48, color: AppColors.of(context).textMuted),
                          SizedBox(height: 8),
                          Text('Görsel bulunamadı', style: TextStyle(color: AppColors.of(context).textSecondary)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (entry.note.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(entry.note, style: TextStyle(color: AppColors.of(context).textSecondary)),
            ],
          ],
        ),
      ),
    );
  }
}

class ApiResponseSnackBar extends SnackBar {
  ApiResponseSnackBar({super.key, required String message})
      : super(
          content: Text(message),
          backgroundColor: Colors.green.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        );
}
