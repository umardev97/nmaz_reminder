import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme.dart';
import '../../../../features/admin/admin_repository.dart';
import '../../../../features/admin/providers/admin_provider.dart';
import '../../../../features/intention/models/daily_intention.dart';
import '../../../../features/prayer/models/prayer_model.dart';
import '../../../widgets/app_ui.dart';

class AdminUserActivitySheet extends ConsumerWidget {
  const AdminUserActivitySheet({
    super.key,
    required this.user,
    required this.date,
  });

  final Map<String, dynamic> user;
  final String date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = user['uid'] as String? ?? '';
    final name = (user['name'] as String?)?.trim();
    final email = user['email'] as String?;
    final title = name?.isNotEmpty == true ? name! : email ?? 'Member';

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.82,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (context, controller) {
        return FutureBuilder<AdminUserActivity>(
          future:
              ref.read(adminRepositoryProvider).fetchUserActivity(uid, date),
          builder: (context, snapshot) {
            return ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: .12),
                      foregroundColor: AppColors.primary,
                      child: Text(_AdminInitials.from(title)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$date activity',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const AppLoadingView(message: 'Loading user activity')
                else if (snapshot.hasError)
                  const AppStateView(
                    title: 'Activity unavailable',
                    message: 'Could not load this member activity.',
                    icon: Icons.cloud_off_rounded,
                  )
                else
                  _ActivityDetails(activity: snapshot.requireData),
              ],
            );
          },
        );
      },
    );
  }
}

class _ActivityDetails extends StatelessWidget {
  const _ActivityDetails({required this.activity});

  final AdminUserActivity activity;

  @override
  Widget build(BuildContext context) {
    final prayer = activity.prayer;
    final completedPrayers = prayer == null
        ? 0
        : [
            prayer.fajr,
            prayer.dhuhr,
            prayer.asr,
            prayer.maghrib,
            prayer.isha,
          ].where((value) => value).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ActivitySection(
          title: 'Prayer activity',
          icon: Icons.mosque_outlined,
          child: prayer == null
              ? const _EmptyActivityText('No prayer activity for this date.')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailRow(
                      label: 'Completed',
                      value: '$completedPrayers / 5 prayers',
                    ),
                    const SizedBox(height: 12),
                    _PrayerStatusWrap(prayer: prayer),
                  ],
                ),
        ),
        const SizedBox(height: 14),
        _ActivitySection(
          title: 'Daily reflection',
          icon: Icons.auto_stories_outlined,
          child: activity.report == null
              ? const _EmptyActivityText('No reflection report for this date.')
              : Column(
                  children: [
                    _DetailRow(label: 'Mood', value: activity.report!.mood),
                    _DetailRow(
                      label: 'Visited places',
                      value: activity.report!.visitedPlaces,
                    ),
                    _DetailRow(
                      label: 'Work done',
                      value: activity.report!.workDone,
                    ),
                    _DetailRow(
                      label: 'Islamic activities',
                      value: activity.report!.islamicActivities,
                    ),
                    _DetailRow(label: 'Notes', value: activity.report!.notes),
                  ],
                ),
        ),
        const SizedBox(height: 14),
        _ActivitySection(
          title: 'Daily intention',
          icon: Icons.task_alt_outlined,
          child: _DetailRow(
            label: 'Status',
            value: activity.intentionCompletion?.completed == true
                ? 'Completed'
                : 'Not completed',
          ),
        ),
        const SizedBox(height: 14),
        _ActivitySection(
          title: 'Completed intentions',
          icon: Icons.fact_check_outlined,
          child: activity.completedIntentions.isEmpty
              ? const _EmptyActivityText('No completed daily intentions yet.')
              : _CompletedIntentionsList(
                  intentions: activity.completedIntentions,
                ),
        ),
      ],
    );
  }
}

class _CompletedIntentionsList extends StatelessWidget {
  const _CompletedIntentionsList({required this.intentions});

  final List<IntentionCompletion> intentions;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final intention in intentions)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    intention.date,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Text(
                  'Completed',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ActivitySection extends StatelessWidget {
  const _ActivitySection({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 10),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _PrayerStatusWrap extends StatelessWidget {
  const _PrayerStatusWrap({required this.prayer});

  final PrayerEntry prayer;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Fajr', prayer.fajr),
      ('Dhuhr', prayer.dhuhr),
      ('Asr', prayer.asr),
      ('Maghrib', prayer.maghrib),
      ('Isha', prayer.isha),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in items)
          Chip(
            avatar: Icon(
              item.$2 ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 18,
              color: item.$2 ? AppColors.primary : AppColors.textSecondary,
            ),
            label: Text(item.$1),
          ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final displayValue = value.trim().isEmpty ? 'Not added' : value.trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 124,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              displayValue,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyActivityText extends StatelessWidget {
  const _EmptyActivityText(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
    );
  }
}

class _AdminInitials {
  static String from(String value) {
    final words = value.trim().split(RegExp(r'\s+'));
    return words
        .take(2)
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase())
        .join();
  }
}
