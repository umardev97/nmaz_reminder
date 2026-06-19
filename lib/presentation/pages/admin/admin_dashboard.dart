import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/app_utils.dart';
import '../../../features/admin/providers/admin_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/intention/models/daily_intention.dart';
import '../../../features/intention/providers/intention_provider.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/app_ui.dart';
import 'tabs/admin_dashboard_tab.dart';
import 'tabs/admin_intentions_tab.dart';
import 'tabs/admin_users_tab.dart';
import 'widgets/admin_user_activity_sheet.dart';

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

  DateTime _activityDate = DateTime.now();
  int _selectedIndex = 0;
  bool _saving = false;

  String get _activityDateId => DateFormat('yyyy-MM-dd').format(_activityDate);

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

  Future<void> _pickIntentionDate() async {
    final initial = DateTime.tryParse(_dateCtl.text.trim()) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) return;
    _dateCtl.text = DateFormat('yyyy-MM-dd').format(picked);
  }

  Future<void> _pickActivityDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _activityDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked == null || !mounted) return;
    setState(() => _activityDate = picked);
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

  void _showUserDetails(Map<String, dynamic> user) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AdminUserActivitySheet(
        user: user,
        date: _activityDateId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersStreamProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            AppLogo(height: 42, compact: true),
            SizedBox(width: 12),
            Text('Admin'),
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
          final members =
              users.where((user) => user['role'] != 'admin').toList();
          return IndexedStack(
            index: _selectedIndex,
            children: [
              AdminDashboardTab(
                memberCount: members.length,
                adminCount: admins,
                dateController: _dateCtl,
                quoteController: _quoteCtl,
                messageController: _messageCtl,
                saving: _saving,
                onPickDate: _pickIntentionDate,
                onSave: _saveIntention,
              ),
              AdminUsersTab(
                members: members,
                activityDate: _activityDate,
                activityDateId: _activityDateId,
                onPickActivityDate: _pickActivityDate,
                onShowUserDetails: _showUserDetails,
              ),
              const AdminIntentionsTab(),
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_alt_outlined),
            selectedIcon: Icon(Icons.people_alt_rounded),
            label: 'Users',
          ),
          NavigationDestination(
            icon: Icon(Icons.format_quote_outlined),
            selectedIcon: Icon(Icons.format_quote_rounded),
            label: 'Intentions',
          ),
        ],
      ),
    );
  }
}
