import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../rituals/providers/ritual_provider.dart';

class RitualCompletionScreen extends ConsumerWidget {
  const RitualCompletionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedRituals = [
      'Niyyah (Intention)',
      "Ihram & Talbiyah",
      'Tawaf (7 Circuits)',
      "Sa'i (7 Circuits)",
      'Halq / Taqsir',
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spaceMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppConstants.spaceXL),

              // ── Celebration header ─────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(AppConstants.spaceXL),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2A2318), Color(0xFF1E1B12)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                  border: Border.all(
                    color: AppColors.primaryGold.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.success.withValues(alpha: 0.15),
                        border: Border.all(
                            color: AppColors.success, width: 2),
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: AppColors.success, size: 44),
                    ),
                    const SizedBox(height: AppConstants.spaceMD),
                    Text(
                      'Umrah Complete!',
                      style: AppTextStyles.headlineLarge
                          .copyWith(color: AppColors.primaryGold),
                    ),
                    const SizedBox(height: AppConstants.spaceSM),
                    Text(
                      'Alhamdulillah — May Allah accept your Umrah and forgive your sins.',
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.spaceLG),
                    // Arabic du'a
                    Text(
                      'تَقَبَّلَ اللهُ مِنَّا وَمِنكُم',
                      style: AppTextStyles.arabicText,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: AppConstants.spaceSM),
                    Text(
                      'Taqabbalallāhu minnā wa minkum',
                      style: AppTextStyles.transliterationText,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'May Allah accept from us and from you.',
                      style: AppTextStyles.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.spaceLG),

              // ── Completed rituals ──────────────────────────────────────
              Text('Completed Rituals', style: AppTextStyles.titleMedium),
              const SizedBox(height: AppConstants.spaceSM),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                  border: Border.all(color: AppColors.cardBorder, width: 0.5),
                ),
                child: Column(
                  children: completedRituals.asMap().entries.map((entry) {
                    final isLast =
                        entry.key == completedRituals.length - 1;
                    return Column(
                      children: [
                        ListTile(
                          leading: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.success.withValues(alpha: 0.15),
                            ),
                            child: const Icon(Icons.check_rounded,
                                color: AppColors.success, size: 16),
                          ),
                          title: Text(entry.value,
                              style: AppTextStyles.titleSmall),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.spaceMD,
                              vertical: 4),
                        ),
                        if (!isLast)
                          const Divider(
                              height: 1, color: AppColors.divider),
                      ],
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: AppConstants.spaceLG),

              // ── What's next ────────────────────────────────────────────
              Text('Next Steps', style: AppTextStyles.titleMedium),
              const SizedBox(height: AppConstants.spaceSM),
              Container(
                padding: const EdgeInsets.all(AppConstants.spaceMD),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                  border: Border.all(color: AppColors.cardBorder, width: 0.5),
                ),
                child: Text(
                  '• You have exited the state of Ihram — all restrictions are lifted\n'
                  '• Perform 2 rak\'ahs of prayer in gratitude\n'
                  '• Drink Zamzam water and make du\'a\n'
                  '• Visit Masjid Al-Haram for as long as you wish\n'
                  '• Consider performing additional voluntary Tawaf',
                  style: AppTextStyles.bodyMedium,
                ),
              ),

              const SizedBox(height: AppConstants.spaceXL),

              // ── Actions ────────────────────────────────────────────────
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(ritualGuideProvider.notifier).reset();
                  context.go(AppRoutes.home);
                },
                icon: const Icon(Icons.home_rounded),
                label: const Text('Return to Dashboard'),
              ),
              const SizedBox(height: AppConstants.spaceSM),
              OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.finalizeJourney),
                icon: const Icon(Icons.flag_rounded),
                label: const Text('Finalize My Journey'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
