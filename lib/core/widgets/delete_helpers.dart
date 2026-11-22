import 'package:flutter/material.dart';

import '../models/mock_exam.dart';
import '../models/question_entry.dart';
import '../models/study_schedule_block.dart';
import '../repositories/app_repository.dart';
import '../theme/app_colors.dart';

Future<bool> confirmDeleteDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Sil',
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final colors = AppColors.of(dialogContext);
      return AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(color: colors.textSecondary, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.danger,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return confirmed == true;
}

Future<bool> deleteQuestionEntryWithUndo(
  BuildContext context,
  QuestionEntry entry,
) async {
  final repository = AppRepositoryScope.of(context);
  final hasScaffold = Scaffold.maybeOf(context) != null;
  final messenger = hasScaffold ? ScaffoldMessenger.maybeOf(context) : null;
  final label = entry.bookName.isNotEmpty
      ? entry.bookName
      : (entry.topic.isNotEmpty ? entry.topic : 'Soru Kaydı');

  final confirmed = await confirmDeleteDialog(
    context,
    title: 'Soru Kaydını Sil',
    message:
        '"$label" (${entry.subject} • ${entry.total} soru) kaydını silmek istediğine emin misin?',
  );
  if (!confirmed) return false;

  await repository.deleteQuestionEntry(entry.id);
  messenger?.clearSnackBars();
  messenger?.showSnackBar(
    SnackBar(
      content: Text('"$label" silindi.'),
      action: SnackBarAction(
        label: 'Geri Al',
        onPressed: () {
          repository.addQuestionEntry(entry);
        },
      ),
    ),
  );
  return true;
}

Future<bool> deleteMockExamWithUndo(
  BuildContext context,
  MockExam exam,
) async {
  final repository = AppRepositoryScope.of(context);
  final hasScaffold = Scaffold.maybeOf(context) != null;
  final messenger = hasScaffold ? ScaffoldMessenger.maybeOf(context) : null;
  final label = exam.title.isEmpty ? 'Deneme' : exam.title;

  final confirmed = await confirmDeleteDialog(
    context,
    title: 'Deneme Kaydını Sil',
    message:
        '"$label" (${exam.scopeSummary} • ${exam.totalNet.toStringAsFixed(1)} net) kaydını silmek istediğine emin misin?',
  );
  if (!confirmed) return false;

  await repository.deleteMockExam(exam.id);
  messenger?.clearSnackBars();
  messenger?.showSnackBar(
    SnackBar(
      content: Text('"$label" silindi.'),
      action: SnackBarAction(
        label: 'Geri Al',
        onPressed: () {
          repository.addMockExam(exam);
        },
      ),
    ),
  );
  return true;
}

Future<bool> deleteScheduleBlockWithUndo(
  BuildContext context,
  StudyScheduleBlock block,
) async {
  final repository = AppRepositoryScope.of(context);
  final hasScaffold = Scaffold.maybeOf(context) != null;
  final messenger = hasScaffold ? ScaffoldMessenger.maybeOf(context) : null;
  final label = block.topic.isNotEmpty
      ? '${block.subject} • ${block.topic}'
      : block.subject;

  final confirmed = await confirmDeleteDialog(
    context,
    title: 'Program Görevini Sil',
    message: '"$label" görevini haftalık programdan silmek istediğine emin misin?',
  );
  if (!confirmed) return false;

  await repository.deleteScheduleBlock(block.id);
  messenger?.clearSnackBars();
  messenger?.showSnackBar(
    SnackBar(
      content: Text('"$label" programdan silindi.'),
      action: SnackBarAction(
        label: 'Geri Al',
        onPressed: () {
          repository.addScheduleBlock(block);
        },
      ),
    ),
  );
  return true;
}
