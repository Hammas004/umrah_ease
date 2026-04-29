import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/hotel.dart';
import '../../../services/hotel_service.dart';

class SelectStayScreen extends ConsumerStatefulWidget {
  const SelectStayScreen({super.key});

  @override
  ConsumerState<SelectStayScreen> createState() => _SelectStayScreenState();
}

class _SelectStayScreenState extends ConsumerState<SelectStayScreen> {
  String _sortBy = 'distance';

  List<Hotel> _sorted(List<Hotel> hotels) {
    final list = List<Hotel>.from(hotels);
    switch (_sortBy) {
      case 'price':
        list.sort((a, b) => a.pricePerNight.compareTo(b.pricePerNight));
      case 'rating':
        list.sort((a, b) => b.rating.compareTo(a.rating));
      default:
        list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final hotelsAsync = ref.watch(hotelsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(title: const Text('Select Your Stay')),
      body: Column(
        children: [
          // ── Sort bar ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceMD,
                vertical: AppConstants.spaceSM),
            decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: AppColors.divider, width: 0.5)),
            ),
            child: Row(
              children: [
                Text('Sort by: ', style: AppTextStyles.bodySmall),
                const SizedBox(width: AppConstants.spaceSM),
                ...[
                  ('distance', 'Distance'),
                  ('price', 'Price'),
                  ('rating', 'Rating'),
                ].map((t) => _SortChip(
                      label: t.$2,
                      active: _sortBy == t.$1,
                      onTap: () => setState(() => _sortBy = t.$1),
                    )),
              ],
            ),
          ),

          // ── Hotel list ──────────────────────────────────────────────────
          Expanded(
            child: hotelsAsync.when(
              loading: () => const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primaryGold),
              ),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: AppColors.error, size: 40),
                    const SizedBox(height: AppConstants.spaceMD),
                    Text('Failed to load hotels',
                        style: AppTextStyles.titleSmall),
                    const SizedBox(height: AppConstants.spaceSM),
                    Text('Please check your connection and try again.',
                        style: AppTextStyles.bodySmall),
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
                        Text('No hotels available',
                            style: AppTextStyles.titleSmall),
                        const SizedBox(height: AppConstants.spaceSM),
                        Text(
                          'Hotels will appear here once added by the admin.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  );
                }

                final sorted = _sorted(hotels);
                return ListView.separated(
                  padding: const EdgeInsets.all(AppConstants.spaceMD),
                  itemCount: sorted.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppConstants.spaceMD),
                  itemBuilder: (_, i) => _HotelCard(
                    hotel: sorted[i],
                    onTap: () => context.push(
                      AppRoutes.hotelDetails,
                      extra: sorted[i],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hotel card ────────────────────────────────────────────────────────────────

class _HotelCard extends StatelessWidget {
  const _HotelCard({required this.hotel, required this.onTap});
  final Hotel hotel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
          border: Border.all(color: AppColors.cardBorder, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel image
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppConstants.radiusLG)),
              ),
              child: Stack(
                children: [
                  if (hotel.imageUrl != null && hotel.imageUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppConstants.radiusLG)),
                      child: Image.network(
                        hotel.imageUrl!,
                        width: double.infinity,
                        height: 140,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            height: 140,
                            color: AppColors.surfaceVariant,
                            child: const Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.primaryGold,
                                  strokeWidth: 2),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.hotel_rounded,
                              color: AppColors.textMuted, size: 48),
                        ),
                      ),
                    )
                  else
                    const Center(
                      child: Icon(Icons.hotel_rounded,
                          color: AppColors.textMuted, size: 48),
                    ),
                  // Rating badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundDark
                            .withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              color: AppColors.primaryGold, size: 14),
                          const SizedBox(width: 4),
                          Text(hotel.rating.toString(),
                              style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppConstants.spaceMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Text(hotel.name,
                              style: AppTextStyles.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis)),
                      Text(
                        'SAR ${hotel.pricePerNight.toInt()}/night',
                        style: AppTextStyles.priceText,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: AppColors.textMuted, size: 13),
                      const SizedBox(width: 3),
                      Text(hotel.location,
                          style: AppTextStyles.bodySmall),
                      const Spacer(),
                      const Icon(Icons.mosque_rounded,
                          color: AppColors.textMuted, size: 13),
                      const SizedBox(width: 3),
                      Text('${hotel.distanceKm} km',
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spaceSM),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: hotel.amenities
                        .take(3)
                        .map((a) => _AmenityChip(label: a))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _SortChip extends StatelessWidget {
  const _SortChip(
      {required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color:
              active ? AppColors.primaryGold : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: active
                ? AppColors.textOnGold
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _AmenityChip extends StatelessWidget {
  const _AmenityChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Text(label, style: AppTextStyles.labelSmall),
    );
  }
}