import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kistas/core/models/question_entry.dart';
import 'package:kistas/core/repositories/app_repository.dart';
import 'package:kistas/core/theme/app_colors.dart';
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
  Widget build(BuildContext context) {
    final repository = AppRepositoryScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Hata Çöz Modu'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<List<QuestionEntry>>(
        valueListenable: repository.questionEntries,
        builder: (context, entries, _) {
          final unsolvedMistakes = entries
              .where((e) => e.imagePaths.isNotEmpty && !e.isSolved)
              .toList();

          if (unsolvedMistakes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline, size: 80, color: Colors.greenAccent),
                  const SizedBox(height: 20),
                  const Text('Tebrikler! Tüm hataları çözdün.', style: TextStyle(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 30),
                  ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Geri Dön')),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: LinearProgressIndicator(
                  value: (unsolvedMistakes.length - _currentIndex) / unsolvedMistakes.length,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.of(context).primary),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentIndex = index),
                  itemCount: unsolvedMistakes.length,
                  itemBuilder: (context, index) {
                    final entry = unsolvedMistakes[index];
                    return _MistakeCard(entry: entry);
                  },
                ),
              ),
              _buildActions(unsolvedMistakes),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActions(List<QuestionEntry> mistakes) {
    final entry = mistakes[_currentIndex];
    final isLast = _currentIndex == mistakes.length - 1;

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
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56), side: const BorderSide(color: Colors.white24)),
              child: Text(isLast ? 'Başa Dön' : 'Atla', style: const TextStyle(color: Colors.white70)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _markSolved(entry),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(56), backgroundColor: Colors.greenAccent, foregroundColor: Colors.black),
              child: const Text('Çözdüm!', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _markSolved(QuestionEntry entry) async {
    final repository = AppRepositoryScope.of(context);
    await repository.markQuestionAsSolved(entry.id);
    ScaffoldMessenger.of(context).showSnackBar(ApiResponseSnackBar(message: 'Harika! Bir hata daha eksildi.'));
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
                Text(entry.topic, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: InteractiveViewer(
                  child: Image.file(
                    File(entry.imagePaths.first), // Show first image
                    fit: BoxFit.contain,
                    cacheWidth: 800, // Higher res for detail mode
                  ),
                ),
              ),
            ),
            if (entry.note.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(entry.note, style: const TextStyle(color: Colors.white70)),
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
