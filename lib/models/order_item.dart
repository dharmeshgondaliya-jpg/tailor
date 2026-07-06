import 'cloth_type.dart';

class OrderItem {
  final ClothType clothType;
  // Map of ClothField.id to the actual measurement or text value entered
  final Map<String, String> measurements;

  OrderItem({
    required this.clothType,
    required this.measurements,
  });

  OrderItem copyWith({
    ClothType? clothType,
    Map<String, String>? measurements,
  }) {
    return OrderItem(
      clothType: clothType ?? this.clothType,
      measurements: measurements ?? Map.from(this.measurements),
    );
  }
}
