import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import 'package:tailor/App/core/constants/color_constants.dart';
import 'package:tailor/App/core/utils/app_text_style.dart';
import 'package:tailor/App/routes/app_routes.dart';
import '../../base_screen/view/base_screen.dart';
import '../../base_screen/view/custom_appbar.dart';
import '../../../widgets/app_textfield.dart';
import '../binding/add_pairs_screen_binding.dart';
import '../controller/add_pairs_screen_controller.dart';
import '../../pairs_listing_screen/model/pair_model.dart';

class AddPairsScreen extends StatekitView<AddPairsScreenController> implements AddPairsScreenBinding {
  AddPairsScreen({super.key, super.tag});

  @override
  void initState() {
    controller.binding = this;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is PairModel) {
        controller.initData(pair: args);
      } else {
        controller.initData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StateBuilder<AddPairsScreenController>(
      controller: controller,
      builder: (context, controller, child) {
        final isEditing = controller.editingPair != null;
        return BaseScreen(
          appBar: CustomAppbar(
            title: Text(
              isEditing ? "Edit Pair" : "Add Pair",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            actions: isEditing
                ? [
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.white),
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
                      // Pair Name Label
                      Text(
                        "Pair Name",
                        style: AppTextStyle.semiBoldBlack(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      // Pair Name Field
                      AppTextField(
                        controller: controller.nameController,
                        hintText: "e.g. Office Wear, Casual Set",
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 24),

                      // Select Clothes Header
                      Text(
                        "Select Clothes",
                        style: AppTextStyle.semiBoldBlack(fontSize: 14),
                      ),
                      const SizedBox(height: 12),

                      // Clothes Checklist
                      if (controller.availableClothes.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Column(
                              children: [
                                Text(
                                  "No clothes available yet.",
                                  style: AppTextStyle.regularBlack(fontSize: 14).copyWith(
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      Routes.clothesListingScreen,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    "Go to Clothes Screen",
                                    style: AppTextStyle.boldBlack(fontSize: 13).copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.availableClothes.length,
                          itemBuilder: (context, index) {
                            final cloth = controller.availableClothes[index];
                            final isSelected = controller.selectedClothes.any((c) => c.id == cloth.id);
                            return Card(
                              elevation: 0,
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: isSelected
                                      ? AppColors.primaryColor
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: CheckboxListTile(
                                activeColor: AppColors.primaryColor,
                                value: isSelected,
                                title: Text(
                                  cloth.name,
                                  style: AppTextStyle.mediumBlack(fontSize: 14),
                                ),
                                subtitle: Text(
                                  "${cloth.measurementFields.length} measurement fields",
                                  style: AppTextStyle.regularBlack(fontSize: 12).copyWith(
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                onChanged: (val) {
                                  controller.toggleClothSelection(cloth);
                                },
                              ),
                            );
                          },
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
                  onPressed: () => controller.savePair(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    isEditing ? "Update Pair" : "Save Pair",
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
          title: Text("Delete Pair", style: AppTextStyle.boldBlack(fontSize: 18)),
          content: Text(
            "Are you sure you want to delete ${controller.editingPair?.name}? This action cannot be undone.",
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
                controller.deletePair(context);
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