import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import 'package:tailor/App/core/utils/app_text_style.dart';
import 'package:tailor/App/core/constants/color_constants.dart';
import '../../../widgets/empty_view.dart';
import '../../../widgets/search_field.dart';
import '../../../widgets/animated_list_item.dart';
import '../binding/customers_page_binding.dart';
import '../controller/customers_page_controller.dart';
import '../model/customer_model.dart';

class CustomersPage extends StatekitView<CustomersPageController> implements CustomersPageBinding {
  CustomersPage({super.key, super.tag});

  @override
  void initState() {
    controller.binding = this;
    super.initState();
    controller.fetchInitData();
  }

  @override
  Widget build(BuildContext context) {
    return StateBuilder<CustomersPageController>(
      controller: controller,
      builder: (context, controller, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            // Search field
            Row(
              children: [
                Expanded(
                  child: SearchField(
                    searchController: controller.searchController,
                    onTextChange: (text) => controller.updateSearch(text),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => controller.navigateToAddCustomer(context),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Customers List or Empty View
            Expanded(child: _buildCustomersContent(controller)),
          ],
        );
      },
    );
  }

  Widget _buildCustomersContent(CustomersPageController controller) {
    if (controller.allCustomers.isEmpty) {
      return const EmptyView(titleText: "No customers yet");
    }

    if (controller.filteredCustomers.isEmpty) {
      return const EmptyView(titleText: "Data not found");
    }

    return ListView.builder(
      itemCount: controller.filteredCustomers.length,
      padding: const EdgeInsets.only(bottom: 80), // padding for FAB
      itemBuilder: (context, index) {
        final customer = controller.filteredCustomers[index];
        return AnimatedListItem(
          index: index,
          child: CustomerCard(
            customer: customer,
            onDelete: () => _showDeleteConfirmation(context, customer),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, CustomerModel customer) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Customer", style: AppTextStyle.boldBlack(fontSize: 18)),
          content: Text(
            "Are you sure you want to delete ${customer.name}? This action cannot be undone.",
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
                controller.deleteCustomer(customer);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${customer.name} deleted successfully."),
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

  @override
  void doSomething() {}
}

class CustomerCard extends StatelessWidget {
  final CustomerModel customer;
  final VoidCallback onDelete;

  const CustomerCard({super.key, required this.customer, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final initial = customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?';

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.red,
      Colors.indigo,
    ];
    final color = colors[customer.name.hashCode % colors.length];

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
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: color.withValues(alpha: 0.1),
                  child: Text(
                    initial,
                    style: AppTextStyle.boldBlack(fontSize: 20).copyWith(color: color),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              customer.name,
                              style: AppTextStyle.boldBlack(fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (customer.isRegular) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.amber.shade300),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star, size: 10, color: Colors.amber.shade800),
                                  const SizedBox(width: 2),
                                  Text(
                                    "Regular",
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone_outlined, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            customer.phone,
                            style: AppTextStyle.regularBlack(
                              fontSize: 13,
                            ).copyWith(color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
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
            if (customer.notes != null && customer.notes!.isNotEmpty) ...[
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
                        customer.notes!,
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
