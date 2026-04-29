import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/umrah_guide.dart';
import '../../education/providers/training_provider.dart';

class EducationHubScreen extends ConsumerWidget {
  const EducationHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guidesAsync = ref.watch(trainingProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(

        title: const Text('Education Hub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                ref.read(trainingProvider.notifier).refresh(),
            tooltip: 'Refresh guides',
          ),
        ],
      ),
      body: guidesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGold),
        ),
        error: (e, _) => _ErrorState(
          message: e.toString(),
          onRetry: () => ref.read(trainingProvider.notifier).refresh(),
        ),
        data: (guides) {
          if (guides.isEmpty) return const _EmptyState();
          final byCategory = ref
              .read(guidesByCategoryProvider)
              .valueOrNull ?? {};
          return _GuideList(byCategory: byCategory);
        },
      ),
    );
  }
}

// ── Guide list ────────────────────────────────────────────────────────────────

class _GuideList extends StatelessWidget {
  const _GuideList({required this.byCategory});
  final Map<String, List<UmrahGuide>> byCategory;

  @override
  Widget build(BuildContext context) {
    final categories = byCategory.keys.toList();

    return ListView.separated(
      padding: const EdgeInsets.all(AppConstants.spaceMD),
      itemCount: categories.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppConstants.spaceMD),
      itemBuilder: (context, i) {
        final cat = categories[i];
        final items = byCategory[cat]!;
        return _CategoryCard(
          category: cat,
          guides: items,
          completedCount: 0,
          totalCount: items.length,
        );
      },
    );
  }
}

// ── Category card ─────────────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.guides,
    required this.completedCount,
    required this.totalCount,
  });
  final String category;
  final List<UmrahGuide> guides;
  final int completedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final fraction =
        totalCount == 0 ? 0.0 : completedCount / totalCount;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppConstants.spaceMD),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.menu_book_rounded,
                      color: AppColors.primaryGold, size: 20),
                ),
                const SizedBox(width: AppConstants.spaceSM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category, style: AppTextStyles.titleSmall),
                      Text('${guides.length} lessons',
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                _ProgressBadge(
                    completed: completedCount, total: totalCount),
              ],
            ),
          ),

          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceMD),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 5,
                backgroundColor: AppColors.surfaceVariant,
                valueColor:
                    const AlwaysStoppedAnimation(AppColors.primaryGold),
              ),
            ),
          ),

          const SizedBox(height: AppConstants.spaceSM),

          // Lesson list
          ...guides.map((guide) => _LessonTile(guide: guide)),

          const SizedBox(height: AppConstants.spaceSM),
        ],
      ),
    );
  }
}

class _ProgressBadge extends StatelessWidget {
  const _ProgressBadge({required this.completed, required this.total});
  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final done = completed == total && total > 0;
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: done
            ? AppColors.success.withValues(alpha: 0.15)
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        done ? 'Done' : '$completed/$total',
        style: AppTextStyles.labelSmall.copyWith(
          color: done ? AppColors.success : AppColors.textMuted,
        ),
      ),
    );
  }
}

// ── Lesson tile ───────────────────────────────────────────────────────────────

class _LessonTile extends StatelessWidget {
  const _LessonTile({required this.guide});
  final UmrahGuide guide;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceMD, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${guide.stepOrder + 1}',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.textMuted),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spaceSM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(guide.title,
                      style: AppTextStyles.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  if (guide.arabicText?.isNotEmpty == true)
                    Text(guide.arabicText!,
                        style: AppTextStyles.arabicText.copyWith(
                            fontSize: 14, height: 1.6),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.rtl),
                ],
              ),
            ),
            const Icon(Icons.play_circle_outline_rounded,
                color: AppColors.primaryGold, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Empty / error states ──────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded,
                color: AppColors.textMuted, size: 56),
            const SizedBox(height: AppConstants.spaceMD),
            Text('No guides available',
                style: AppTextStyles.titleMedium),
            const SizedBox(height: AppConstants.spaceSM),
            Text(
              'Connect to the internet once to download your Umrah guides for offline use.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.error, size: 56),
            const SizedBox(height: AppConstants.spaceMD),
            Text('Failed to load guides', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppConstants.spaceSM),
            Text(message,
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center),
            const SizedBox(height: AppConstants.spaceLG),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
