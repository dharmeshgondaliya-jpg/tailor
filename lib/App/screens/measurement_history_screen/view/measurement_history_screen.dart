import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:statekit/statekit.dart';
import 'package:tailor/App/core/constants/color_constants.dart';
import 'package:tailor/App/core/utils/app_text_style.dart';
import '../../base_screen/view/base_screen.dart';
import '../../base_screen/view/custom_appbar.dart';
import '../../../widgets/empty_view.dart';
import '../../../widgets/animated_list_item.dart';
import '../binding/measurement_history_screen_binding.dart';
import '../controller/measurement_history_screen_controller.dart';
import '../../add_order_screen/model/customer_measurement_model.dart';

class MeasurementHistoryScreen extends StatekitView<MeasurementHistoryScreenController>
    implements MeasurementHistoryScreenBinding {
  MeasurementHistoryScreen({super.key, super.tag});

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
        title: Text("Measurement History"),
      ),
      body: StateBuilder<MeasurementHistoryScreenController>(
        controller: controller,
        builder: (context, controller, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Search Scope Info Header
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
                      "Item: ${controller.clothOrPairName}",
                      style: AppTextStyle.mediumBlack(fontSize: 12).copyWith(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _buildHistoryContent(controller),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHistoryContent(MeasurementHistoryScreenController controller) {
    if (controller.measurements.isEmpty) {
      return const EmptyView(
        titleText: "No measurement history found",
      );
    }

    return ListView.builder(
      itemCount: controller.measurements.length,
      padding: const EdgeInsets.only(bottom: 24),
      itemBuilder: (context, index) {
        final measurement = controller.measurements[index];
        return AnimatedListItem(
          index: index,
          child: InkWell(
            onTap: () => controller.selectMeasurement(context, measurement),
            borderRadius: BorderRadius.circular(12),
            child: HistoryCard(measurement: measurement),
          ),
        );
      },
    );
  }

  @override
  void doSomething() {}
}

class HistoryCard extends StatelessWidget {
  final CustomerMeasurementModel measurement;
  const HistoryCard({super.key, required this.measurement});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.history, color: AppColors.primaryColor, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('dd MMM yyyy, hh:mm a').format(measurement.dateAdded),
                      style: AppTextStyle.boldBlack(fontSize: 13),
                    ),
                  ],
                ),
                Text(
                  "Select",
                  style: AppTextStyle.boldBlack(fontSize: 12).copyWith(color: AppColors.primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: measurement.clothesMeasurements.map((clothMeas) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clothMeas.clothName,
                        style: AppTextStyle.boldBlack(fontSize: 14).copyWith(color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: clothMeas.values.map((v) {
                          final isInches = v.type == 'inches';
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "${v.fieldName}: ${v.value}${isInches ? ' in' : ''}",
                              style: AppTextStyle.mediumBlack(fontSize: 12).copyWith(color: Colors.black87),
                            ),
                          );
                        }).toList(),
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
  }
}