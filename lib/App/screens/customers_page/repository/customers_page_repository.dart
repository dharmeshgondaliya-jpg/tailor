import '../model/customer_model.dart';

class CustomersPageRepository {
  static final List<CustomerModel> _customers = [
    CustomerModel(
      name: "Sarah Connor",
      phone: "+1 555-0199",
      address: "123 Cyberdyne Way, Los Angeles, CA",
      notes: "Prefers heavy double-stitching, quick alterations.",
      isRegular: true,
    ),
    CustomerModel(
      name: "Peter Parker",
      phone: "+1 555-0142",
      address: "20 Ingram St, Forest Hills, Queens, NY",
      notes: "Needs custom flexible stitching for active wear.",
      isRegular: false,
    ),
    CustomerModel(
      name: "Bruce Wayne",
      phone: "+1 555-0100",
      address: "1007 Mountain Drive, Gotham City",
      notes: null,
      isRegular: true,
    ),
    CustomerModel(
      name: "Clark Kent",
      phone: "+1 555-0177",
      address: "344 Clinton St, Apt 3B, Metropolis",
      notes: "X-Large shirts, extra-long sleeve lengths.",
      isRegular: false,
    ),
    CustomerModel(
      name: "Diana Prince",
      phone: "+1 555-0121",
      address: "777 Gateway Blvd, Washington, DC",
      notes: "Prefers premium silk inner linings.",
      isRegular: true,
    ),
  ];

  List<CustomerModel> getCustomers() {
    return _customers;
  }

  void addCustomer(CustomerModel customer, {String? originalName}) {
    if (originalName != null) {
      final index = _customers.indexWhere((c) => c.name == originalName);
      if (index >= 0) {
        _customers[index] = customer;
        return;
      }
    }
    final index = _customers.indexWhere((c) => c.name == customer.name);
    if (index >= 0) {
      _customers[index] = customer;
    } else {
      _customers.add(customer);
    }
  }

  void deleteCustomer(CustomerModel customer) {
    _customers.remove(customer);
  }
}