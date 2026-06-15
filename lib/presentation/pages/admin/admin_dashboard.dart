import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../core/styles.dart';
import '../../../features/admin/providers/admin_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/app_ui.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersStreamProvider);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const AppLogo(height: 42, compact: true),
            const SizedBox(width: 12),
            const Text('Admin'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => ref.read(authControllerProvider).signOut(),
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: usersAsync.when(
        data: (users) {
          final admins = users.where((user) => user['role'] == 'admin').length;
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: AppPage(
                  maxWidth: 900,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Community overview',
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      Text(
                        'Manage members and keep an eye on account access.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                              child: _StatCard(
                                  value: '${users.length}',
                                  label: 'Members',
                                  icon: Icons.people_alt_outlined)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _StatCard(
                                  value: '$admins',
                                  label: 'Admins',
                                  icon: Icons.admin_panel_settings_outlined)),
                        ],
                      ),
                      const SizedBox(height: 28),
                      const SectionHeader(title: 'All members'),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              if (users.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppStateView(
                    title: 'No members yet',
                    message: 'New member accounts will appear here.',
                    showLogo: true,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  sliver: SliverList.separated(
                    itemCount: users.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final name = (user['name'] as String?)?.trim();
                      final email = user['email'] as String?;
                      final role = user['role'] as String? ?? 'user';
                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 860),
                          child: PremiumCard(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor:
                                    AppColors.primary.withValues(alpha: .12),
                                foregroundColor: AppColors.primary,
                                child: Text(_initials(name ?? email ?? 'M')),
                              ),
                              title: Text(
                                  name?.isNotEmpty == true
                                      ? name!
                                      : 'Unnamed member',
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              subtitle: Text(email ?? 'No email added',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                          color: AppColors.textSecondary)),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: role == 'admin'
                                      ? AppColors.primary.withValues(alpha: .1)
                                      : AppColors.surfaceMuted,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.pill),
                                ),
                                child: Text(
                                    role == 'admin' ? 'Admin' : 'Member',
                                    style:
                                        Theme.of(context).textTheme.labelSmall),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
        loading: () => const AppLoadingView(message: 'Loading member accounts'),
        error: (_, __) => const AppStateView(
          title: 'Member list unavailable',
          message: 'Check your connection and try again.',
          icon: Icons.cloud_off_rounded,
        ),
      ),
    );
  }

  static String _initials(String value) {
    final words = value.trim().split(RegExp(r'\s+'));
    return words
        .take(2)
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase())
        .join();
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.value, required this.label, required this.icon});
  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          gradient: AppGradients.premium,
          borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accent),
          const SizedBox(height: 18),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: Colors.white)),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white70)),
        ],
      ),
    );
  }
}
