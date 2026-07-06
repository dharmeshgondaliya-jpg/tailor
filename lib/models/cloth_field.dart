enum ClothFieldType {
  inches,
  text,
}

class ClothField {
  final String id;
  final String name;
  final ClothFieldType type;
  final String defaultValue;

  ClothField({
    required this.id,
    required this.name,
    required this.type,
    this.defaultValue = '',
  });

  ClothField copyWith({
    String? id,
    String? name,
    ClothFieldType? type,
    String? defaultValue,
  }) {
    return ClothField(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      defaultValue: defaultValue ?? this.defaultValue,
    );
  }
}
