import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:statekit/statekit.dart';
import 'package:tailor/App/core/constants/color_constants.dart';
import 'package:tailor/App/core/utils/app_text_style.dart';
import 'package:tailor/App/core/utils/date_picker_utils.dart';
import '../../../widgets/animated_list_item.dart';
import '../../../widgets/app_checkbox.dart';
import '../../../widgets/empty_view.dart';
import '../../../widgets/search_field.dart';
import '../binding/orders_page_binding.dart';
import '../controller/orders_page_controller.dart';
import '../model/order_model.dart';

class OrdersPage extends StatekitView<OrdersPageController> implements OrdersPageBinding {
  OrdersPage({super.key, super.tag});

  @override
  void initState() {
    controller.binding = this;
    super.initState();
    controller.fetchInitData();
  }

  @override
  Widget build(BuildContext context) {
    return StateBuilder<OrdersPageController>(
      controller: controller,
      builder: (context, controller, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            // Search and Filter Row
            Row(
              children: [
                Expanded(
                  child: SearchField(
                    searchController: controller.searchController,
                    onTextChange: (text) => controller.updateSearch(text),
                  ),
                ),
                const SizedBox(width: 8),
                Stack(
                  children: [
                    IconButton(
                      onPressed: () => _showFilterBottomSheet(context),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.filter_list_outlined),
                    ),
                    if (controller.selectedStatuses.isNotEmpty ||
                        controller.selectedOrderDate != null ||
                        controller.selectedCompletionDate != null)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => controller.navigateToAddOrder(context),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Orders List or Empty View
            Expanded(child: _buildOrdersContent(controller)),
          ],
        );
      },
    );
  }

  Widget _buildOrdersContent(OrdersPageController controller) {
    if (controller.allOrders.isEmpty) {
      return const EmptyView(titleText: "No orders yet");
    }

    if (controller.filteredOrders.isEmpty) {
      return const EmptyView(titleText: "Data not found");
    }

    return ListView.builder(
      itemCount: controller.filteredOrders.length,
      padding: const EdgeInsets.only(bottom: 80), // padding to prevent overlap with FAB
      itemBuilder: (context, index) {
        final order = controller.filteredOrders[index];
        return AnimatedListItem(
          index: index,
          child: OrderCard(
            order: order,
            onDelete: () => _showOrderDeleteConfirmation(context, order),
          ),
        );
      },
    );
  }

  void _showOrderDeleteConfirmation(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Order", style: AppTextStyle.boldBlack(fontSize: 18)),
          content: Text(
            "Are you sure you want to delete order ${order.orderNumber}? This action cannot be undone.",
            style: AppTextStyle.regularBlack(fontSize: 14).copyWith(color: Colors.grey.shade700),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: AppTextStyle.mediumBlack(fontSize: 14).copyWith(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                controller.deleteOrder(order);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Order ${order.orderNumber} deleted successfully."),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                "Delete",
                style: AppTextStyle.mediumBlack(fontSize: 14).copyWith(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 18,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: StateBuilder<OrdersPageController>(
            controller: controller,
            builder: (context, controller, child) {
              final formattedOrderDate = controller.selectedOrderDate == null
                  ? "Select Date"
                  : DateFormat('dd/MM/yyyy').format(controller.selectedOrderDate!);
              final formattedCompletionDate = controller.selectedCompletionDate == null
                  ? "Select Date"
                  : DateFormat('dd/MM/yyyy').format(controller.selectedCompletionDate!);

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bottom sheet Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Filter Orders", style: AppTextStyle.boldBlack(fontSize: 18)),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Order Date Picker
                  Text("Order Date", style: AppTextStyle.semiBoldBlack(fontSize: 14)),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () async {
                      final picked = await context.selectDate(
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        initialDate: controller.selectedOrderDate ?? DateTime.now(),
                      );
                      controller.setOrderDate(picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formattedOrderDate,
                            style: AppTextStyle.regularBlack(fontSize: 14).copyWith(
                              color: controller.selectedOrderDate == null
                                  ? Colors.grey.shade500
                                  : Colors.black,
                            ),
                          ),
                          Row(
                            children: [
                              if (controller.selectedOrderDate != null)
                                GestureDetector(
                                  onTap: () => controller.setOrderDate(null),
                                  child: const Icon(Icons.clear, size: 18, color: Colors.grey),
                                ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Completion Date Picker
                  Text("Completion Date", style: AppTextStyle.semiBoldBlack(fontSize: 14)),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () async {
                      final picked = await context.selectDate(
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        initialDate: controller.selectedCompletionDate ?? DateTime.now(),
                      );
                      controller.setCompletionDate(picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formattedCompletionDate,
                            style: AppTextStyle.regularBlack(fontSize: 14).copyWith(
                              color: controller.selectedCompletionDate == null
                                  ? Colors.grey.shade500
                                  : Colors.black,
                            ),
                          ),
                          Row(
                            children: [
                              if (controller.selectedCompletionDate != null)
                                GestureDetector(
                                  onTap: () => controller.setCompletionDate(null),
                                  child: const Icon(Icons.clear, size: 18, color: Colors.grey),
                                ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Status Multi-Select Checkboxes
                  Text("Status", style: AppTextStyle.semiBoldBlack(fontSize: 14)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: controller.availableStatuses.map((status) {
                      final isSelected = controller.selectedStatuses.contains(status);
                      return InkWell(
                        onTap: () => controller.toggleStatus(status),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryColor.withValues(alpha: 0.1)
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: AppCheckbox(
                                  value: isSelected,
                                  onChanged: (_) => controller.toggleStatus(status),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                status,
                                style: AppTextStyle.mediumBlack(fontSize: 13).copyWith(
                                  color: isSelected ? AppColors.primaryColor : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            controller.clearFilters();
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            "Clear All",
                            style: AppTextStyle.mediumBlack(
                              fontSize: 14,
                            ).copyWith(color: Colors.grey.shade700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            "Apply Filters",
                            style: AppTextStyle.mediumBlack(
                              fontSize: 14,
                            ).copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  void doSomething() {}
}

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onDelete;
  const OrderCard({super.key, required this.order, required this.onDelete});

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
                Expanded(
                  child: Text(order.customerName, style: AppTextStyle.boldBlack(fontSize: 16)),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        order.orderNumber,
                        style: AppTextStyle.mediumBlack(
                          fontSize: 12,
                        ).copyWith(color: Colors.grey.shade700),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: onDelete,
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
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
                    style: AppTextStyle.mediumBlack(fontSize: 12).copyWith(color: statusTextColor),
                  ),
                ),
                if (order.isOverdue) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 14, color: Colors.red.shade700),
                        const SizedBox(width: 4),
                        Text(
                          "Overdue",
                          style: AppTextStyle.mediumBlack(
                            fontSize: 12,
                          ).copyWith(color: Colors.red.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Labor Cost",
                      style: AppTextStyle.regularBlack(
                        fontSize: 12,
                      ).copyWith(color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "\$${order.laborCost.toStringAsFixed(2)}",
                      style: AppTextStyle.boldBlack(
                        fontSize: 15,
                      ).copyWith(color: AppColors.primaryColor),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Quantity",
                      style: AppTextStyle.regularBlack(
                        fontSize: 12,
                      ).copyWith(color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${order.quantity} Pairs (${order.clothesName})",
                      style: AppTextStyle.semiBoldBlack(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      "Ordered: ${DateFormat('dd/MM/yyyy').format(order.orderDate)}",
                      style: AppTextStyle.regularBlack(
                        fontSize: 12,
                      ).copyWith(color: Colors.grey.shade600),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.assignment_turned_in_outlined,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Delivery: ${DateFormat('dd/MM/yyyy').format(order.completionDate)}",
                      style: AppTextStyle.regularBlack(
                        fontSize: 12,
                      ).copyWith(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
            if (order.notes != null && order.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.notes, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        order.notes!,
                        style: AppTextStyle.regularBlack(
                          fontSize: 12,
                        ).copyWith(color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
