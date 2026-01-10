import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../core/models/flashcard.dart';
import '../../../core/repositories/app_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ambient_background.dart';
import '../../../core/widgets/glass_panel.dart';

// Helper to render basic math symbols as unicode for better visibility
String _sanitizeMath(String text) {
  return text
      .replaceAll('\$', '') // Remove LaTeX $ delimiters
      .replaceAll(r'\(', '') // Remove LaTeX \( delimiters
      .replaceAll(r'\)', '') // Remove LaTeX \) delimiters
      .replaceAll(r'\[', '') // Remove LaTeX \[ delimiters
      .replaceAll(r'\]', '') // Remove LaTeX \] delimiters
      .replaceAll('^2', '²')
      .replaceAll('^3', '³')
      .replaceAll('^n', 'ⁿ')
      .replaceAll('sqrt', '√')
      .replaceAll('<=', '≤')
      .replaceAll('>=', '≥')
      .replaceAll('!=', '≠')
      .replaceAll('->', '→');
}

class FlashcardStudyScreen extends StatefulWidget {
  const FlashcardStudyScreen({
    super.key,
    required this.cards,
    required this.topicTitle,
  });

  final List<Flashcard> cards;
  final String topicTitle;

  @override
  State<FlashcardStudyScreen> createState() => _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends State<FlashcardStudyScreen> {
  late final PageController _pageController;
  late List<Flashcard> _cards;
  int _currentIndex = 0;
  bool _showAnswer = false;

  @override
  void initState() {
    super.initState();
    _cards = List.from(widget.cards);
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _deleteCurrentCard() async {
    final card = _cards[_currentIndex];
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kartı Sil'),
        content: const Text('Bu bilgi kartını silmek istediğine emin misin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final repository = AppRepositoryScope.of(context);
      await repository.deleteFlashcard(widget.topicTitle, card.id);
      
      setState(() {
        _cards.removeAt(_currentIndex);
        if (_cards.isEmpty) {
          Navigator.of(context).pop();
          return;
        }
        if (_currentIndex >= _cards.length) {
          _currentIndex = _cards.length - 1;
        }
        _showAnswer = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _Header(
                title: widget.topicTitle,
                current: _currentIndex + 1,
                total: _cards.length,
                onDelete: _deleteCurrentCard,
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                      _showAnswer = false;
                    });
                  },
                  itemCount: _cards.length,
                  itemBuilder: (context, index) {
                    return _FlashcardItem(
                      card: _cards[index],
                      isFlipped: _showAnswer,
                      onFlip: () => setState(() => _showAnswer = !_showAnswer),
                    );
                  },
                ),
              ),
              _Controls(
                onPrev: _currentIndex > 0
                    ? () => _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        )
                    : null,
                onNext: _currentIndex < _cards.length - 1
                    ? () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.current,
    required this.total,
    required this.onDelete,
  });

  final String title;
  final int current;
  final int total;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white54),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Bilgi Kartları',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white38,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$current / $total',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.of(context).primaryLight,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            tooltip: 'Kartı Sil',
          ),
        ],
      ),
    );
  }
}

class _FlashcardItem extends StatelessWidget {
  const _FlashcardItem({
    required this.card,
    required this.isFlipped,
    required this.onFlip,
  });

  final Flashcard card;
  final bool isFlipped;
  final VoidCallback onFlip;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        final rotate = Tween(begin: pi, end: 0.0).animate(animation);
        return AnimatedBuilder(
          animation: rotate,
          child: child,
          builder: (context, child) {
            final isUnder = (ValueKey(isFlipped) != child!.key);
            var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
            tilt *= isUnder ? -1.0 : 1.0;
            final value = isUnder ? min(rotate.value, pi / 2) : rotate.value;
            return Transform(
              transform: Matrix4.rotationY(value)..setEntry(3, 0, tilt),
              alignment: Alignment.center,
              child: child,
            );
          },
        );
      },
      child: isFlipped ? _buildBack(context) : _buildFront(context),
    );
  }

  Widget _buildFront(BuildContext context) {
    return KeyedSubtree(
      key: const ValueKey(false),
      child: _CardBase(
        onTap: onFlip,
        color: AppColors.of(context).surface,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.help_outline, size: 48, color: Colors.white24),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: MarkdownBody(
                data: _sanitizeMath(card.question),
                styleSheet: MarkdownStyleSheet(
                  p: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                  textAlign: WrapAlignment.center,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Cevabı görmek için tıkla',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white38,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBack(BuildContext context) {
    return KeyedSubtree(
      key: const ValueKey(true),
      child: _CardBase(
        onTap: onFlip,
        color: AppColors.of(context).primary.withOpacity(0.15),
        borderColor: AppColors.of(context).primary.withOpacity(0.3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 48, color: Colors.greenAccent),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: MarkdownBody(
                data: _sanitizeMath(card.answer),
                styleSheet: MarkdownStyleSheet(
                  p: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                  textAlign: WrapAlignment.center,
                ),
              ),
            ),
            if (card.hint != null && card.hint!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'İpucu: ${card.hint}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white54,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CardBase extends StatelessWidget {
  const _CardBase({
    required this.child,
    required this.onTap,
    required this.color,
    this.borderColor,
  });

  final Widget child;
  final VoidCallback onTap;
  final Color color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassPanel(
          padding: EdgeInsets.zero,
          radius: BorderRadius.circular(32),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: borderColor ?? Colors.white.withOpacity(0.05)),
              borderRadius: BorderRadius.circular(32),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({this.onPrev, this.onNext});

  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Row(
        children: [
          _ControlButton(
            icon: Icons.arrow_back,
            onTap: onPrev,
            label: 'Önceki',
          ),
          const Spacer(),
          _ControlButton(
            icon: Icons.arrow_forward,
            onTap: onNext,
            label: 'Sonraki',
            isPrimary: true,
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    this.onTap,
    required this.label,
    this.isPrimary = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final String label;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isPrimary ? AppColors.of(context).primary : Colors.white12;
    final foregroundColor = isPrimary ? AppColors.of(context).onPrimary : Colors.white;
    return Opacity(
      opacity: onTap == null ? 0.4 : 1.0,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
