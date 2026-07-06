import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/cloth_field.dart';
import '../services/app_data.dart';
import 'order_form_screen.dart';
import 'bill_pdf_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final AppData _appData = AppData();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Order>>(
      valueListenable: _appData.orders,
      builder: (context, orders, child) {
        // Find current version of order from database
        final Order order;
        try {
          order = orders.firstWhere((o) => o.id == widget.order.id);
        } catch (_) {
          // If deleted, pop the screen safely
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
          });
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final orderDateStr = '${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}';
        final deliveryDateStr = '${order.completionDate.day}/${order.completionDate.month}/${order.completionDate.year}';

        Color statusColor;
        switch (order.status) {
          case OrderStatus.pending:
            statusColor = Colors.orange;
            break;
          case OrderStatus.inProgress:
            statusColor = Colors.blue;
            break;
          case OrderStatus.completed:
            statusColor = Colors.green;
            break;
          case OrderStatus.delivered:
            statusColor = Colors.grey;
            break;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(order.billNumber),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                tooltip: 'Edit Order',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderFormScreen(order: order),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                tooltip: 'Delete Order',
                onPressed: () => _showDeleteConfirmation(context, order),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header details
                Card(
                  elevation: 0,
                  color: statusColor.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: statusColor.withOpacity(0.2)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bill Amount',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₹${order.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                order.status.label.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoColumn('Order Date', orderDateStr),
                            _buildInfoColumn('Delivery Target', deliveryDateStr),
                            _buildInfoColumn('Quantity', '${order.quantity}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Customer Info Card
                Text(
                  'Client Directory',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                      child: Text(
                        order.customer.name.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(order.customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(order.customer.mobile),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                ),
                const SizedBox(height: 24),

                // Quick Status Updater
                Text(
                  'Update Status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: OrderStatus.values.map((s) {
                    final isCurrent = order.status == s;
                    Color btnColor;
                    switch (s) {
                      case OrderStatus.pending:
                        btnColor = Colors.orange;
                        break;
                      case OrderStatus.inProgress:
                        btnColor = Colors.blue;
                        break;
                      case OrderStatus.completed:
                        btnColor = Colors.green;
                        break;
                      case OrderStatus.delivered:
                        btnColor = Colors.grey;
                        break;
                    }
                    return ChoiceChip(
                      label: Text(s.label),
                      selected: isCurrent,
                      onSelected: (selected) {
                        if (selected) {
                          _appData.updateOrder(order.copyWith(status: s));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Order marked as ${s.label}')),
                          );
                        }
                      },
                      labelStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isCurrent ? Colors.white : Colors.grey[700],
                      ),
                      selectedColor: btnColor,
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Items & Measurements Breakdown
                Text(
                  'Garments & Measurements',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...order.items.map((item) => _buildGarmentMeasurementsCard(context, item)),
                const SizedBox(height: 16),

                // Special Notes
                if (order.notes.isNotEmpty) ...[
                  Text(
                    'Special Instructions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.shade200.withOpacity(0.5)),
                    ),
                    child: Text(
                      order.notes,
                      style: TextStyle(color: Colors.grey[800], fontSize: 13, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // Action Footers: Generate PDF
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BillPdfScreen(order: order),
                        ),
                      );
                    },
                    icon: const Icon(Icons.picture_as_pdf_rounded),
                    label: const Text('Generate Invoice / PDF Bill'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildGarmentMeasurementsCard(BuildContext context, OrderItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                Icon(Icons.square_foot_rounded, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  item.clothType.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Measurements list
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: item.clothType.fields.length,
              itemBuilder: (context, idx) {
                final field = item.clothType.fields[idx];
                final value = item.measurements[field.id] ?? '—';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        field.name,
                        style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500),
                      ),
                      Text(
                        field.type == ClothFieldType.inches ? '$value"' : value,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Order?'),
          content: Text(
            'Are you sure you want to delete order ${order.billNumber}? This action is permanent.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                _appData.deleteOrder(order.id);
                // We pop dialog. The list notifier will pop the details screen automatically since we handle it in build!
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Order ${order.billNumber} deleted')),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
