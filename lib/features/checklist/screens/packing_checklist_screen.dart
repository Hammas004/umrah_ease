import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/checklist_item.dart';
import '../../checklist/providers/checklist_provider.dart';

class PackingChecklistScreen extends ConsumerWidget {
  const PackingChecklistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checklistAsync = ref.watch(checklistProvider);
    final (checked, total) = ref.watch(checklistProgressProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Packing Checklist'),
        actions: [
          Padding(
            padding:
                const EdgeInsets.only(right: AppConstants.spaceMD),
            child: Center(
              child: Text(
                '$checked / $total',
                style: AppTextStyles.goldLabel,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context, ref),
        child: const Icon(Icons.add_rounded),
      ),
      body: checklistAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGold),
        ),
        error: (e, st) {
          debugPrint('Checklist error: $e\n$st');
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Error loading checklist',
                    style: AppTextStyles.bodyMedium),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(e.toString(),
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontSize: 12, color: AppColors.textMuted),
                      textAlign: TextAlign.center),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(checklistProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
        data: (items) {
          final fraction = total == 0 ? 0.0 : checked / total;
          final byCategory = <String, List<ChecklistItem>>{};
          for (final item in items) {
            byCategory.putIfAbsent(item.category, () => []).add(item);
          }

          return Column(
            children: [
              // ── Overall progress bar ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(AppConstants.spaceMD),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Overall Progress',
                            style: AppTextStyles.titleSmall),
                        Text(
                          '${(fraction * 100).round()}%',
                          style: AppTextStyles.goldLabel,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spaceSM),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: fraction,
                        minHeight: 8,
                        backgroundColor: AppColors.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation(
                          fraction == 1
                              ? AppColors.success
                              : AppColors.primaryGold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Category expansion tiles ──────────────────────────────
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(
                      bottom: AppConstants.spaceXXL + AppConstants.spaceMD),
                  itemCount: byCategory.length,
                  itemBuilder: (_, i) {
                    final cat = byCategory.keys.elementAt(i);
                    final catItems = byCategory[cat]!;
                    final catChecked =
                        catItems.where((it) => it.isChecked).length;
                    return _CategorySection(
                      category: cat,
                      items: catItems,
                      checked: catChecked,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, WidgetRef ref) {
    final categories = ['Documents', 'Clothing', 'Medications', 'Toiletries', 'Electronics', 'Other'];
    String selectedCategory = categories.first;
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.fromLTRB(
            AppConstants.spaceMD,
            AppConstants.spaceMD,
            AppConstants.spaceMD,
            MediaQuery.of(ctx).viewInsets.bottom + AppConstants.spaceMD,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Add Custom Item',
                  style: AppTextStyles.titleMedium),
              const SizedBox(height: AppConstants.spaceMD),
              InputDecorator(
                decoration: const InputDecoration(labelText: 'Category'),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    dropdownColor: AppColors.surface,
                    isExpanded: true,
                    items: categories
                        .map((c) =>
                            DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => selectedCategory = v!),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spaceSM),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                    labelText: 'Item name'),
              ),
              const SizedBox(height: AppConstants.spaceMD),
              ElevatedButton(
                onPressed: () {
                  final name = controller.text.trim();
                  if (name.isEmpty) return;
                  ref.read(checklistProvider.notifier).addCustom(
                      selectedCategory, name);
                  Navigator.pop(ctx);
                },
                child: const Text('Add Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Category section ──────────────────────────────────────────────────────────

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.category,
    required this.items,
    required this.checked,
  });
  final String category;
  final List<ChecklistItem> items;
  final int checked;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceMD,
          vertical: AppConstants.spaceSM / 2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          title: Row(
            children: [
              Text(category, style: AppTextStyles.titleSmall),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: checked == items.length
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$checked/${items.length}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: checked == items.length
                        ? AppColors.success
                        : AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
          children: items.map((item) => _ChecklistRow(item: item)).toList(),
        ),
      ),
    );
  }
}

// ── Checklist row ─────────────────────────────────────────────────────────────

class _ChecklistRow extends ConsumerWidget {
  const _ChecklistRow({required this.item});
  final ChecklistItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => ref
          .read(checklistProvider.notifier)
          .toggle(item.id, !item.isChecked),
      onLongPress: item.isCustom
          ? () => _confirmDelete(context, ref)
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceMD, vertical: 8),
        child: Row(
          children: [
            Checkbox(
              value: item.isChecked,
              onChanged: (v) => ref
                  .read(checklistProvider.notifier)
                  .toggle(item.id, v!),
            ),
            const SizedBox(width: AppConstants.spaceSM),
            Expanded(
              child: Text(
                item.itemName,
                style: AppTextStyles.bodyMedium.copyWith(
                  decoration: item.isChecked
                      ? TextDecoration.lineThrough
                      : null,
                  color: item.isChecked
                      ? AppColors.textMuted
                      : AppColors.textPrimary,
                ),
              ),
            ),
            if (item.isCustom)
              const Icon(Icons.person_outline_rounded,
                  color: AppColors.textMuted, size: 14),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete item?'),
        content: Text(item.itemName),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(checklistProvider.notifier).delete(item.id);
              Navigator.pop(context);
            },
            child: Text('Delete',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
