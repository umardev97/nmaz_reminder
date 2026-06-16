import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/report/models/report_model.dart';
import '../../../features/report/providers/report_provider.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/app_ui.dart';

class ReflectionsPage extends ConsumerWidget {
  const ReflectionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(firebaseUserProvider).asData?.value;
    if (user == null) {
      return const Scaffold(
        body: AppStateView(
          title: 'Sign in required',
          message: 'Sign in to view your saved reflections.',
          icon: Icons.lock_outline_rounded,
        ),
      );
    }

    final reportsAsync = ref.watch(reportsStreamProvider(user.uid));
    return Scaffold(
      appBar: AppBar(title: const Text('My reflections')),
      body: reportsAsync.when(
        data: (reports) {
          if (reports.isEmpty) {
            return const AppStateView(
              title: 'No reflections yet',
              message: 'Saved daily reflections will appear here.',
              icon: Icons.edit_note_outlined,
              showLogo: true,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            itemCount: reports.length + 1,
            separatorBuilder: (_, index) => index == 0
                ? const SizedBox(height: 18)
                : const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppLogo(height: 64, compact: true),
                        const SizedBox(height: 18),
                        Text(
                          'My reflections',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'A private record of the moments, work, and worship you saved.',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: _ReflectionCard(report: reports[index - 1]),
                ),
              );
            },
          );
        },
        loading: () =>
            const AppLoadingView(message: 'Loading your reflections'),
        error: (_, __) => const AppStateView(
          title: 'Reflections unavailable',
          message: 'Check your connection and try again.',
          icon: Icons.cloud_off_rounded,
        ),
      ),
    );
  }
}

class _ReflectionCard extends StatelessWidget {
  const _ReflectionCard({required this.report});

  final DailyReport report;

  @override
  Widget build(BuildContext context) {
    final parsedDate = DateTime.tryParse(report.date);
    final dateLabel = parsedDate == null
        ? report.date
        : DateFormat('EEEE, d MMMM yyyy').format(parsedDate);
    final rows = [
      if (report.visitedPlaces.trim().isNotEmpty)
        _ReflectionRow(
          icon: Icons.place_outlined,
          title: 'Where I went',
          value: report.visitedPlaces.trim(),
        ),
      if (report.workDone.trim().isNotEmpty)
        _ReflectionRow(
          icon: Icons.work_outline_rounded,
          title: 'What I accomplished',
          value: report.workDone.trim(),
        ),
      if (report.islamicActivities.trim().isNotEmpty)
        _ReflectionRow(
          icon: Icons.mosque_outlined,
          title: 'Islamic activities',
          value: report.islamicActivities.trim(),
        ),
      if (report.notes.trim().isNotEmpty)
        _ReflectionRow(
          icon: Icons.notes_rounded,
          title: 'Notes',
          value: report.notes.trim(),
        ),
    ];

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateLabel,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Daily reflection',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  report.mood,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (rows.isEmpty)
            Text(
              'Saved without extra notes.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            )
          else
            ...rows.expand(
              (row) => [
                row,
                if (row != rows.last)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ReflectionRow extends StatelessWidget {
  const _ReflectionRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 3),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
