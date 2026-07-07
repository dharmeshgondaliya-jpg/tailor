import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import 'package:tailor/App/routes/app_routes.dart';
import '../model/order_model.dart';
import '../repository/orders_page_repository.dart';
import '../binding/orders_page_binding.dart';

class OrdersPageController extends StateController<OrdersPageBinding> {
  final OrdersPageRepository _repository = OrdersPageRepository();

  final TextEditingController searchController = TextEditingController();

  List<OrderModel> allOrders = [];
  List<OrderModel> filteredOrders = [];

  // Filter criteria
  DateTime? selectedOrderDate;
  DateTime? selectedCompletionDate;
  final Set<String> selectedStatuses = {};

  // Available statuses
  final List<String> availableStatuses = ['Pending', 'Processing', 'Completed', 'Cancelled'];

  Future<void> fetchInitData() async {
    allOrders = _repository.getOrders();
    _applyFilters();
  }

  void updateSearch(String query) {
    _applyFilters();
  }

  void setOrderDate(DateTime? date) {
    selectedOrderDate = date;
    _applyFilters();
  }

  void setCompletionDate(DateTime? date) {
    selectedCompletionDate = date;
    _applyFilters();
  }

  void toggleStatus(String status) {
    if (selectedStatuses.contains(status)) {
      selectedStatuses.remove(status);
    } else {
      selectedStatuses.add(status);
    }
    _applyFilters();
  }

  void clearFilters() {
    selectedOrderDate = null;
    selectedCompletionDate = null;
    selectedStatuses.clear();
    searchController.clear();
    _applyFilters();
  }

  void _applyFilters() {
    final query = searchController.text.trim().toLowerCase();

    filteredOrders = allOrders.where((order) {
      // 1. Search Query filter (matches customer name, order number, or clothes name)
      if (query.isNotEmpty) {
        final matchesName = order.customerName.toLowerCase().contains(query);
        final matchesNumber = order.orderNumber.toLowerCase().contains(query);
        final matchesClothes = order.clothesName.toLowerCase().contains(query);
        if (!matchesName && !matchesNumber && !matchesClothes) {
          return false;
        }
      }

      // 2. Order Date filter (comparing date parts only)
      if (selectedOrderDate != null) {
        final orderDateOnly = DateTime(
          order.orderDate.year,
          order.orderDate.month,
          order.orderDate.day,
        );
        final filterOrderDateOnly = DateTime(
          selectedOrderDate!.year,
          selectedOrderDate!.month,
          selectedOrderDate!.day,
        );
        if (orderDateOnly != filterOrderDateOnly) {
          return false;
        }
      }

      // 3. Completion Date filter (comparing date parts only)
      if (selectedCompletionDate != null) {
        final compDateOnly = DateTime(
          order.completionDate.year,
          order.completionDate.month,
          order.completionDate.day,
        );
        final filterCompDateOnly = DateTime(
          selectedCompletionDate!.year,
          selectedCompletionDate!.month,
          selectedCompletionDate!.day,
        );
        if (compDateOnly != filterCompDateOnly) {
          return false;
        }
      }

      // 4. Status filter (multi-select)
      if (selectedStatuses.isNotEmpty) {
        if (!selectedStatuses.contains(order.status)) {
          return false;
        }
      }

      return true;
    }).toList();

    update();
  }

  Future<void> navigateToAddOrder(BuildContext context) async {
    await Navigator.pushNamed(context, Routes.addOrderScreen);
    fetchInitData();
  }

  void deleteOrder(OrderModel order) {
    _repository.deleteOrder(order);
    fetchInitData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
