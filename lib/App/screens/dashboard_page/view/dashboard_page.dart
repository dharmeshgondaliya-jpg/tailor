import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:statekit/statekit.dart';
import 'package:tailor/App/core/constants/color_constants.dart';
import 'package:tailor/App/core/utils/app_text_style.dart';
import '../binding/dashboard_page_binding.dart';
import '../controller/dashboard_page_controller.dart';
import '../../orders_page/model/order_model.dart';

class DashboardPage extends StatekitView<DashboardPageController> implements DashboardPageBinding {
  DashboardPage({super.key, super.tag});

  @override
  void initState() {
    controller.binding = this;
    controller.fetchDashboardData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StateBuilder<DashboardPageController>(
      controller: controller,
      builder: (context, controller, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Quick Actions
              Text("Quick Actions", style: AppTextStyle.boldBlack(fontSize: 16)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.navigateToAddCustomer(context),
                      icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
                      label: const Text("New Customer"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryColor,
                        side: const BorderSide(color: AppColors.primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => controller.navigateToAddOrder(context),
                      icon: const Icon(Icons.add_shopping_cart_outlined, size: 18, color: Colors.white),
                      label: const Text("New Order", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // 2. Metrics / Statistics Grid
              Text("Statistics Summary", style: AppTextStyle.boldBlack(fontSize: 16)),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(
                    title: "Pending",
                    count: controller.pendingCount,
                    color: Colors.amber,
                    icon: Icons.hourglass_empty,
                  ),
                  _buildStatCard(
                    title: "Processing",
                    count: controller.runningCount,
                    color: Colors.blue,
                    icon: Icons.autorenew,
                  ),
                  _buildStatCard(
                    title: "Ready",
                    count: controller.readyCount,
                    color: Colors.teal,
                    icon: Icons.check_circle_outline,
                  ),
                  _buildStatCard(
                    title: "Completed",
                    count: controller.completedCount,
                    color: Colors.green,
                    icon: Icons.done_all,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Overview Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Active Customers: ${controller.totalCustomers}",
                      style: AppTextStyle.mediumBlack(fontSize: 13).copyWith(color: Colors.grey.shade700),
                    ),
                    Text(
                      "Running Tasks: ${controller.totalRunning}",
                      style: AppTextStyle.mediumBlack(fontSize: 13).copyWith(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // 3. Tab Segment Selector
              Text("Today's Tasks", style: AppTextStyle.boldBlack(fontSize: 16)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildTabHeader(0, "Due Today", controller.dueTodayOrders.length),
                  const SizedBox(width: 8),
                  _buildTabHeader(1, "Ready", controller.readyTodayOrders.length),
                  const SizedBox(width: 8),
                  _buildTabHeader(2, "Completion", controller.completionTodayOrders.length),
                ],
              ),
              const SizedBox(height: 16),

              // 4. Tab List Details
              _buildActiveTaskList(controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Text(
                count.toString(),
                style: AppTextStyle.boldBlack(fontSize: 22).copyWith(color: color),
              ),
            ],
          ),
          Text(
            title,
            style: AppTextStyle.boldBlack(fontSize: 13).copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildTabHeader(int index, String label, int count) {
    final isSelected = controller.activeTab == index;
    final color = isSelected ? AppColors.primaryColor : Colors.grey.shade100;
    final textColor = isSelected ? Colors.white : Colors.black87;

    return Expanded(
      child: InkWell(
        onTap: () => controller.selectTab(index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
            ),
          ),
          child: Text(
            "$label ($count)",
            style: AppTextStyle.boldBlack(fontSize: 11).copyWith(color: textColor),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTaskList(DashboardPageController controller) {
    List<OrderModel> activeList = [];
    String emptyMessage = "";

    switch (controller.activeTab) {
      case 0:
        activeList = controller.dueTodayOrders;
        emptyMessage = "No orders due today";
        break;
      case 1:
        activeList = controller.readyTodayOrders;
        emptyMessage = "No orders marked ready today";
        break;
      case 2:
        activeList = controller.completionTodayOrders;
        emptyMessage = "No orders completed today";
        break;
    }

    if (activeList.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.grey.shade400, size: 36),
            const SizedBox(height: 8),
            Text(
              emptyMessage,
              style: AppTextStyle.mediumBlack(fontSize: 13).copyWith(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return Column(
      children: activeList.map((order) {
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.customerName, style: AppTextStyle.boldBlack(fontSize: 14)),
                Text(order.orderNumber, style: AppTextStyle.regularBlack(fontSize: 12).copyWith(color: Colors.grey)),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  order.clothesName,
                  style: AppTextStyle.regularBlack(fontSize: 13).copyWith(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Delivery: ${DateFormat('dd MMM').format(order.completionDate)}",
                      style: const TextStyle(fontSize: 11, color: Colors.redAccent, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        order.status,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(order.status),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.amber.shade800;
      case 'processing':
        return Colors.blue;
      case 'ready':
        return Colors.teal;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  void doSomething() {}
}
