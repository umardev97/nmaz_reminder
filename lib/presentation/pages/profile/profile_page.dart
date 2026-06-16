import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_utils.dart';
import '../../../core/notification_service.dart';
import '../../../core/theme.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/app_ui.dart';
import '../settings/notification_settings_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(appUserProvider).asData?.value;
    final authUser = ref.watch(firebaseUserProvider).asData?.value;
    final name = user?.name.trim().isNotEmpty == true
        ? user!.name
        : 'Nmaz Reminder member';
    final email = user?.email ?? authUser?.email ?? 'Private account';

    Future<void> confirmSignOut() async {
      final confirmed = await AppDialogs.confirm(
        context,
        title: 'Sign out?',
        message:
            'You will need to sign in again to view your reminders and progress.',
        confirmLabel: 'Sign out',
      );
      if (!confirmed || !context.mounted) return;

      try {
        await ref.read(authControllerProvider).signOut();
      } catch (e) {
        if (!context.mounted) return;
        AppSnackBar.showError(
          context,
          e,
          fallback: 'We could not sign you out. Please try again.',
        );
      }
    }

    Future<void> confirmDeleteAccount() async {
      final confirmed = await AppDialogs.confirm(
        context,
        title: 'Delete account?',
        message:
            'This will permanently delete your account, prayer progress, reports, settings, and reminder tokens.',
        confirmLabel: 'Delete account',
        destructive: true,
      );
      if (!confirmed || !context.mounted) return;

      try {
        await NotificationService.cancelAll();
        await ref.read(authControllerProvider).deleteAccount();
        if (!context.mounted) return;
        AppSnackBar.showSuccess(context, 'Your account has been deleted.');
      } catch (e) {
        if (!context.mounted) return;
        AppSnackBar.showError(
          context,
          e,
          fallback: 'We could not delete your account. Please try again.',
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        child: AppPage(
          child: Column(
            children: [
              const SizedBox(height: 12),
              const AppLogo(height: 84, compact: true),
              const SizedBox(height: 18),
              Text(name,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center),
              const SizedBox(height: 5),
              Text(email,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 30),
              PremiumCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _ProfileTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Prayer reminders',
                      subtitle: 'Schedule and notification preferences',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const NotificationSettingsPage()),
                      ),
                    ),
                    const Divider(height: 1),
                    const _ProfileTile(
                      icon: Icons.location_on_outlined,
                      title: 'Prayer location',
                      subtitle: 'Lahore, Pakistan',
                    ),
                    const Divider(height: 1),
                    const _ProfileTile(
                      icon: Icons.shield_outlined,
                      title: 'Privacy and account',
                      subtitle: 'Your activity stays connected to your account',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: confirmSignOut,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sign out'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: confirmDeleteAccount,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side:
                        BorderSide(color: Theme.of(context).colorScheme.error),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Delete account'),
                ),
              ),
              const SizedBox(height: 24),
              Text('Nmaz Reminder 1.0.0',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile(
      {required this.icon,
      required this.title,
      required this.subtitle,
      this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 21),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(subtitle,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.textSecondary)),
      trailing: onTap == null ? null : const Icon(Icons.chevron_right_rounded),
    );
  }
}
