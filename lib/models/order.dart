import 'customer.dart';
import 'order_item.dart';

enum OrderStatus {
  pending,
  inProgress,
  completed,
  delivered,
}

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.delivered:
        return 'Delivered';
    }
  }
}

class Order {
  final String id;
  final String billNumber;
  final Customer customer;
  final List<OrderItem> items;
  final int quantity;
  final String notes;
  final DateTime orderDate;
  final DateTime completionDate;
  final OrderStatus status;
  final double price;

  Order({
    required this.id,
    required this.billNumber,
    required this.customer,
    required this.items,
    required this.quantity,
    required this.notes,
    required this.orderDate,
    required this.completionDate,
    required this.status,
    required this.price,
  });

  bool get isPair => items.length > 1;

  String get itemsSummary {
    return items.map((e) => e.clothType.name).join(' + ');
  }

  Order copyWith({
    String? id,
    String? billNumber,
    Customer? customer,
    List<OrderItem>? items,
    int? quantity,
    String? notes,
    DateTime? orderDate,
    DateTime? completionDate,
    OrderStatus? status,
    double? price,
  }) {
    return Order(
      id: id ?? this.id,
      billNumber: billNumber ?? this.billNumber,
      customer: customer ?? this.customer,
      items: items ?? this.items,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      orderDate: orderDate ?? this.orderDate,
      completionDate: completionDate ?? this.completionDate,
      status: status ?? this.status,
      price: price ?? this.price,
    );
  }
}
