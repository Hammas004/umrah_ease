import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../rituals/providers/ritual_provider.dart';

class SaiGuideScreen extends ConsumerWidget {
  const SaiGuideScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circuits = ref.watch(saiCounterProvider);
    final notifier = ref.read(saiCounterProvider.notifier);
    final isComplete = circuits == 7;

    // Alternate direction: odd circuits Safa→Marwa, even circuits Marwa→Safa
    final goingToMarwa = circuits % 2 == 0;
    final fromLabel = goingToMarwa ? 'Safa' : 'Marwa';
    final toLabel = goingToMarwa ? 'Marwa' : 'Safa';

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text("Sa'i Guide"),
        actions: [
          TextButton(
            onPressed: () => notifier.reset(),
            child: Text('Reset',
                style: AppTextStyles.labelLarge
                    .copyWith(color: AppColors.primaryGold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Circuit counter ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.spaceXL),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2A2318), Color(0xFF1E1B12)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                border: Border.all(
                  color: isComplete
                      ? AppColors.success.withValues(alpha: 0.5)
                      : AppColors.primaryGold.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    isComplete ? 'Sa\'i Complete!' : 'Circuit',
                    style: AppTextStyles.titleSmall
                        .copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: AppConstants.spaceSM),
                  Text(
                    '$circuits / 7',
                    style: AppTextStyles.countdownLarge.copyWith(fontSize: 56),
                  ),
                  if (!isComplete) ...[
                    const SizedBox(height: AppConstants.spaceMD),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _MountLabel(name: fromLabel, isStart: true),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.primaryGold,
                            size: 28,
                          ),
                        ),
                        _MountLabel(name: toLabel, isStart: false),
                      ],
                    ),
                  ] else
                    Padding(
                      padding:
                          const EdgeInsets.only(top: AppConstants.spaceSM),
                      child: const Icon(Icons.check_circle_rounded,
                          color: AppColors.success, size: 40),
                    ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spaceLG),

            // ── Circuit dots ──────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(7, (i) {
                final done = i < circuits;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done
                        ? AppColors.success.withValues(alpha: 0.2)
                        : AppColors.surfaceVariant,
                    border: Border.all(
                      color:
                          done ? AppColors.success : AppColors.divider,
                      width: 0.8,
                    ),
                  ),
                  child: Center(
                    child: done
                        ? const Icon(Icons.check_rounded,
                            color: AppColors.success, size: 14)
                        : Text('${i + 1}',
                            style: AppTextStyles.labelSmall),
                  ),
                );
              }),
            ),

            const SizedBox(height: AppConstants.spaceLG),

            // ── Du'a card ─────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppConstants.spaceMD),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                border: Border.all(color: AppColors.cardBorder, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Du\'a for This Circuit',
                      style: AppTextStyles.titleSmall
                          .copyWith(color: AppColors.primaryGold)),
                  const SizedBox(height: AppConstants.spaceMD),
                  if (circuits == 0 || goingToMarwa) ...[
                    Text(
                      'إِنَّ الصَّفَا وَالْمَرْوَةَ مِن شَعَائِرِ اللَّهِ',
                      style: AppTextStyles.arabicText,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: AppConstants.spaceSM),
                    Text(
                      'Innaṣ-ṣafā wal-marwata min sha\'ā\'irillāh',
                      style: AppTextStyles.transliterationText,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.spaceSM),
                    Text(
                      '"Indeed, Safa and Marwa are among the symbols of Allah."',
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    Text(
                      'رَبِّ اغْفِرْ وَارْحَمْ، إِنَّكَ أَنتَ الْأَعَزُّ الْأَكْرَمُ',
                      style: AppTextStyles.arabicText,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: AppConstants.spaceSM),
                    Text(
                      'Rabbigh-fir warḥam, innaka antal-a\'azzul-akram',
                      style: AppTextStyles.transliterationText,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.spaceSM),
                    Text(
                      '"My Lord, forgive and have mercy. Indeed You are the Most Mighty, the Most Noble."',
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spaceLG),

            // ── Instructions ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppConstants.spaceMD),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                border: Border.all(color: AppColors.cardBorder, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: AppColors.primaryGold, size: 16),
                      const SizedBox(width: 6),
                      Text('Instructions',
                          style: AppTextStyles.titleSmall),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spaceSM),
                  Text(
                    '• Men jog briskly between the two green marker lights on the valley floor\n'
                    '• Women and elderly walk at a normal pace\n'
                    '• Face Masjid Al-Haram at each mount and make du\'a three times\n'
                    '• Each one-way trip counts as one circuit (7 trips total)\n'
                    '• Sa\'i ends at Marwa (circuit 7)',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spaceXL),

            // ── Complete circuit button ────────────────────────────────────
            if (!isComplete)
              ElevatedButton.icon(
                onPressed: notifier.increment,
                icon: const Icon(Icons.add_rounded),
                label: Text(
                    'Complete Circuit ${circuits + 1}'),
              )
            else
              OutlinedButton.icon(
                onPressed: notifier.reset,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Start Sa\'i Again'),
              ),

            const SizedBox(height: AppConstants.spaceLG),
          ],
        ),
      ),
    );
  }
}

class _MountLabel extends StatelessWidget {
  const _MountLabel({required this.name, required this.isStart});
  final String name;
  final bool isStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(
          color: isStart
              ? AppColors.primaryGold.withValues(alpha: 0.5)
              : AppColors.divider,
          width: 0.8,
        ),
      ),
      child: Text(name,
          style: AppTextStyles.titleSmall.copyWith(
            color: isStart ? AppColors.primaryGold : AppColors.textPrimary,
          )),
    );
  }
}
