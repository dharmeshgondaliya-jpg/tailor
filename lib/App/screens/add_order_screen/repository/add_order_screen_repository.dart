import '../../orders_page/model/order_model.dart';
import '../../orders_page/repository/orders_page_repository.dart';

class AddOrderScreenRepository {
  final OrdersPageRepository _ordersRepository = OrdersPageRepository();

  void saveOrder(OrderModel order) {
    _ordersRepository.addOrder(order);
  }
}