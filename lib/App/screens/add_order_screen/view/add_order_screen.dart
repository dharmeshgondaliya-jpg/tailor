import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:statekit/statekit.dart';
import 'package:tailor/App/core/constants/color_constants.dart';
import 'package:tailor/App/core/utils/app_text_style.dart';
import '../../base_screen/view/base_screen.dart';
import '../../base_screen/view/custom_appbar.dart';
import '../../../widgets/app_textfield.dart';
import '../binding/add_order_screen_binding.dart';
import '../controller/add_order_screen_controller.dart';
import '../../customers_page/model/customer_model.dart';

class AddOrderScreen extends StatekitView<AddOrderScreenController>
    implements AddOrderScreenBinding {
  AddOrderScreen({super.key, super.tag});

  @override
  void initState() {
    controller.binding = this;
    controller.initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      appBar: const CustomAppbar(
        title: Text(
          "Add Order",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: StateBuilder<AddOrderScreenController>(
        controller: controller,
        builder: (context, controller, child) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 16, bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Customer Selector
                      Text("Select Customer", style: AppTextStyle.semiBoldBlack(fontSize: 14)),
                      const SizedBox(height: 8),
                      Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.black54, width: 0.8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<CustomerModel>(
                            value: controller.selectedCustomer,
                            hint: const Text("Choose a customer", style: TextStyle(fontSize: 14)),
                            isExpanded: true,
                            items: controller.customers.map((customer) {
                              return DropdownMenuItem(
                                value: customer,
                                child: Text(customer.name, style: const TextStyle(fontSize: 14)),
                              );
                            }).toList(),
                            onChanged: controller.selectCustomer,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Selected Items summary display
                      Text("Selected Items", style: AppTextStyle.semiBoldBlack(fontSize: 14)),
                      const SizedBox(height: 8),
                      if (controller.selectedClothes.isEmpty && controller.selectedPairs.isEmpty)
                        Text(
                          "No items selected yet",
                          style: AppTextStyle.regularBlack(
                            fontSize: 13,
                          ).copyWith(color: Colors.grey.shade500),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ...controller.selectedClothes.map((cloth) {
                              return Chip(
                                label: Text(cloth.name, style: const TextStyle(fontSize: 12)),
                                onDeleted: () => controller.toggleClothSelection(cloth, false),
                                backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              );
                            }),
                            ...controller.selectedPairs.map((pair) {
                              return Chip(
                                label: Text(
                                  "${pair.name} (Pair)",
                                  style: const TextStyle(fontSize: 12),
                                ),
                                onDeleted: () => controller.togglePairSelection(pair, false),
                                backgroundColor: Colors.amber.shade100,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              );
                            }),
                          ],
                        ),
                      const SizedBox(height: 20),

                      // 2. Select Clothes
                      Text(
                        "Select Clothes (Multiple)",
                        style: AppTextStyle.semiBoldBlack(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300, width: 0.8),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade50,
                        ),
                        child: Column(
                          children: controller.clothes.map((cloth) {
                            final isSelected = controller.selectedClothes.any(
                              (c) => c.name == cloth.name,
                            );
                            return CheckboxListTile(
                              title: Text(cloth.name, style: const TextStyle(fontSize: 13)),
                              value: isSelected,
                              activeColor: AppColors.primaryColor,
                              onChanged: (val) {
                                if (val != null) {
                                  controller.toggleClothSelection(cloth, val);
                                }
                              },
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 3. Select Pairs
                      Text(
                        "Select Pairs (Multiple)",
                        style: AppTextStyle.semiBoldBlack(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300, width: 0.8),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade50,
                        ),
                        child: Column(
                          children: controller.pairs.map((pair) {
                            final isSelected = controller.selectedPairs.any(
                              (p) => p.name == pair.name,
                            );
                            return CheckboxListTile(
                              title: Text(pair.name, style: const TextStyle(fontSize: 13)),
                              value: isSelected,
                              activeColor: AppColors.primaryColor,
                              onChanged: (val) {
                                if (val != null) {
                                  controller.togglePairSelection(pair, val);
                                }
                              },
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 4. Measurements Section
                      if (controller.selectedCustomer != null &&
                          (controller.selectedClothes.isNotEmpty ||
                              controller.selectedPairs.isNotEmpty)) ...[
                        Text(
                          "Measurement Details",
                          style: AppTextStyle.semiBoldBlack(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: controller.selectedMeasurement == null
                                ? Colors.red.shade50
                                : AppColors.primaryColor.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: controller.selectedMeasurement == null
                                  ? Colors.red.shade200
                                  : AppColors.primaryColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (controller.selectedMeasurement == null) ...[
                                Row(
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.red.shade700,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "Please configure measurements for this order",
                                        style: AppTextStyle.mediumBlack(
                                          fontSize: 13,
                                        ).copyWith(color: Colors.red.shade700),
                                      ),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline,
                                      color: AppColors.primaryColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "Measurement Configured",
                                        style: AppTextStyle.boldBlack(
                                          fontSize: 14,
                                        ).copyWith(color: AppColors.primaryColor),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Configured Date: ${DateFormat('dd MMM yyyy').format(controller.selectedMeasurement!.dateAdded)}",
                                  style: AppTextStyle.regularBlack(
                                    fontSize: 12,
                                  ).copyWith(color: Colors.grey.shade600),
                                ),
                                const SizedBox(height: 6),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: controller.selectedMeasurement!.clothesMeasurements.map((
                                    cm,
                                  ) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        "${cm.clothName}: ${cm.values.map((v) => '${v.fieldName}=${v.value}').join(', ')}",
                                        style: AppTextStyle.regularBlack(
                                          fontSize: 12,
                                        ).copyWith(color: Colors.grey.shade700),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () =>
                                          controller.navigateToSelectMeasurementHistory(context),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: controller.selectedMeasurement == null
                                              ? Colors.red.shade300
                                              : AppColors.primaryColor,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        "Select History",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: controller.selectedMeasurement == null
                                              ? Colors.red.shade700
                                              : AppColors.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          controller.navigateToAddNewMeasurement(context),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: controller.selectedMeasurement == null
                                            ? Colors.red.shade600
                                            : AppColors.primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        "Add New",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // 5. Date Pickers
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Order Date", style: AppTextStyle.semiBoldBlack(fontSize: 14)),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: controller.orderDate,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2100),
                                    );
                                    if (picked != null) controller.updateOrderDate(picked);
                                  },
                                  child: Container(
                                    height: 40,
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(color: Colors.black54, width: 0.8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          DateFormat('dd/MM/yyyy').format(controller.orderDate),
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                        const Icon(
                                          Icons.calendar_today_outlined,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Approx Delivery",
                                  style: AppTextStyle.semiBoldBlack(fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: controller.completionDate,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2100),
                                    );
                                    if (picked != null) controller.updateCompletionDate(picked);
                                  },
                                  child: Container(
                                    height: 40,
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(color: Colors.black54, width: 0.8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          DateFormat(
                                            'dd/MM/yyyy',
                                          ).format(controller.completionDate),
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                        const Icon(
                                          Icons.calendar_today_outlined,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 6. Status and Quantity
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Select Status",
                                  style: AppTextStyle.semiBoldBlack(fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 40,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: Colors.black54, width: 0.8),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: controller.status,
                                      isExpanded: true,
                                      items: const [
                                        DropdownMenuItem(
                                          value: "Pending",
                                          child: Text("Pending", style: TextStyle(fontSize: 13)),
                                        ),
                                        DropdownMenuItem(
                                          value: "Processing",
                                          child: Text("Processing", style: TextStyle(fontSize: 13)),
                                        ),
                                        DropdownMenuItem(
                                          value: "Ready",
                                          child: Text("Ready", style: TextStyle(fontSize: 13)),
                                        ),
                                        DropdownMenuItem(
                                          value: "Completed",
                                          child: Text("Completed", style: TextStyle(fontSize: 13)),
                                        ),
                                        DropdownMenuItem(
                                          value: "Cancelled",
                                          child: Text("Cancelled", style: TextStyle(fontSize: 13)),
                                        ),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) controller.updateStatus(val);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Quantity", style: AppTextStyle.semiBoldBlack(fontSize: 14)),
                                const SizedBox(height: 8),
                                AppTextField(
                                  controller: controller.quantityController,
                                  hintText: "1",
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 7. Labor Cost and Advance Amount
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Labor Cost (\$)',
                                  style: AppTextStyle.semiBoldBlack(fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                AppTextField(
                                  controller: controller.laborCostController,
                                  hintText: "e.g. 50.0",
                                  keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Advance Paid (\$)',
                                  style: AppTextStyle.semiBoldBlack(fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                AppTextField(
                                  controller: controller.advanceAmountController,
                                  hintText: "e.g. 20.0",
                                  keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 8. Urgent Switch
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Urgent Order", style: AppTextStyle.semiBoldBlack(fontSize: 14)),
                            Switch(
                              value: controller.isUrgent,
                              activeThumbColor: Colors.red,
                              onChanged: controller.toggleUrgent,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 9. Notes
                      Text("Notes (Optional)", style: AppTextStyle.semiBoldBlack(fontSize: 14)),
                      const SizedBox(height: 8),
                      AppTextField(
                        controller: controller.notesController,
                        hintText: "Special stitching instructions...",
                        height: 80,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Save Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton(
                  onPressed: () => controller.saveOrder(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    "Save Order",
                    style: AppTextStyle.mediumBlack(fontSize: 14).copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void doSomething() {}
}
