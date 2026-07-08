import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:statekit/statekit.dart';
import 'package:tailor/App/core/constants/color_constants.dart';
import 'package:tailor/App/core/utils/app_text_style.dart';
import 'package:tailor/App/routes/app_routes.dart';
import 'package:tailor/App/screens/customers_page/model/customer_model.dart';
import 'package:tailor/App/screens/orders_page/model/order_model.dart';
import '../../base_screen/view/base_screen.dart';
import '../../base_screen/view/custom_appbar.dart';
import '../binding/customer_details_screen_binding.dart';
import '../controller/customer_details_screen_controller.dart';

class CustomerDetailsScreen extends StatekitView<CustomerDetailsScreenController>
    implements CustomerDetailsScreenBinding {
  CustomerDetailsScreen({super.key, super.tag});

  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      final customer = ModalRoute.of(context)!.settings.arguments as CustomerModel;
      controller.customer = customer;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.initData(customer);
      });
      _initialized = true;
    }

    return StateBuilder<CustomerDetailsScreenController>(
      controller: controller,
      builder: (context, controller, child) {
        final customer = controller.customer;
        final hasUnpaid = controller.activeOrders.any((o) => o.paymentStatus.toLowerCase() != 'paid');
        
        final colors = [
          Colors.blue,
          Colors.green,
          Colors.orange,
          Colors.purple,
          Colors.teal,
          Colors.red,
          Colors.indigo,
        ];
        final avatarColor = colors[customer.name.hashCode % colors.length];
        final initial = customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?';

        return BaseScreen(
          appBar: CustomAppbar(
            title: const Text("Customer Details"),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: () => controller.navigateToEditCustomer(context),
              ),
            ],
          ),
          padding: EdgeInsets.zero,
          bottomNavigationBar: hasUnpaid
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        Routes.billPreviewScreen,
                        arguments: customer,
                      );
                    },
                    icon: const Icon(Icons.receipt_long_rounded, color: Colors.white),
                    label: const Text(
                      "Generate Bill",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                )
              : null,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1. Customer Info Header Card ─────────────────────────────
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: avatarColor.withValues(alpha: 0.1),
                              child: Text(
                                initial,
                                style: AppTextStyle.boldBlack(
                                  fontSize: 24,
                                ).copyWith(color: avatarColor),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          customer.name,
                                          style: AppTextStyle.boldBlack(fontSize: 20),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (customer.isRegular) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryColor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            "Regular",
                                            style: AppTextStyle.mediumBlack(
                                              fontSize: 10,
                                            ).copyWith(color: AppColors.primaryColor),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    customer.phone.isNotEmpty ? customer.phone : "No Phone Number",
                                    style: AppTextStyle.mediumBlack(
                                      fontSize: 14,
                                    ).copyWith(color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (customer.address.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 18,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  customer.address,
                                  style: AppTextStyle.regularBlack(
                                    fontSize: 13,
                                  ).copyWith(color: Colors.grey.shade700),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (customer.notes != null && customer.notes!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.notes, size: 16, color: Colors.grey.shade600),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    customer.notes!,
                                    style: AppTextStyle.regularBlack(fontSize: 12).copyWith(
                                      color: Colors.grey.shade700,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── 2. Active Orders ─────────────────────────────────────────
                Text(
                  "Active Orders (${controller.activeOrders.length})",
                  style: AppTextStyle.boldBlack(fontSize: 16),
                ),
                const SizedBox(height: 10),
                if (controller.activeOrders.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Text(
                        "No active orders found",
                        style: AppTextStyle.regularBlack(
                          fontSize: 14,
                        ).copyWith(color: Colors.grey.shade500),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.activeOrders.length,
                    itemBuilder: (context, index) {
                      return _CustomerOrderCard(order: controller.activeOrders[index]);
                    },
                  ),
                const SizedBox(height: 24),

                // ── 3. Past Orders ───────────────────────────────────────────
                Text(
                  "Past Paid Orders (${controller.pastOrders.length})",
                  style: AppTextStyle.boldBlack(fontSize: 16),
                ),
                const SizedBox(height: 10),
                if (controller.pastOrders.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Text(
                        "No past orders found",
                        style: AppTextStyle.regularBlack(
                          fontSize: 14,
                        ).copyWith(color: Colors.grey.shade500),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.pastOrders.length,
                    itemBuilder: (context, index) {
                      return _CustomerOrderCard(order: controller.pastOrders[index]);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void doSomething() {}
}

class _CustomerOrderCard extends StatelessWidget {
  final OrderModel order;
  const _CustomerOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    Color statusBgColor;
    Color statusTextColor;
    switch (order.status.toLowerCase()) {
      case 'completed':
        statusBgColor = Colors.green.shade50;
        statusTextColor = Colors.green.shade700;
        break;
      case 'processing':
        statusBgColor = Colors.blue.shade50;
        statusTextColor = Colors.blue.shade700;
        break;
      case 'cancelled':
        statusBgColor = Colors.grey.shade100;
        statusTextColor = Colors.grey.shade700;
        break;
      case 'pending':
      default:
        statusBgColor = Colors.orange.shade50;
        statusTextColor = Colors.orange.shade700;
        break;
    }

    Color paymentBgColor;
    Color paymentTextColor;
    switch (order.paymentStatus.toLowerCase()) {
      case 'paid':
        paymentBgColor = Colors.green.shade50;
        paymentTextColor = Colors.green.shade700;
        break;
      case 'advance':
        paymentBgColor = Colors.blue.shade50;
        paymentTextColor = Colors.blue.shade700;
        break;
      case 'partial paid':
      case 'advance partial':
        paymentBgColor = Colors.teal.shade50;
        paymentTextColor = Colors.teal.shade700;
        break;
      case 'unpaid':
      default:
        paymentBgColor = Colors.orange.shade50;
        paymentTextColor = Colors.orange.shade800;
        break;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.orderNumber, style: AppTextStyle.boldBlack(fontSize: 15)),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        order.status,
                        style: AppTextStyle.mediumBlack(
                          fontSize: 11,
                        ).copyWith(color: statusTextColor),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: paymentBgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        order.paymentStatus,
                        style: AppTextStyle.mediumBlack(
                          fontSize: 11,
                        ).copyWith(color: paymentTextColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.checkroom, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(order.clothesName, style: AppTextStyle.mediumBlack(fontSize: 14)),
                ),
                Text(
                  "Qty: ${order.quantity}",
                  style: AppTextStyle.regularBlack(
                    fontSize: 13,
                  ).copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Due: ${DateFormat('dd/MM/yyyy').format(order.completionDate)}",
                  style: AppTextStyle.regularBlack(fontSize: 12).copyWith(
                    color:
                        order.completionDate.isBefore(DateTime.now()) && order.status != 'Completed'
                        ? Colors.red
                        : Colors.grey.shade600,
                  ),
                ),
                Text(
                  "₹${order.laborCost.toStringAsFixed(0)}",
                  style: AppTextStyle.boldBlack(
                    fontSize: 15,
                  ).copyWith(color: AppColors.primaryColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
