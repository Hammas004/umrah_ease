import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/transport_option.dart';

class SelectTransportScreen extends StatefulWidget {
  const SelectTransportScreen({super.key});

  @override
  State<SelectTransportScreen> createState() =>
      _SelectTransportScreenState();
}

class _SelectTransportScreenState extends State<SelectTransportScreen> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(title: const Text('Select Transportation')),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppConstants.spaceMD),
              itemCount: TransportOption.mockList.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppConstants.spaceMD),
              itemBuilder: (_, i) {
                final opt = TransportOption.mockList[i];
                return _TransportCard(
                  option: opt,
                  isSelected: _selectedId == opt.id,
                  onSelect: () =>
                      setState(() => _selectedId = opt.id),
                );
              },
            ),
          ),

          // ── Book CTA ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppConstants.spaceMD),
            child: ElevatedButton.icon(
              onPressed: _selectedId == null
                  ? null
                  : () {
                      final opt = TransportOption.mockList
                          .firstWhere((o) => o.id == _selectedId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                '${opt.label} booked! Booking flow requires backend integration.')),
                      );
                    },
              icon: const Icon(Icons.directions_rounded),
              label: Text(_selectedId == null
                  ? 'Select an option'
                  : 'Confirm Transport'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Transport card ────────────────────────────────────────────────────────────

class _TransportCard extends StatelessWidget {
  const _TransportCard({
    required this.option,
    required this.isSelected,
    required this.onSelect,
  });
  final TransportOption option;
  final bool isSelected;
  final VoidCallback onSelect;

  IconData get _icon => switch (option.type) {
        'shuttle' => Icons.directions_bus_rounded,
        'taxi' => Icons.local_taxi_rounded,
        'metro' => Icons.train_rounded,
        _ => Icons.directions_walk_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: AppConstants.animFast,
        padding: const EdgeInsets.all(AppConstants.spaceMD),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGold
                : AppColors.cardBorder,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryGold.withValues(alpha: 0.15)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon,
                  color: isSelected
                      ? AppColors.primaryGold
                      : AppColors.iconDefault,
                  size: 26),
            ),
            const SizedBox(width: AppConstants.spaceMD),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option.label, style: AppTextStyles.titleSmall),
                  const SizedBox(height: 2),
                  Text(option.description,
                      style: AppTextStyles.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: AppConstants.spaceSM),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined,
                          color: AppColors.textMuted, size: 13),
                      const SizedBox(width: 4),
                      Text(option.duration,
                          style: AppTextStyles.bodySmall),
                      const SizedBox(width: AppConstants.spaceMD),
                      const Icon(Icons.payments_outlined,
                          color: AppColors.textMuted, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        option.priceFrom == 0
                            ? 'Free'
                            : 'From ${option.currency} ${option.priceFrom.toInt()}',
                        style: AppTextStyles.goldLabel,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Selection indicator
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppColors.primaryGold
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryGold
                      : AppColors.divider,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      color: AppColors.textOnGold, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
