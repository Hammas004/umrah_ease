/// A single item in the Packing Checklist, backed by the sqflite
/// `checklist_items` table.
class ChecklistItem {
  const ChecklistItem({
    required this.id,
    required this.category,
    required this.itemName,
    required this.isChecked,
    required this.isCustom,
    required this.sortOrder,
  });

  final int id;
  final String category;
  final String itemName;
  final bool isChecked;
  final bool isCustom;
  final int sortOrder;

  factory ChecklistItem.fromMap(Map<String, dynamic> map) => ChecklistItem(
        id: map['id'] as int,
        category: map['category'] as String,
        itemName: map['item_name'] as String,
        isChecked: (map['is_checked'] as int) == 1,
        isCustom: (map['is_custom'] as int) == 1,
        sortOrder: map['sort_order'] as int,
      );

  ChecklistItem copyWith({bool? isChecked}) => ChecklistItem(
        id: id,
        category: category,
        itemName: itemName,
        isChecked: isChecked ?? this.isChecked,
        isCustom: isCustom,
        sortOrder: sortOrder,
      );
}
