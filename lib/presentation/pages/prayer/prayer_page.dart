import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../core/styles.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/prayer/models/prayer_model.dart';
import '../../../features/prayer/providers/prayer_provider.dart';
import '../../widgets/app_ui.dart';

class PrayerPage extends ConsumerStatefulWidget {
  const PrayerPage({super.key, this.embedded = false});

  final bool embedded;

  @override
  ConsumerState<PrayerPage> createState() => _PrayerPageState();
}

class _PrayerPageState extends ConsumerState<PrayerPage> {
  String? _marking;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(firebaseUserProvider).asData?.value;
    if (user == null) {
      return const Scaffold(
        body: AppStateView(
          title: 'Sign in required',
          message: 'Sign in to view and track today’s prayers.',
          icon: Icons.lock_outline_rounded,
        ),
      );
    }
    final today = DateTime.now();
    final date = DateFormat('yyyy-MM-dd').format(today);
    final prayerAsync = ref.watch(todayPrayerProvider(user.uid));

    final content = prayerAsync.when(
      data: (entry) => _PrayerContent(
        entry: entry,
        marking: _marking,
        onMark: (key, label) => _markPrayer(user.uid, date, key, label),
      ),
      loading: () => const AppLoadingView(message: 'Loading today’s prayers'),
      error: (_, __) => AppStateView(
        title: 'Prayers are unavailable',
        message: 'Check your connection and try loading the day again.',
        icon: Icons.cloud_off_rounded,
        actionLabel: 'Try again',
        onAction: () => ref.invalidate(todayPrayerProvider(user.uid)),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.embedded,
        title: const Text('Today’s prayers'),
      ),
      body: content,
    );
  }

  Future<void> _markPrayer(
      String uid, String date, String key, String label) async {
    setState(() => _marking = key);
    try {
      await ref.read(markPrayerProvider)(uid, date, key);
      ref.invalidate(todayPrayerProvider(uid));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label marked as complete')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Could not update this prayer. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _marking = null);
    }
  }
}

class _PrayerContent extends StatelessWidget {
  const _PrayerContent(
      {required this.entry, required this.marking, required this.onMark});

  final PrayerEntry? entry;
  final String? marking;
  final Future<void> Function(String key, String label) onMark;

  @override
  Widget build(BuildContext context) {
    final prayers = [
      (
        'fajr',
        'Fajr',
        'Dawn prayer',
        Icons.wb_twilight_rounded,
        entry?.fajr ?? false
      ),
      (
        'dhuhr',
        'Dhuhr',
        'Midday prayer',
        Icons.light_mode_rounded,
        entry?.dhuhr ?? false
      ),
      (
        'asr',
        'Asr',
        'Afternoon prayer',
        Icons.wb_sunny_outlined,
        entry?.asr ?? false
      ),
      (
        'maghrib',
        'Maghrib',
        'Sunset prayer',
        Icons.nights_stay_outlined,
        entry?.maghrib ?? false
      ),
      (
        'isha',
        'Isha',
        'Night prayer',
        Icons.dark_mode_rounded,
        entry?.isha ?? false
      ),
    ];
    final completed = prayers.where((item) => item.$5).length;

    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          AppPage(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: AppGradients.premium,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 76,
                        height: 76,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: completed / 5,
                              strokeWidth: 7,
                              backgroundColor: Colors.white12,
                              valueColor: const AlwaysStoppedAnimation(
                                  AppColors.accent),
                            ),
                            Center(
                              child: Text(
                                '$completed/5',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              completed == 5 ? 'Day complete' : 'Stay present',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              completed == 5
                                  ? 'You have marked every prayer today.'
                                  : '${5 - completed} prayer${5 - completed == 1 ? '' : 's'} remaining today.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                Text(DateFormat('EEEE, d MMMM').format(DateTime.now()),
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 14),
                ...prayers.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _PrayerTile(
                      label: item.$2,
                      subtitle: item.$3,
                      icon: item.$4,
                      done: item.$5,
                      loading: marking == item.$1,
                      onTap: item.$5 || marking != null
                          ? null
                          : () => onMark(item.$1, item.$2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerTile extends StatelessWidget {
  const _PrayerTile(
      {required this.label,
      required this.subtitle,
      required this.icon,
      required this.done,
      required this.loading,
      this.onTap});
  final String label;
  final String subtitle;
  final IconData icon;
  final bool done;
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: done
            ? AppColors.success.withValues(alpha: .08)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: done
              ? AppColors.success.withValues(alpha: .35)
              : AppColors.divider,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: done
                ? AppColors.success.withValues(alpha: .12)
                : AppColors.primary.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(14),
          ),
          child:
              Icon(icon, color: done ? AppColors.success : AppColors.primary),
        ),
        title: Text(label, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitle,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textSecondary)),
        trailing: loading
            ? const SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5))
            : Icon(
                done
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: done ? AppColors.success : AppColors.textSecondary,
                size: 28,
              ),
        onTap: onTap,
      ),
    );
  }
}
