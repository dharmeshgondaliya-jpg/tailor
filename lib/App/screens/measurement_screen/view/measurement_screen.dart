import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import 'package:tailor/App/core/constants/color_constants.dart';
import 'package:tailor/App/core/utils/app_text_style.dart';
import '../../base_screen/view/base_screen.dart';
import '../../base_screen/view/custom_appbar.dart';
import '../../../widgets/app_textfield.dart';
import '../binding/measurement_screen_binding.dart';
import '../controller/measurement_screen_controller.dart';

class MeasurementScreen extends StatekitView<MeasurementScreenController> implements MeasurementScreenBinding {
  MeasurementScreen({super.key, super.tag});

  @override
  void initState() {
    controller.binding = this;
    super.initState();
    // Fetch arguments and pass to controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        controller.initArgs(args);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      appBar: const CustomAppbar(
        title: Text(
          "New Measurement",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: StateBuilder<MeasurementScreenController>(
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
                      // Customer Scope Header Info
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Customer: ${controller.customerName}",
                              style: AppTextStyle.boldBlack(fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Cloth/Pair: ${controller.clothOrPairName}",
                              style: AppTextStyle.mediumBlack(fontSize: 12).copyWith(color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // List of clothes and their fields
                      ...controller.entries.map((entry) {
                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.checkroom, color: AppColors.primaryColor, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      entry.cloth.name,
                                      style: AppTextStyle.boldBlack(fontSize: 15),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Divider(),
                                const SizedBox(height: 12),
                                Column(
                                  children: entry.fields.map((fEntry) {
                                    final isInches = fEntry.field.type == 'inches';
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              fEntry.field.name,
                                              style: AppTextStyle.mediumBlack(fontSize: 14),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            flex: 3,
                                            child: AppTextField(
                                              controller: fEntry.controller,
                                              hintText: isInches
                                                  ? "Value (in)"
                                                  : "Value (text)",
                                              keyboardType: isInches
                                                  ? const TextInputType.numberWithOptions(decimal: true)
                                                  : TextInputType.text,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // Bottom Save Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton(
                  onPressed: () => controller.saveMeasurement(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    "Save Measurement",
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