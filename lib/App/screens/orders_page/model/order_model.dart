class OrderModel {
  final String orderNumber;
  final String customerName;
  final String status;
  final DateTime orderDate;
  final DateTime completionDate;
  final double laborCost;
  final double advanceAmount;
  final bool isUrgent;
  final int quantity;
  final String clothesName;
  final String paymentStatus; // 'Unpaid', 'Advance', 'Partial Paid', 'Paid'
  final String? notes;

  OrderModel({
    required this.orderNumber,
    required this.customerName,
    required this.status,
    required this.orderDate,
    required this.completionDate,
    required this.laborCost,
    this.advanceAmount = 0.0,
    this.isUrgent = false,
    required this.quantity,
    required this.clothesName,
    required this.paymentStatus,
    this.notes,
  });

  bool get isOverdue {
    if (status.toLowerCase() == 'completed') return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final compDateOnly = DateTime(completionDate.year, completionDate.month, completionDate.day);
    return compDateOnly.isBefore(today);
  }
}
