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
                    color: AppColors.of(context).primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.auto_awesome, color: AppColors.of(context).primary),
                ),
                SizedBox(width: 12),
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
                  icon: Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),
            SizedBox(height: 16),
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
                        p: TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
                        h1: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        h2: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        h3: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                        strong: TextStyle(color: AppColors.of(context).primaryLight, fontWeight: FontWeight.bold),
                        em: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
                        code: TextStyle(
                          color: AppColors.of(context).primaryLight,
                          backgroundColor: Colors.transparent,
                          fontFamily: 'monospace',
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        listBullet: TextStyle(color: AppColors.of(context).primary),
                        blockquote: TextStyle(color: Colors.white70),
                        blockquoteDecoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border(left: BorderSide(color: AppColors.of(context).primary, width: 4)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.of(context).primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text('Tamam'),
            ),
          ],
        ),
      ),
    );
  }
}
