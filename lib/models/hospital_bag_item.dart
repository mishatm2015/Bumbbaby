class HospitalBagItem {
  HospitalBagItem({
    required this.id,
    required this.label,
    required this.categoryId,
    this.checked = false,
    this.isCustom = false,
    this.subcategory,
  });

  final String id;
  final String label;
  final String categoryId;
  final String? subcategory;
  bool checked;
  final bool isCustom;

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'categoryId': categoryId,
        'subcategory': subcategory,
        'checked': checked,
        'isCustom': isCustom,
      };

  factory HospitalBagItem.fromJson(Map<String, dynamic> json) {
    return HospitalBagItem(
      id: json['id'] as String,
      label: json['label'] as String,
      categoryId: json['categoryId'] as String,
      subcategory: json['subcategory'] as String?,
      checked: json['checked'] as bool? ?? false,
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }
}

class HospitalBagCategory {
  const HospitalBagCategory({
    required this.id,
    required this.emoji,
    required this.name,
  });

  final String id;
  final String emoji;
  final String name;
}
