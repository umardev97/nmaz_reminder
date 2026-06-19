import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme.dart';
import '../../../../features/intention/models/daily_intention.dart';
import '../../../../features/intention/providers/intention_provider.dart';
import '../../../widgets/app_ui.dart';

class AdminIntentionsTab extends ConsumerWidget {
  const AdminIntentionsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intentionsAsync = ref.watch(allIntentionsProvider);

    return SingleChildScrollView(
      child: AppPage(
        maxWidth: 900,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Uploaded intentions',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Review the quotes and task messages uploaded for users.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),
            intentionsAsync.when(
              data: (intentions) =>
                  _UploadedIntentionsList(intentions: intentions),
              loading: () => const PremiumCard(
                child: AppLoadingView(message: 'Loading uploaded intentions'),
              ),
              error: (_, __) => const PremiumCard(
                child: AppStateView(
                  title: 'Intentions unavailable',
                  message: 'Could not load uploaded quotes right now.',
                  icon: Icons.cloud_off_rounded,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadedIntentionsList extends StatelessWidget {
  const _UploadedIntentionsList({required this.intentions});

  final List<DailyIntention> intentions;

  @override
  Widget build(BuildContext context) {
    if (intentions.isEmpty) {
      return const PremiumCard(
        child: AppStateView(
          title: 'No intentions uploaded',
          message: 'Saved daily quotes and messages will appear here.',
          icon: Icons.format_quote_rounded,
        ),
      );
    }

    return Column(
      children: [
        for (final intention in intentions)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: PremiumCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.format_quote_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          intention.date,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
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
                        intention.quote.trim().isEmpty
                            ? 'No quote added'
                            : intention.quote.trim(),
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
                        intention.message.trim().isEmpty
                            ? 'No message added'
                            : intention.message.trim(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.background,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
      ],
    );
  }
}
