import '../model/order_model.dart';

class OrdersPageRepository {
  static final List<OrderModel> _orders = [
    OrderModel(
      orderNumber: "#ORD-101",
      customerName: "John Doe",
      status: "Pending",
      orderDate: DateTime.now().subtract(const Duration(days: 3)),
      completionDate: DateTime.now().add(const Duration(days: 2)),
      laborCost: 45.0,
      quantity: 2,
      clothesName: "Shirt & Pant",
      notes: "Short sleeves on the shirt.",
    ),
    OrderModel(
      orderNumber: "#ORD-102",
      customerName: "Alice Smith",
      status: "Processing",
      orderDate: DateTime.now().subtract(const Duration(days: 5)),
      completionDate: DateTime.now().subtract(const Duration(days: 1)), // Overdue
      laborCost: 120.0,
      quantity: 1,
      clothesName: "Wedding Suit",
      notes: "Add extra pockets inside the jacket.",
    ),
    OrderModel(
      orderNumber: "#ORD-103",
      customerName: "Bob Johnson",
      status: "Completed",
      orderDate: DateTime.now().subtract(const Duration(days: 10)),
      completionDate: DateTime.now().subtract(const Duration(days: 3)),
      laborCost: 80.0,
      quantity: 3,
      clothesName: "Kurtas",
      notes: null,
    ),
    OrderModel(
      orderNumber: "#ORD-104",
      customerName: "Emma Watson",
      status: "Pending",
      orderDate: DateTime.now().subtract(const Duration(days: 1)),
      completionDate: DateTime.now().add(const Duration(days: 5)),
      laborCost: 60.0,
      quantity: 2,
      clothesName: "Salwar Kameez",
      notes: "Needs lace borders on the dupatta.",
    ),
    OrderModel(
      orderNumber: "#ORD-105",
      customerName: "Michael Brown",
      status: "Cancelled",
      orderDate: DateTime.now().subtract(const Duration(days: 7)),
      completionDate: DateTime.now().subtract(const Duration(days: 4)),
      laborCost: 50.0,
      quantity: 1,
      clothesName: "Jeans Alteration",
      notes: "Shorten length by 2 inches.",
    ),
    OrderModel(
      orderNumber: "#ORD-106",
      customerName: "Sarah Jenkins",
      status: "Processing",
      orderDate: DateTime.now().subtract(const Duration(days: 2)),
      completionDate: DateTime.now(),
      laborCost: 150.0,
      quantity: 4,
      clothesName: "Shirts",
      notes: "Different colors, regular fit.",
    ),
  ];

  List<OrderModel> getOrders() {
    return _orders;
  }

  void addOrder(OrderModel order) {
    _orders.add(order);
  }

  void deleteOrder(OrderModel order) {
    _orders.remove(order);
  }
}