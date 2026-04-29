import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app_router.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../shared/providers/firebase_providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Logout', style: AppTextStyles.titleLarge),
        content: Text(
          'Are you sure you want to logout from the admin panel?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: AppTextStyles.bodyMedium),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Logout',
                style: AppTextStyles.goldLabel
                    .copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(firebaseAuthProvider).signOut();
      if (context.mounted) context.go(AppRoutes.adminLogin);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => _logout(context, ref),
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Welcome banner ────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.spaceLG),
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusLG),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.admin_panel_settings_rounded,
                      color: AppColors.textOnGold, size: 32),
                  const SizedBox(height: AppConstants.spaceSM),
                  Text(
                    'Welcome, Admin',
                    style: AppTextStyles.headlineMedium
                        .copyWith(color: AppColors.textOnGold),
                  ),
                  if (user?.email != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      user!.email!,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textOnGold),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spaceLG),

            Text('Manage Hotels', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppConstants.spaceMD),

            // ── Action cards ──────────────────────────────────────────────
            _ActionCard(
              icon: Icons.add_business_rounded,
              title: 'Add Hotel',
              subtitle: 'Add a new hotel to the Umrah Ease listings',
              onTap: () => context.push(AppRoutes.addHotel),
            ),
            const SizedBox(height: AppConstants.spaceMD),
            _ActionCard(
              icon: Icons.hotel_rounded,
              title: 'View Hotels',
              subtitle: 'Browse, edit or delete existing hotels',
              onTap: () => context.push(AppRoutes.viewHotels),
            ),
            const SizedBox(height: AppConstants.spaceXL),

            // ── Logout button ─────────────────────────────────────────────
            OutlinedButton.icon(
              onPressed: () => _logout(context, ref),
              icon: const Icon(Icons.logout_rounded,
                  color: AppColors.error, size: 18),
              label: Text('Logout',
                  style: AppTextStyles.buttonText
                      .copyWith(color: AppColors.error)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: AppColors.error.withValues(alpha: 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Action card widget ────────────────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spaceMD),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
          border: Border.all(color: AppColors.cardBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              ),
              child: Icon(icon, color: AppColors.primaryGold, size: 26),
            ),
            const SizedBox(width: AppConstants.spaceMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleSmall),
                  const SizedBox(height: 3),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}