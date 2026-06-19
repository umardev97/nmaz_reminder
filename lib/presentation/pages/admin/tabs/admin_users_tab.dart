import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme.dart';
import '../../../widgets/app_ui.dart';

class AdminUsersTab extends StatelessWidget {
  const AdminUsersTab({
    super.key,
    required this.members,
    required this.activityDate,
    required this.activityDateId,
    required this.onPickActivityDate,
    required this.onShowUserDetails,
  });

  final List<Map<String, dynamic>> members;
  final DateTime activityDate;
  final String activityDateId;
  final VoidCallback onPickActivityDate;
  final ValueChanged<Map<String, dynamic>> onShowUserDetails;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: AppPage(
            maxWidth: 900,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ActivityDateCard(
                  date: activityDate,
                  onPickDate: onPickActivityDate,
                ),
                const SizedBox(height: 28),
                SectionHeader(title: 'User activity on $activityDateId'),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        if (members.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: AppStateView(
              title: 'No users yet',
              message: 'Member accounts will appear here.',
              showLogo: true,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            sliver: SliverList.separated(
              itemCount: members.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final user = members[index];
                final name = (user['name'] as String?)?.trim();
                final email = user['email'] as String?;
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 860),
                    child: PremiumCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        onTap: () => onShowUserDetails(user),
                        leading: CircleAvatar(
                          backgroundColor:
                              AppColors.primary.withValues(alpha: .12),
                          foregroundColor: AppColors.primary,
                          child: Text(_initials(name ?? email ?? 'M')),
                        ),
                        title: Text(
                          name?.isNotEmpty == true ? name! : 'Unnamed member',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          email ?? 'No email added',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            'User',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: Colors.black),
                          ),
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
  }

  static String _initials(String value) {
    final words = value.trim().split(RegExp(r'\s+'));
    return words
        .take(2)
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase())
        .join();
  }
}

class _ActivityDateCard extends StatelessWidget {
  const _ActivityDateCard({
    required this.date,
    required this.onPickDate,
  });

  final DateTime date;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
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
            child: const Icon(
              Icons.calendar_month_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Activity date',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, d MMM yyyy').format(date),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Pick date',
            onPressed: onPickDate,
            icon: const Icon(Icons.edit_calendar_outlined),
          ),
        ],
      ),
    );
  }
}
