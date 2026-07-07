import '../../orders_page/model/order_model.dart';
import '../../orders_page/repository/orders_page_repository.dart';
import '../../customers_page/repository/customers_page_repository.dart';

class DashboardPageRepository {
  final OrdersPageRepository _ordersRepo = OrdersPageRepository();
  final CustomersPageRepository _customersRepo = CustomersPageRepository();

  List<OrderModel> getOrders() {
    return _ordersRepo.getOrders();
  }

  int getCustomersCount() {
    return _customersRepo.getCustomers().length;
  }
}