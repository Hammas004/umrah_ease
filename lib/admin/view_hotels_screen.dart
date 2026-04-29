import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app_router.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/models/hotel.dart';
import '../services/hotel_service.dart';

class ViewHotelsScreen extends ConsumerWidget {
  const ViewHotelsScreen({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Hotel hotel,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Delete Hotel', style: AppTextStyles.titleLarge),
        content: Text(
          'Are you sure you want to delete "${hotel.name}"? This cannot be undone.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: AppTextStyles.bodyMedium),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Delete',
                style:
                    AppTextStyles.goldLabel.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(hotelServiceProvider).deleteHotel(hotel.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(const SnackBar(
              content: Text('Hotel deleted successfully.'),
              backgroundColor: AppColors.success,
            ));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hotelsAsync = ref.watch(hotelsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(title: const Text('View Hotels')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addHotel),
        backgroundColor: AppColors.primaryGold,
        foregroundColor: AppColors.textOnGold,
        icon: const Icon(Icons.add_rounded),
        label: Text('Add Hotel', style: AppTextStyles.labelLarge.copyWith(color: AppColors.textOnGold)),
      ),
      body: hotelsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGold),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: AppColors.error, size: 48),
              const SizedBox(height: AppConstants.spaceMD),
              Text('Failed to load hotels',
                  style: AppTextStyles.titleSmall),
              const SizedBox(height: AppConstants.spaceSM),
              Text(e.toString(), style: AppTextStyles.bodySmall),
            ],
          ),
        ),
        data: (hotels) {
          if (hotels.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hotel_rounded,
                      color: AppColors.textMuted,
                      size: AppConstants.iconXL),
                  const SizedBox(height: AppConstants.spaceMD),
                  Text('No hotels yet', style: AppTextStyles.titleSmall),
                  const SizedBox(height: AppConstants.spaceSM),
                  Text('Tap the button below to add your first hotel.',
                      style: AppTextStyles.bodySmall),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spaceMD,
              AppConstants.spaceMD,
              AppConstants.spaceMD,
              100, // space for FAB
            ),
            itemCount: hotels.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppConstants.spaceMD),
            itemBuilder: (_, i) => _AdminHotelCard(
              hotel: hotels[i],
              onEdit: () =>
                  context.push(AppRoutes.addHotel, extra: hotels[i]),
              onDelete: () => _confirmDelete(context, ref, hotels[i]),
            ),
          );
        },
      ),
    );
  }
}

// ── Admin hotel card ──────────────────────────────────────────────────────────

class _AdminHotelCard extends StatelessWidget {
  const _AdminHotelCard({
    required this.hotel,
    required this.onEdit,
    required this.onDelete,
  });

  final Hotel hotel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hotel image
          if (hotel.imageUrl != null && hotel.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppConstants.radiusLG)),
              child: Image.network(
                hotel.imageUrl!,
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _ImagePlaceholder(),
              ),
            )
          else
            _ImagePlaceholder(radius: AppConstants.radiusLG),

          Padding(
            padding: const EdgeInsets.all(AppConstants.spaceMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + rating
                Row(
                  children: [
                    Expanded(
                      child: Text(hotel.name,
                          style: AppTextStyles.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: AppColors.primaryGold, size: 14),
                        const SizedBox(width: 3),
                        Text(hotel.rating.toString(),
                            style: AppTextStyles.labelSmall
                                .copyWith(color: AppColors.textPrimary)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Location + distance
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        color: AppColors.textMuted, size: 13),
                    const SizedBox(width: 3),
                    Text('${hotel.location} · ${hotel.distanceKm} km from Haram',
                        style: AppTextStyles.bodySmall),
                  ],
                ),
                const SizedBox(height: 4),

                // Price
                Text('SAR ${hotel.pricePerNight.toInt()}/night',
                    style: AppTextStyles.priceText
                        .copyWith(fontSize: 14)),

                // Amenities preview
                if (hotel.amenities.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spaceSM),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: hotel.amenities
                        .take(3)
                        .map((a) => _SmallChip(a))
                        .toList(),
                  ),
                ],

                const SizedBox(height: AppConstants.spaceMD),
                const Divider(color: AppColors.divider, height: 1),
                const SizedBox(height: AppConstants.spaceSM),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_rounded, size: 16),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spaceSM),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline_rounded,
                            size: 16, color: AppColors.error),
                        label: Text('Delete',
                            style: AppTextStyles.buttonText
                                .copyWith(color: AppColors.error)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          side: BorderSide(
                              color: AppColors.error.withValues(alpha: 0.5)),
                        ),
                      ),
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
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({this.radius});
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: radius != null
          ? BorderRadius.vertical(top: Radius.circular(radius!))
          : BorderRadius.zero,
      child: Container(
        width: double.infinity,
        height: 80,
        color: AppColors.surfaceVariant,
        child: const Center(
          child:
              Icon(Icons.hotel_rounded, color: AppColors.textMuted, size: 32),
        ),
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  const _SmallChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Text(label, style: AppTextStyles.labelSmall),
    );
  }
}