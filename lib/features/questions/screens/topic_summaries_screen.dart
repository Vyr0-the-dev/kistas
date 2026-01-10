import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/models/topic_summary.dart';
import '../../../core/repositories/app_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../dashboard/screens/roadmap_screen.dart';
import 'topic_detail_screen.dart';

class TopicSummariesScreen extends StatefulWidget {
  const TopicSummariesScreen({super.key});

  @override
  State<TopicSummariesScreen> createState() => _TopicSummariesScreenState();
}

class _TopicSummariesScreenState extends State<TopicSummariesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _activeFilter = 'Tümü';
  String _activeTag = 'Tümü';
  bool _weakOnly = false;
  bool _staleOnly = false;
  TopicSort _activeSort = TopicSort.recent;
  final Set<String> _selectedIds = {};
  bool _manualSelectionMode = false;

  bool get _isSelectionMode => _manualSelectionMode || _selectedIds.isNotEmpty;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSelection(String id) {
    setState(() {
      _manualSelectionMode = true;
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedIds.clear();
      _manualSelectionMode = false;
    });
  }

  void _selectAll(List<TopicProgress> items) {
    setState(() {
      _manualSelectionMode = true;
      if (_selectedIds.length == items.length) {
        _selectedIds.clear();
      } else {
        for (final item in items) {
          _selectedIds.add(item.topic.id);
        }
      }
    });
  }

  Future<void> _deleteSelected() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${_selectedIds.length} Konuyu Sil'),
        content: const Text('Seçili konuları ve ilgili tüm verileri silmek istediğine emin misin?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Vazgeç')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final repository = AppRepositoryScope.of(context);
      for (final id in _selectedIds) {
        await repository.deleteUserTopic(id);
      }
      _clearSelection();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seçili konular silindi.')),
        );
      }
    }
  }

  Future<void> _updateSelectedTag() async {
    final controller = TextEditingController(text: 'KPSS');
    final newTag = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${_selectedIds.length} Konunun Etiketini Değiştir'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Yeni Etiket (Örn: YKS, DGS)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Vazgeç')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );

    if (newTag != null && newTag.isNotEmpty && mounted) {
      final repository = AppRepositoryScope.of(context);
      final currentTopics = repository.userTopics.value;
      
      for (final id in _selectedIds) {
        final topicIndex = currentTopics.indexWhere((t) => t.id == id);
        if (topicIndex != -1) {
          final updatedTopic = currentTopics[topicIndex].copyWith(tag: newTag);
          await repository.updateUserTopic(updatedTopic);
        }
      }
      _clearSelection();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Seçili konular "$newTag" olarak güncellendi.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final repository = AppRepositoryScope.of(context);

    return ValueListenableBuilder(
      valueListenable: repository.userTopics,
      builder: (context, currentTopics, _) {
        return ValueListenableBuilder(
          valueListenable: repository.questionEntries,
          builder: (context, _, __) {
            final progress = repository.buildTopicProgress();
            final filtered = _applyFilters(progress);
            return PopScope(
              canPop: !_isSelectionMode,
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) return;
                if (_isSelectionMode) {
                  _clearSelection();
                }
              },
              child: Scaffold(
                backgroundColor: Colors.transparent, // AmbientBackground zaten var
                appBar: _isSelectionMode 
                  ? AppBar(
                    backgroundColor: AppColors.of(context).surface,
                    title: Text('${_selectedIds.length} Seçildi'),
                    leading: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _clearSelection,
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.label_outline),
                        tooltip: 'Etiket Değiştir',
                        onPressed: _updateSelectedTag,
                      ),
                      IconButton(
                        icon: Icon(
                          _selectedIds.length == filtered.length 
                            ? Icons.deselect_outlined 
                            : Icons.select_all_outlined
                        ),
                        tooltip: 'Tümünü Seç/Kaldır',
                        onPressed: () => _selectAll(filtered),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: _deleteSelected,
                      ),
                    ],
                  )
                : null,
              body: Column(
                children: [
                  if (!_isSelectionMode)
                    _Header(
                      topics: currentTopics,
                      controller: _searchController,
                      onFilterChanged: (value) => setState(() {
                        _activeFilter = value;
                      }),
                      activeFilter: _activeFilter,
                      onTagChanged: (value) => setState(() {
                        _activeTag = value;
                        _activeFilter = 'Tümü';
                      }),
                      activeTag: _activeTag,
                      weakOnly: _weakOnly,
                      staleOnly: _staleOnly,
                      onToggleWeak: () => setState(() {
                        _weakOnly = !_weakOnly;
                      }),
                      onToggleStale: () => setState(() {
                        _staleOnly = !_staleOnly;
                      }),
                      onOpenSort: () => _openSortSheet(context),
                      onBulkAdd: () => _showBulkAddDialog(context),
                    ),
                  Expanded(
                    child: filtered.isEmpty 
                      ? _buildEmptyState(context)
                      : ListView.builder(
                          padding: EdgeInsets.fromLTRB(20, _isSelectionMode ? 16 : 16, 20, 120),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            final isSelected = _selectedIds.contains(item.topic.id);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _TopicCard(
                                progress: item,
                                isSelected: isSelected,
                                isSelectionMode: _isSelectionMode,
                                onTap: () {
                                  if (_isSelectionMode) {
                                    _toggleSelection(item.topic.id);
                                  } else {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => TopicDetailScreen(
                                          topic: item.topic,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                onLongPress: () => _toggleSelection(item.topic.id),
                              ),
                            );
                          },
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

  Widget _buildEmptyState(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_add, size: 64, color: Colors.white24),
          SizedBox(height: 16),
          Text(
            'Henüz konu yok.',
            style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Kendi konularını ekleyerek başlayabilirsin.',
            style: TextStyle(color: Colors.white38),
          ),
        ],
      ),
    );
  }

  void _showBulkAddDialog(BuildContext context) {
    final controller = TextEditingController();
    final tagController = TextEditingController(text: 'KPSS');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Toplu Konu Ekle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bir CSV dosyası seçebilir veya aşağıya manuel yazabilirsiniz.',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _pickAndProcessCsv(context, tagController.text),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('CSV Dosyası Seç'),
                ),
              ),
              const SizedBox(height: 16),
              const Center(child: Text('— VEYA —', style: TextStyle(fontSize: 10, color: Colors.white38))),
              const SizedBox(height: 16),
              const Text(
                'Sınav / Etiket (Örn: KPSS, YKS, DGS)',
                style: TextStyle(fontSize: 11, color: Colors.white54),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: tagController,
                decoration: const InputDecoration(
                  hintText: 'Sınav Türü',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Format: Ders,Konu Adı\nÖrn: Matematik,Üslü Sayılar',
                style: TextStyle(fontSize: 11, color: Colors.white54),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Ders,Konu\nDers,Konu...', 
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Vazgeç')),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              _processBulkAdd(context, text, tag: tagController.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _pickAndProcessCsv(BuildContext context, String tag) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt'],
      );

      if (result != null && result.files.single.bytes != null) {
        final content = String.fromCharCodes(result.files.single.bytes!);
        if (context.mounted) {
          _processBulkAdd(context, content, tag: tag);
          Navigator.pop(context); // Diyaloğu kapat
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dosya okuma hatası oluştu.')),
        );
      }
    }
  }

  void _processBulkAdd(BuildContext context, String text, {String tag = 'KPSS'}) async {
    final repository = AppRepositoryScope.of(context);
    final lines = text.split('\n');
    final List<TopicSummary> newTopics = [];

    for (var line in lines) {
      if (!line.contains(',')) continue;
      final parts = line.split(',');
      if (parts.length < 2) continue;
      
      final subject = parts[0].trim();
      final title = parts[1].trim();

      if (subject.isEmpty || title.isEmpty) continue;
      
      newTopics.add(TopicSummary(
        id: '${subject.toLowerCase()}-${title.toLowerCase().replaceAll(' ', '-')}-${DateTime.now().millisecondsSinceEpoch}-${newTopics.length}',
        subject: subject,
        title: title,
        nextReview: '',
        tag: tag.isEmpty ? 'KPSS' : tag,
      ));
    }

    if (newTopics.isNotEmpty) {
      await repository.addUserTopics(newTopics);
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${newTopics.length} konu başarıyla eklendi.')),
        );
      }
    }
  }

  List<TopicProgress> _applyFilters(List<TopicProgress> items) {
    final query = _searchController.text.trim().toLowerCase();
    var filtered = [...items];
    
    if (_activeTag != 'Tümü') {
      filtered = filtered.where((item) => item.topic.tag == _activeTag).toList();
    }

    if (_activeFilter != 'Tümü') {
      filtered = filtered.where((item) => item.topic.subject == _activeFilter).toList();
    }

    if (_weakOnly) {
      filtered = filtered.where((item) => item.totalQuestions > 0 && item.accuracy < 0.5).toList();
    }
    if (_staleOnly) {
      final now = DateTime.now();
      filtered = filtered.where((item) => item.lastStudied != null && now.difference(item.lastStudied!).inDays >= 7).toList();
    }
    if (query.isNotEmpty) {
      filtered = filtered.where((item) => item.topic.title.toLowerCase().contains(query) || item.topic.subject.toLowerCase().contains(query)).toList();
    }
    filtered.sort((a, b) => _sortByActive(a, b, _activeSort));
    return filtered;
  }

  void _openSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.of(context).surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Sıralama',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              _SortOption(
                label: 'En son çalışılan',
                active: _activeSort == TopicSort.recent,
                onTap: () => _selectSort(context, TopicSort.recent),
              ),
              _SortOption(
                label: 'Doğruluk düşükten yükseğe',
                active: _activeSort == TopicSort.accuracyLow,
                onTap: () => _selectSort(context, TopicSort.accuracyLow),
              ),
              _SortOption(
                label: 'Doğruluk yüksekten düşüğe',
                active: _activeSort == TopicSort.accuracyHigh,
                onTap: () => _selectSort(context, TopicSort.accuracyHigh),
              ),
              _SortOption(
                label: 'Toplam soru (yüksekten)',
                active: _activeSort == TopicSort.totalQuestions,
                onTap: () => _selectSort(context, TopicSort.totalQuestions),
              ),
              _SortOption(
                label: 'Alfabetik',
                active: _activeSort == TopicSort.alphabetical,
                onTap: () => _selectSort(context, TopicSort.alphabetical),
              ),
            ],
          ),
        );
      },
    );
  }

  void _selectSort(BuildContext context, TopicSort sort) {
    setState(() => _activeSort = sort);
    Navigator.of(context).pop();
  }

  void _showManageTagsSheet(BuildContext context, List<TopicSummary> allTopics) {
    final tags = allTopics.map((e) => e.tag).toSet().toList();
    tags.sort();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.of(context).surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 16),
            Text('Sınav / Etiket Yönetimi', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (tags.isEmpty)
              const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text('Henüz etiket yok.', style: TextStyle(color: Colors.white38)))
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: tags.length,
                  itemBuilder: (context, index) {
                    final tag = tags[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(tag, style: const TextStyle(color: Colors.white)),
                      subtitle: Text('${allTopics.where((t) => t.tag == tag).length} konu', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.white54, size: 20),
                            onPressed: () => _renameTag(context, tag, allTopics),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                            onPressed: () => _deleteTag(context, tag, allTopics),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _renameTag(BuildContext context, String oldTag, List<TopicSummary> allTopics) async {
    final controller = TextEditingController(text: oldTag);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Etiketi Düzenle'),
        content: TextField(controller: controller, decoration: const InputDecoration(border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Vazgeç')),
          ElevatedButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Güncelle')),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != oldTag && mounted) {
      final repository = AppRepositoryScope.of(context);
      final topicsToUpdate = allTopics.where((t) => t.tag == oldTag).map((t) => t.copyWith(tag: newName)).toList();
      await repository.bulkUpdateUserTopics(topicsToUpdate);
      Navigator.pop(context); // Sheet'i kapat
      _showSnack(context, 'Etiket güncellendi.');
    }
  }

  Future<void> _deleteTag(BuildContext context, String tag, List<TopicSummary> allTopics) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sınavı Sil: $tag'),
        content: Text('Bu sınava ait tüm konular ve çalışma verileri silinecek. Emin misin?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Vazgeç')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Hepsini Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final repository = AppRepositoryScope.of(context);
      final idsToDelete = allTopics.where((t) => t.tag == tag).map((t) => t.id).toList();
      for (final id in idsToDelete) {
        await repository.deleteUserTopic(id);
      }
      Navigator.pop(context); // Sheet'i kapat
      _showSnack(context, '$tag sınavı ve konuları silindi.');
    }
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.topics,
    required this.controller,
    required this.onFilterChanged,
    required this.activeFilter,
    required this.onTagChanged,
    required this.activeTag,
    required this.weakOnly,
    required this.staleOnly,
    required this.onToggleWeak,
    required this.onToggleStale,
    required this.onOpenSort,
    required this.onBulkAdd,
  });

  final List<TopicSummary> topics;
  final TextEditingController controller;
  final ValueChanged<String> onFilterChanged;
  final String activeFilter;
  final ValueChanged<String> onTagChanged;
  final String activeTag;
  final bool weakOnly;
  final bool staleOnly;
  final VoidCallback onToggleWeak;
  final VoidCallback onToggleStale;
  final VoidCallback onOpenSort;
  final VoidCallback onBulkAdd;

  @override
  Widget build(BuildContext context) {
    final tags = topics.map((e) => e.tag).toSet().toList();
    tags.sort();

    final filteredTopics = activeTag == 'Tümü' 
        ? topics 
        : topics.where((t) => t.tag == activeTag).toList();
    final subjects = filteredTopics.map((e) => e.subject).toSet().toList();
    subjects.sort();

    return GlassPanel(
      padding: EdgeInsets.zero,
      radius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Konular',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: onBulkAdd,
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.of(context).primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.add, color: Colors.white70),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const RoadmapScreen()),
                        ),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.of(context).primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.map, color: AppColors.of(context).primaryLight),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: AppColors.of(context).textSecondary),
                  hintText: 'Konu, ders veya etiket ara...'
                ),
                onChanged: (_) => onFilterChanged(activeFilter),
              ),
            ),
            const SizedBox(height: 12),
            if (tags.length > 1) ...[
              SizedBox(
                height: 32,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _TagChip(
                      label: 'Tümü',
                      active: activeTag == 'Tümü',
                      onTap: () => onTagChanged('Tümü'),
                    ),
                    ...tags.map((tag) => _TagChip(
                      label: tag,
                      active: activeTag == tag,
                      onTap: () => onTagChanged(tag),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _ChipButton(
                    label: 'Tümü',
                    active: activeFilter == 'Tümü',
                    onTap: () => onFilterChanged('Tümü'),
                  ),
                  ...subjects.map((subject) => _ChipButton(
                    label: subject,
                    active: activeFilter == subject,
                    onTap: () => onFilterChanged(subject),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onOpenSort,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.of(context).surface,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.sort, color: Colors.white70, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Sırala',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(width: 1, height: 24, color: Colors.white12),
                  const SizedBox(width: 12),
                  _FilterToggle(
                    label: 'Zayıf',
                    color: AppColors.of(context).danger,
                    active: weakOnly,
                    onTap: onToggleWeak,
                  ),
                  const SizedBox(width: 8),
                  _FilterToggle(
                    label: 'Uzun süre önce',
                    color: AppColors.of(context).warning,
                    icon: Icons.history,
                    active: staleOnly,
                    onTap: onToggleStale,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.of(context).primaryLight.withValues(alpha: 0.3) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: active ? AppColors.of(context).primaryLight : Colors.white12,
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: active ? Colors.white : Colors.white38,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                ),
          ),
        ),
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  const _ChipButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.of(context).primary : AppColors.of(context).surface,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: active ? Theme.of(context).colorScheme.onPrimary : AppColors.of(context).textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}

class _FilterToggle extends StatelessWidget {
  const _FilterToggle({
    required this.label,
    required this.color,
    this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.2) : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: active ? 0.5 : 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
            ] else
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.progress,
    required this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.isSelectionMode = false,
  });

  final TopicProgress progress;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final bool isSelectionMode;

  @override
  Widget build(BuildContext context) {
    final status = _statusFromProgress(context, progress);
    final statusColor = status.color;
    final timeLabel = progress.lastStudied == null
        ? 'Hiç çalışılmadı'
        : '${_daysAgo(progress.lastStudied!)} gün önce';

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.of(context).primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: GlassPanel(
          padding: const EdgeInsets.all(16),
          radius: BorderRadius.circular(18),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  progress.topic.title,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                if (progress.topic.importance >= 4) ...[
                                  const SizedBox(width: 6),
                                  const Icon(Icons.local_fire_department,
                                      color: Colors.orangeAccent, size: 18),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${progress.topic.subject} • ${progress.topic.tag}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.of(context).textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      if (!isSelectionMode)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(status.icon, color: statusColor, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    progress.totalQuestions == 0 ? '—' : '%${progress.progressPercent}',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: statusColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              timeLabel,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.of(context).textSecondary,
                                  ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'İlerleme',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.of(context).textSecondary,
                            ),
                      ),
                      Text(
                        progress.totalQuestions == 0 ? '0%' : '%${progress.progressPercent}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress.progressRatio,
                      minHeight: 6,
                      backgroundColor: AppColors.of(context).surfaceLight,
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                  ),
                ],
              ),
              if (isSelectionMode)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.of(context).primary : Colors.black26,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Icon(
                      isSelected ? Icons.check : Icons.circle_outlined,
                      size: 16,
                      color: isSelected ? Colors.black : Colors.white38,
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

class _StatusInfo {
  const _StatusInfo({required this.icon, required this.color});
  final IconData icon;
  final Color color;
}

_StatusInfo _statusFromProgress(BuildContext context, TopicProgress progress) {
  if (progress.totalQuestions == 0) return const _StatusInfo(icon: Icons.remove, color: Colors.white54);
  if (progress.accuracy < 0.5) return _StatusInfo(icon: Icons.warning, color: AppColors.of(context).danger);
  if (progress.accuracy >= 0.8) return _StatusInfo(icon: Icons.check_circle, color: AppColors.of(context).success);
  return _StatusInfo(icon: Icons.trending_up, color: AppColors.of(context).warning);
}

int _daysAgo(DateTime date) {
  final now = DateTime.now();
  return now.difference(date).inDays;
}

int _sortByActive(TopicProgress a, TopicProgress b, TopicSort sort) {
  switch (sort) {
    case TopicSort.recent: return _compareDatesDesc(a.lastStudied, b.lastStudied);
    case TopicSort.accuracyLow: return a.accuracy.compareTo(b.accuracy);
    case TopicSort.accuracyHigh: return b.accuracy.compareTo(a.accuracy);
    case TopicSort.totalQuestions: return b.totalQuestions.compareTo(a.totalQuestions);
    case TopicSort.alphabetical: return a.topic.title.compareTo(b.topic.title);
  }
}

int _compareDatesDesc(DateTime? a, DateTime? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  return b.compareTo(a);
}

enum TopicSort { recent, accuracyLow, accuracyHigh, totalQuestions, alphabetical }

class _SortOption extends StatelessWidget {
  const _SortOption({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
      trailing: active ? Icon(Icons.check_circle, color: AppColors.of(context).primary) : const Icon(Icons.circle_outlined, color: Colors.white38),
    );
  }
}
