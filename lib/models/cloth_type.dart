import 'cloth_field.dart';

class ClothType {
  final String id;
  final String name;
  final List<ClothField> fields;

  ClothType({
    required this.id,
    required this.name,
    required this.fields,
  });

  ClothType copyWith({
    String? id,
    String? name,
    List<ClothField>? fields,
  }) {
    return ClothType(
      id: id ?? this.id,
      name: name ?? this.name,
      fields: fields ?? this.fields,
    );
  }
}
