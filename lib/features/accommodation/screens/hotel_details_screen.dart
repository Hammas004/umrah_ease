import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/hotel.dart';

class HotelDetailsScreen extends StatelessWidget {
  const HotelDetailsScreen({super.key, required this.hotel});
  final Hotel hotel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: CustomScrollView(
        slivers: [
          // ── Hero image ───────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.backgroundDark,
            flexibleSpace: FlexibleSpaceBar(
              background: (hotel.imageUrl != null &&
                      hotel.imageUrl!.isNotEmpty)
                  ? Image.network(
                      hotel.imageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: AppColors.surfaceVariant,
                          child: const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primaryGold),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.surfaceVariant,
                        child: const Center(
                          child: Icon(Icons.hotel_rounded,
                              color: AppColors.textMuted, size: 64),
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.surfaceVariant,
                      child: const Center(
                        child: Icon(Icons.hotel_rounded,
                            color: AppColors.textMuted, size: 64),
                      ),
                    ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spaceMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hotel name + rating
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(hotel.name,
                            style: AppTextStyles.headlineMedium),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: AppColors.primaryGold, size: 16),
                              const SizedBox(width: 4),
                              Text(hotel.rating.toString(),
                                  style: AppTextStyles.titleSmall
                                      .copyWith(
                                          color: AppColors.primaryGold)),
                            ],
                          ),
                          Text('${hotel.reviewCount} reviews',
                              style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.spaceSM),

                  // Location (city)
                  if (hotel.location.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            color: AppColors.textMuted, size: 16),
                        const SizedBox(width: 6),
                        Text(hotel.location,
                            style: AppTextStyles.bodyMedium),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],

                  // Distance
                  Row(
                    children: [
                      const Icon(Icons.mosque_rounded,
                          color: AppColors.primaryGold, size: 16),
                      const SizedBox(width: 6),
                      Text(
                          '${hotel.distanceKm} km from Masjid Al-Haram',
                          style: AppTextStyles.bodyMedium),
                    ],
                  ),

                  const SizedBox(height: AppConstants.spaceLG),

                  // Price
                  Row(
                    children: [
                      Text('From ', style: AppTextStyles.bodyMedium),
                      Text(
                          '${hotel.currency} ${hotel.pricePerNight.toInt()}',
                          style: AppTextStyles.priceText
                              .copyWith(fontSize: 24)),
                      Text(' / night',
                          style: AppTextStyles.bodyMedium),
                    ],
                  ),

                  const SizedBox(height: AppConstants.spaceLG),

                  // ── Path to Kaaba ───────────────────────────────────────
                  Text('Path to Masjid Al-Haram',
                      style: AppTextStyles.titleMedium),
                  const SizedBox(height: AppConstants.spaceSM),
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMD),
                      border: Border.all(
                          color: AppColors.cardBorder, width: 0.5),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.map_rounded,
                                  color: AppColors.textMuted, size: 40),
                              const SizedBox(height: 8),
                              Text('Interactive map',
                                  style: AppTextStyles.bodySmall),
                              Text(
                                  'Requires Maps integration',
                                  style: AppTextStyles.labelSmall),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundDark
                                  .withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                                '${hotel.distanceKm} km',
                                style: AppTextStyles.labelSmall
                                    .copyWith(
                                        color: AppColors.primaryGold)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppConstants.spaceLG),

                  // ── Description ──────────────────────────────────────
                  if (hotel.description != null &&
                      hotel.description!.isNotEmpty) ...[
                    Text('About', style: AppTextStyles.titleMedium),
                    const SizedBox(height: AppConstants.spaceSM),
                    Text(hotel.description!,
                        style: AppTextStyles.bodyMedium),
                    const SizedBox(height: AppConstants.spaceLG),
                  ],

                  // ── Amenities ─────────────────────────────────────────
                  Text('Amenities', style: AppTextStyles.titleMedium),
                  const SizedBox(height: AppConstants.spaceSM),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: hotel.amenities
                        .map((a) => _AmenityBadge(label: a))
                        .toList(),
                  ),

                  const SizedBox(height: AppConstants.spaceXL),

                  // ── Book button ──────────────────────────────────────
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Booking flow requires Nusuk integration')),
                      );
                    },
                    icon: const Icon(Icons.bookmark_add_rounded),
                    label: Text(
                        'Book — ${hotel.currency} ${hotel.pricePerNight.toInt()}/night'),
                  ),

                  const SizedBox(height: AppConstants.spaceLG),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmenityBadge extends StatelessWidget {
  const _AmenityBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_rounded,
              color: AppColors.primaryGold, size: 14),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.labelMedium),
        ],
      ),
    );
  }
}
