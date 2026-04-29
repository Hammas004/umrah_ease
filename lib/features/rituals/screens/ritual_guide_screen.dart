import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../rituals/providers/ritual_provider.dart';

class RitualGuideScreen extends ConsumerWidget {
  const RitualGuideScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ritualGuideProvider);
    final notifier = ref.read(ritualGuideProvider.notifier);
    final step = state.current;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(step.ritualGroup),
        actions: [
          TextButton(
            onPressed: () => notifier.reset(),
            child: Text('Reset',
                style: AppTextStyles.labelLarge
                    .copyWith(color: AppColors.primaryGold)),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Progress bar ────────────────────────────────────────────────────
          LinearProgressIndicator(
            value: state.progressFraction,
            minHeight: 3,
            backgroundColor: AppColors.surfaceVariant,
            valueColor:
                const AlwaysStoppedAnimation(AppColors.primaryGold),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spaceMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Step indicator
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Step ${state.currentIndex + 1} of ${state.steps.length}',
                          style: AppTextStyles.labelMedium
                              .copyWith(color: AppColors.primaryGold),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.spaceMD),

                  // Title
                  Text(step.title, style: AppTextStyles.headlineMedium),

                  const SizedBox(height: AppConstants.spaceLG),

                  // Arabic text card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppConstants.spaceLG),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2A2318), Color(0xFF1E1B12)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusLG),
                      border: Border.all(
                        color: AppColors.primaryGold.withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          step.arabicText,
                          style: AppTextStyles.arabicText,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                        ),
                        const Divider(
                            color: AppColors.divider, height: 32),
                        Text(
                          step.transliteration,
                          style: AppTextStyles.transliterationText,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppConstants.spaceSM),
                        Text(
                          step.englishText,
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textPrimary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppConstants.spaceLG),

                  // Instructions
                  Text('How to Perform',
                      style: AppTextStyles.titleSmall
                          .copyWith(color: AppColors.primaryGold)),
                  const SizedBox(height: AppConstants.spaceSM),
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spaceMD),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMD),
                      border: Border.all(
                          color: AppColors.cardBorder, width: 0.5),
                    ),
                    child: Text(
                      step.instructions,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),

                  const SizedBox(height: AppConstants.spaceLG),

                  // Steps overview
                  Text('All Steps',
                      style: AppTextStyles.titleSmall
                          .copyWith(color: AppColors.textMuted)),
                  const SizedBox(height: AppConstants.spaceSM),
                  _StepsOverview(state: state),

                  const SizedBox(height: AppConstants.spaceXL),
                ],
              ),
            ),
          ),

          // ── Navigation buttons ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppConstants.spaceMD),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border:
                  Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: state.isFirst ? null : notifier.previous,
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text('Previous'),
                  ),
                ),
                const SizedBox(width: AppConstants.spaceMD),
                Expanded(
                  child: state.isLast
                      ? ElevatedButton.icon(
                          onPressed: () =>
                              context.push(AppRoutes.ritualCompletion),
                          icon: const Icon(Icons.check_circle_rounded,
                              size: 18),
                          label: const Text('Complete'),
                        )
                      : ElevatedButton.icon(
                          onPressed: notifier.next,
                          icon: const Icon(Icons.arrow_forward_rounded,
                              size: 18),
                          label: const Text('Next'),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Steps overview ────────────────────────────────────────────────────────────

class _StepsOverview extends ConsumerWidget {
  const _StepsOverview({required this.state});
  final RitualGuideState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: List.generate(state.steps.length, (i) {
        final isCurrent = i == state.currentIndex;
        final isCompleted = i < state.currentIndex;
        return GestureDetector(
          onTap: () =>
              ref.read(ritualGuideProvider.notifier).jumpTo(i),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.success.withValues(alpha: 0.2)
                  : isCurrent
                      ? AppColors.primaryGold
                      : AppColors.surfaceVariant,
              shape: BoxShape.circle,
              border: isCurrent
                  ? null
                  : Border.all(color: AppColors.divider, width: 0.5),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check_rounded,
                      color: AppColors.success, size: 14)
                  : Text(
                      '${i + 1}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isCurrent
                            ? AppColors.textOnGold
                            : AppColors.textMuted,
                        fontWeight: isCurrent
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
            ),
          ),
        );
      }),
    );
  }
}
