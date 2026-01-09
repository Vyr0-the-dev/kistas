import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'glass_panel.dart';

class AiLoadingDialog extends StatefulWidget {
  const AiLoadingDialog({super.key, required this.status});

  final String status;

  static Future<T?> show<T>(BuildContext context, {String status = 'AI düşünüyor...'}) {
    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (_) => AiLoadingDialog(status: status),
    );
  }

  @override
  State<AiLoadingDialog> createState() => _AiLoadingDialogState();
}

class _AiLoadingDialogState extends State<AiLoadingDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _opacityAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.of(context).primary.withOpacity(_opacityAnimation.value * 0.6),
                        blurRadius: 30 * _scaleAnimation.value,
                        spreadRadius: 5,
                      ),
                      BoxShadow(
                        color: AppColors.of(context).primaryLight.withOpacity(_opacityAnimation.value * 0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.of(context).primaryLight,
                                AppColors.of(context).primary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 32,
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 32),
            GlassPanel(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              radius: BorderRadius.circular(16),
              child: Text(
                widget.status,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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
