import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/providers/firebase_providers.dart';
import '../providers/user_profile_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() =>
      _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  // Defaults match the design: First-Timer is pre-selected, Family for group.
  bool _isFirstTimer = true;
  String _groupSize = 'single';

  Future<void> _complete() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    await ref.read(profileSetupProvider.notifier).completeSetup(
          uid: user.uid,
          isFirstTimer: _isFirstTimer,
          groupSize: _groupSize,
        );

    // Router redirect fires automatically once currentUserProfileProvider
    // emits profileComplete == true. No manual navigation needed.
  }

  @override
  Widget build(BuildContext context) {
    final setupState = ref.watch(profileSetupProvider);
    final user = ref.watch(currentUserProvider);

    ref.listen(profileSetupProvider, (prev, next) {
      if (prev?.isLoading == true && !next.isLoading && !next.hasError) {
        // Write succeeded — navigate immediately without waiting for the
        // Firestore stream to reflect the update.
        context.go(AppRoutes.home);
        return;
      }
      if (next.hasError) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(
              content: Text('Failed to save profile. Please try again.')));
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),

              // ── Header ─────────────────────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    // Avatar placeholder
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceVariant,
                        border: Border.all(
                            color: AppColors.primaryGold, width: 2),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: AppColors.iconDefault,
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.displayName ?? 'Pilgrim',
                      style: AppTextStyles.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Let's personalise your journey",
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // ── Divider ─────────────────────────────────────────────────────
              const Divider(),
              const SizedBox(height: 32),

              // ── Experience level ────────────────────────────────────────────
              Text('Experience Level', style: AppTextStyles.titleSmall),
              const SizedBox(height: 12),
              _ExperienceToggle(
                isFirstTimer: _isFirstTimer,
                onChanged: (val) => setState(() => _isFirstTimer = val),
              ),
              const SizedBox(height: 32),

              // ── Group size ──────────────────────────────────────────────────
              Text('Group Size', style: AppTextStyles.titleSmall),
              const SizedBox(height: 12),
              _GroupSizeSelector(
                selected: _groupSize,
                onChanged: (val) => setState(() => _groupSize = val),
              ),
              const SizedBox(height: 48),

              // ── Continue ────────────────────────────────────────────────────
              ElevatedButton(
                onPressed: setupState.isLoading ? null : _complete,
                child: setupState.isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation(AppColors.textOnGold),
                        ),
                      )
                    : const Text('CONTINUE'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Experience Toggle ─────────────────────────────────────────────────────────
//
// Matches the design: a pill-shaped container holding two equal tappable
// segments.  The active segment fills with primaryGold; the inactive one is
// transparent with white text.

class _ExperienceToggle extends StatelessWidget {
  const _ExperienceToggle({
    required this.isFirstTimer,
    required this.onChanged,
  });

  final bool isFirstTimer;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          _Segment(
            label: 'First-Timer',
            isSelected: isFirstTimer,
            isLeft: true,
            onTap: () => onChanged(true),
          ),
          _Segment(
            label: 'Experienced',
            isSelected: !isFirstTimer,
            isLeft: false,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.isSelected,
    required this.isLeft,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isLeft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const radius = Radius.circular(AppConstants.radiusMD - 1);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppConstants.animNormal,
          decoration: BoxDecoration(
            color:
                isSelected ? AppColors.primaryGold : Colors.transparent,
            borderRadius: BorderRadius.only(
              topLeft: isLeft ? radius : Radius.zero,
              bottomLeft: isLeft ? radius : Radius.zero,
              topRight: isLeft ? Radius.zero : radius,
              bottomRight: isLeft ? Radius.zero : radius,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.labelLarge.copyWith(
              color: isSelected
                  ? AppColors.textOnGold
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Group Size Selector ───────────────────────────────────────────────────────
//
// Three equal-width cards with an icon and label.  Selected card gets a gold
// border and a subtle gold surface tint.

class _GroupSizeSelector extends StatelessWidget {
  const _GroupSizeSelector({
    required this.selected,
    required this.onChanged,
  });

  final String selected;
  final ValueChanged<String> onChanged;

  static const _options = [
    (value: 'single', label: 'Single', icon: Icons.person_rounded),
    (value: 'family', label: 'Family', icon: Icons.family_restroom_rounded),
    (value: 'group', label: 'Group', icon: Icons.groups_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _options.map((opt) {
        final isSelected = selected == opt.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: opt.value != 'group' ? 12 : 0,
            ),
            child: _GroupCard(
              label: opt.label,
              icon: opt.icon,
              isSelected: isSelected,
              onTap: () => onChanged(opt.value),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animNormal,
        height: 80,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGold.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          border: Border.all(
            color: isSelected ? AppColors.primaryGold : AppColors.cardBorder,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryGold : AppColors.iconDefault,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected
                    ? AppColors.primaryGold
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
