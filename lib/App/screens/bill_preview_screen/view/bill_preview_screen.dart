import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:statekit/statekit.dart';
import 'package:tailor/App/core/constants/color_constants.dart';
import 'package:tailor/App/core/utils/app_text_style.dart';
import 'package:tailor/App/screens/customers_page/model/customer_model.dart';
import '../../base_screen/view/base_screen.dart';
import '../../base_screen/view/custom_appbar.dart';
import '../binding/bill_preview_screen_binding.dart';
import '../controller/bill_preview_screen_controller.dart';

class BillPreviewScreen extends StatekitView<BillPreviewScreenController> implements BillPreviewScreenBinding {
  BillPreviewScreen({super.key, super.tag});

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

    return StateBuilder<BillPreviewScreenController>(
      controller: controller,
      builder: (context, controller, child) {
        final customer = controller.customer;

        return BaseScreen(
          appBar: const CustomAppbar(
            title: Text("Invoice Preview"),
          ),
          padding: EdgeInsets.zero,
          bottomNavigationBar: Container(
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
              onPressed: controller.printBill,
              icon: const Icon(Icons.print_rounded, color: Colors.white),
              label: const Text(
                "Print Bill (PDF)",
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
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Shop Logo/Name Header
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.store_rounded, size: 48, color: AppColors.primaryColor),
                          const SizedBox(height: 8),
                          Text(
                            "STITCH & STYLE STUDIO",
                            style: AppTextStyle.boldBlack(fontSize: 18).copyWith(letterSpacing: 1.2),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "High Quality Bespoke Tailoring & Alterations",
                            style: AppTextStyle.regularBlack(fontSize: 11).copyWith(
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Invoice Metadata
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "BILL TO",
                              style: AppTextStyle.mediumBlack(fontSize: 11).copyWith(color: Colors.grey.shade500),
                            ),
                            const SizedBox(height: 6),
                            Text(customer.name, style: AppTextStyle.boldBlack(fontSize: 15)),
                            const SizedBox(height: 4),
                            Text(customer.phone, style: AppTextStyle.regularBlack(fontSize: 13)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "INVOICE DATE",
                              style: AppTextStyle.mediumBlack(fontSize: 11).copyWith(color: Colors.grey.shade500),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              DateFormat('dd/MM/yyyy').format(DateTime.now()),
                              style: AppTextStyle.boldBlack(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Invoice Items Header
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              "Item Details",
                              style: AppTextStyle.boldBlack(fontSize: 12).copyWith(color: Colors.grey.shade700),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              "Qty",
                              textAlign: TextAlign.center,
                              style: AppTextStyle.boldBlack(fontSize: 12).copyWith(color: Colors.grey.shade700),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "Rate",
                              textAlign: TextAlign.right,
                              style: AppTextStyle.boldBlack(fontSize: 12).copyWith(color: Colors.grey.shade700),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "Amount",
                              textAlign: TextAlign.right,
                              style: AppTextStyle.boldBlack(fontSize: 12).copyWith(color: Colors.grey.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Invoice Items List
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.unpaidOrders.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final order = controller.unpaidOrders[index];
                        final amount = order.laborCost * order.quantity;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(order.orderNumber, style: AppTextStyle.boldBlack(fontSize: 13)),
                                    const SizedBox(height: 4),
                                    Text(
                                      order.clothesName,
                                      style: AppTextStyle.regularBlack(fontSize: 12).copyWith(color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  order.quantity.toString(),
                                  textAlign: TextAlign.center,
                                  style: AppTextStyle.regularBlack(fontSize: 13),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  "₹${order.laborCost.toStringAsFixed(0)}",
                                  textAlign: TextAlign.right,
                                  style: AppTextStyle.regularBlack(fontSize: 13),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  "₹${amount.toStringAsFixed(0)}",
                                  textAlign: TextAlign.right,
                                  style: AppTextStyle.boldBlack(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Financial Summary Block
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 220,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Subtotal", style: AppTextStyle.regularBlack(fontSize: 13).copyWith(color: Colors.grey.shade600)),
                                  Text("₹${controller.subtotal.toStringAsFixed(0)}", style: AppTextStyle.mediumBlack(fontSize: 13)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Advance Paid", style: AppTextStyle.regularBlack(fontSize: 13).copyWith(color: Colors.grey.shade600)),
                                  Text("-₹${controller.advancePaid.toStringAsFixed(0)}", style: AppTextStyle.mediumBlack(fontSize: 13).copyWith(color: Colors.green)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Divider(),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Balance Due", style: AppTextStyle.boldBlack(fontSize: 14)),
                                  Text(
                                    "₹${controller.balanceDue.toStringAsFixed(0)}",
                                    style: AppTextStyle.boldBlack(fontSize: 16).copyWith(color: Colors.red),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void doSomething() {}
}
