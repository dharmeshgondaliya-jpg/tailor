import '../../orders_page/model/order_model.dart';
import '../../orders_page/repository/orders_page_repository.dart';

class CustomerDetailsScreenRepository {
  final OrdersPageRepository _ordersRepo = OrdersPageRepository();

  List<OrderModel> getOrdersForCustomer(String customerName) {
    return _ordersRepo.getOrders().where((o) => o.customerName == customerName).toList();
  }
}