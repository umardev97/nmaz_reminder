import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../core/styles.dart';
import '../../core/app_utils.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/intention/models/daily_intention.dart';
import '../../features/intention/providers/intention_provider.dart';
import '../../features/prayer/providers/prayer_provider.dart';
import '../widgets/app_logo.dart';
import '../widgets/app_ui.dart';
import 'prayer/prayer_page.dart';
import 'profile/profile_page.dart';
import 'report/report_page.dart';
import 'settings/notification_settings_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _DashboardView(),
      const PrayerPage(embedded: true),
      const ReportPage(embedded: true),
      const ProfilePage(),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.access_time_outlined),
            selectedIcon: Icon(Icons.access_time_filled_rounded),
            label: 'Prayers',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note_rounded),
            label: 'Reflect',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _DashboardView extends ConsumerWidget {
  const _DashboardView();

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
    final firstName = (appUser?.name.trim().isNotEmpty ?? false)
        ? appUser!.name.trim().split(' ').first
        : 'there';

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          titleSpacing: 20,
          title: Row(
            children: [
              const AppLogo(height: 44, compact: true),
              const SizedBox(width: 12),
              Text('Nmaz Reminder',
                  style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Notification settings',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const NotificationSettingsPage()),
              ),
              icon: const Icon(Icons.notifications_none_rounded),
            ),
            const SizedBox(width: 10),
          ],
        ),
        SliverToBoxAdapter(
          child: AppPage(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_greeting()}, $firstName',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 6),
                Text(
                  DateFormat('EEEE, d MMMM').format(DateTime.now()),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 26),
                Container(
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
                                      color:
                                          Colors.white.withValues(alpha: .09),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(Icons.mosque_rounded,
                                        color: AppColors.accent),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '$completed / 5',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: Colors.white,
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
                                    ?.copyWith(color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                completed == 5
                                    ? 'All five prayers are marked. Beautiful consistency.'
                                    : 'A gentle check-in for the prayers that matter most.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.white70),
                              ),
                              const SizedBox(height: 22),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(99),
                                child: LinearProgressIndicator(
                                  minHeight: 8,
                                  value: completed / 5,
                                  backgroundColor: Colors.white12,
                                  valueColor: const AlwaysStoppedAnimation(
                                      AppColors.accent),
                                ),
                              ),
                            ],
                          );
                        },
                        loading: () => const SizedBox(
                          height: 150,
                          child: Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.accent)),
                        ),
                        error: (_, __) => const SizedBox(
                          height: 120,
                          child: Center(
                            child: Text(
                                'Progress will appear when you are online.',
                                style: TextStyle(color: Colors.white70)),
                          ),
                        ),
                      ) ??
                      const SizedBox(height: 150),
                ),
                const SizedBox(height: 30),
                const SectionHeader(title: 'Quick actions'),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth > 560;
                    final cards = [
                      _ActionCard(
                        title: 'Today’s prayers',
                        subtitle: 'Review and mark completion',
                        icon: Icons.access_time_filled_rounded,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const PrayerPage()),
                        ),
                      ),
                      _ActionCard(
                        title: 'Daily reflection',
                        subtitle: 'Capture your day in a minute',
                        icon: Icons.auto_stories_rounded,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ReportPage()),
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
                              cards[1]
                            ],
                          );
                  },
                ),
                const SizedBox(height: 28),
                intention.when(
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
                    child: AppLoadingView(message: 'Loading daily intention'),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
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
                Text(
                  quote?.trim().isNotEmpty == true
                      ? quote!.trim()
                      : 'Consistency grows through gentle, repeatable steps.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  message?.trim().isNotEmpty == true
                      ? message!.trim()
                      : 'Complete one small meaningful action today.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
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
