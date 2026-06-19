import 'package:flutter/material.dart';

import '../../../../core/styles.dart';
import '../../../../core/theme.dart';
import '../../../widgets/app_ui.dart';

class AdminDashboardTab extends StatelessWidget {
  const AdminDashboardTab({
    super.key,
    required this.memberCount,
    required this.adminCount,
    required this.dateController,
    required this.quoteController,
    required this.messageController,
    required this.saving,
    required this.onPickDate,
    required this.onSave,
  });

  final int memberCount;
  final int adminCount;
  final TextEditingController dateController;
  final TextEditingController quoteController;
  final TextEditingController messageController;
  final bool saving;
  final VoidCallback onPickDate;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AppPage(
        maxWidth: 900,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Community overview',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Manage members and keep an eye on account access.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),
            _IntentionAdminCard(
              dateController: dateController,
              quoteController: quoteController,
              messageController: messageController,
              saving: saving,
              onPickDate: onPickDate,
              onSave: onSave,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    value: '$memberCount',
                    label: 'Users',
                    icon: Icons.people_alt_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    value: '$adminCount',
                    label: 'Admins',
                    icon: Icons.admin_panel_settings_outlined,
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

class _IntentionAdminCard extends StatelessWidget {
  const _IntentionAdminCard({
    required this.dateController,
    required this.quoteController,
    required this.messageController,
    required this.saving,
    required this.onPickDate,
    required this.onSave,
  });

  final TextEditingController dateController;
  final TextEditingController quoteController;
  final TextEditingController messageController;
  final bool saving;
  final VoidCallback onPickDate;
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
            readOnly: true,
            onTap: onPickDate,
            decoration: const InputDecoration(
              labelText: 'Date',
              prefixIcon: Icon(Icons.event_outlined),
              suffixIcon: Icon(Icons.calendar_month_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: quoteController,
            textCapitalization: TextCapitalization.sentences,
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
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
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
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
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppGradients.premium,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accent),
          const SizedBox(height: 18),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: Colors.white),
          ),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
