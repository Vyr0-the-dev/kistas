import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kistas/core/models/question_entry.dart';
import 'package:kistas/core/repositories/app_repository.dart';
import 'package:kistas/core/theme/app_colors.dart';
import 'package:kistas/core/widgets/glass_panel.dart';
import 'package:kistas/features/questions/screens/entry_wizard_screen.dart';
import 'mistake_solve_screen.dart';

class MistakeGalleryScreen extends StatefulWidget {
  const MistakeGalleryScreen({super.key, this.topicFilter});
  final String? topicFilter;

  @override
  State<MistakeGalleryScreen> createState() => _MistakeGalleryScreenState();
}

class _MistakeGalleryScreenState extends State<MistakeGalleryScreen> {
  String? _selectedTopic;

  @override
  void initState() {
    super.initState();
    _selectedTopic = widget.topicFilter;
  }

  @override
  Widget build(BuildContext context) {
    final repository = AppRepositoryScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(_selectedTopic ?? 'Hata Defteri'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_selectedTopic != null && widget.topicFilter == null) {
              setState(() => _selectedTopic = null);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome_motion, color: Colors.greenAccent),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MistakeSolveScreen()),
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder<List<QuestionEntry>>(
        valueListenable: repository.questionEntries,
        builder: (context, entries, _) {
          if (_selectedTopic == null) {
            return _buildTopicDeck(entries);
          } else {
            return _buildImageGrid(entries);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewMistake(context),
        backgroundColor: AppColors.of(context).primary,
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget _buildTopicDeck(List<QuestionEntry> entries) {
    // Group entries by topic that have images
    final Map<String, List<QuestionEntry>> topicGroups = {};
    for (final e in entries) {
      if (e.imagePaths.isNotEmpty) {
        topicGroups.putIfAbsent(e.topic, () => []).add(e);
      }
    }

    if (topicGroups.isEmpty) {
      return _buildEmptyState(context);
    }

    final topics = topicGroups.keys.toList()..sort();

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: topics.length,
      itemBuilder: (context, index) {
        final topic = topics[index];
        final count = topicGroups[topic]!.fold(0, (sum, e) => sum + e.imagePaths.length);
        final latestImage = topicGroups[topic]!.first.imagePaths.first;

        return GestureDetector(
          onTap: () => setState(() => _selectedTopic = topic),
          child: GlassPanel(
            padding: EdgeInsets.zero,
            radius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.2,
                    child: Image.file(
                      File(latestImage), 
                      fit: BoxFit.cover,
                      cacheWidth: 300, // Optimized for deck card
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        topic.isEmpty ? 'Konusuz' : topic,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$count Soru',
                        style: TextStyle(color: AppColors.of(context).primaryLight, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageGrid(List<QuestionEntry> entries) {
    final List<_MistakeImageItem> images = [];
    for (final e in entries) {
      if (e.topic == _selectedTopic) {
        for (var i = 0; i < e.imagePaths.length; i++) {
          images.add(_MistakeImageItem(entry: e, imagePath: e.imagePaths[i], index: i));
        }
      }
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) => _MistakeCard(item: images[index]),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.image_not_supported_outlined, size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          const Text('Henüz hatalı soru kaydetmedin.', style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 24),
          ElevatedButton.icon(onPressed: () => _addNewMistake(context), icon: const Icon(Icons.add_a_photo), label: const Text('Fotoğraf Ekle')),
        ],
      ),
    );
  }

  void _addNewMistake(BuildContext context) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.camera);
    if (xFile != null && context.mounted) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => EntryWizardScreen(type: EntryType.question, initialImagePath: xFile.path)));
    }
  }
}

class _MistakeImageItem {
  final QuestionEntry entry;
  final String imagePath;
  final int index;
  _MistakeImageItem({required this.entry, required this.imagePath, required this.index});
}

class _MistakeCard extends StatelessWidget {
  const _MistakeCard({required this.item});
  final _MistakeImageItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => _MistakeDetailScreen(item: item))),
      child: GlassPanel(
        padding: EdgeInsets.zero,
        radius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Hero(
                tag: 'mistake_${item.entry.id}_${item.index}',
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.file(
                    File(item.imagePath), 
                    fit: BoxFit.cover,
                    cacheWidth: 400, // Optimized for grid view
                    errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, color: Colors.white24))),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.entry.subject, style: TextStyle(color: AppColors.of(context).primaryLight, fontSize: 10, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(_formatDate(item.entry.createdAt), style: const TextStyle(color: Colors.white38, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}.${date.month}.${date.year}';
}

class _MistakeDetailScreen extends StatelessWidget {
  const _MistakeDetailScreen({required this.item});
  final _MistakeImageItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () => _deleteEntry(context)),
        ],
      ),
      body: Center(
        child: Hero(tag: 'mistake_${item.entry.id}_${item.index}', child: InteractiveViewer(child: Image.file(File(item.imagePath), fit: BoxFit.contain))),
      ),
      bottomSheet: Container(
        color: Colors.black87,
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${item.entry.subject} - ${item.entry.topic}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Kaynak: ${item.entry.bookName.isEmpty ? "Belirtilmedi" : item.entry.bookName}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
            if (item.entry.note.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(item.entry.note, style: const TextStyle(color: Colors.white70)),
            ],
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.check), label: const Text('Kapat'), style: OutlinedButton.styleFrom(foregroundColor: Colors.white))),
          ]),
        ),
      ),
    );
  }

  void _deleteEntry(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kaydı Sil?'),
        content: const Text('Bu test kaydı ve içerisindeki tüm fotoğraflar silinecek.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Vazgeç')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Sil')),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      await AppRepositoryScope.of(context).deleteQuestionEntry(item.entry.id);
      if (context.mounted) Navigator.pop(context);
    }
  }
}
