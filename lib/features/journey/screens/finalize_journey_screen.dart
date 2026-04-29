import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_profile_provider.dart';

class FinalizeJourneyScreen extends ConsumerStatefulWidget {
  const FinalizeJourneyScreen({super.key});

  @override
  ConsumerState<FinalizeJourneyScreen> createState() =>
      _FinalizeJourneyScreenState();
}

class _FinalizeJourneyScreenState
    extends ConsumerState<FinalizeJourneyScreen> {
  int _rating = 0;
  final _feedbackController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final name =
        profileAsync.valueOrNull?.displayName ?? 'Pilgrim';

    if (_submitted) return _SuccessView(name: name);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(title: const Text('Finalize My Journey')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Farewell header ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppConstants.spaceLG),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2A2318), Color(0xFF1E1B12)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusXL),
                border: Border.all(
                  color: AppColors.primaryGold.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.flight_takeoff_rounded,
                      color: AppColors.primaryGold, size: 44),
                  const SizedBox(height: AppConstants.spaceMD),
                  Text(
                    'Journey Complete, $name',
                    style: AppTextStyles.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spaceSM),
                  Text(
                    'May Allah accept your Umrah and grant you many more blessed journeys.',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spaceLG),
                  Text(
                    'تَقَبَّلَ اللهُ مِنَّا وَمِنكُم',
                    style: AppTextStyles.arabicText,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spaceLG),

            // ── Journey summary ──────────────────────────────────────
            Text('Your Journey Summary',
                style: AppTextStyles.titleMedium),
            const SizedBox(height: AppConstants.spaceSM),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusMD),
                border: Border.all(
                    color: AppColors.cardBorder, width: 0.5),
              ),
              child: Column(
                children: const [
                  _SummaryRow(
                      icon: Icons.check_circle_rounded,
                      color: AppColors.success,
                      label: 'Niyyah',
                      value: 'Completed'),
                  Divider(height: 1, color: AppColors.divider),
                  _SummaryRow(
                      icon: Icons.check_circle_rounded,
                      color: AppColors.success,
                      label: 'Ihram & Talbiyah',
                      value: 'Completed'),
                  Divider(height: 1, color: AppColors.divider),
                  _SummaryRow(
                      icon: Icons.check_circle_rounded,
                      color: AppColors.success,
                      label: 'Tawaf (7 circuits)',
                      value: 'Completed'),
                  Divider(height: 1, color: AppColors.divider),
                  _SummaryRow(
                      icon: Icons.check_circle_rounded,
                      color: AppColors.success,
                      label: "Sa'i (7 circuits)",
                      value: 'Completed'),
                  Divider(height: 1, color: AppColors.divider),
                  _SummaryRow(
                      icon: Icons.check_circle_rounded,
                      color: AppColors.success,
                      label: 'Halq / Taqsir',
                      value: 'Completed'),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spaceLG),

            // ── Rating ───────────────────────────────────────────────
            Text('Rate Your Experience',
                style: AppTextStyles.titleMedium),
            const SizedBox(height: AppConstants.spaceSM),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                return GestureDetector(
                  onTap: () => setState(() => _rating = i + 1),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      i < _rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: AppColors.primaryGold,
                      size: 38,
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: AppConstants.spaceLG),

            // ── Feedback ─────────────────────────────────────────────
            Text('Leave a Note (optional)',
                style: AppTextStyles.titleMedium),
            const SizedBox(height: AppConstants.spaceSM),
            TextField(
              controller: _feedbackController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                    'What was most meaningful about your journey?',
              ),
            ),

            const SizedBox(height: AppConstants.spaceXL),

            // ── Submit ───────────────────────────────────────────────
            ElevatedButton.icon(
              onPressed: () => setState(() => _submitted = true),
              icon: const Icon(Icons.check_rounded),
              label: const Text('Complete My Journey'),
            ),

            const SizedBox(height: AppConstants.spaceSM),

            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Sign Out?'),
                    content: const Text(
                        'You will be signed out of Umrah Ease.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ref
                              .read(authNotifierProvider.notifier)
                              .signOut();
                        },
                        child: Text('Sign Out',
                            style: TextStyle(
                                color: AppColors.error)),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign Out'),
            ),

            const SizedBox(height: AppConstants.spaceLG),
          ],
        ),
      ),
    );
  }
}

// ── Success view ──────────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spaceXXL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryGold.withValues(alpha: 0.15),
                    border: Border.all(
                        color: AppColors.primaryGold, width: 2),
                  ),
                  child: const Icon(Icons.favorite_rounded,
                      color: AppColors.primaryGold, size: 44),
                ),
                const SizedBox(height: AppConstants.spaceLG),
                Text('Jazakallahu Khayran, $name',
                    style: AppTextStyles.headlineMedium,
                    textAlign: TextAlign.center),
                const SizedBox(height: AppConstants.spaceSM),
                Text(
                  'Thank you for using Umrah Ease. Your feedback helps us improve for every pilgrim.',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spaceXXL),
                ElevatedButton.icon(
                  onPressed: () => context.go(AppRoutes.home),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Back to Dashboard'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Summary row ───────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceMD, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppConstants.spaceSM),
          Expanded(
              child: Text(label, style: AppTextStyles.titleSmall)),
          Text(value,
              style: AppTextStyles.labelMedium
                  .copyWith(color: AppColors.success)),
        ],
      ),
    );
  }
}
