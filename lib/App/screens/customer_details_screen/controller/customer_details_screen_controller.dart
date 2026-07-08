import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import '../../customers_page/model/customer_model.dart';
import '../../customers_page/repository/customers_page_repository.dart';
import '../../orders_page/model/order_model.dart';
import '../../../routes/app_routes.dart';
import '../repository/customer_details_screen_repository.dart';
import '../binding/customer_details_screen_binding.dart';

class CustomerDetailsScreenController extends StateController<CustomerDetailsScreenBinding> {
  final CustomerDetailsScreenRepository _repository = CustomerDetailsScreenRepository();

  late CustomerModel customer;
  List<OrderModel> activeOrders = [];
  List<OrderModel> pastOrders = [];

  void initData(CustomerModel customer) {
    this.customer = customer;
    final allOrders = _repository.getOrdersForCustomer(customer.name);
    activeOrders = allOrders.where((o) => o.paymentStatus.toLowerCase() != 'paid').toList();
    pastOrders = allOrders.where((o) => o.paymentStatus.toLowerCase() == 'paid').toList();
    update();
  }

  void refreshData() {
    initData(customer);
  }

  void navigateToEditCustomer(BuildContext context) async {
    await Navigator.pushNamed(
      context,
      Routes.addCustomerScreen,
      arguments: customer,
    );
    
    // If we get an updated customer back or need to find it by name
    final matched = CustomersPageRepository().getCustomers().firstWhere(
      (c) => c.name == customer.name,
      orElse: () => customer,
    );
    initData(matched);
  }
}