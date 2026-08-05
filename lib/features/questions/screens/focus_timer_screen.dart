import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../core/widgets/glass_panel.dart';

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
      backgroundColor: AppColors.of(context).background,
      body: AmbientBackground(
        child: SafeArea(
          child: Stack(
          children: [
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white54),
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
                    SizedBox(height: 16),
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
                    SizedBox(height: 24),
                    ValueListenableBuilder<int>(
                      valueListenable: remainingSeconds,
                      builder: (context, seconds, _) {
                        return ValueListenableBuilder<bool>(
                          valueListenable: running,
                          builder: (context, isRunning, _) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (seconds > 0) ...[
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
                                ],
                                TextButton(
                                  onPressed: onReset,
                                  child: const Text('Sıfırla'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    SizedBox(height: 40),
                    Text(
                      'Odaklanma Atmosferi',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white38,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                    ),
                    SizedBox(height: 16),
                    GlassPanel(
                      padding: const EdgeInsets.all(12),
                      radius: BorderRadius.circular(20),
                      child: Column(
                        children: [
                          _AtmosphereTile(
                            label: 'Lo-Fi Müzik (Ders Odaklı)',
                            subtitle: 'Uygulama içinde çalmaya devam eder',
                            icon: Icons.headset,
                            url: 'https://www.youtube.com/watch?v=jfKfPfyJRdk',
                          ),
                          const Divider(color: Colors.white10),
                          _AtmosphereTile(
                            label: 'Yağmur Sesi (Derin Odak)',
                            subtitle: 'Zihni sakinleştirir',
                            icon: Icons.umbrella,
                            url: 'https://www.youtube.com/watch?v=mPZkdNFkNps',
                          ),
                          const Divider(color: Colors.white10),
                          _AtmosphereTile(
                            label: 'Kütüphane Ambiyansı',
                            subtitle: 'Sınav atmosferi yaratır',
                            icon: Icons.local_library,
                            url: 'https://www.youtube.com/watch?v=4vIQON2fDWM',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _AtmosphereTile extends StatelessWidget {
  const _AtmosphereTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.url,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final String url;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.of(context).primary, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white38, fontSize: 11),
      ),
      trailing: const Icon(Icons.open_in_new, color: Colors.white24, size: 16),
    );
  }
}

String _formatTimer(int totalSeconds) {
  final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
  final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
