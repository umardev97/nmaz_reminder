import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/app_utils.dart';
import '../../../core/theme.dart';
import '../../../core/styles.dart';
import '../../../features/admin/providers/admin_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/intention/models/daily_intention.dart';
import '../../../features/intention/providers/intention_provider.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/app_ui.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  final _quoteCtl = TextEditingController();
  final _messageCtl = TextEditingController();
  final _dateCtl = TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  );
  bool _saving = false;

  @override
  void dispose() {
    _quoteCtl.dispose();
    _messageCtl.dispose();
    _dateCtl.dispose();
    super.dispose();
  }

  Future<void> _saveIntention() async {
    final date = _dateCtl.text.trim();
    final quote = _quoteCtl.text.trim();
    final message = _messageCtl.text.trim();
    if (date.isEmpty || quote.isEmpty || message.isEmpty) {
      AppSnackBar.show(context, 'Add a date, quote, and message first.');
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(saveIntentionProvider)(
        DailyIntention(date: date, quote: quote, message: message),
      );
      if (!mounted) return;
      AppSnackBar.showSuccess(context, 'Daily intention saved');
      _quoteCtl.clear();
      _messageCtl.clear();
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        e,
        fallback: 'Could not save the daily intention. Please try again.',
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await AppDialogs.confirm(
      context,
      title: 'Sign out?',
      message: 'You will need to sign in again to manage the app.',
      confirmLabel: 'Sign out',
    );
    if (!confirmed || !mounted) return;

    try {
      await ref.read(authControllerProvider).signOut();
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        e,
        fallback: 'We could not sign you out. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: _confirmSignOut,
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
                      _IntentionAdminCard(
                        dateController: _dateCtl,
                        quoteController: _quoteCtl,
                        messageController: _messageCtl,
                        saving: _saving,
                        onSave: _saveIntention,
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

class _IntentionAdminCard extends StatelessWidget {
  const _IntentionAdminCard({
    required this.dateController,
    required this.quoteController,
    required this.messageController,
    required this.saving,
    required this.onSave,
  });

  final TextEditingController dateController;
  final TextEditingController quoteController;
  final TextEditingController messageController;
  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily intention',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Set the quote and message users will complete today.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: dateController,
            decoration: const InputDecoration(
              labelText: 'Date',
              prefixIcon: Icon(Icons.event_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: quoteController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Quote',
              prefixIcon: Icon(Icons.format_quote_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: messageController,
            minLines: 2,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Task message',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.task_alt_rounded),
            ),
          ),
          const SizedBox(height: 16),
          FullWidthButton(
            label: 'Save daily intention',
            icon: Icons.save_outlined,
            loading: saving,
            onPressed: onSave,
          ),
        ],
      ),
    );
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
