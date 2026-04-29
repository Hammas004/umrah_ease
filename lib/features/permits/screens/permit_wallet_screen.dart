import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/permit.dart';
import '../providers/permit_provider.dart';

class PermitWalletScreen extends ConsumerWidget {
  const PermitWalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permitsAsync = ref.watch(permitProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Digital Permit Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(permitProvider.notifier).refresh(),
          ),
        ],
      ),
      body: permitsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGold),
        ),
        error: (e, _) => _ErrorView(
            onRetry: () =>
                ref.read(permitProvider.notifier).refresh()),
        data: (permits) {
          if (permits.isEmpty) return const _EmptyWallet();
          return ListView.separated(
            padding: const EdgeInsets.all(AppConstants.spaceMD),
            itemCount: permits.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppConstants.spaceMD),
            itemBuilder: (_, i) => _PermitCard(permit: permits[i]),
          );
        },
      ),
    );
  }
}

// ── Permit card ───────────────────────────────────────────────────────────────

class _PermitCard extends StatelessWidget {
  const _PermitCard({required this.permit});
  final Permit permit;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy');
    final isActive = permit.status == 'active';
    final statusColor = switch (permit.status) {
      'active' => AppColors.success,
      'pending' => AppColors.warning,
      _ => AppColors.error,
    };

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A2318), Color(0xFF1E1B12)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(
          color: isActive
              ? AppColors.primaryGold.withValues(alpha: 0.5)
              : AppColors.divider,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Card header
          Padding(
            padding: const EdgeInsets.all(AppConstants.spaceMD),
            child: Row(
              children: [
                const Icon(Icons.badge_rounded,
                    color: AppColors.primaryGold, size: 28),
                const SizedBox(width: AppConstants.spaceSM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${permit.permitType.toUpperCase()} PERMIT',
                        style: AppTextStyles.labelLarge
                            .copyWith(color: AppColors.primaryGold),
                      ),
                      Text('Nusuk — Kingdom of Saudi Arabia',
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    permit.status.toUpperCase(),
                    style: AppTextStyles.labelSmall
                        .copyWith(color: statusColor),
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.divider, height: 1),

          // Details grid
          Padding(
            padding: const EdgeInsets.all(AppConstants.spaceMD),
            child: Column(
              children: [
                _DetailRow(
                    label: 'Permit Number',
                    value: permit.permitNumber),
                const SizedBox(height: AppConstants.spaceSM),
                _DetailRow(
                    label: 'Holder',
                    value: permit.holderName),
                if (permit.passportNumber != null) ...[
                  const SizedBox(height: AppConstants.spaceSM),
                  _DetailRow(
                      label: 'Passport',
                      value: permit.passportNumber!),
                ],
                if (permit.nationality != null) ...[
                  const SizedBox(height: AppConstants.spaceSM),
                  _DetailRow(
                      label: 'Nationality',
                      value: permit.nationality!),
                ],
                const SizedBox(height: AppConstants.spaceSM),
                _DetailRow(
                    label: 'Valid From',
                    value: fmt.format(permit.validFrom)),
                const SizedBox(height: AppConstants.spaceSM),
                _DetailRow(
                    label: 'Valid To',
                    value: fmt.format(permit.validTo)),
              ],
            ),
          ),

          const Divider(color: AppColors.divider, height: 1),

          // QR placeholder
          Padding(
            padding: const EdgeInsets.all(AppConstants.spaceMD),
            child: Column(
              children: [
                Text('Scan at Entry Point',
                    style: AppTextStyles.labelMedium),
                const SizedBox(height: AppConstants.spaceSM),
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusSM),
                  ),
                  child: Center(
                    child: Icon(Icons.qr_code_2_rounded,
                        color: AppColors.backgroundDark, size: 100),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.permitLabel),
        Text(value, style: AppTextStyles.permitValue),
      ],
    );
  }
}

// ── Empty / error states ──────────────────────────────────────────────────────

class _EmptyWallet extends StatelessWidget {
  const _EmptyWallet();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceVariant,
              ),
              child: const Icon(Icons.badge_outlined,
                  color: AppColors.textMuted, size: 40),
            ),
            const SizedBox(height: AppConstants.spaceMD),
            Text('No Permits Found',
                style: AppTextStyles.titleMedium),
            const SizedBox(height: AppConstants.spaceSM),
            Text(
              'Your Nusuk permit will appear here once issued. Make sure your account email matches your Nusuk registration.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spaceLG),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: const Text('Open Nusuk Portal'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded,
              color: AppColors.textMuted, size: 48),
          const SizedBox(height: AppConstants.spaceMD),
          Text('Could not load permits',
              style: AppTextStyles.titleMedium),
          const SizedBox(height: AppConstants.spaceLG),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
