import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../features/auth/providers/user_profile_provider.dart';
import '../../../features/checklist/providers/checklist_provider.dart';
import '../../../features/education/providers/training_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final guidesAsync = ref.watch(trainingProvider);
    final (checked, total) = ref.watch(checklistProgressProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _Header(profileAsync: profileAsync),
            ),

            // ── Journey countdown ────────────────────────────────────────────
            const SliverToBoxAdapter(child: _CountdownCard()),

            // ── Quick actions grid ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppConstants.spaceMD, 0, AppConstants.spaceMD, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quick Actions', style: AppTextStyles.titleMedium),
                    const SizedBox(height: AppConstants.spaceSM),
                    _QuickActionsGrid(),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(
                child: SizedBox(height: AppConstants.spaceLG)),

            // ── Preparation progress ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: _SectionHeader(title: 'Preparation'),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spaceMD),
                child: _ProgressCard(
                  label: 'Packing Checklist',
                  icon: Icons.luggage_rounded,
                  checked: checked,
                  total: total,
                  onTap: () => context.push(AppRoutes.packingChecklist),
                ),
              ),
            ),

            const SliverToBoxAdapter(
                child: SizedBox(height: AppConstants.spaceMD)),

            // ── Training overview ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Umrah Training',
                action: 'View all',
                onAction: () => context.push(AppRoutes.educationHub),
              ),
            ),
            SliverToBoxAdapter(
              child: guidesAsync.when(
                loading: () => const _ShimmerCard(),
                error: (_, __) => const SizedBox.shrink(),
                data: (guides) {
                  final categories =
                      guides.map((g) => g.category).toSet().toList();
                  return SizedBox(
                    height: 88,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spaceMD),
                      itemCount: categories.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: AppConstants.spaceSM),
                      itemBuilder: (_, i) =>
                          _CategoryChip(label: categories[i]),
                    ),
                  );
                },
              ),
            ),

            const SliverToBoxAdapter(
                child: SizedBox(height: AppConstants.spaceXL)),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.profileAsync});
  final AsyncValue profileAsync;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppConstants.spaceMD,
          AppConstants.spaceMD, AppConstants.spaceMD, AppConstants.spaceLG),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Assalamu Alaikum,', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 2),
                profileAsync.when(
                  loading: () => const SizedBox(height: 24),
                  error: (_, __) => Text('Pilgrim',
                      style: AppTextStyles.headlineMedium),
                  data: (profile) => Text(
                    profile?.displayName ?? 'Pilgrim',
                    style: AppTextStyles.headlineMedium,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceVariant,
              border: Border.all(color: AppColors.primaryGold, width: 1.5),
            ),
            child: const Icon(Icons.person_rounded,
                color: AppColors.primaryGold, size: 22),
          ),
        ],
      ),
    );
  }
}

// ── Countdown card ────────────────────────────────────────────────────────────

class _CountdownCard extends StatelessWidget {
  const _CountdownCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppConstants.spaceMD, 0,
          AppConstants.spaceMD, AppConstants.spaceLG),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spaceMD),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2A2318), Color(0xFF1E1B12)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
          border: Border.all(
              color: AppColors.primaryGold.withValues(alpha: 0.3), width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.mosque_rounded,
                    color: AppColors.primaryGold, size: 18),
                const SizedBox(width: AppConstants.spaceSM),
                Text('Journey to Makkah',
                    style: AppTextStyles.labelLarge
                        .copyWith(color: AppColors.primaryGold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Upcoming',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.success)),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceMD),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _CountUnit(value: '14', label: 'DAYS'),
                _CountDivider(),
                _CountUnit(value: '08', label: 'HRS'),
                _CountDivider(),
                _CountUnit(value: '30', label: 'MINS'),
              ],
            ),
            const SizedBox(height: AppConstants.spaceMD),
            Row(
              children: [
                const Icon(Icons.flight_rounded,
                    color: AppColors.textMuted, size: 14),
                const SizedBox(width: 4),
                Text('Jeddah, Saudi Arabia',
                    style: AppTextStyles.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CountUnit extends StatelessWidget {
  const _CountUnit({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.countdownLarge),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.labelSmall),
      ],
    );
  }
}

class _CountDivider extends StatelessWidget {
  const _CountDivider();

  @override
  Widget build(BuildContext context) {
    return Text(':',
        style: AppTextStyles.countdownLarge
            .copyWith(color: AppColors.primaryGoldDark));
  }
}

// ── Quick actions grid ────────────────────────────────────────────────────────

class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _Action(
          icon: Icons.school_rounded,
          label: 'Education Hub',
          color: const Color(0xFF7C5CBF),
          onTap: () => context.push(AppRoutes.educationHub)),
      _Action(
          icon: Icons.menu_book_rounded,
          label: 'Ritual Guide',
          color: const Color(0xFF1E7D52),
          onTap: () => context.push(AppRoutes.ritualGuide)),
      _Action(
          icon: Icons.family_restroom_rounded,
          label: 'Family Tracker',
          color: const Color(0xFF1A6FA8),
          onTap: () => context.push(AppRoutes.familyTracker)),
      _Action(
          icon: Icons.emergency_rounded,
          label: 'Emergency',
          color: AppColors.error,
          onTap: () => context.push(AppRoutes.emergency)),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppConstants.spaceSM,
      crossAxisSpacing: AppConstants.spaceSM,
      childAspectRatio: 2.4,
      children: actions
          .map((a) => _QuickActionCard(action: a))
          .toList(),
    );
  }
}

class _Action {
  const _Action(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.action});
  final _Action action;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceMD, vertical: AppConstants.spaceSM),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          border:
              Border.all(color: AppColors.cardBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: action.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(action.icon, color: action.color, size: 18),
            ),
            const SizedBox(width: AppConstants.spaceSM),
            Expanded(
              child: Text(action.label,
                  style: AppTextStyles.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppConstants.spaceMD, 0,
          AppConstants.spaceMD, AppConstants.spaceSM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.titleMedium),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(action!,
                  style: AppTextStyles.labelLarge
                      .copyWith(color: AppColors.primaryGold)),
            ),
        ],
      ),
    );
  }
}

// ── Progress card ─────────────────────────────────────────────────────────────

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.label,
    required this.icon,
    required this.checked,
    required this.total,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final int checked;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : checked / total;
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                Icon(icon, color: AppColors.primaryGold, size: 20),
                const SizedBox(width: AppConstants.spaceSM),
                Text(label, style: AppTextStyles.titleSmall),
                const Spacer(),
                Text('$checked / $total',
                    style: AppTextStyles.goldLabel),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textMuted, size: 18),
              ],
            ),
            const SizedBox(height: AppConstants.spaceSM),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 6,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: const AlwaysStoppedAnimation(AppColors.primaryGold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Category chip ─────────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.educationHub),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(AppConstants.spaceSM),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          border: Border.all(color: AppColors.cardBorder, width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.book_rounded,
                color: AppColors.primaryGold, size: 22),
            const SizedBox(height: 4),
            Text(label,
                style: AppTextStyles.labelMedium,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

// ── Shimmer placeholder ───────────────────────────────────────────────────────

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD),
      child: Container(
        height: 88,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        ),
      ),
    );
  }
}
