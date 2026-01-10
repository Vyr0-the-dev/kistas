import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/models/topic_summary.dart';
import '../../../core/models/mock_exam.dart';
import '../../../core/models/question_entry.dart';
import '../../../core/repositories/app_repository.dart';
import '../../../core/services/gemini_client.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ai_loading_dialog.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/in_app_notice.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _apiKeyController;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = AppRepositoryScope.of(context);

    if (_apiKeyController.text.isEmpty && repository.geminiApiKey.value.isNotEmpty) {
      _apiKeyController.text = repository.geminiApiKey.value;
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 140),
        children: [
          _buildBranding(context),
          const SizedBox(height: 24),
          _buildCollapsibleSection(
            context,
            title: 'Kişisel Hedefler',
            icon: Icons.person_outline,
            children: [
              ValueListenableBuilder<int>(
                valueListenable: repository.dailyGoal,
                builder: (context, goal, _) {
                  return _GoalRow(
                    value: goal,
                    onDecrease: () => repository.setDailyGoal(goal - 5),
                    onIncrease: () => repository.setDailyGoal(goal + 5),
                  );
                },
              ),
              const Divider(color: Colors.white10, height: 24),
              ValueListenableBuilder<DateTime>(
                valueListenable: repository.examDate,
                builder: (context, examDate, _) {
                  return _ExamDateRow(
                    value: examDate,
                    onTap: () => _selectExamDate(context, repository, examDate),
                  );
                },
              ),
            ],
          ),
          _buildCollapsibleSection(
            context,
            title: 'Sınav / Etiket Yönetimi',
            icon: Icons.label_important_outline,
            children: [
              ValueListenableBuilder<List<TopicSummary>>(
                valueListenable: repository.userTopics,
                builder: (context, allTopics, _) {
                  return _TagManagementList(
                    allTopics: allTopics,
                    onRename: (oldTag) => _renameTag(context, oldTag, allTopics),
                    onDelete: (tag) => _deleteTag(context, tag, allTopics),
                  );
                },
              ),
            ],
          ),
          _buildCollapsibleSection(
            context,
            title: 'AI Asistanı (Gemini)',
            icon: Icons.auto_awesome_outlined,
            children: [
              _AiConfigurationSection(
                controller: _apiKeyController,
                repository: repository,
              ),
              const Divider(color: Colors.white10, height: 32),
              _AiUsageTracker(repository: repository),
              const Divider(color: Colors.white10, height: 32),
              _AiGoalSection(repository: repository),
            ],
          ),
          _buildCollapsibleSection(
            context,
            title: 'Bildirimler',
            icon: Icons.notifications_none_outlined,
            children: [
              _ReminderSection(repository: repository),
            ],
          ),
          _buildCollapsibleSection(
            context,
            title: 'Görünüm & Tema',
            icon: Icons.palette_outlined,
            children: [
              ValueListenableBuilder<String>(
                valueListenable: repository.themeKey,
                builder: (context, themeKey, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Renk Teması',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      _ThemeGrid(
                        currentTheme: themeKey,
                        onThemeSelected: repository.setTheme,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          _buildCollapsibleSection(
            context,
            title: 'Veri Yönetimi',
            icon: Icons.storage_outlined,
            children: [
              _ProfileAction(
                title: 'Yedekleme Oluştur',
                subtitle: 'JSON olarak dışa aktar',
                icon: Icons.cloud_upload_outlined,
                onTap: () => _exportBackup(context, repository),
              ),
              const Divider(color: Colors.white10, height: 16),
              _ProfileAction(
                title: 'Yedek Yükle',
                subtitle: 'Dosyadan geri yükle',
                icon: Icons.cloud_download_outlined,
                onTap: () => _importBackup(context, repository),
              ),
              const Divider(color: Colors.white10, height: 16),
              _ProfileAction(
                title: 'Verileri Sıfırla',
                subtitle: 'Tüm kayıtları kalıcı olarak sil',
                icon: Icons.delete_forever_outlined,
                iconColor: AppColors.of(context).danger,
                onTap: () => _confirmReset(context, repository),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBranding(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/images/KISTAS.svg',
            width: 140,
            fit: BoxFit.contain,
          ),
          Transform.translate(
            offset: const Offset(0, -35),
            child: Text(
              'v1.0.0',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white38,
                    letterSpacing: 2,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsibleSection(
    BuildContext context,
    {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassPanel(
        padding: EdgeInsets.zero,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: Icon(icon, color: AppColors.of(context).primaryLight, size: 22),
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            expandedAlignment: Alignment.topLeft,
            children: children,
          ),
        ),
      ),
    );
  }

  Future<void> _selectExamDate(
    BuildContext context,
    AppRepository repository,
    DateTime currentDate,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      await repository.setExamDate(picked);
    }
  }

  Future<void> _renameTag(
    BuildContext context,
    String oldTag,
    List<TopicSummary> allTopics,
  ) async {
    final controller = TextEditingController(text: oldTag);
    final String? newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Etiketi Düzenle'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != oldTag && mounted) {
      final repository = AppRepositoryScope.of(context);
      final topicsToUpdate = allTopics
          .where((t) => t.tag == oldTag)
          .map((t) => t.copyWith(tag: newName))
          .toList();
      await repository.bulkUpdateUserTopics(topicsToUpdate);
      _showSnack(context, 'Etiket güncellendi.');
    }
  }

  Future<void> _deleteTag(
    BuildContext context,
    String tag,
    List<TopicSummary> allTopics,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sınavı Sil: $tag'),
        content: const Text(
          'Bu sınava ait tüm konular ve çalışma verileri silinecek. Emin misin?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
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
      _showSnack(context, '$tag sınavı ve konuları silindi.');
    }
  }
}

class _TagManagementList extends StatelessWidget {
  const _TagManagementList({
    required this.allTopics,
    required this.onRename,
    required this.onDelete,
  });

  final List<TopicSummary> allTopics;
  final Function(String) onRename;
  final Function(String) onDelete;

  @override
  Widget build(BuildContext context) {
    final tags = allTopics.map((e) => e.tag).toSet().toList();
    tags.sort();

    if (tags.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Henüz etiket yok.', style: TextStyle(color: Colors.white38)),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tags.length,
      separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1),
      itemBuilder: (context, index) {
        final tag = tags[index];
        final count = allTopics.where((t) => t.tag == tag).length;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            tag,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          subtitle: Text(
            '$count konu',
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white54, size: 18),
                onPressed: () => onRename(tag),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                onPressed: () => onDelete(tag),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AiConfigurationSection extends StatelessWidget {
  const _AiConfigurationSection({required this.controller, required this.repository});

  final TextEditingController controller;
  final AppRepository repository;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'API Yapılandırması',
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(hintText: 'Gemini API Anahtarı'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  final apiKey = controller.text.trim();
                  if (apiKey.isEmpty) {
                    _showSnack(context, 'API anahtarı boş olamaz.');
                    return;
                  }
                  await repository.setGeminiApiKey(apiKey);
                  if (!context.mounted) return;
                  await _fetchAndSelectModel(context, repository, apiKey);
                },
                child: const Text('Kaydet'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _fetchAndSelectModel(context, repository, controller.text),
                child: const Text('Model Seç'),
              ),
            ),
          ],
        ),
        ValueListenableBuilder<String>(
          valueListenable: repository.geminiModel,
          builder: (context, model, _) {
            if (model.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _ModelInfoCard(model: model),
            );
          },
        ),
      ],
    );
  }
}

class _AiUsageTracker extends StatelessWidget {
  const _AiUsageTracker({required this.repository});
  final AppRepository repository;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI Kullanım Takibi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
        ),
        const SizedBox(height: 6),
        const Text(
          'Bugün yapılan AI istekleri.',
          style: TextStyle(color: Colors.white54, fontSize: 11),
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<int>(
          valueListenable: repository.aiRequestCountToday,
          builder: (context, count, _) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.of(context).primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.of(context).primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.analytics, color: AppColors.of(context).primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bugünkü Kullanım',
                          style: TextStyle(color: Colors.white54, fontSize: 10),
                        ),
                        Text(
                          '$count İstek',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Limit: 1500',
                      style: TextStyle(color: Colors.white54, fontSize: 9),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AiGoalSection extends StatelessWidget {
  const _AiGoalSection({required this.repository});
  final AppRepository repository;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI Hedef Asistanı',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
        ),
        const SizedBox(height: 6),
        const Text(
          'Çalışma verilerine göre hedef önerir.',
          style: TextStyle(color: Colors.white54, fontSize: 11),
        ),
        const SizedBox(height: 12),
        _AiGoalDisplay(repository: repository),
        const SizedBox(height: 14),
        _AiCadenceSelector(repository: repository),
        const SizedBox(height: 12),
        _AiNotificationToggle(repository: repository),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _requestAiGoals(context, repository),
            icon: const Icon(Icons.auto_awesome),
            label: const Text('AI Hedef Öner'),
          ),
        ),
      ],
    );
  }
}

class _AiGoalDisplay extends StatelessWidget {
  const _AiGoalDisplay({required this.repository});
  final AppRepository repository;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, int>>(
      valueListenable: repository.aiGoalTargets,
      builder: (context, targets, _) {
        return ValueListenableBuilder<DateTime?>(
          valueListenable: repository.aiGoalUpdatedAt,
          builder: (context, updatedAt, __) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _AiGoalTile(label: 'Günlük', value: targets['daily'], suffix: 'soru'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _AiGoalTile(label: 'Haftalık', value: targets['weekly'], suffix: 'soru'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _AiGoalTile(label: 'Aylık', value: targets['monthly'], suffix: 'soru'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  updatedAt == null
                      ? 'Henüz hedef oluşturulmadı.'
                      : 'Son güncelleme: ${_formatDateTime(updatedAt)}',
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _AiGoalTile extends StatelessWidget {
  const _AiGoalTile({required this.label, required this.value, required this.suffix});
  final String label;
  final int? value;
  final String suffix;
  @override
  Widget build(BuildContext context) {
    final display = value == null ? '—' : value.toString();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9)),
          const SizedBox(height: 4),
          Text(
            '$display $suffix',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _AiCadenceSelector extends StatelessWidget {
  const _AiCadenceSelector({required this.repository});
  final AppRepository repository;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: repository.aiGoalCadence,
      builder: (context, cadence, _) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _AiCadenceChip(
              label: 'Günlük',
              isSelected: cadence == 'daily',
              onTap: () => repository.setAiGoalCadence('daily'),
            ),
            _AiCadenceChip(
              label: 'Haftalık',
              isSelected: cadence == 'weekly',
              onTap: () => repository.setAiGoalCadence('weekly'),
            ),
            _AiCadenceChip(
              label: 'Aylık',
              isSelected: cadence == 'monthly',
              onTap: () => repository.setAiGoalCadence('monthly'),
            ),
          ],
        );
      },
    );
  }
}

class _AiCadenceChip extends StatelessWidget {
  const _AiCadenceChip({required this.label, required this.isSelected, required this.onTap});
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.of(context).primary.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? AppColors.of(context).primary : Colors.white12,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white54,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class _AiNotificationToggle extends StatelessWidget {
  const _AiNotificationToggle({required this.repository});
  final AppRepository repository;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: repository.aiNotificationsEnabled,
      builder: (context, enabled, _) {
        return Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.of(context).primary.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.notifications, color: AppColors.of(context).primary),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Bildirimleri',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  Text(
                    'Öneriler bildirim kutusuna düşsün.',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: enabled,
              onChanged: repository.setAiNotificationsEnabled,
              activeColor: AppColors.of(context).primary,
            ),
          ],
        );
      },
    );
  }
}

class _ReminderSection extends StatelessWidget {
  const _ReminderSection({required this.repository});
  final AppRepository repository;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: repository.reminderEnabled,
      builder: (context, enabled, _) {
        return ValueListenableBuilder<String>(
          valueListenable: repository.reminderTime,
          builder: (context, time, __) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hedef Hatırlatıcısı',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.of(context).primary.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.alarm, color: AppColors.of(context).primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Günlük hedef uyarısı',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            enabled ? 'Saat $time' : 'Şu an kapalı',
                            style: const TextStyle(color: Colors.white54, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: enabled,
                      onChanged: (value) async {
                        await repository.setReminderEnabled(value);
                        if (value) {
                          await NotificationService.scheduleDailyReminder(
                            repository.reminderTime.value,
                          );
                        } else {
                          await NotificationService.cancelReminder();
                        }
                      },
                      activeColor: AppColors.of(context).primary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: enabled ? () => _pickReminderTime(context, repository) : null,
                    icon: const Icon(Icons.schedule, size: 18),
                    label: const Text('Saat Seç', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(height: 16),
                _WeeklyPlanSection(repository: repository),
              ],
            );
          },
        );
      },
    );
  }
}

class _WeeklyPlanSection extends StatelessWidget {
  const _WeeklyPlanSection({required this.repository});
  final AppRepository repository;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: repository.weeklyPlanEnabled,
      builder: (context, enabled, _) {
        return ValueListenableBuilder<String>(
          valueListenable: repository.weeklyPlanTime,
          builder: (context, time, __) {
            return ValueListenableBuilder<int>(
              valueListenable: repository.weeklyPlanWeekday,
              builder: (context, weekday, ___) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Haftalık Plan Bildirimi',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.of(context).primary.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.event_note, color: AppColors.of(context).primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Haftalık plan hatırlat',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                enabled ? '${_weekdayLabel(weekday)} • $time' : 'Şu an kapalı',
                                style: const TextStyle(color: Colors.white54, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: enabled,
                          onChanged: (value) async {
                            await repository.setWeeklyPlanEnabled(value);
                            if (value) {
                              await NotificationService.scheduleWeeklyPlanWithBody(
                                time: repository.weeklyPlanTime.value,
                                weekday: repository.weeklyPlanWeekday.value,
                                body: _weeklyPlanBody(repository),
                              );
                            } else {
                              await NotificationService.cancelWeeklyPlan();
                            }
                          },
                          activeColor: AppColors.of(context).primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: enabled ? () => _pickWeeklyPlanDay(context, repository) : null,
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: const Text('Gün', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: enabled ? () => _pickWeeklyPlanTime(context, repository) : null,
                            icon: const Icon(Icons.schedule, size: 16),
                            label: const Text('Saat', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _GoalButton extends StatelessWidget {
  const _GoalButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }
}

class _ModelInfoCard extends StatelessWidget {
  const _ModelInfoCard({required this.model});
  final String model;
  @override
  Widget build(BuildContext context) {
    final info = _getModelInfo(model);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.of(context).surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.of(context).primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.smart_toy, color: AppColors.of(context).primary, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  model,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(info.description, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ücretsiz Limitler',
                  style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                _LimitRow(label: 'Dakikalık İstek', value: info.rpm),
                _LimitRow(label: 'Günlük İstek', value: info.rpd),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LimitRow extends StatelessWidget {
  const _LimitRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
          Text(
            value,
            style: TextStyle(
              color: AppColors.of(context).primaryLight,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeGrid extends StatelessWidget {
  const _ThemeGrid({required this.currentTheme, required this.onThemeSelected});
  final String currentTheme;
  final Function(String) onThemeSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['midnight', 'ocean', 'volcanic', 'forest', 'royal'].map((key) {
            final config = _getThemeColor(key);
            return _ThemeOption(
              color: config.primary,
              label: config.label,
              isSelected: currentTheme == key,
              onTap: () => onThemeSelected(key),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['sunset', 'glacier', 'crimson', 'amber', 'graphite'].map((key) {
            final config = _getThemeColor(key);
            return _ThemeOption(
              color: config.primary,
              label: config.label,
              isSelected: currentTheme == key,
              onTap: () => onThemeSelected(key),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.color,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final Color color;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: Colors.white, width: 2)
                    : Border.all(color: Colors.white12, width: 1),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ]
                    : [],
              ),
              child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAction extends StatelessWidget {
  const _ProfileAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.iconColor,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.of(context).primary).withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.of(context).primary),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white54, fontSize: 11),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54, size: 20),
    );
  }
}

class _ExamDateRow extends StatelessWidget {
  const _ExamDateRow({required this.value, required this.onTap});
  final DateTime value;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.of(context).primary.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.event, color: AppColors.of(context).primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sınav Tarihi',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
              ),
              Text(
                '${value.day}.${value.month}.${value.year}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: onTap,
          child: const Text('Düzenle', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({required this.value, required this.onDecrease, required this.onIncrease});
  final int value;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.of(context).primary.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.flag, color: AppColors.of(context).primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Günlük Hedef',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
              ),
              Text('$value soru', style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ),
        Row(
          children: [
            _GoalButton(icon: Icons.remove, onTap: onDecrease),
            const SizedBox(width: 8),
            _GoalButton(icon: Icons.add, onTap: onIncrease),
          ],
        ),
      ],
    );
  }
}

// Global functions & Helpers
String _weekdayLabel(int weekday) {
  switch (weekday) {
    case DateTime.monday: return 'Pazartesi';
    case DateTime.tuesday: return 'Salı';
    case DateTime.wednesday: return 'Çarşamba';
    case DateTime.thursday: return 'Perşembe';
    case DateTime.friday: return 'Cuma';
    case DateTime.saturday: return 'Cumartesi';
    case DateTime.sunday: return 'Pazar';
    default: return 'Pazartesi';
  }
}

String _weeklyPlanBody(AppRepository repository) {
  final program = repository.aiProgramLast.value;
  if (program == null || program.trim().isEmpty) return 'Bu hafta için çalışma planını güncelle.';
  final firstLine = program.trim().split('\n').first;
  return firstLine.length > 120 ? '${firstLine.substring(0, 120)}…' : firstLine;
}

String _formatDateTime(DateTime dateTime) =>
    '${dateTime.day}.${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';

void _showSnack(BuildContext context, String message) => InAppNotice.show(context, message);

Future<void> Function() _showLoadingDialog(BuildContext context, String title) {
  bool isOpen = true;
  AiLoadingDialog.show(context, status: title).then((_) => isOpen = false);
  return () async {
    if (isOpen && context.mounted) Navigator.of(context).pop();
  };
}

Future<void> _fetchAndSelectModel(
  BuildContext context,
  AppRepository repository,
  String apiKey,
) async {
  if (apiKey.isEmpty) {
    _showSnack(context, 'Önce API anahtarını girin.');
    return;
  }
  final closeLoading = _showLoadingDialog(context, 'Modeller listeleniyor...');
  try {
    final client = GeminiClient();
    final models = await client.listModels(apiKey);
    closeLoading();
    if (!context.mounted || models.isEmpty) return;
    final selected = await showDialog<String>(
      context: context,
      builder: (context) {
        final currentModel = repository.geminiModel.value;
        return AlertDialog(
          title: const Text('Model Seç'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: models.length,
              itemBuilder: (context, index) {
                final model = models[index];
                final isActive = model == currentModel;
                return ListTile(
                  title: Text(
                    model,
                    style: TextStyle(
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive ? AppColors.of(context).primaryLight : Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  trailing: isActive
                      ? Icon(Icons.check, color: AppColors.of(context).primaryLight)
                      : null,
                  onTap: () => Navigator.of(context).pop(model),
                );
              },
            ),
          ),
        );
      },
    );
    if (selected != null && context.mounted) {
      await repository.setGeminiModel(selected);
      if (repository.geminiApiKey.value != apiKey) await repository.setGeminiApiKey(apiKey);
      _showSnack(context, 'Model seçildi: $selected');
    }
  } catch (e) {
    closeLoading();
    _showSnack(context, 'Hata: API anahtarını kontrol et.');
  }
}

Future<void> _requestAiGoals(BuildContext context, AppRepository repository) async {
  final apiKey = repository.geminiApiKey.value;
  if (apiKey.isEmpty) {
    _showSnack(context, 'Gemini anahtarını profilden ekle.');
    return;
  }
  final closeLoading = _showLoadingDialog(context, 'AI hedef hazırlanıyor...');
  try {
    final client = GeminiClient();
    final model =
        repository.geminiModel.value.isEmpty ? 'gemini-1.5-flash-latest' : repository.geminiModel.value;
    final entries = repository.questionEntries.value;
    final exams = repository.mockExams.value;
    final streak = _calculateStreak(entries, exams);
    final prompt =
        'KPSS/YKS adayı için çalışma verilerine göre JSON formatında günlük, haftalık ve aylık soru hedefi öner. Veri: $streak gün seri.';
    final result = await client.generateText(apiKey: apiKey, prompt: prompt, model: model);
    await repository.incrementAiRequestCount();
    closeLoading();
    if (context.mounted) {
      final parsed = _parseAiGoalResult(result);
      if (parsed != null) await _showAiGoalDialog(context, repository, parsed);
    }
  } catch (e) {
    closeLoading();
    _showSnack(context, 'AI hedef önerisi alınamadı.');
  }
}

_AiGoalResult? _parseAiGoalResult(String raw) {
  final match = RegExp(r'\{[\s\S]*\}').firstMatch(raw);
  if (match == null) return null;
  try {
    final decoded = jsonDecode(match.group(0)!);
    return _AiGoalResult(
      daily: decoded['daily'] ?? 50,
      weekly: decoded['weekly'] ?? 350,
      monthly: decoded['monthly'] ?? 1500,
      note: decoded['note'] ?? 'Başarılar!',
    );
  } catch (_) {
    return null;
  }
}

Future<void> _showAiGoalDialog(
  BuildContext context,
  AppRepository repository,
  _AiGoalResult goals,
) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('AI Hedef Önerisi'),
      content: Text(
        'Günlük: ${goals.daily}\nHaftalık: ${goals.weekly}\nAylık: ${goals.monthly}\n\n${goals.note}',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Kapat')),
        ElevatedButton(
          onPressed: () async {
            await repository.setDailyGoal(goals.daily);
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Uygula'),
        ),
      ],
    ),
  );
}

int _calculateStreak(List<QuestionEntry> entries, List<MockExam> exams) {
  final activityDates = <DateTime>{};
  for (final e in entries) {
    activityDates.add(DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day));
  }
  for (final e in exams) {
    activityDates.add(DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day));
  }
  if (activityDates.isEmpty) return 0;
  var streak = 0;
  var current = DateTime.now();
  while (true) {
    if (!activityDates.contains(DateTime(current.year, current.month, current.day))) break;
    streak++;
    current = current.subtract(const Duration(days: 1));
  }
  return streak;
}

Future<void> _exportBackup(BuildContext context, AppRepository repository) async {
  final data = repository.exportData();
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/kistas_backup.json');
  await file.writeAsString(data);
  await Share.shareXFiles([XFile(file.path)], text: 'Kıstas Yedeği');
}

Future<void> _importBackup(BuildContext context, AppRepository repository) async {
  final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
  if (result == null) return;
  try {
    final file = File(result.files.single.path!);
    final raw = await file.readAsString();
    await repository.importData(raw);
    if (context.mounted) _showSnack(context, 'Yedek yüklendi.');
  } catch (_) {
    if (context.mounted) _showSnack(context, 'Hata: Geçersiz yedek dosyası.');
  }
}

Future<void> _confirmReset(BuildContext context, AppRepository repository) async {
  final reset = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Verileri Sıfırla'),
      content: const Text('Tüm veriler silinecek. Emin misin?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Vazgeç')),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          child: const Text('Sil')
        ),
      ],
    ),
  );
  if (reset == true && context.mounted) {
    await repository.clearAll();
    _showSnack(context, 'Veriler sıfırlandı.');
  }
}

Future<void> _pickReminderTime(BuildContext context, AppRepository repository) async {
  final picked =
      await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 20, minute: 0));
  if (picked != null) {
    final time =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    await repository.setReminderTime(time);
    if (repository.reminderEnabled.value) await NotificationService.scheduleDailyReminder(time);
  }
}

Future<void> _pickWeeklyPlanDay(BuildContext context, AppRepository repository) async {
  final selected = await showModalBottomSheet<int>(
    context: context,
    builder: (context) => ListView(
      shrinkWrap: true,
      children: [1, 2, 3, 4, 5, 6, 7]
          .map((d) => ListTile(
                title: Text(_weekdayLabel(d)),
                onTap: () => Navigator.pop(context, d),
              ))
          .toList(),
    ),
  );
  if (selected != null) await repository.setWeeklyPlanWeekday(selected);
}

Future<void> _pickWeeklyPlanTime(BuildContext context, AppRepository repository) async {
  final picked =
      await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 9, minute: 0));
  if (picked != null) {
    await repository.setWeeklyPlanTime(
      '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
    );
  }
}

class _AiGoalResult {
  final int daily;
  final int weekly;
  final int monthly;
  final String note;
  _AiGoalResult({
    required this.daily,
    required this.weekly,
    required this.monthly,
    required this.note,
  });
}

class _ModelDetails {
  final String description;
  final String rpm;
  final String rpd;
  _ModelDetails(this.description, this.rpm, this.rpd);
}

_ModelDetails _getModelInfo(String model) {
  if (model.contains('1.5-flash')) return _ModelDetails('Hızlı ve dengeli model.', '15 RPM', '1500 RPD');
  if (model.contains('1.5-pro')) return _ModelDetails('En zeki ve kapsamlı model.', '2 RPM', '50 RPD');
  return _ModelDetails('Standart Gemini modeli.', '—', '—');
}

class _ThemeColorConfig {
  final Color primary;
  final String label;
  _ThemeColorConfig(this.primary, this.label);
}

_ThemeColorConfig _getThemeColor(String key) {
  switch (key) {
    case 'midnight':
      return _ThemeColorConfig(AppColors.midnight.primary, 'Midnight');
    case 'ocean':
      return _ThemeColorConfig(AppColors.ocean.primary, 'Okyanus');
    case 'volcanic':
      return _ThemeColorConfig(AppColors.volcanic.primary, 'Volkanik');
    case 'forest':
      return _ThemeColorConfig(AppColors.forest.primary, 'Orman');
    case 'royal':
      return _ThemeColorConfig(AppColors.royal.primary, 'Asil');
    case 'sunset':
      return _ThemeColorConfig(AppColors.sunset.primary, 'Sunset');
    case 'glacier':
      return _ThemeColorConfig(AppColors.glacier.primary, 'Buzul');
    case 'crimson':
      return _ThemeColorConfig(AppColors.crimson.primary, 'Lal');
    case 'amber':
      return _ThemeColorConfig(AppColors.amber.primary, 'Kehribar');
    case 'graphite':
      return _ThemeColorConfig(AppColors.graphite.primary, 'Grafit');
    default:
      return _ThemeColorConfig(Colors.blue, 'Bilinmeyen');
  }
}
