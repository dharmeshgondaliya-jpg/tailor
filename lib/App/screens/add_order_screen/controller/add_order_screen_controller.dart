import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:statekit/statekit.dart';
import 'package:tailor/App/routes/app_routes.dart';
import '../../customers_page/model/customer_model.dart';
import '../../customers_page/repository/customers_page_repository.dart';
import '../../clothes_listing_screen/model/cloth_model.dart';
import '../../clothes_listing_screen/repository/clothes_listing_screen_repository.dart';
import '../../pairs_listing_screen/model/pair_model.dart';
import '../../pairs_listing_screen/repository/pairs_listing_screen_repository.dart';
import '../../orders_page/model/order_model.dart';
import '../repository/add_order_screen_repository.dart';
import '../binding/add_order_screen_binding.dart';
import '../model/customer_measurement_model.dart';

class AddOrderScreenController extends StateController<AddOrderScreenBinding> {
  final AddOrderScreenRepository _repository = AddOrderScreenRepository();
  final CustomersPageRepository _customersRepo = CustomersPageRepository();
  final ClothesListingScreenRepository _clothesRepo = ClothesListingScreenRepository();
  final PairsListingScreenRepository _pairsRepo = PairsListingScreenRepository();

  DateTime orderDate = DateTime.now();
  DateTime completionDate = DateTime.now().add(const Duration(days: 7));
  
  CustomerModel? selectedCustomer;
  String status = "Pending";
  
  final TextEditingController quantityController = TextEditingController(text: "1");
  bool isUrgent = false;
  final TextEditingController laborCostController = TextEditingController();
  final TextEditingController advanceAmountController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  
  CustomerMeasurementModel? selectedMeasurement;

  List<CustomerModel> customers = [];
  List<ClothModel> clothes = [];
  List<PairModel> pairs = [];

  final List<ClothModel> selectedClothes = [];
  final List<PairModel> selectedPairs = [];

  OrderModel? editingOrder;

  void initData({OrderModel? order}) {
    customers = _customersRepo.getCustomers();
    clothes = _clothesRepo.getClothes();
    pairs = _pairsRepo.getPairs();

    selectedClothes.clear();
    selectedPairs.clear();

    if (order != null) {
      editingOrder = order;
      orderDate = order.orderDate;
      completionDate = order.completionDate;

      // Match customer
      selectedCustomer = customers.firstWhere(
        (c) => c.name == order.customerName,
        orElse: () => CustomerModel(name: order.customerName, phone: "", address: ""),
      );

      // Match clothes and pairs
      final parts = order.clothesName.split(', ').map((s) => s.trim()).toList();
      for (final part in parts) {
        final matchedCloth = clothes.firstWhere(
          (c) => c.name == part,
          orElse: () => ClothModel(id: "", name: "", measurementFields: []),
        );
        if (matchedCloth.name.isNotEmpty) {
          selectedClothes.add(matchedCloth);
        }

        final matchedPair = pairs.firstWhere(
          (p) => p.name == part,
          orElse: () => PairModel(id: "", name: "", clothes: []),
        );
        if (matchedPair.name.isNotEmpty) {
          selectedPairs.add(matchedPair);
        }
      }

      status = order.status;
      paymentStatus = order.paymentStatus;
      quantityController.text = order.quantity.toString();
      isUrgent = order.isUrgent;
      laborCostController.text = order.laborCost.toStringAsFixed(0);
      advanceAmountController.text = order.advanceAmount.toStringAsFixed(0);
      notesController.text = order.notes ?? "";

      selectedMeasurement = CustomerMeasurementModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        customerName: order.customerName,
        clothOrPairName: order.clothesName,
        dateAdded: DateTime.now(),
        clothesMeasurements: [],
      );
    } else {
      editingOrder = null;
      orderDate = DateTime.now();
      completionDate = DateTime.now().add(const Duration(days: 7));
      selectedCustomer = null;
      status = "Pending";
      paymentStatus = "Unpaid";
      quantityController.text = "1";
      isUrgent = false;
      laborCostController.clear();
      advanceAmountController.clear();
      notesController.clear();
      selectedMeasurement = null;
    }

    update();
  }

  String paymentStatus = "Unpaid";

  void updatePaymentStatus(String val) {
    paymentStatus = val;
    update();
  }

  void toggleUrgent(bool value) {
    HapticFeedback.lightImpact();
    isUrgent = value;
    update();
  }

  void selectCustomer(CustomerModel? customer) {
    HapticFeedback.lightImpact();
    selectedCustomer = customer;
    selectedMeasurement = null;
    update();
  }

  void toggleClothSelection(ClothModel cloth, bool selected) {
    HapticFeedback.lightImpact();
    if (selected) {
      if (!selectedClothes.any((c) => c.name == cloth.name)) {
        selectedClothes.add(cloth);
      }
    } else {
      selectedClothes.removeWhere((c) => c.name == cloth.name);
    }
    selectedMeasurement = null;
    update();
  }

  void togglePairSelection(PairModel pair, bool selected) {
    HapticFeedback.lightImpact();
    if (selected) {
      if (!selectedPairs.any((p) => p.name == pair.name)) {
        selectedPairs.add(pair);
      }
    } else {
      selectedPairs.removeWhere((p) => p.name == pair.name);
    }
    selectedMeasurement = null;
    update();
  }

  void updateStatus(String val) {
    HapticFeedback.lightImpact();
    status = val;
    update();
  }

  void updateOrderDate(DateTime date) {
    orderDate = date;
    update();
  }

  void updateCompletionDate(DateTime date) {
    completionDate = date;
    update();
  }

  String getSelectedItemsNames() {
    final names = <String>[];
    names.addAll(selectedClothes.map((c) => c.name));
    names.addAll(selectedPairs.map((p) => p.name));
    return names.join(', ');
  }

  List<ClothModel> getUniqueClothes() {
    final unique = <ClothModel>[];
    for (final c in selectedClothes) {
      if (!unique.any((x) => x.name == c.name)) {
        unique.add(c);
      }
    }
    for (final p in selectedPairs) {
      for (final c in p.clothes) {
        if (!unique.any((x) => x.name == c.name)) {
          unique.add(c);
        }
      }
    }
    return unique;
  }

  Future<void> navigateToSelectMeasurementHistory(BuildContext context) async {
    if (selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a customer first")),
      );
      return;
    }
    
    if (selectedClothes.isEmpty && selectedPairs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one cloth or pair first")),
      );
      return;
    }

    final result = await Navigator.pushNamed(
      context,
      Routes.measurementHistoryScreen,
      arguments: {
        'customerName': selectedCustomer!.name,
        'clothOrPairName': getSelectedItemsNames(),
      },
    );

    if (result != null && result is CustomerMeasurementModel) {
      selectedMeasurement = result;
      update();
    }
  }

  Future<void> navigateToAddNewMeasurement(BuildContext context) async {
    if (selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a customer first")),
      );
      return;
    }
    
    final uniqueClothes = getUniqueClothes();
    if (uniqueClothes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one cloth or pair first")),
      );
      return;
    }

    final result = await Navigator.pushNamed(
      context,
      Routes.measurementScreen,
      arguments: {
        'customerName': selectedCustomer!.name,
        'selectionType': 'multi',
        'item': uniqueClothes,
      },
    );

    if (result != null && result is CustomerMeasurementModel) {
      selectedMeasurement = result;
      update();
    }
  }

  void saveOrder(BuildContext context) {
    HapticFeedback.mediumImpact();
    final customer = selectedCustomer;
    final laborText = laborCostController.text.trim();
    final qtyText = quantityController.text.trim();

    if (customer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a customer")),
      );
      return;
    }

    if (selectedClothes.isEmpty && selectedPairs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one cloth or pair")),
      );
      return;
    }

    if (qtyText.isEmpty || int.tryParse(qtyText) == null || int.parse(qtyText) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid quantity")),
      );
      return;
    }

    if (laborText.isEmpty || double.tryParse(laborText) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid labor amount")),
      );
      return;
    }

    if (selectedMeasurement == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please configure measurements for this order")),
      );
      return;
    }

    final advanceText = advanceAmountController.text.trim();
    final advanceVal = double.tryParse(advanceText) ?? 0.0;

    final isEditing = editingOrder != null;

    final order = OrderModel(
      orderNumber: editingOrder?.orderNumber ?? "#ORD-${DateTime.now().millisecondsSinceEpoch % 100000}",
      customerName: customer.name,
      status: status,
      orderDate: orderDate,
      completionDate: completionDate,
      laborCost: double.parse(laborText),
      advanceAmount: advanceVal,
      isUrgent: isUrgent,
      quantity: int.parse(qtyText),
      clothesName: getSelectedItemsNames(),
      paymentStatus: paymentStatus,
      notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
    );

    _repository.saveOrder(order);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Order ${order.orderNumber} for ${customer.name} ${isEditing ? 'updated' : 'created'} successfully")),
    );

    Navigator.pop(context);
  }

  void deleteOrder(BuildContext context) {
    HapticFeedback.mediumImpact();
    final order = editingOrder;
    if (order != null) {
      _repository.deleteOrder(order);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Order ${order.orderNumber} deleted successfully")),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    quantityController.dispose();
    laborCostController.dispose();
    advanceAmountController.dispose();
    notesController.dispose();
    super.dispose();
  }
}