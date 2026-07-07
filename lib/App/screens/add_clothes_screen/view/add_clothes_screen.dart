import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import 'package:tailor/App/core/constants/color_constants.dart';
import 'package:tailor/App/core/utils/app_text_style.dart';
import '../../base_screen/view/base_screen.dart';
import '../../base_screen/view/custom_appbar.dart';
import '../../../widgets/app_textfield.dart';
import '../binding/add_clothes_screen_binding.dart';
import '../controller/add_clothes_screen_controller.dart';

class AddClothesScreen extends StatekitView<AddClothesScreenController>
    implements AddClothesScreenBinding {
  AddClothesScreen({super.key, super.tag});

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
          "Add Cloth",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: StateBuilder<AddClothesScreenController>(
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
                      // Cloth Name Label
                      Text("Cloth Name", style: AppTextStyle.semiBoldBlack(fontSize: 14)),
                      const SizedBox(height: 8),
                      // Cloth Name Field
                      AppTextField(
                        controller: controller.nameController,
                        hintText: "e.g. Shirt, Pant, Kurta",
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 24),

                      // Measurement Fields Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Measurement Fields",
                            style: AppTextStyle.semiBoldBlack(fontSize: 14),
                          ),
                          TextButton.icon(
                            onPressed: controller.addField,
                            icon: const Icon(Icons.add, size: 18, color: AppColors.primaryColor),
                            label: Text(
                              "Add Field",
                              style: AppTextStyle.boldBlack(
                                fontSize: 14,
                              ).copyWith(color: AppColors.primaryColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Dynamic Fields List
                      if (controller.fields.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              "No measurement fields added yet",
                              style: AppTextStyle.regularBlack(
                                fontSize: 14,
                              ).copyWith(color: Colors.grey.shade500),
                            ),
                          ),
                        )
                      else
                        Column(
                          children: List.generate(controller.fields.length, (index) {
                            final field = controller.fields[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  // Field Name input
                                  Expanded(
                                    flex: 3,
                                    child: AppTextField(
                                      controller: field.nameController,
                                      hintText: "e.g. Length, Waist",
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Field Type Dropdown
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      height: 40,
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(color: Colors.black54, width: 0.8),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: field.type,
                                          items: const [
                                            DropdownMenuItem(
                                              value: "inches",
                                              child: Text("Inches", style: TextStyle(fontSize: 13)),
                                            ),
                                            DropdownMenuItem(
                                              value: "input",
                                              child: Text("Input", style: TextStyle(fontSize: 13)),
                                            ),
                                          ],
                                          onChanged: (val) {
                                            if (val != null) {
                                              controller.updateFieldType(index, val);
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),

                                  // Remove Button
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => controller.removeField(index),
                                  ),
                                ],
                              ),
                            );
                          }),
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
                  onPressed: () => controller.saveCloth(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    "Save Cloth",
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
