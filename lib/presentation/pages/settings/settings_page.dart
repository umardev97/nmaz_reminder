import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_utils.dart';
import '../../../core/constants.dart';
import '../../../core/notification_service.dart';
import '../../../core/theme.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/prayer/providers/prayer_notification_provider.dart';
import '../../widgets/app_ui.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _remindersEnabled = true;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = ref.read(firebaseUserProvider).asData?.value;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final pref = await ref
          .read(settingsRepositoryProvider)
          .getReminderEnabled(user.uid);
      if (mounted) setState(() => _remindersEnabled = pref);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _setReminders(bool value) async {
    final user = ref.read(firebaseUserProvider).asData?.value;
    if (user == null) return;
    setState(() {
      _remindersEnabled = value;
      _saving = true;
    });
    try {
      await ref
          .read(settingsRepositoryProvider)
          .setReminderEnabled(user.uid, value);
      if (value) {
        await ref.read(defaultPrayerScheduler)();
      } else {
        await NotificationService.cancelAll();
      }
      if (!mounted) return;
      AppSnackBar.showSuccess(
        context,
        value ? 'Prayer reminders enabled' : 'Prayer reminders disabled',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _remindersEnabled = !value);
      AppSnackBar.showError(
        context,
        e,
        fallback: 'Could not update reminders. Please try again.',
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showPrivacyInfo() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Privacy'),
        content: const Text(AppConstants.privacyNote),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _loading
          ? const AppLoadingView(message: 'Loading settings')
          : SingleChildScrollView(
              child: AppPage(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel('Notifications'),
                    PremiumCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 4),
                            leading: _IconBox(
                                Icons.notifications_active_outlined),
                            title: const Text('Prayer reminders'),
                            subtitle: const Text('Azan alert at each prayer time'),
                            trailing: _saving
                                ? const SizedBox.square(
                                    dimension: 24,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.5))
                                : Switch(
                                    value: _remindersEnabled,
                                    onChanged: _setReminders,
                                  ),
                          ),
                          const Divider(height: 1),
                          _SettingsTile(
                            icon: Icons.schedule_rounded,
                            title: 'Follow-up reminder',
                            value: AppConstants.followUpDisplay,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    _SectionLabel('Prayer'),
                    PremiumCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _SettingsTile(
                            icon: Icons.location_on_outlined,
                            title: 'Prayer location',
                            value: AppConstants.defaultPrayerLocation,
                          ),
                          const Divider(height: 1),
                          _SettingsTile(
                            icon: Icons.calculate_outlined,
                            title: 'Calculation method',
                            value: AppConstants.defaultCalculationMethod,
                          ),
                          const Divider(height: 1),
                          _SettingsTile(
                            icon: Icons.volume_up_outlined,
                            title: 'Notification sound',
                            value: AppConstants.defaultNotificationSound,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    _SectionLabel('Account'),
                    PremiumCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _SettingsTile(
                            icon: Icons.shield_outlined,
                            title: 'Privacy',
                            value: 'Tap to learn more',
                            onTap: _showPrivacyInfo,
                          ),
                          const Divider(height: 1),
                          _SettingsTile(
                            icon: Icons.info_outline_rounded,
                            title: 'App version',
                            value: AppConstants.appVersion,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              color: AppColors.primary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Prayer times are calculated for '
                              '${AppConstants.defaultPrayerLocation} using the '
                              '${AppConstants.defaultCalculationMethod} method.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      leading: _IconBox(icon),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.textSecondary),
          ],
        ],
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox(this.icon);
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(icon, color: AppColors.primary, size: 20),
    );
  }
}
