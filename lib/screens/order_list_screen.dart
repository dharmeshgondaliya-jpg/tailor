import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/app_data.dart';
import 'order_detail_screen.dart';
import 'order_form_screen.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final AppData _appData = AppData();
  String _searchQuery = '';
  OrderStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search Bar & Filter Chips
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by client name or invoice #...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
          ),

          // Horizontal Status Filter Chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                FilterChip(
                  label: const Text('All Orders'),
                  selected: _statusFilter == null,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _statusFilter = null;
                      });
                    }
                  },
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                const SizedBox(width: 8),
                ...OrderStatus.values.map((status) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(status.label),
                      selected: _statusFilter == status,
                      onSelected: (selected) {
                        setState(() {
                          _statusFilter = selected ? status : null;
                        });
                      },
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Order List Content
          Expanded(
            child: ValueListenableBuilder<List<Order>>(
              valueListenable: _appData.orders,
              builder: (context, orders, child) {
                final filtered = orders.where((o) {
                  // Search query filter
                  final nameMatch = o.customer.name.toLowerCase().contains(_searchQuery.toLowerCase());
                  final billMatch = o.billNumber.toLowerCase().contains(_searchQuery.toLowerCase());
                  final queryMatches = nameMatch || billMatch;

                  // Status filter
                  final statusMatches = _statusFilter == null || o.status == _statusFilter;

                  return queryMatches && statusMatches;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No orders found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _statusFilter != null
                              ? 'No orders matching the status "${_statusFilter!.label}".'
                              : 'Tap the "+" button to create your first order.',
                          style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 80.0),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final order = filtered[index];
                    return _buildOrderCard(context, order);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const OrderFormScreen(),
            ),
          );
        },
        tooltip: 'New Order',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
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

    final formattedDate = '${order.completionDate.day}/${order.completionDate.month}/${order.completionDate.year}';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isOverdue = order.status != OrderStatus.delivered &&
        order.status != OrderStatus.completed &&
        order.completionDate.isBefore(today);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailScreen(order: order),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Name, Bill Code & Total Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      order.customer.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '₹${order.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.billNumber,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  if (order.quantity > 1)
                    Text(
                      'Qty: ${order.quantity}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 1),
              const SizedBox(height: 12),

              // Items Summary
              Row(
                children: [
                  Icon(Icons.checkroom_rounded, size: 16, color: Colors.grey[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.itemsSummary,
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (order.isPair)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'PAIR',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.indigo[800]),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Status and Dates
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.event_rounded,
                        size: 14,
                        color: isOverdue ? Colors.red[400] : Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Due: $formattedDate',
                        style: TextStyle(
                          color: isOverdue ? Colors.red[600] : Colors.grey[600],
                          fontSize: 12,
                          fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (isOverdue) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'LATE',
                            style: TextStyle(fontSize: 9, color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ]
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.status.label,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
