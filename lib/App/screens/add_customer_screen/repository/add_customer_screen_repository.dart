import '../../customers_page/model/customer_model.dart';
import '../../customers_page/repository/customers_page_repository.dart';

class AddCustomerScreenRepository {
  final CustomersPageRepository _customersRepository = CustomersPageRepository();

  void saveCustomer(CustomerModel customer) {
    _customersRepository.addCustomer(customer);
  }
}