import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:statekit/statekit.dart';
import '../../customers_page/model/customer_model.dart';
import '../repository/add_customer_screen_repository.dart';
import '../binding/add_customer_screen_binding.dart';

class AddCustomerScreenController extends StateController<AddCustomerScreenBinding> {
  final AddCustomerScreenRepository _repository = AddCustomerScreenRepository();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  bool isRegular = false;

  void toggleRegular(bool value) {
    HapticFeedback.lightImpact();
    isRegular = value;
    update();
  }

  CustomerModel? editingCustomer;

  void initData({CustomerModel? customer}) {
    if (customer != null) {
      editingCustomer = customer;
      nameController.text = customer.name;
      phoneController.text = customer.phone;
      addressController.text = customer.address;
      notesController.text = customer.notes ?? "";
      isRegular = customer.isRegular;
    } else {
      editingCustomer = null;
      nameController.clear();
      phoneController.clear();
      addressController.clear();
      notesController.clear();
      isRegular = false;
    }
    update();
  }

  void saveCustomer(BuildContext context) {
    HapticFeedback.mediumImpact();
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final address = addressController.text.trim();
    final notes = notesController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter customer name")),
      );
      return;
    }

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter mobile number")),
      );
      return;
    }

    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter address")),
      );
      return;
    }

    final isEditing = editingCustomer != null;

    final customer = CustomerModel(
      name: name,
      phone: phone,
      address: address,
      notes: notes.isEmpty ? null : notes,
      isRegular: isRegular,
    );

    _repository.saveCustomer(customer, originalName: editingCustomer?.name);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Customer $name ${isEditing ? 'updated' : 'added'} successfully")),
    );

    Navigator.pop(context);
  }

  void deleteCustomer(BuildContext context) {
    HapticFeedback.mediumImpact();
    final customer = editingCustomer;
    if (customer != null) {
      _repository.deleteCustomer(customer);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Customer ${customer.name} deleted successfully")),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    notesController.dispose();
    super.dispose();
  }
}