import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import 'package:tailor/App/routes/app_routes.dart';
import '../model/customer_model.dart';
import '../repository/customers_page_repository.dart';
import '../binding/customers_page_binding.dart';

class CustomersPageController extends StateController<CustomersPageBinding> {
  final CustomersPageRepository _repository = CustomersPageRepository();

  final TextEditingController searchController = TextEditingController();

  List<CustomerModel> allCustomers = [];
  List<CustomerModel> filteredCustomers = [];

  Future<void> fetchInitData() async {
    allCustomers = _repository.getCustomers();
    _applyFilters();
  }

  void updateSearch(String query) {
    _applyFilters();
  }

  void deleteCustomer(CustomerModel customer) {
    _repository.deleteCustomer(customer);
    fetchInitData();
  }

  void _applyFilters() {
    final query = searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      filteredCustomers = List.from(allCustomers);
    } else {
      filteredCustomers = allOrdersFiltered(query);
    }
    update();
  }

  List<CustomerModel> allOrdersFiltered(String query) {
    return allCustomers.where((customer) {
      final matchesName = customer.name.toLowerCase().contains(query);
      final matchesPhone = customer.phone.toLowerCase().contains(query);
      return matchesName || matchesPhone;
    }).toList();
  }

  Future<void> navigateToAddCustomer(BuildContext context) async {
    await Navigator.pushNamed(context, Routes.addCustomerScreen);
    fetchInitData();
  }

  Future<void> navigateToEditCustomer(BuildContext context, CustomerModel customer) async {
    await Navigator.pushNamed(context, Routes.addCustomerScreen, arguments: customer);
    fetchInitData();
  }

  Future<void> navigateToCustomerDetails(BuildContext context, CustomerModel customer) async {
    await Navigator.pushNamed(context, Routes.customerDetailsScreen, arguments: customer);
    fetchInitData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
