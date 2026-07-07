import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import 'package:tailor/App/core/constants/color_constants.dart';
import 'package:tailor/App/core/utils/app_text_style.dart';
import '../../base_screen/view/base_screen.dart';
import '../../base_screen/view/custom_appbar.dart';
import '../../../widgets/app_textfield.dart';
import '../binding/add_customer_screen_binding.dart';
import '../controller/add_customer_screen_controller.dart';

class AddCustomerScreen extends StatekitView<AddCustomerScreenController> implements AddCustomerScreenBinding {
  AddCustomerScreen({super.key, super.tag});

  @override
  void initState() {
    controller.binding = this;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      appBar: const CustomAppbar(
        title: Text(
          "Add Customer",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: StateBuilder<AddCustomerScreenController>(
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
                      // Name Field
                      Text(
                        "Customer Name",
                        style: AppTextStyle.semiBoldBlack(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      AppTextField(
                        controller: controller.nameController,
                        hintText: "e.g. John Doe",
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 20),

                      // Mobile Number Field
                      Text(
                        "Mobile Number",
                        style: AppTextStyle.semiBoldBlack(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      AppTextField(
                        controller: controller.phoneController,
                        hintText: "e.g. +1 555-0100",
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 20),

                      // Address Field
                      Text(
                        "Address",
                        style: AppTextStyle.semiBoldBlack(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      AppTextField(
                        controller: controller.addressController,
                        hintText: "e.g. 123 Main St, New York",
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 20),

                      // Notes Field
                      Text(
                        "Notes (Optional)",
                        style: AppTextStyle.semiBoldBlack(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      AppTextField(
                        controller: controller.notesController,
                        hintText: "e.g. Prefers slim fit designs",
                        height: 80,
                        maxLines: 3,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 24),

                      // Regular Customer Row
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Regular Customer",
                                  style: AppTextStyle.semiBoldBlack(fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Mark if this is a frequent customer",
                                  style: AppTextStyle.regularBlack(fontSize: 12).copyWith(
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: controller.isRegular,
                              activeThumbColor: AppColors.primaryColor,
                              onChanged: controller.toggleRegular,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Save Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton(
                  onPressed: () => controller.saveCustomer(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    "Save Customer",
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