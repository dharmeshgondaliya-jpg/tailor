import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import 'package:tailor/App/core/constants/color_constants.dart';
import 'package:tailor/App/core/utils/app_text_style.dart';
import '../../base_screen/view/base_screen.dart';
import '../../base_screen/view/custom_appbar.dart';
import '../../../widgets/app_textfield.dart';
import '../binding/add_clothes_screen_binding.dart';
import '../controller/add_clothes_screen_controller.dart';
import '../../clothes_listing_screen/model/cloth_model.dart';

class AddClothesScreen extends StatekitView<AddClothesScreenController>
    implements AddClothesScreenBinding {
  AddClothesScreen({super.key, super.tag});

  @override
  void initState() {
    controller.binding = this;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is ClothModel) {
        controller.initData(cloth: args);
      } else {
        controller.initData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StateBuilder<AddClothesScreenController>(
      controller: controller,
      builder: (context, controller, child) {
        final isEditing = controller.editingCloth != null;
        return BaseScreen(
          appBar: CustomAppbar(
            title: Text(isEditing ? "Edit Cloth" : "Add Cloth"),
            actions: isEditing
                ? [
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _showDeleteConfirmation(context),
                    ),
                  ]
                : null,
          ),
          body: Column(
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
                                      textInputAction: index == controller.fields.length - 1
                                          ? TextInputAction.done
                                          : TextInputAction.next,
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Field Type Dropdown
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      height: 48,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.grey.shade300, width: 1.0),
                                        color: Colors.white,
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: field.type,
                                          isExpanded: true,
                                          icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade500),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    isEditing ? "Update Cloth" : "Save Cloth",
                    style: AppTextStyle.mediumBlack(fontSize: 14).copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Cloth", style: AppTextStyle.boldBlack(fontSize: 18)),
          content: Text(
            "Are you sure you want to delete ${controller.editingCloth?.name}? This action cannot be undone.",
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
                Navigator.pop(context); // Pop dialog
                controller.deleteCloth(context);
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
