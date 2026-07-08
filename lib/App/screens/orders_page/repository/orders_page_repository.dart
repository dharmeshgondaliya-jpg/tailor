import '../model/order_model.dart';

class OrdersPageRepository {
  static final List<OrderModel> _orders = [
    OrderModel(
      orderNumber: "#ORD-101",
      customerName: "Sarah Connor",
      status: "Pending",
      orderDate: DateTime.now().subtract(const Duration(days: 3)),
      completionDate: DateTime.now().add(const Duration(days: 2)),
      laborCost: 450.0,
      advanceAmount: 150.0,
      isUrgent: true,
      quantity: 2,
      clothesName: "Shirt & Pant",
      paymentStatus: "Advance",
      notes: "Short sleeves on the shirt.",
      items: [
        OrderItemModel(personName: "John Connor", itemName: "Shirt", quantity: 1, laborCost: 200.0),
        OrderItemModel(personName: "T-800", itemName: "Leather Jacket", quantity: 1, laborCost: 250.0),
      ],
    ),
    OrderModel(
      orderNumber: "#ORD-102",
      customerName: "Peter Parker",
      status: "Processing",
      orderDate: DateTime.now().subtract(const Duration(days: 5)),
      completionDate: DateTime.now().subtract(const Duration(days: 1)), // Overdue
      laborCost: 1200.0,
      advanceAmount: 0.0,
      isUrgent: false,
      quantity: 1,
      clothesName: "Wedding Suit",
      paymentStatus: "Unpaid",
      notes: "Add extra pockets inside the jacket.",
    ),
    OrderModel(
      orderNumber: "#ORD-103",
      customerName: "Bruce Wayne",
      status: "Completed",
      orderDate: DateTime.now().subtract(const Duration(days: 10)),
      completionDate: DateTime.now().subtract(const Duration(days: 3)),
      laborCost: 800.0,
      advanceAmount: 800.0,
      isUrgent: false,
      quantity: 3,
      clothesName: "Kurtas",
      paymentStatus: "Paid",
      notes: null,
    ),
    OrderModel(
      orderNumber: "#ORD-104",
      customerName: "Clark Kent",
      status: "Pending",
      orderDate: DateTime.now().subtract(const Duration(days: 1)),
      completionDate: DateTime.now().add(const Duration(days: 5)),
      laborCost: 600.0,
      advanceAmount: 200.0,
      isUrgent: false,
      quantity: 2,
      clothesName: "Salwar Kameez",
      paymentStatus: "Partial Paid",
      notes: "Needs lace borders on the dupatta.",
      items: [
        OrderItemModel(personName: "Clark Kent", itemName: "Suit", quantity: 1, laborCost: 400.0),
        OrderItemModel(personName: "Lois Lane", itemName: "Blouse", quantity: 1, laborCost: 200.0),
      ],
    ),
    OrderModel(
      orderNumber: "#ORD-105",
      customerName: "Diana Prince",
      status: "Cancelled",
      orderDate: DateTime.now().subtract(const Duration(days: 7)),
      completionDate: DateTime.now().subtract(const Duration(days: 4)),
      laborCost: 500.0,
      advanceAmount: 0.0,
      isUrgent: false,
      quantity: 1,
      clothesName: "Jeans Alteration",
      paymentStatus: "Unpaid",
      notes: "Shorten length by 2 inches.",
    ),
    OrderModel(
      orderNumber: "#ORD-106",
      customerName: "Sarah Connor",
      status: "Processing",
      orderDate: DateTime.now().subtract(const Duration(days: 2)),
      completionDate: DateTime.now(),
      laborCost: 1500.0,
      advanceAmount: 500.0,
      isUrgent: true,
      quantity: 4,
      clothesName: "Shirts",
      paymentStatus: "Advance",
      notes: "Different colors, regular fit.",
    ),
  ];

  List<OrderModel> getOrders() {
    return _orders;
  }

  void addOrder(OrderModel order) {
    final index = _orders.indexWhere((o) => o.orderNumber == order.orderNumber);
    if (index >= 0) {
      _orders[index] = order;
    } else {
      _orders.add(order);
    }
  }

  void deleteOrder(OrderModel order) {
    _orders.removeWhere((o) => o.orderNumber == order.orderNumber);
  }
}