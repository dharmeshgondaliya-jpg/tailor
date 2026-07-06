import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../models/cloth_field.dart';
import '../models/cloth_type.dart';
import '../models/order_item.dart';
import '../models/order.dart';

class AppData {
  // Singleton Pattern
  static final AppData _instance = AppData._internal();
  factory AppData() => _instance;
  AppData._internal() {
    _initDummyData();
  }

  final ValueNotifier<List<Customer>> customers = ValueNotifier<List<Customer>>([]);
  final ValueNotifier<List<ClothType>> clothTypes = ValueNotifier<List<ClothType>>([]);
  final ValueNotifier<List<Order>> orders = ValueNotifier<List<Order>>([]);

  int _nextBillNum = 1005;

  void _initDummyData() {
    // 1. Initial Cloth Types
    final shirtFields = [
      ClothField(id: 's_length', name: 'Length', type: ClothFieldType.inches, defaultValue: '28'),
      ClothField(id: 's_chest', name: 'Chest', type: ClothFieldType.inches, defaultValue: '40'),
      ClothField(id: 's_waist', name: 'Waist', type: ClothFieldType.inches, defaultValue: '36'),
      ClothField(id: 's_shoulder', name: 'Shoulder', type: ClothFieldType.inches, defaultValue: '18'),
      ClothField(id: 's_sleeve', name: 'Sleeve Length', type: ClothFieldType.inches, defaultValue: '24'),
      ClothField(id: 's_collar', name: 'Collar Size', type: ClothFieldType.inches, defaultValue: '15.5'),
      ClothField(id: 's_pocket', name: 'Pocket Style', type: ClothFieldType.text, defaultValue: 'Standard Left'),
    ];

    final pantFields = [
      ClothField(id: 'p_waist', name: 'Waist Size', type: ClothFieldType.inches, defaultValue: '32'),
      ClothField(id: 'p_length', name: 'Length / Outseam', type: ClothFieldType.inches, defaultValue: '40'),
      ClothField(id: 'p_hip', name: 'Hip Size', type: ClothFieldType.inches, defaultValue: '38'),
      ClothField(id: 'p_inseam', name: 'Inseam', type: ClothFieldType.inches, defaultValue: '30'),
      ClothField(id: 'p_cuff', name: 'Bottom Cuff', type: ClothFieldType.inches, defaultValue: '14'),
      ClothField(id: 'p_pocket_type', name: 'Pocket Style', type: ClothFieldType.text, defaultValue: 'Cross Pockets'),
    ];

    final kurtaFields = [
      ClothField(id: 'k_length', name: 'Kurta Length', type: ClothFieldType.inches, defaultValue: '42'),
      ClothField(id: 'k_chest', name: 'Chest', type: ClothFieldType.inches, defaultValue: '42'),
      ClothField(id: 'k_shoulder', name: 'Shoulder Width', type: ClothFieldType.inches, defaultValue: '19'),
      ClothField(id: 'k_sleeve', name: 'Sleeve Length', type: ClothFieldType.inches, defaultValue: '25'),
      ClothField(id: 'k_neck', name: 'Neck / Collar Size', type: ClothFieldType.inches, defaultValue: '16'),
      ClothField(id: 'k_design', name: 'Collar Design', type: ClothFieldType.text, defaultValue: 'Mandarin Collar'),
    ];

    final types = [
      ClothType(id: '1', name: 'Shirt', fields: shirtFields),
      ClothType(id: '2', name: 'Pant', fields: pantFields),
      ClothType(id: '3', name: 'Kurta', fields: kurtaFields),
    ];
    clothTypes.value = types;

    // 2. Initial Customers
    final custs = [
      Customer(id: 'c1', name: 'Dharmesh Gondaliya', mobile: '9876543210', address: '101, Sunshine Heights, Mumbai', notes: 'Prefers slim-cut fit, double button cuffs.'),
      Customer(id: 'c2', name: 'Aarav Mehta', mobile: '9123456789', address: '405, Rosewood Apartments, Pune', notes: 'Prefers linen shirts, loose comfort fit.'),
      Customer(id: 'c3', name: 'Vikram Singh', mobile: '8877665544', address: '7B, Palace Road, Jaipur', notes: 'Kurta neck needs strict finishing. Prefers pocket on both sides of Kurta.'),
      Customer(id: 'c4', name: 'Neha Sharma', mobile: '9988776655', address: 'Apartment 12, Green Glen Layout, Bangalore', notes: 'Prefers cotton fabric trousers.'),
    ];
    customers.value = custs;

    // 3. Initial Orders
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final ordersList = [
      Order(
        id: 'o1',
        billNumber: 'INV-1001',
        customer: custs[0], // Dharmesh
        items: [
          OrderItem(
            clothType: types[0], // Shirt
            measurements: {
              's_length': '29',
              's_chest': '41.5',
              's_waist': '37',
              's_shoulder': '18.5',
              's_sleeve': '24.5',
              's_collar': '16',
              's_pocket': 'Standard Square Left',
            },
          ),
          OrderItem(
            clothType: types[1], // Pant
            measurements: {
              'p_waist': '33',
              'p_length': '41',
              'p_hip': '39',
              'p_inseam': '31',
              'p_cuff': '14.5',
              'p_pocket_type': 'Single Back, Cross Pockets',
            },
          ),
        ],
        quantity: 1,
        notes: 'Wedding reception outfit. Needs delivery on time.',
        orderDate: today.subtract(const Duration(days: 3)),
        completionDate: today, // Due today
        status: OrderStatus.inProgress,
        price: 1800.00,
      ),
      Order(
        id: 'o2',
        billNumber: 'INV-1002',
        customer: custs[1], // Aarav
        items: [
          OrderItem(
            clothType: types[0], // Shirt
            measurements: {
              's_length': '28',
              's_chest': '39',
              's_waist': '35',
              's_shoulder': '17.5',
              's_sleeve': '23.5',
              's_collar': '15',
              's_pocket': 'No Pocket',
            },
          ),
        ],
        quantity: 2,
        notes: 'Linen casual shirts. Easy breathing fit.',
        orderDate: today.subtract(const Duration(days: 1)),
        completionDate: today.add(const Duration(days: 2)),
        status: OrderStatus.pending,
        price: 1500.00,
      ),
      Order(
        id: 'o3',
        billNumber: 'INV-1003',
        customer: custs[2], // Vikram
        items: [
          OrderItem(
            clothType: types[2], // Kurta
            measurements: {
              'k_length': '44',
              'k_chest': '43',
              'k_shoulder': '19',
              'k_sleeve': '25.5',
              'k_neck': '16.5',
              'k_design': 'Sherwani collar, designer embroidery',
            },
          ),
        ],
        quantity: 1,
        notes: 'Festive season Kurta. Needs designer button detailing.',
        orderDate: today.subtract(const Duration(days: 5)),
        completionDate: today, // Completed today
        status: OrderStatus.completed,
        price: 1200.00,
      ),
      Order(
        id: 'o4',
        billNumber: 'INV-1004',
        customer: custs[3], // Neha
        items: [
          OrderItem(
            clothType: types[1], // Pant
            measurements: {
              'p_waist': '30',
              'p_length': '39.5',
              'p_hip': '36.5',
              'p_inseam': '29',
              'p_cuff': '13.5',
              'p_pocket_type': 'Two Side Slash Pockets',
            },
          ),
        ],
        quantity: 1,
        notes: 'Office wear formal trousers.',
        orderDate: today.subtract(const Duration(days: 8)),
        completionDate: today.subtract(const Duration(days: 2)),
        status: OrderStatus.delivered,
        price: 750.00,
      ),
    ];
    orders.value = ordersList;
  }

  // --- Customer CRUD ---
  void addCustomer(Customer c) {
    customers.value = List.from(customers.value)..add(c);
  }

  void updateCustomer(Customer c) {
    customers.value = customers.value.map((item) => item.id == c.id ? c : item).toList();
    // Also update customer references in existing orders
    orders.value = orders.value.map((order) {
      if (order.customer.id == c.id) {
        return order.copyWith(customer: c);
      }
      return order;
    }).toList();
  }

  void deleteCustomer(String id) {
    customers.value = List.from(customers.value)..removeWhere((item) => item.id == id);
    // Remove orders associated with the customer for visual consistency
    orders.value = List.from(orders.value)..removeWhere((order) => order.customer.id == id);
  }

  // --- ClothType CRUD ---
  void addClothType(ClothType t) {
    clothTypes.value = List.from(clothTypes.value)..add(t);
  }

  void updateClothType(ClothType t) {
    clothTypes.value = clothTypes.value.map((item) => item.id == t.id ? t : item).toList();
  }

  void deleteClothType(String id) {
    clothTypes.value = List.from(clothTypes.value)..removeWhere((item) => item.id == id);
  }

  // --- Order CRUD ---
  String generateInvoiceNumber() {
    final num = _nextBillNum;
    _nextBillNum++;
    return 'INV-$num';
  }

  void addOrder(Order o) {
    orders.value = List.from(orders.value)..insert(0, o);
  }

  void updateOrder(Order o) {
    orders.value = orders.value.map((item) => item.id == o.id ? o : item).toList();
  }

  void deleteOrder(String id) {
    orders.value = List.from(orders.value)..removeWhere((item) => item.id == id);
  }
}
