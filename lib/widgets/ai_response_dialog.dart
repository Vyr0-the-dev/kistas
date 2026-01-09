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
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (context) => AiResponseDialog(title: title, content: content),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: GlassPanel(
        padding: const EdgeInsets.all(24),
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
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: Container(
                padding: const EdgeInsets.only(right: 8), // For scrollbar space
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Scrollbar(
                  thumbVisibility: true,
                  radius: const Radius.circular(4),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: MarkdownBody(
                      data: content,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
                        h1: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        h2: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        h3: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                        strong: const TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.bold),
                        em: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
                        code: const TextStyle(
                          color: AppColors.primaryLight,
                          backgroundColor: Colors.transparent,
                          fontFamily: 'monospace',
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        listBullet: const TextStyle(color: AppColors.primary),
                        blockquote: const TextStyle(color: Colors.white70),
                        blockquoteDecoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: const Border(left: BorderSide(color: AppColors.primary, width: 4)),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text('Tamam'),
            ),
          ],
        ),
      ),
    );
  }
}
