import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../theme/app_colors.dart';
import 'glass_panel.dart';

class AiResponseDialog extends StatelessWidget {
  const AiResponseDialog({
    super.key,
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  static Future<void> show(BuildContext context, String title, String content) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (context) => AiResponseDialog(title: title, content: content),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: GlassPanel(
        padding: const EdgeInsets.all(20),
        radius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.auto_awesome, color: colors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: colors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Flexible(
              child: Container(
                padding: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: colors.subtleFill,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.border),
                ),
                child: Scrollbar(
                  thumbVisibility: true,
                  radius: const Radius.circular(4),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(14),
                    child: MarkdownBody(
                      data: content,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(color: colors.textPrimary, fontSize: 14.5, height: 1.5),
                        h1: TextStyle(color: colors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800),
                        h2: TextStyle(color: colors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
                        h3: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                        strong: TextStyle(color: colors.primary, fontWeight: FontWeight.w700),
                        em: TextStyle(color: colors.textSecondary, fontStyle: FontStyle.italic),
                        code: TextStyle(
                          color: colors.primary,
                          backgroundColor: colors.primary.withValues(alpha: 0.08),
                          fontFamily: 'monospace',
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: colors.surfaceLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        listBullet: TextStyle(color: colors.primary),
                        blockquote: TextStyle(color: colors.textSecondary),
                        blockquoteDecoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border(left: BorderSide(color: colors.primary, width: 3.5)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tamam'),
            ),
          ],
        ),
      ),
    );
  }
}
