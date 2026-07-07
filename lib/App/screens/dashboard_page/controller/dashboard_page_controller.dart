import 'package:statekit/statekit.dart';
import '../repository/dashboard_page_repository.dart';
import '../binding/dashboard_page_binding.dart';

import 'package:flutter/material.dart';
import 'package:tailor/App/routes/app_routes.dart';
import '../../orders_page/model/order_model.dart';

class DashboardPageController extends StateController<DashboardPageBinding> {
  final DashboardPageRepository _repository = DashboardPageRepository();

  int totalCustomers = 0;
  int totalOrders = 0;
  int pendingCount = 0;
  int runningCount = 0;
  int readyCount = 0;
  int completedCount = 0;
  int dueTodayCount = 0;
  int totalRunning = 0;

  List<OrderModel> dueTodayOrders = [];
  List<OrderModel> readyTodayOrders = [];
  List<OrderModel> completionTodayOrders = [];

  void fetchDashboardData() {
    totalCustomers = _repository.getCustomersCount();
    final allOrders = _repository.getOrders();
    totalOrders = allOrders.length;

    pendingCount = allOrders.where((o) => o.status.toLowerCase() == 'pending').length;
    runningCount = allOrders.where((o) => o.status.toLowerCase() == 'processing').length;
    readyCount = allOrders.where((o) => o.status.toLowerCase() == 'ready').length;
    completedCount = allOrders.where((o) => o.status.toLowerCase() == 'completed').length;
    
    totalRunning = pendingCount + runningCount;

    dueTodayOrders = allOrders.where((o) {
      final statusLower = o.status.toLowerCase();
      return _isToday(o.completionDate) && statusLower != 'completed' && statusLower != 'cancelled';
    }).toList();

    dueTodayCount = dueTodayOrders.length;

    readyTodayOrders = allOrders.where((o) {
      return o.status.toLowerCase() == 'ready' && _isToday(o.completionDate);
    }).toList();

    completionTodayOrders = allOrders.where((o) {
      return _isToday(o.completionDate);
    }).toList();

    update();
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Future<void> navigateToAddOrder(BuildContext context) async {
    await Navigator.pushNamed(context, Routes.addOrderScreen);
    fetchDashboardData();
  }

  Future<void> navigateToAddCustomer(BuildContext context) async {
    await Navigator.pushNamed(context, Routes.addCustomerScreen);
    fetchDashboardData();
  }

  int activeTab = 0;
  void selectTab(int index) {
    activeTab = index;
    update();
  }
}