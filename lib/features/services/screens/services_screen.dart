import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(title: const Text('Services')),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spaceMD),
        children: [
          Text('Plan Your Stay', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppConstants.spaceSM),
          _ServiceCard(
            icon: Icons.hotel_rounded,
            title: 'Select Your Stay',
            subtitle: 'Browse hotels near Masjid Al-Haram',
            color: const Color(0xFF1A6FA8),
            onTap: () => context.push(AppRoutes.selectStay),
          ),
          const SizedBox(height: AppConstants.spaceSM),
          _ServiceCard(
            icon: Icons.directions_bus_rounded,
            title: 'Select Transportation',
            subtitle: 'Shuttle, taxi, metro & walking routes',
            color: const Color(0xFF1E7D52),
            onTap: () => context.push(AppRoutes.selectTransport),
          ),

          const SizedBox(height: AppConstants.spaceLG),
          Text('Ritual Preparation', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppConstants.spaceSM),
          _ServiceCard(
            icon: Icons.luggage_rounded,
            title: 'Packing Checklist',
            subtitle: 'Everything you need for your Umrah',
            color: const Color(0xFF7C5CBF),
            onTap: () => context.push(AppRoutes.packingChecklist),
          ),
          const SizedBox(height: AppConstants.spaceSM),
          _ServiceCard(
            icon: Icons.menu_book_rounded,
            title: 'Sa\'i Guide',
            subtitle: 'Step-by-step circuit counter for Sa\'i',
            color: const Color(0xFF8D6E3F),
            onTap: () => context.push(AppRoutes.saiGuide),
          ),

          const SizedBox(height: AppConstants.spaceLG),
          Text('Safety', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppConstants.spaceSM),
          _ServiceCard(
            icon: Icons.emergency_rounded,
            title: 'Emergency Assistance',
            subtitle: 'SOS, emergency numbers & hospitals',
            color: AppColors.error,
            onTap: () => context.push(AppRoutes.emergency),
          ),
          const SizedBox(height: AppConstants.spaceSM),
          _ServiceCard(
            icon: Icons.family_restroom_rounded,
            title: 'Family Safety Tracker',
            subtitle: 'Track your group\'s live location',
            color: const Color(0xFF1A6FA8),
            onTap: () => context.push(AppRoutes.familyTracker),
          ),

          const SizedBox(height: AppConstants.spaceLG),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spaceMD),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          border: Border.all(color: AppColors.cardBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: AppConstants.spaceMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleSmall),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: AppTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
