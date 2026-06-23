import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_utils.dart';
import '../../../core/styles.dart';
import '../../../core/theme.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/intention/models/daily_intention.dart';
import '../../../features/intention/providers/intention_provider.dart';
import '../../../features/prayer/providers/prayer_provider.dart';
import '../../../features/quran/providers/quran_provider.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/app_ui.dart';
import '../prayer/prayer_page.dart';
import '../report/report_page.dart';
import '../settings/settings_page.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(firebaseUserProvider).asData?.value;
    final appUser = ref.watch(appUserProvider).asData?.value;
    final prayer =
    user == null ? null : ref.watch(todayPrayerProvider(user.uid));
    final intention = ref.watch(todayIntentionProvider);
    final completion = user == null
        ? null
        : ref.watch(todayIntentionCompletionProvider(user.uid));
    final quranReading = user == null
        ? null
        : ref.watch(todayQuranReadingProvider(user.uid));
    final firstName = (appUser?.name.trim().isNotEmpty ?? false)
        ? appUser!.name.trim().split(' ').first
        : 'there';

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverAppBar(
          elevation: 0,
          pinned: true,
          floating: true,
          snap: true,
          stretch: true,
          toolbarHeight: 72,
          expandedHeight: 96,
          titleSpacing: 20,
          backgroundColor: Theme.of(context)
              .scaffoldBackgroundColor
              .withValues(alpha: .82),
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,

          // Premium glass effect like modern apps
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .scaffoldBackgroundColor
                      .withValues(alpha: .72),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withValues(alpha: .06),
                    ),
                  ),
                ),
              ),
            ),
          ),

          title: Row(
            children: [
              const AppLogo(height: 44, compact: true),
              const SizedBox(width: 12),
              Text(
                'Nmaz Reminder',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton.filledTonal(
                tooltip: 'Notification settings',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SettingsPage(),
                  ),
                ),
                icon: const Icon(Icons.notifications_none_rounded),
              ),
            ),
          ],
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _HeaderSection(firstName: firstName),
          ),
        ),

        SliverToBoxAdapter(
          child: AppPage(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: Container(
                    key: ValueKey(prayer?.isLoading),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppGradients.premium,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: AppShadows.soft,
                    ),
                    child: prayer?.when(
                      data: (entry) {
                        final values = [
                          entry?.fajr ?? false,
                          entry?.dhuhr ?? false,
                          entry?.asr ?? false,
                          entry?.maghrib ?? false,
                          entry?.isha ?? false,
                        ];

                        final completed =
                            values.where((value) => value).length;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: .09),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.mosque_rounded,
                                    color: AppColors.accent,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '$completed / 5',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            Text(
                              completed == 5
                                  ? 'A complete day'
                                  : 'Today’s prayer progress',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              completed == 5
                                  ? 'All five prayers are marked. Beautiful consistency.'
                                  : 'A gentle check-in for the prayers that matter most.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                color: Colors.white70,
                                height: 1.4,
                              ),
                            ),

                            const SizedBox(height: 22),

                            ClipRRect(
                              borderRadius: BorderRadius.circular(99),
                              child: LinearProgressIndicator(
                                minHeight: 8,
                                value: completed / 5,
                                backgroundColor: Colors.white12,
                                valueColor: const AlwaysStoppedAnimation(
                                  AppColors.accent,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => const SizedBox(
                        height: 150,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                      error: (_, __) => const SizedBox(
                        height: 120,
                        child: Center(
                          child: Text(
                            'Progress will appear when you are online.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                    ) ??
                        const SizedBox(height: 150),
                  ),
                ),

                const SizedBox(height: 30),

                const SectionHeader(title: 'Quick actions'),

                const SizedBox(height: 14),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth > 560;

                    final cards = [
                      _ActionCard(
                        title: 'Today’s prayers',
                        subtitle: 'Review and mark completion',
                        icon: Icons.access_time_filled_rounded,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PrayerPage(),
                          ),
                        ),
                      ),
                      _ActionCard(
                        title: 'Daily reflection',
                        subtitle: 'Capture your day in a minute',
                        icon: Icons.auto_stories_rounded,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ReportPage(),
                          ),
                        ),
                      ),
                    ];

                    return wide
                        ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: cards[0]),
                        const SizedBox(width: 14),
                        Expanded(child: cards[1]),
                      ],
                    )
                        : Column(
                      children: [
                        cards[0],
                        const SizedBox(height: 14),
                        cards[1],
                      ],
                    );
                  },
                ),

                const SizedBox(height: 28),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: intention.when(
                    data: (item) => _DailyIntentionCard(
                      intention: item,
                      completed: completion?.asData?.value?.completed ?? false,
                      loading: completion?.isLoading ?? false,
                      onChanged: user == null
                          ? null
                          : (completed) async {
                        try {
                          await ref.read(setIntentionCompletionProvider)(
                            user.uid,
                            completed,
                          );

                          if (context.mounted) {
                            AppSnackBar.showSuccess(
                              context,
                              completed
                                  ? 'Daily intention completed'
                                  : 'Daily intention marked incomplete',
                            );
                          }
                        } catch (e) {
                          if (!context.mounted) return;

                          AppSnackBar.showError(
                            context,
                            e,
                            fallback:
                            'Could not update today’s intention. Please try again.',
                          );
                        }
                      },
                    ),
                    loading: () => const PremiumCard(
                      child: AppLoadingView(
                        message: 'Loading daily intention',
                      ),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),

                const SizedBox(height: 14),

                _QuranReadingCard(
                  reading: quranReading,
                  onChanged: user == null
                      ? null
                      : (read) async {
                          try {
                            await ref.read(setQuranReadingProvider)(
                              user.uid,
                              read,
                            );
                            if (context.mounted) {
                              AppSnackBar.showSuccess(
                                context,
                                read
                                    ? 'Quran reading marked for today'
                                    : 'Quran reading unmarked',
                              );
                            }
                          } catch (e) {
                            if (!context.mounted) return;
                            AppSnackBar.showError(
                              context,
                              e,
                              fallback:
                                  'Could not update Quran reading. Please try again.',
                            );
                          }
                        },
                ),

                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.firstName,
  });

  final String? firstName;

  @override
  Widget build(BuildContext context) {
    final name = firstName?.trim().isNotEmpty == true ? firstName! : 'Friend';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF111827),
              Color(0xFF1F2937),
              Color(0xFF065F46),
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .18),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -18,
              top: -22,
              child: Icon(
                Icons.nightlight_round,
                size: 110,
                color: Colors.white.withValues(alpha: .06),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Salaam, $name',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Stay close to your prayers today.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyIntentionCard extends StatelessWidget {
  const _DailyIntentionCard({
    required this.intention,
    required this.completed,
    required this.loading,
    required this.onChanged,
  });

  final DailyIntention? intention;
  final bool completed;
  final bool loading;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final quote = intention?.quote;
    final message = intention?.message;

    return PremiumCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              completed
                  ? Icons.task_alt_rounded
                  : Icons.lightbulb_outline_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A small daily intention',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quote',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      quote?.trim().isNotEmpty == true
                          ? quote!.trim()
                          : 'Consistency grows through gentle, repeatable steps.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.background,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Message',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message?.trim().isNotEmpty == true
                          ? message!.trim()
                          : 'Complete one small meaningful action today.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.background,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Complete'),
                      selected: completed,
                      onSelected: loading || onChanged == null
                          ? null
                          : (_) => onChanged!(true),
                    ),
                    ChoiceChip(
                      label: const Text('Not yet'),
                      selected: !completed,
                      onSelected: loading || onChanged == null
                          ? null
                          : (_) => onChanged!(false),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuranReadingCard extends StatelessWidget {
  const _QuranReadingCard({required this.reading, required this.onChanged});

  final AsyncValue<dynamic>? reading;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final isRead = reading?.asData?.value?.read == true;
    final isLoading = reading?.isLoading ?? false;

    return PremiumCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isRead ? Icons.menu_book_rounded : Icons.menu_book_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quran recitation',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Did you read Quran Majeed today?',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Yes, I did'),
                      selected: isRead,
                      onSelected: isLoading || onChanged == null
                          ? null
                          : (_) => onChanged!(true),
                    ),
                    ChoiceChip(
                      label: const Text('Not yet'),
                      selected: !isRead,
                      onSelected: isLoading || onChanged == null
                          ? null
                          : (_) => onChanged!(false),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard(
      {required this.title,
        required this.subtitle,
        required this.icon,
        required this.onTap});
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color:
              Theme.of(context).colorScheme.primary.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 15, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}