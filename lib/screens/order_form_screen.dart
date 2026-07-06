import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../models/cloth_type.dart';
import '../models/cloth_field.dart';
import '../models/order_item.dart';
import '../models/order.dart';
import '../services/app_data.dart';
import 'customer_form_screen.dart';

class OrderFormScreen extends StatefulWidget {
  final Order? order; // If editing an existing order
  final Customer? preSelectedCustomer; // If creating directly from a customer

  const OrderFormScreen({super.key, this.order, this.preSelectedCustomer});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final AppData _appData = AppData();
  final _formKey = GlobalKey<FormState>();

  int _currentStep = 0;

  // Step 1: Customer State
  Customer? _selectedCustomer;

  // Step 2: Garments Configuration
  final List<ClothType> _selectedClothTypes = [];

  // Step 3: Dynamic Measurements State
  // Format: {ClothType.id: {Field.id: ValueString}}
  final Map<String, Map<String, String>> _measurements = {};

  // Step 4: Metadata State
  int _quantity = 1;
  double _price = 500.0;
  final TextEditingController _notesController = TextEditingController();
  DateTime _orderDate = DateTime.now();
  DateTime _completionDate = DateTime.now().add(const Duration(days: 7));
  OrderStatus _status = OrderStatus.pending;

  bool get isEditMode => widget.order != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      final o = widget.order!;
      _selectedCustomer = o.customer;
      for (var item in o.items) {
        _selectedClothTypes.add(item.clothType);
        _measurements[item.clothType.id] = Map.from(item.measurements);
      }
      _quantity = o.quantity;
      _price = o.price;
      _notesController.text = o.notes;
      _orderDate = o.orderDate;
      _completionDate = o.completionDate;
      _status = o.status;
    } else if (widget.preSelectedCustomer != null) {
      _selectedCustomer = widget.preSelectedCustomer;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _inlineAddCustomer() async {
    final result = await Navigator.push<Customer>(
      context,
      MaterialPageRoute(builder: (_) => const CustomerFormScreen()),
    );
    if (result != null) {
      setState(() {
        _selectedCustomer = result;
      });
    }
  }

  void _saveOrder() {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer first')),
      );
      setState(() => _currentStep = 0);
      return;
    }
    if (_selectedClothTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one garment for this order')),
      );
      setState(() => _currentStep = 1);
      return;
    }

    // Assemble OrderItems
    final List<OrderItem> items = [];
    for (var clothType in _selectedClothTypes) {
      final itemMeasurements = _measurements[clothType.id] ?? {};
      // Fill missing defaults
      for (var field in clothType.fields) {
        if (!itemMeasurements.containsKey(field.id)) {
          itemMeasurements[field.id] = field.defaultValue;
        }
      }
      items.add(OrderItem(clothType: clothType, measurements: itemMeasurements));
    }

    final orderData = Order(
      id: isEditMode ? widget.order!.id : DateTime.now().millisecondsSinceEpoch.toString(),
      billNumber: isEditMode ? widget.order!.billNumber : _appData.generateInvoiceNumber(),
      customer: _selectedCustomer!,
      items: items,
      quantity: _quantity,
      notes: _notesController.text.trim(),
      orderDate: _orderDate,
      completionDate: _completionDate,
      status: _status,
      price: _price,
    );

    if (isEditMode) {
      _appData.updateOrder(orderData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order updated successfully')),
      );
    } else {
      _appData.addOrder(orderData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order created successfully')),
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Order' : 'Create New Order'),
        actions: [
          if (_currentStep == 3)
            IconButton(
              icon: const Icon(Icons.check_rounded),
              onPressed: _saveOrder,
              tooltip: 'Save Order',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          type: StepperType.horizontal,
          currentStep: _currentStep,
          onStepTapped: (step) {
            setState(() {
              _currentStep = step;
            });
          },
          onStepContinue: () {
            if (_currentStep < 3) {
              setState(() {
                _currentStep += 1;
              });
            } else {
              _saveOrder();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep -= 1;
              });
            } else {
              Navigator.of(context).pop();
            }
          },
          controlsBuilder: (BuildContext context, ControlsDetails details) {
            final isLast = _currentStep == 3;
            return Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(isLast ? 'Place Order' : 'Continue'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: details.onStepCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(_currentStep == 0 ? 'Cancel' : 'Back'),
                    ),
                  ),
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text('Customer'),
              isActive: _currentStep >= 0,
              state: _selectedCustomer != null ? StepState.complete : StepState.indexed,
              content: _buildCustomerStep(),
            ),
            Step(
              title: const Text('Garments'),
              isActive: _currentStep >= 1,
              state: _selectedClothTypes.isNotEmpty ? StepState.complete : StepState.indexed,
              content: _buildGarmentsStep(),
            ),
            Step(
              title: const Text('Sizes'),
              isActive: _currentStep >= 2,
              state: _measurements.isNotEmpty ? StepState.complete : StepState.indexed,
              content: _buildMeasurementsStep(),
            ),
            Step(
              title: const Text('Details'),
              isActive: _currentStep >= 3,
              state: StepState.indexed,
              content: _buildDetailsStep(),
            ),
          ],
        ),
      ),
    );
  }

  // --- Step 1: Customer Selection ---
  Widget _buildCustomerStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Select Customer',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: _inlineAddCustomer,
              icon: const Icon(Icons.add_rounded),
              label: const Text('New Client'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_selectedCustomer != null) ...[
          // Show selected customer card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  child: Text(_selectedCustomer!.name.substring(0, 1).toUpperCase()),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedCustomer!.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mobile: ${_selectedCustomer!.mobile}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      _selectedCustomer = null;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Search directory to choose customer
        Text(
          'Select from Directory:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]),
        ),
        const SizedBox(height: 10),
        Container(
          constraints: const BoxConstraints(maxHeight: 250),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ValueListenableBuilder<List<Customer>>(
            valueListenable: _appData.customers,
            builder: (context, customers, child) {
              if (customers.isEmpty) {
                return const Center(child: Text('No customers found. Create one.'));
              }
              return ListView.separated(
                shrinkWrap: true,
                itemCount: customers.length,
                separatorBuilder: (_, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final c = customers[index];
                  final isSel = _selectedCustomer?.id == c.id;
                  return ListTile(
                    title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(c.mobile, style: const TextStyle(fontSize: 12)),
                    trailing: isSel
                        ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary)
                        : null,
                    selected: isSel,
                    onTap: () {
                      setState(() {
                        _selectedCustomer = c;
                      });
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // --- Step 2: Garment Composition (Single or Custom Pair) ---
  Widget _buildGarmentsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Garments',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Select one or multiple items to bundle them together (e.g. Shirt + Pant pair).',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 16),

        // Display current compilation
        if (_selectedClothTypes.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Compiled Order Items:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _selectedClothTypes.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final cloth = entry.value;
                    return InputChip(
                      label: Text(cloth.name),
                      onDeleted: () {
                        setState(() {
                          _selectedClothTypes.removeAt(idx);
                        });
                      },
                      deleteIconColor: Colors.red[400],
                      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Available Garment list
        ValueListenableBuilder<List<ClothType>>(
          valueListenable: _appData.clothTypes,
          builder: (context, types, child) {
            return Column(
              children: types.map((type) {
                final isAdded = _selectedClothTypes.any((t) => t.id == type.id);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isAdded ? Theme.of(context).colorScheme.primary : Colors.grey.shade200,
                      width: isAdded ? 1.5 : 1,
                    ),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.checkroom_rounded),
                    title: Text(type.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${type.fields.length} measurement parameters'),
                    trailing: isAdded
                        ? Icon(Icons.remove_circle_outline_rounded, color: Colors.red[400])
                        : Icon(Icons.add_circle_outline_rounded, color: Theme.of(context).colorScheme.primary),
                    onTap: () {
                      setState(() {
                        if (isAdded) {
                          _selectedClothTypes.removeWhere((t) => t.id == type.id);
                        } else {
                          _selectedClothTypes.add(type);
                        }
                      });
                    },
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  // --- Step 3: Measurement Entry ---
  Widget _buildMeasurementsStep() {
    if (_selectedClothTypes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('Please select at least one garment template in the previous step.'),
        ),
      );
    }

    return DefaultTabController(
      length: _selectedClothTypes.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Record Measurements',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Provide dimensions in inches or write text specs for each garment.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // Tab Bar for each garment
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: _selectedClothTypes.map((type) => Tab(text: type.name)).toList(),
          ),
          const SizedBox(height: 16),

          // Tab views
          SizedBox(
            height: 400,
            child: TabBarView(
              children: _selectedClothTypes.map((type) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: type.fields.length,
                  itemBuilder: (context, idx) {
                    final field = type.fields[idx];
                    return _buildMeasurementFieldRow(type, field);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementFieldRow(ClothType type, ClothField field) {
    // Current value
    if (!_measurements.containsKey(type.id)) {
      _measurements[type.id] = {};
    }
    final fieldMap = _measurements[type.id]!;
    if (!fieldMap.containsKey(field.id)) {
      fieldMap[field.id] = field.defaultValue.isNotEmpty ? field.defaultValue : (field.type == ClothFieldType.inches ? '30' : '');
    }
    final currentVal = fieldMap[field.id]!;

    if (field.type == ClothFieldType.text) {
      // Text Field Row
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: TextFormField(
          initialValue: currentVal,
          decoration: InputDecoration(
            labelText: field.name,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.edit_note_rounded),
          ),
          onChanged: (val) {
            setState(() {
              _measurements[type.id]![field.id] = val;
            });
          },
        ),
      );
    } else {
      // Inches Slider / Tape Ruler selector
      double valDouble = double.tryParse(currentVal) ?? 30.0;
      if (valDouble < 5) valDouble = 5;
      if (valDouble > 80) valDouble = 80;

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  field.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$currentVal inches',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                  onPressed: () {
                    final newVal = (valDouble - 0.5).clamp(5.0, 80.0);
                    setState(() {
                      _measurements[type.id]![field.id] = newVal.toString();
                    });
                  },
                ),
                Expanded(
                  child: Slider(
                    value: valDouble,
                    min: 5,
                    max: 80,
                    divisions: 150, // 0.5 inch divisions
                    label: '$currentVal"',
                    onChanged: (newVal) {
                      setState(() {
                        _measurements[type.id]![field.id] = newVal.toStringAsFixed(1);
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  onPressed: () {
                    final newVal = (valDouble + 0.5).clamp(5.0, 80.0);
                    setState(() {
                      _measurements[type.id]![field.id] = newVal.toString();
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  // --- Step 4: Metadata (Scheduling & pricing) ---
  Widget _buildDetailsStep() {
    final orderDateStr = '${_orderDate.day}/${_orderDate.month}/${_orderDate.year}';
    final deliveryDateStr = '${_completionDate.day}/${_completionDate.month}/${_completionDate.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Scheduling & Pricing',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        // Quantity Input
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Quantity / Pairs',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                  onPressed: () {
                    if (_quantity > 1) {
                      setState(() {
                        _quantity--;
                      });
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    '$_quantity',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  onPressed: () {
                    setState(() {
                      _quantity++;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Price Input
        TextFormField(
          initialValue: _price.toStringAsFixed(0),
          decoration: InputDecoration(
            labelText: 'Stitching Charge / Price (₹) *',
            prefixIcon: const Icon(Icons.currency_rupee_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a pricing amount';
            }
            if (double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
          onChanged: (val) {
            _price = double.tryParse(val) ?? 0.0;
          },
        ),
        const SizedBox(height: 16),

        // Order Date Picker
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          leading: const Icon(Icons.calendar_month_rounded),
          title: const Text('Order Date'),
          trailing: Text(
            orderDateStr,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _orderDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (picked != null) {
              setState(() {
                _orderDate = picked;
              });
            }
          },
        ),
        const SizedBox(height: 12),

        // Delivery Date Picker
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          leading: const Icon(Icons.event_available_rounded, color: Colors.orange),
          title: const Text('Target Delivery Date'),
          trailing: Text(
            deliveryDateStr,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.orange),
          ),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _completionDate,
              firstDate: _orderDate,
              lastDate: DateTime(2030),
            );
            if (picked != null) {
              setState(() {
                _completionDate = picked;
              });
            }
          },
        ),
        const SizedBox(height: 16),

        // Status Dropdown
        DropdownButtonFormField<OrderStatus>(
          value: _status,
          decoration: InputDecoration(
            labelText: 'Order Status',
            prefixIcon: const Icon(Icons.info_outline_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: OrderStatus.values.map((status) {
            return DropdownMenuItem(
              value: status,
              child: Text(status.label),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _status = val;
              });
            }
          },
        ),
        const SizedBox(height: 16),

        // Notes Input
        TextFormField(
          controller: _notesController,
          decoration: InputDecoration(
            labelText: 'General Special Instructions',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: 'Any specific instructions (e.g. urgent, extra buttons, client lining material).',
          ),
          maxLines: 3,
        ),
      ],
    );
  }
}
