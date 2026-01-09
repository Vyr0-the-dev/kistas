import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/app_notification.dart';
import '../models/mock_exam.dart';
import '../models/question_entry.dart';
import '../services/app_repository.dart';
import '../services/gemini_client.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';
import '../widgets/ai_loading_dialog.dart';
import '../widgets/ai_response_dialog.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/glass_panel.dart';
import '../widgets/in_app_notice.dart';
import 'analysis_screen.dart';
import 'home_screen.dart';
import 'quick_add_screen.dart';
import 'topic_summaries_screen.dart';

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
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 140),
          children: [
            Text(
              'Profil',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            SizedBox(height: 6),
            Text(
              'Verilerini güvenle yönet ve yedekle.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.of(context).textSecondary,
                  ),
            ),
            SizedBox(height: 20),
            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const Divider(color: Colors.white12, height: 24),
                  _AiUsageTracker(repository: repository),
                  const Divider(color: Colors.white12, height: 24),
                  _AiGoalSection(repository: repository),
                  const Divider(color: Colors.white12, height: 24),
                  _ReminderSection(repository: repository),
                  const Divider(color: Colors.white12, height: 24),
                  ValueListenableBuilder<String>(
                    valueListenable: repository.themeKey,
                    builder: (context, themeKey, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tema',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          SizedBox(height: 12),
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              _ThemeOption(
                                color: AppColors.midnight.primary,
                                label: 'Midnight',
                                isSelected: themeKey == 'midnight',
                                onTap: () => repository.setTheme('midnight'),
                              ),
                              _ThemeOption(
                                color: AppColors.ocean.primary,
                                label: 'Okyanus',
                                isSelected: themeKey == 'ocean',
                                onTap: () => repository.setTheme('ocean'),
                              ),
                              _ThemeOption(
                                color: AppColors.volcanic.primary,
                                label: 'Volkanik',
                                isSelected: themeKey == 'volcanic',
                                onTap: () => repository.setTheme('volcanic'),
                              ),
                              _ThemeOption(
                                color: AppColors.forest.primary,
                                label: 'Orman',
                                isSelected: themeKey == 'forest',
                                onTap: () => repository.setTheme('forest'),
                              ),
                              _ThemeOption(
                                color: AppColors.royal.primary,
                                label: 'Asil',
                                isSelected: themeKey == 'royal',
                                onTap: () => repository.setTheme('royal'),
                              ),
                              _ThemeOption(
                                color: AppColors.sunset.primary,
                                label: 'Sunset',
                                isSelected: themeKey == 'sunset',
                                onTap: () => repository.setTheme('sunset'),
                              ),
                              _ThemeOption(
                                color: AppColors.glacier.primary,
                                label: 'Buzul',
                                isSelected: themeKey == 'glacier',
                                onTap: () => repository.setTheme('glacier'),
                              ),
                              _ThemeOption(
                                color: AppColors.crimson.primary,
                                label: 'Lal',
                                isSelected: themeKey == 'crimson',
                                onTap: () => repository.setTheme('crimson'),
                              ),
                              _ThemeOption(
                                color: AppColors.amber.primary,
                                label: 'Kehribar',
                                isSelected: themeKey == 'amber',
                                onTap: () => repository.setTheme('amber'),
                              ),
                              _ThemeOption(
                                color: AppColors.graphite.primary,
                                label: 'Grafit',
                                isSelected: themeKey == 'graphite',
                                onTap: () => repository.setTheme('graphite'),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const Divider(color: Colors.white12, height: 24),
                  ValueListenableBuilder<String>(
                    valueListenable: repository.geminiApiKey,
                    builder: (context, key, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gemini API Anahtarı',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: _apiKeyController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: 'AIza...',
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () async {
                                    final apiKey = _apiKeyController.text.trim();
                                    if (apiKey.isEmpty) {
                                      _showSnack(
                                          context, 'API anahtarı boş olamaz.');
                                      return;
                                    }
                                    await repository.setGeminiApiKey(apiKey);
                                    if (!context.mounted) {
                                      return;
                                    }
                                    await _fetchAndSelectModel(
                                        context, repository, apiKey);
                                  },
                                  child: Text('Kaydet'),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _fetchAndSelectModel(
                                    context,
                                    repository,
                                    _apiKeyController.text,
                                  ),
                                  child: Text('Model Seç'),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          ValueListenableBuilder<String>(
                            valueListenable: repository.geminiModel,
                            builder: (context, model, _) {
                              if (model.isEmpty) {
                                return SizedBox.shrink();
                              }
                              return _ModelInfoCard(model: model);
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  const Divider(color: Colors.white12, height: 24),
                  _ProfileAction(
                    title: 'Yedekleme Oluştur',
                    subtitle: 'Verilerini JSON olarak dışa aktar.',
                    icon: Icons.cloud_upload,
                    onTap: () => _exportBackup(context, repository),
                  ),
                  const Divider(color: Colors.white12, height: 24),
                  _ProfileAction(
                    title: 'İçe Aktar',
                    subtitle: 'Önceki yedeği geri yükle.',
                    icon: Icons.cloud_download,
                    onTap: () => _importBackup(context, repository),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            GlassPanel(
              child: _ProfileAction(
                title: 'Verileri Sıfırla',
                subtitle: 'Tüm soru ve deneme kayıtlarını sil.',
                icon: Icons.delete_forever,
                iconColor: AppColors.of(context).danger,
                onTap: () => _confirmReset(context, repository),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        activeIndex: 4,
        onSelect: (index) => _navigateFromNav(context, index),
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
          color: (iconColor ?? AppColors.of(context).primary).withOpacity(0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.of(context).primary),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.of(context).textSecondary,
            ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.white54),
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
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.white, width: 3)
                  : Border.all(color: Colors.white12, width: 1),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 12,
                        spreadRadius: 2,
                      )
                    ]
                  : [],
            ),
            child: isSelected
                ? Icon(Icons.check, color: Colors.white, size: 28)
                : null,
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isSelected ? Colors.white : AppColors.of(context).textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
          ),
        ],
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({
    required this.value,
    required this.onDecrease,
    required this.onIncrease,
  });

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
            color: AppColors.of(context).primary.withOpacity(0.18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.flag, color: AppColors.of(context).primary),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Günlük Hedef',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                '$value soru',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.of(context).textSecondary,
                    ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            _GoalButton(icon: Icons.remove, onTap: onDecrease),
            SizedBox(width: 8),
            _GoalButton(icon: Icons.add, onTap: onIncrease),
          ],
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
        Text(
          'AI Hedef Asistanı',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
        SizedBox(height: 6),
        Text(
          'Çalışma verilerine göre günlük/haftalık/aylık hedef önerir.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.of(context).textSecondary,
              ),
        ),
        SizedBox(height: 12),
        ValueListenableBuilder<Map<String, int>>(
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
                          child: _AiGoalTile(
                            label: 'Günlük',
                            value: targets['daily'],
                            suffix: 'soru',
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: _AiGoalTile(
                            label: 'Haftalık',
                            value: targets['weekly'],
                            suffix: 'soru',
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: _AiGoalTile(
                            label: 'Aylık',
                            value: targets['monthly'],
                            suffix: 'soru',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      updatedAt == null
                          ? 'Henüz hedef oluşturulmadı.'
                          : 'Son güncelleme: ${_formatDateTime(updatedAt)}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.of(context).textSecondary,
                          ),
                    ),
                  ],
                );
              },
            );
          },
        ),
        SizedBox(height: 14),
        ValueListenableBuilder<String>(
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
        ),
        SizedBox(height: 12),
        ValueListenableBuilder<bool>(
          valueListenable: repository.aiNotificationsEnabled,
          builder: (context, enabled, _) {
            return Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.of(context).primary.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      Icon(Icons.notifications, color: AppColors.of(context).primary),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Bildirimleri',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Text(
                        'Öneriler bildirim kutusuna düşsün.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.of(context).textSecondary,
                            ),
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
        ),
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _requestAiGoals(context, repository),
            icon: Icon(Icons.auto_awesome),
            label: Text('AI Hedef Öner'),
          ),
        ),
        SizedBox(height: 12),
        ValueListenableBuilder<String?>(
          valueListenable: repository.aiProgramLast,
          builder: (context, program, _) {
            return ValueListenableBuilder<DateTime?>(
              valueListenable: repository.aiProgramUpdatedAt,
              builder: (context, updatedAt, __) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      updatedAt == null
                          ? 'Henüz bir program oluşturulmadı.'
                          : 'Son program: ${_formatDateTime(updatedAt)}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.of(context).textSecondary,
                          ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _AiGoalTile extends StatelessWidget {
  const _AiGoalTile({
    required this.label,
    required this.value,
    required this.suffix,
  });

  final String label;
  final int? value;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final display = value == null ? '—' : value.toString();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.of(context).textSecondary,
                  letterSpacing: 0.4,
                ),
          ),
          SizedBox(height: 4),
          Text(
            '$display $suffix',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _AiCadenceChip extends StatelessWidget {
  const _AiCadenceChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.of(context).primary.withOpacity(0.2)
              : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? AppColors.of(context).primary : Colors.white12,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isSelected ? Colors.white : AppColors.of(context).textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
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
                Text(
                  'Hedef Hatırlatıcısı',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.of(context).primary.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          Icon(Icons.alarm, color: AppColors.of(context).primary),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Günlük hedef uyarısı',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            enabled
                                ? 'Saat $time'
                                : 'Şu an kapalı',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppColors.of(context).textSecondary,
                                ),
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
                SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _requestExactAlarm(context),
                    icon: Icon(Icons.settings_suggest),
                    label: Text('Alarm İzni Kontrol'),
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: enabled
                        ? () => _pickReminderTime(context, repository)
                        : null,
                    icon: Icon(Icons.schedule),
                    label: Text('Saat Seç'),
                  ),
                ),
                SizedBox(height: 16),
                _WeeklyPlanSection(repository: repository),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await NotificationService.showReminderNow('Bu bir test bildirimidir.');
                      if (!context.mounted) return;
                      _showSnack(context, 'Test bildirimi gönderildi.');
                    },
                    icon: Icon(Icons.notifications_active),
                    label: Text('Test Bildirimi Gönder'),
                  ),
                ),
                SizedBox(height: 8),
                TextButton(
                  onPressed: () async {
                    final granted = await NotificationService.requestExactAlarmPermission();
                    if (!context.mounted) return;
                    _showSnack(
                      context, 
                      granted ? 'Tam zamanlı alarm izni var.' : 'İzin verilmedi. Ayarlardan açın.',
                    );
                  },
                  child: Text('Kesin Alarm İznini Kontrol Et (Android 12+)'),
                ),
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
                    Text(
                      'Haftalık Plan Bildirimi',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.of(context).primary.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.event_note,
                              color: AppColors.of(context).primary),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Haftalık plan hatırlat',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              Text(
                                enabled
                                    ? '${_weekdayLabel(weekday)} • $time'
                                    : 'Şu an kapalı',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.of(context).textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: enabled,
                          onChanged: (value) async {
                            await repository.setWeeklyPlanEnabled(value);
                            if (value) {
                              await NotificationService
                                  .scheduleWeeklyPlanWithBody(
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
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: enabled
                                ? () => _pickWeeklyPlanDay(
                                      context,
                                      repository,
                                    )
                                : null,
                            icon: Icon(Icons.calendar_today),
                            label: Text('Gün Seç'),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: enabled
                                ? () => _pickWeeklyPlanTime(
                                      context,
                                      repository,
                                    )
                                : null,
                            icon: Icon(Icons.schedule),
                            label: Text('Saat Seç'),
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
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white70),
      ),
    );
  }
}

class _AiGoalResult {
  const _AiGoalResult({
    required this.daily,
    required this.weekly,
    required this.monthly,
    required this.note,
  });

  final int daily;
  final int weekly;
  final int monthly;
  final String note;
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

    if (!context.mounted) {
      return;
    }
    // Navigator.of(context).pop();

    if (models.isEmpty) {
      _showSnack(context, 'Hiçbir model bulunamadı.');
      return;
    }

    final selected = await showDialog<String>(
      context: context,
      builder: (context) {
        final currentModel = repository.geminiModel.value;
        return AlertDialog(
          title: Text('Model Seç'),
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
                    ),
                  ),
                  trailing: isActive ? Icon(Icons.check, color: AppColors.of(context).primaryLight) : null,
                  onTap: () => Navigator.of(context).pop(model),
                );
              },
            ),
          ),
        );
      },
    );

    if (selected != null) {
      await repository.setGeminiModel(selected);
      // Also save the API key if it hasn't been saved yet
      if (repository.geminiApiKey.value != apiKey) {
        await repository.setGeminiApiKey(apiKey);
      }
      if (!context.mounted) {
        return;
      }
      _showSnack(context, 'Model seçildi: $selected');
    }
  } catch (e) {
    closeLoading();
    if (!context.mounted) {
      return;
    }
    // Navigator.of(context).pop();
    
    String message = 'Hata: ${e.toString().replaceAll("Exception: ", "")}';
    if (e.toString().contains('429')) {
      message = 'API kotası aşıldı. Lütfen daha sonra tekrar deneyin.';
    } else if (e.toString().contains('503')) {
      message = 'AI servisi yoğun. Lütfen daha sonra deneyin.';
    }
    _showSnack(context, message);
  }
}

Future<void> _requestAiGoals(
  BuildContext context,
  AppRepository repository,
) async {
  final apiKey = repository.geminiApiKey.value;
  if (apiKey.isEmpty) {
    _showSnack(context, 'Gemini anahtarını profilden ekle.');
    return;
  }

  final entries = repository.questionEntries.value;
  final exams = repository.mockExams.value;
  final now = DateTime.now();

  final last7Questions = _sumQuestionsSince(entries, now, 7);
  final last7Minutes = _sumMinutesSince(entries, now, 7);
  final last30Questions = _sumQuestionsSince(entries, now, 30);
  final avgNet = _averageNet(exams);
  final streak = _calculateStreak(entries, exams);
  final cadence = repository.aiGoalCadence.value;

  final prompt = '''
KPSS P3 adayı için gerçekçi soru hedefleri belirle. 
Veriler:
- Son 7 gün: $last7Questions soru, $last7Minutes dk çalışma.
- Son 30 gün: $last30Questions soru.
- Ortalama Net: ${avgNet.toStringAsFixed(1)}
- Çalışma serisi: $streak gün.
- Kullanıcı tercihi: ${_cadenceLabel(cadence)} odaklı.

İstenen çıktı: Sadece JSON formatında, başka metin ekleme.
Şema:
{
  "daily": int,
  "weekly": int,
  "monthly": int,
  "note": "Kısa, motive edici mentor notu (maks 120 karakter)"
}
Gerçekçi ol, mevcut performansın %10-20 üzerine çıkmayı hedefle.
''';

  final closeLoading = _showLoadingDialog(context, 'AI hedef hazırlanıyor...');
  try {
    final client = GeminiClient();
    final model = repository.geminiModel.value.isEmpty
        ? 'gemini-1.5-flash'
        : repository.geminiModel.value;
    final result = await client.generateText(
      apiKey: apiKey,
      prompt: prompt,
      model: model,
    );
    await repository.incrementAiRequestCount();
    
    closeLoading();

    if (!context.mounted) {
      return;
    }
    // Navigator.of(context).pop();
    final parsed = _parseAiGoalResult(result);
    if (parsed == null) {
      if (!context.mounted) {
        return;
      }
      await _showResultDialog(context, 'AI Hedef Önerisi', result);
      return;
    }
    await _showAiGoalDialog(context, repository, parsed);
  } catch (e) {
    closeLoading();
    if (!context.mounted) {
      return;
    }
    // Navigator.of(context).pop();
    
    String message = 'AI hedef önerisi alınamadı.';
    if (e.toString().contains('429')) {
      message = 'API kotası aşıldı. Lütfen daha sonra tekrar deneyin.';
    } else if (e.toString().contains('404')) {
      message = 'Seçilen model bulunamadı.';
    } else if (e.toString().contains('503')) {
      message = 'AI servisi yoğun. Lütfen daha sonra deneyin.';
    }
    
    _showSnack(context, message);
  }
}

Future<void> _showAiGoalDialog(
  BuildContext context,
  AppRepository repository,
  _AiGoalResult goals,
) async {
  final cadence = repository.aiGoalCadence.value;
  final cadenceLabel = _cadenceLabel(cadence);
  final result = await showDialog<_AiGoalDialogAction>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('AI Hedef Önerisi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Günlük: ${goals.daily} soru'),
            Text('Haftalık: ${goals.weekly} soru'),
            Text('Aylık: ${goals.monthly} soru'),
            SizedBox(height: 12),
            Text(goals.note),
            SizedBox(height: 8),
            Text(
              'Seçili kadans: $cadenceLabel',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(_AiGoalDialogAction.saveOnly),
            child: Text('Kaydet'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.of(context).pop(_AiGoalDialogAction.applySelected),
            child: Text('Uygula'),
          ),
        ],
      );
    },
  );

  if (!context.mounted) {
    return;
  }
  if (result == null) {
    return;
  }

  await repository.setAiGoalTargets({
    'daily': goals.daily,
    'weekly': goals.weekly,
    'monthly': goals.monthly,
  });
  await repository.setAiGoalUpdatedAt(DateTime.now());

  if (result == _AiGoalDialogAction.applySelected) {
    if (cadence == 'daily') {
      await repository.setDailyGoal(goals.daily);
      if (!context.mounted) {
        return;
      }
      _showSnack(context, 'Günlük hedef güncellendi.');
    } else {
      if (!context.mounted) {
        return;
      }
      _showSnack(context, '$cadenceLabel hedefi kaydedildi.');
    }
  } else {
    if (!context.mounted) {
      return;
    }
    _showSnack(context, 'AI hedefleri kaydedildi.');
  }

  if (repository.aiNotificationsEnabled.value) {
    await repository.addNotification(
      AppNotification(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: 'AI Hedef Önerisi',
        body: 'Günlük ${goals.daily}, haftalık ${goals.weekly}, '
            'aylık ${goals.monthly} soru.',
        createdAt: DateTime.now(),
      ),
    );
  }
}

_AiGoalResult? _parseAiGoalResult(String raw) {
  final match = RegExp(r'\{[\s\S]*\}').firstMatch(raw);
  if (match == null) {
    return null;
  }
  try {
    final decoded = jsonDecode(match.group(0)!);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }
    final daily = _readInt(decoded['daily']);
    final weekly = _readInt(decoded['weekly']);
    final monthly = _readInt(decoded['monthly']);
    if (daily == null || weekly == null || monthly == null) {
      return null;
    }
    final note = decoded['note']?.toString().trim() ?? '';
    return _AiGoalResult(
      daily: daily,
      weekly: weekly,
      monthly: monthly,
      note: note.isEmpty ? 'AI önerisi hazır.' : note,
    );
  } catch (_) {
    return null;
  }
}

int? _readInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.round();
  }
  if (value is String) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleaned);
  }
  return null;
}

int _sumQuestionsSince(List<QuestionEntry> entries, DateTime now, int days) {
  return entries
      .where((entry) => now.difference(entry.createdAt).inDays < days)
      .fold<int>(0, (sum, entry) => sum + entry.total);
}

int _sumMinutesSince(List<QuestionEntry> entries, DateTime now, int days) {
  return entries
      .where((entry) => now.difference(entry.createdAt).inDays < days)
      .fold<int>(0, (sum, entry) => sum + entry.minutes);
}

double _averageNet(List<MockExam> exams) {
  if (exams.isEmpty) {
    return 0;
  }
  final total = exams.fold<double>(0, (sum, exam) => sum + exam.totalNet);
  return total / exams.length;
}



double _overallAccuracy(List<QuestionEntry> entries) {
  final correct = entries.fold<int>(0, (sum, entry) => sum + entry.correct);
  final total = entries.fold<int>(0, (sum, entry) => sum + entry.total);
  if (total == 0) {
    return 0;
  }
  return correct / total;
}

int _calculateStreak(List<QuestionEntry> entries, List<MockExam> exams) {
  final activityDates = <DateTime>{};
  for (final entry in entries) {
    activityDates.add(DateTime(entry.createdAt.year, entry.createdAt.month,
        entry.createdAt.day));
  }
  for (final exam in exams) {
    activityDates.add(DateTime(
        exam.createdAt.year, exam.createdAt.month, exam.createdAt.day));
  }
  if (activityDates.isEmpty) {
    return 0;
  }
  var streak = 0;
  var current = DateTime.now();
  while (true) {
    final normalized = DateTime(current.year, current.month, current.day);
    if (!activityDates.contains(normalized)) {
      break;
    }
    streak += 1;
    current = current.subtract(const Duration(days: 1));
  }
  return streak;
}

String _cadenceLabel(String cadence) {
  switch (cadence) {
    case 'weekly':
      return 'Haftalık';
    case 'monthly':
      return 'Aylık';
    default:
      return 'Günlük';
  }
}

String _formatDateTime(DateTime dateTime) {
  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$day.$month ${hour}:$minute';
}

enum _AiGoalDialogAction { saveOnly, applySelected }

Future<void> Function() _showLoadingDialog(BuildContext context, String title) {
  bool isOpen = true;
  AiLoadingDialog.show(context, status: title).then((_) => isOpen = false);
  return () async {
    if (isOpen && context.mounted) {
      Navigator.of(context).pop();
    }
  };
}

Future<void> _showResultDialog(
  BuildContext context,
  String title,
  String content,
) {
  return AiResponseDialog.show(context, title, content);
}

Future<void> _exportBackup(
  BuildContext context,
  AppRepository repository,
) async {
  final data = repository.exportData();
  final dir = await getTemporaryDirectory();
  final fileName =
      'road_to_atc_backup_${DateTime.now().millisecondsSinceEpoch}.json';
  final file = File('${dir.path}/$fileName');
  await file.writeAsString(data);
  await Share.shareXFiles([XFile(file.path)], text: 'Road to ATC yedeği');
}



Future<void> _requestExactAlarm(BuildContext context) async {
  final granted = await NotificationService.requestExactAlarmPermission();
  if (!context.mounted) return;
  if (granted) {
    _showSnack(context, 'Tam zamanlı alarm izni verildi.');
  } else {
    _showSnack(context, 'Alarm izni verilmedi veya gerekmiyor.');
  }
}

Future<void> _pickReminderTime(
  BuildContext context,
  AppRepository repository,
) async {
  final raw = repository.reminderTime.value;
  final parts = raw.split(':');
  final initial = TimeOfDay(
    hour: parts.length > 1 ? int.tryParse(parts[0]) ?? 20 : 20,
    minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
  );
  final picked = await showTimePicker(
    context: context,
    initialTime: initial,
  );
  if (!context.mounted) {
    return;
  }
  if (picked == null) {
    return;
  }
  final formatted =
      '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
  await repository.setReminderTime(formatted);
  if (repository.reminderEnabled.value) {
    await NotificationService.scheduleDailyReminder(formatted);
  }
  if (!context.mounted) {
    return;
  }
  _showSnack(context, 'Hatırlatıcı saati güncellendi.');
}

Future<void> _pickWeeklyPlanDay(
  BuildContext context,
  AppRepository repository,
) async {
  final selected = await showModalBottomSheet<int>(
    context: context,
    backgroundColor: AppColors.of(context).surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return ListView(
        shrinkWrap: true,
        children: [
          _weekdayTile(context, DateTime.monday),
          _weekdayTile(context, DateTime.tuesday),
          _weekdayTile(context, DateTime.wednesday),
          _weekdayTile(context, DateTime.thursday),
          _weekdayTile(context, DateTime.friday),
          _weekdayTile(context, DateTime.saturday),
          _weekdayTile(context, DateTime.sunday),
        ],
      );
    },
  );
  if (!context.mounted) {
    return;
  }
  if (selected == null) {
    return;
  }
  await repository.setWeeklyPlanWeekday(selected);
  if (repository.weeklyPlanEnabled.value) {
    await NotificationService.scheduleWeeklyPlanWithBody(
      time: repository.weeklyPlanTime.value,
      weekday: repository.weeklyPlanWeekday.value,
      body: _weeklyPlanBody(repository),
    );
  }
}

Widget _weekdayTile(BuildContext context, int weekday) {
  return ListTile(
    title: Text(
      _weekdayLabel(weekday),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
    ),
    onTap: () => Navigator.of(context).pop(weekday),
  );
}

Future<void> _pickWeeklyPlanTime(
  BuildContext context,
  AppRepository repository,
) async {
  final raw = repository.weeklyPlanTime.value;
  final parts = raw.split(':');
  final initial = TimeOfDay(
    hour: parts.length > 1 ? int.tryParse(parts[0]) ?? 9 : 9,
    minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
  );
  final picked = await showTimePicker(
    context: context,
    initialTime: initial,
  );
  if (!context.mounted) {
    return;
  }
  if (picked == null) {
    return;
  }
  final formatted =
      '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
  await repository.setWeeklyPlanTime(formatted);
  if (repository.weeklyPlanEnabled.value) {
    await NotificationService.scheduleWeeklyPlanWithBody(
      time: repository.weeklyPlanTime.value,
      weekday: repository.weeklyPlanWeekday.value,
      body: _weeklyPlanBody(repository),
    );
  }
  if (!context.mounted) {
    return;
  }
  _showSnack(context, 'Haftalık plan saati güncellendi.');
}

String _weekdayLabel(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return 'Pazartesi';
    case DateTime.tuesday:
      return 'Salı';
    case DateTime.wednesday:
      return 'Çarşamba';
    case DateTime.thursday:
      return 'Perşembe';
    case DateTime.friday:
      return 'Cuma';
    case DateTime.saturday:
      return 'Cumartesi';
    case DateTime.sunday:
      return 'Pazar';
    default:
      return 'Pazartesi';
  }
}

String _weeklyPlanBody(AppRepository repository) {
  final program = repository.aiProgramLast.value;
  if (program == null || program.trim().isEmpty) {
    return 'Bu hafta için çalışma planını güncelle.';
  }
  final trimmed = program.trim();
  final firstLine = trimmed.split('\n').first;
  return firstLine.length > 120 ? '${firstLine.substring(0, 120)}…' : firstLine;
}

Future<void> _importBackup(
  BuildContext context,
  AppRepository repository,
) async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['json'],
  );
  if (result == null || result.files.single.path == null) {
    return;
  }
  final file = File(result.files.single.path!);
  try {
    final raw = await file.readAsString();
    await repository.importData(raw);
    if (!context.mounted) {
      return;
    }
    _showSnack(context, 'Yedek başarıyla içe aktarıldı.');
  } catch (_) {
    if (!context.mounted) {
      return;
    }
    _showSnack(context, 'Yedek okunamadı. Dosyayı kontrol et.');
  }
}

Future<void> _confirmReset(
  BuildContext context,
  AppRepository repository,
) async {
  final shouldReset = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Verileri Sıfırla'),
        content: Text('Tüm kayıtlar silinsin mi? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Sil'),
          ),
        ],
      );
    },
  );
  if (!context.mounted) {
    return;
  }
  if (shouldReset == true) {
    await repository.clearAll();
    if (!context.mounted) {
      return;
    }
    _showSnack(context, 'Tüm veriler silindi.');
  }
}

void _showSnack(BuildContext context, String message) {
  InAppNotice.show(context, message);
}

class _AiUsageTracker extends StatelessWidget {
  const _AiUsageTracker({required this.repository});

  final AppRepository repository;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Kullanım Takibi',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
        SizedBox(height: 6),
        Text(
          'Bugün yapılan AI isteklerinin sayısı.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.of(context).textSecondary,
              ),
        ),
        SizedBox(height: 12),
        ValueListenableBuilder<int>(
          valueListenable: repository.aiRequestCountToday,
          builder: (context, count, _) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.of(context).primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.of(context).primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.analytics, color: AppColors.of(context).primary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bugünkü İstekler',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.of(context).textSecondary,
                              ),
                        ),
                        Text(
                          '$count İstek',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Limit: 1500',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white54,
                          ),
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

class _ModelInfoCard extends StatelessWidget {
  const _ModelInfoCard({required this.model});

  final String model;

  @override
  Widget build(BuildContext context) {
    final info = _getModelInfo(model);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.of(context).surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.of(context).primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.smart_toy, color: AppColors.of(context).primary),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  model,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            info.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
          ),
          SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tahmini Limitler (Ücretsiz Paket)',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.of(context).textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                SizedBox(height: 6),
                _LimitRow(label: 'Dakikalık İstek (RPM)', value: info.rpm),
                _LimitRow(label: 'Günlük İstek (RPD)', value: info.rpd),
                _LimitRow(label: 'Dakikalık Token (TPM)', value: info.tpm),
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
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white54,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.of(context).primaryLight,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _ModelInfo {
  const _ModelInfo({
    required this.description,
    required this.rpm,
    required this.rpd,
    required this.tpm,
  });

  final String description;
  final String rpm;
  final String rpd;
  final String tpm;
}

_ModelInfo _getModelInfo(String model) {
  if (model.contains('flash')) {
    return const _ModelInfo(
      description: 'Hızlı ve verimli model. Günlük işler için ideal.',
      rpm: '15',
      rpd: '1,500',
      tpm: '1 Milyon',
    );
  } else if (model.contains('pro')) {
    return const _ModelInfo(
      description: 'Daha karmaşık ve akıl yürütme gerektiren işler için.',
      rpm: '2',
      rpd: '50',
      tpm: '32,000',
    );
  } else {
    return const _ModelInfo(
      description: 'Genel amaçlı Gemini modeli.',
      rpm: 'Değişken',
      rpd: 'Değişken',
      tpm: 'Değişken',
    );
  }
}

void _navigateFromNav(BuildContext context, int index) {
  switch (index) {
    case 0:
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
      return;
    case 1:
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => TopicSummariesScreen()),
      );
      return;
    case 2:
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => QuickAddScreen()),
      );
      return;
    case 3:
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => AnalysisScreen()),
      );
      return;
    case 4:
      return;
  }
}
