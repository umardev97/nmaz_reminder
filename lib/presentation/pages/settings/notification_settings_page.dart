import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_error.dart';
import '../../../core/app_utils.dart';
import '../../../core/notification_service.dart';
import '../../../core/theme.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/auth/settings_repository.dart';
import '../../../features/prayer/providers/prayer_notification_provider.dart';
import '../../widgets/app_ui.dart';

class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends ConsumerState<NotificationSettingsPage> {
  bool _enabled = true;
  bool _loading = true;
  bool _saving = false;
  String? _error;

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
      final pref = await SettingsRepository().getReminderEnabled(user.uid);
      if (mounted) setState(() => _enabled = pref);
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = userMessageFromError(
            e,
            fallback: 'Your preferences could not be loaded.',
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _setEnabled(bool value) async {
    final user = ref.read(firebaseUserProvider).asData?.value;
    if (user == null) return;
    setState(() {
      _enabled = value;
      _saving = true;
    });
    try {
      await SettingsRepository().setReminderEnabled(user.uid, value);
      if (value) {
        await ref.read(defaultPrayerScheduler)();
      } else {
        await NotificationService.cancelAll();
      }
      if (!mounted) return;
      AppSnackBar.showSuccess(
        context,
        value ? 'Prayer reminders are on' : 'Prayer reminders are off',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _enabled = !value);
      AppSnackBar.showError(
        context,
        e,
        fallback: 'Could not update reminders. Please try again.',
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: _loading
          ? const AppLoadingView(message: 'Loading reminder settings')
          : _error != null
              ? AppStateView(
                  title: 'Settings unavailable',
                  message: _error!,
                  icon: Icons.notifications_off_outlined,
                  actionLabel: 'Try again',
                  onAction: _load,
                )
              : SingleChildScrollView(
                  child: AppPage(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Prayer reminders',
                            style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 8),
                        Text(
                          'Stay gently connected to each prayer throughout your day.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 26),
                        PremiumCard(
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: .1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Icon(
                                    Icons.notifications_active_outlined,
                                    color: AppColors.primary),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Enable reminders',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Prayer time and follow-up alerts',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                              color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              if (_saving)
                                const SizedBox.square(
                                    dimension: 24,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.5))
                              else
                                Switch(value: _enabled, onChanged: _setEnabled),
                            ],
                          ),
                        ),
                        const SizedBox(height: 26),
                        Text('Reminder details',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        const PremiumCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              _DetailTile(
                                  icon: Icons.location_on_outlined,
                                  title: 'Location',
                                  value: 'Lahore, Pakistan'),
                              Divider(height: 1),
                              _DetailTile(
                                  icon: Icons.schedule_rounded,
                                  title: 'Follow-up',
                                  value: '30 minutes after prayer'),
                              Divider(height: 1),
                              _DetailTile(
                                  icon: Icons.volume_up_outlined,
                                  title: 'Sound',
                                  value: 'Azan'),
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
                                  'Your device may ask for notification and exact alarm permission so reminders arrive on time.',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile(
      {required this.icon, required this.title, required this.value});
  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: Flexible(
        child: Text(value,
            textAlign: TextAlign.end,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textSecondary)),
      ),
    );
  }
}
