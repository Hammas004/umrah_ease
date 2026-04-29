import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../services/hotel_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Edit profile',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Profile editing — connect to your backend to save changes')),
              );
            },
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGold),
        ),
        error: (_, __) => Center(
            child: Text('Error loading profile',
                style: AppTextStyles.bodyMedium)),
        data: (profile) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spaceMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Avatar + info ──────────────────────────────────────
              _ProfileHeader(
                name: profile?.displayName ?? 'Pilgrim',
                email: profile?.email ?? '',
                isFirstTimer: profile?.isFirstTimer ?? true,
                groupSize: profile?.groupSize ?? 'single',
              ),

              const SizedBox(height: AppConstants.spaceLG),

              // ── Journey settings ───────────────────────────────────
              _SectionTitle(title: 'Journey Settings'),
              const SizedBox(height: AppConstants.spaceSM),
              _InfoTile(
                icon: Icons.person_rounded,
                label: 'Experience Level',
                value: profile?.isFirstTimer == true
                    ? 'First-Timer'
                    : 'Experienced',
              ),
              _InfoTile(
                icon: Icons.groups_rounded,
                label: 'Group Type',
                value: _capitalize(profile?.groupSize ?? 'single'),
              ),
              _InfoTile(
                icon: Icons.language_rounded,
                label: 'Language',
                value: profile?.language ?? 'English',
              ),

              const SizedBox(height: AppConstants.spaceLG),

              // ── App settings ───────────────────────────────────────
              _SectionTitle(title: 'App Settings'),
              const SizedBox(height: AppConstants.spaceSM),
              _ToggleTile(
                icon: Icons.notifications_rounded,
                label: 'Prayer Time Alerts',
                initialValue: true,
              ),
              _ToggleTile(
                icon: Icons.cloud_download_rounded,
                label: 'Auto-download Guides on Wi-Fi',
                initialValue: true,
              ),
              _ToggleTile(
                icon: Icons.location_on_rounded,
                label: 'Share Location with Family',
                initialValue: false,
              ),

              const SizedBox(height: AppConstants.spaceLG),

              // ── Support ────────────────────────────────────────────
              _SectionTitle(title: 'Support'),
              const SizedBox(height: AppConstants.spaceSM),
              _ActionTile(
                icon: Icons.help_outline_rounded,
                label: 'Help & FAQ',
                onTap: () {},
              ),
              _ActionTile(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Policy',
                onTap: () {},
              ),
              _ActionTile(
                icon: Icons.info_outline_rounded,
                label: 'About Umrah Ease',
                onTap: () => _showAbout(context),
              ),

              const SizedBox(height: AppConstants.spaceLG),

              // ── Admin Panel (visible only to admin users) ──────────
              _AdminSection(),

              // ── Finalize / sign-out ────────────────────────────────
              OutlinedButton.icon(
                onPressed: () =>
                    context.push(AppRoutes.finalizeJourney),
                icon: const Icon(Icons.flag_rounded),
                label: const Text('Finalize My Journey'),
              ),

              const SizedBox(height: AppConstants.spaceSM),

              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                onPressed: () => _confirmSignOut(context, ref),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign Out'),
              ),

              const SizedBox(height: AppConstants.spaceLG),

              Center(
                child: Text('Umrah Ease v1.0.0',
                    style: AppTextStyles.labelSmall),
              ),
              const SizedBox(height: AppConstants.spaceLG),
            ],
          ),
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out?'),
        content: const Text(
            'You will be returned to the sign-in screen.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authNotifierProvider.notifier).signOut();
            },
            child: Text('Sign Out',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Umrah Ease',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2025 Umrah Ease',
      children: [
        const SizedBox(height: 12),
        const Text(
            'Your complete offline guide for a blessed Umrah and Hajj journey.'),
      ],
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.isFirstTimer,
    required this.groupSize,
  });
  final String name;
  final String email;
  final bool isFirstTimer;
  final String groupSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceVariant,
              border: Border.all(
                  color: AppColors.primaryGold, width: 2),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'P',
                style: AppTextStyles.headlineLarge
                    .copyWith(color: AppColors.primaryGold),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.titleLarge),
                const SizedBox(height: 2),
                Text(email,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: AppConstants.spaceSM),
                Row(
                  children: [
                    _Badge(
                      label:
                          isFirstTimer ? 'First-Timer' : 'Experienced',
                      color: isFirstTimer
                          ? AppColors.primaryGold
                          : AppColors.success,
                    ),
                    const SizedBox(width: 6),
                    _Badge(
                      label: _cap(groupSize),
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style:
              AppTextStyles.labelSmall.copyWith(color: color)),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Text(title,
      style: AppTextStyles.titleSmall
          .copyWith(color: AppColors.textMuted));
}

class _InfoTile extends StatelessWidget {
  const _InfoTile(
      {required this.icon,
      required this.label,
      required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spaceSM),
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceMD, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(AppConstants.radiusMD),
        border:
            Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryGold, size: 20),
          const SizedBox(width: AppConstants.spaceMD),
          Expanded(
              child: Text(label, style: AppTextStyles.titleSmall)),
          Text(value,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _ToggleTile extends StatefulWidget {
  const _ToggleTile(
      {required this.icon,
      required this.label,
      required this.initialValue});
  final IconData icon;
  final String label;
  final bool initialValue;

  @override
  State<_ToggleTile> createState() => _ToggleTileState();
}

class _ToggleTileState extends State<_ToggleTile> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spaceSM),
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceMD, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(AppConstants.radiusMD),
        border:
            Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(widget.icon,
              color: AppColors.primaryGold, size: 20),
          const SizedBox(width: AppConstants.spaceMD),
          Expanded(
              child:
                  Text(widget.label, style: AppTextStyles.titleSmall)),
          Switch(
            value: _value,
            onChanged: (v) => setState(() => _value = v),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.spaceSM),
        padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceMD, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              BorderRadius.circular(AppConstants.radiusMD),
          border:
              Border.all(color: AppColors.cardBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.iconDefault, size: 20),
            const SizedBox(width: AppConstants.spaceMD),
            Expanded(
                child:
                    Text(label, style: AppTextStyles.titleSmall)),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Admin section (only shown to admin users) ─────────────────────────────────

class _AdminSection extends ConsumerWidget {
  const _AdminSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdminAsync = ref.watch(isAdminProvider);

    // Only show when confirmed admin — invisible to regular users
    return isAdminAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (isAdmin) {
        if (!isAdmin) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(title: 'Administration'),
            const SizedBox(height: AppConstants.spaceSM),
            GestureDetector(
              onTap: () => context.push(AppRoutes.adminDashboard),
              child: Container(
                margin:
                    const EdgeInsets.only(bottom: AppConstants.spaceSM),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spaceMD, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.08),
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusMD),
                  border: Border.all(
                      color: AppColors.primaryGold.withValues(alpha: 0.4),
                      width: 0.8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.admin_panel_settings_rounded,
                        color: AppColors.primaryGold, size: 20),
                    const SizedBox(width: AppConstants.spaceMD),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Admin Panel',
                              style: AppTextStyles.titleSmall.copyWith(
                                  color: AppColors.primaryGold)),
                          Text('Manage hotels and app content',
                              style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.primaryGold, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spaceSM),
          ],
        );
      },
    );
  }
}
