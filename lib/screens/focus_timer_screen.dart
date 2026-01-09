import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class FocusTimerScreen extends StatelessWidget {
  const FocusTimerScreen({
    super.key,
    required this.remainingSeconds,
    required this.running,
    required this.onPause,
    required this.onResume,
    required this.onReset,
  });

  final ValueListenable<int> remainingSeconds;
  final ValueListenable<bool> running;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Odak Modu',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder<int>(
                      valueListenable: remainingSeconds,
                      builder: (context, seconds, _) {
                        return Text(
                          _formatTimer(seconds),
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    ValueListenableBuilder<bool>(
                      valueListenable: running,
                      builder: (context, isRunning, _) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: isRunning ? onPause : onResume,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              child: Text(isRunning ? 'Duraklat' : 'Devam Et'),
                            ),
                            const SizedBox(width: 12),
                            TextButton(
                              onPressed: onReset,
                              child: const Text('Sıfırla'),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatTimer(int totalSeconds) {
  final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
  final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
