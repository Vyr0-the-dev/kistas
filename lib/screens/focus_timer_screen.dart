import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_colors.dart';
import '../widgets/ambient_background.dart';
import '../widgets/glass_panel.dart';

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
                            SizedBox(width: 12),
                            TextButton(
                              onPressed: onReset,
                              child: Text('Sıfırla'),
                            ),
                          ],
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _AtmosphereButton(
                          label: 'Lo-Fi',
                          icon: Icons.headset,
                          url: 'https://www.youtube.com/watch?v=jfKfPfyJRdk',
                        ),
                        SizedBox(width: 12),
                        _AtmosphereButton(
                          label: 'Yağmur',
                          icon: Icons.umbrella,
                          url: 'https://www.youtube.com/watch?v=mPZkdNFkNps',
                        ),
                        SizedBox(width: 12),
                        _AtmosphereButton(
                          label: 'Kütüphane',
                          icon: Icons.local_library,
                          url: 'https://www.youtube.com/watch?v=4vIQON2fDWM',
                        ),
                      ],
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

class _AtmosphereButton extends StatelessWidget {
  const _AtmosphereButton({
    required this.label,
    required this.icon,
    required this.url,
  });

  final String label;
  final IconData icon;
  final String url;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Icon(icon, color: Colors.white70),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white54,
                ),
          ),
        ],
      ),
    );
  }
}

String _formatTimer(int totalSeconds) {
  final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
  final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
