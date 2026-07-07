import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import '../../add_order_screen/model/customer_measurement_model.dart';
import '../../add_order_screen/repository/measurements_repository.dart';
import '../binding/measurement_history_screen_binding.dart';

class MeasurementHistoryScreenController extends StateController<MeasurementHistoryScreenBinding> {
  final MeasurementsRepository _repository = MeasurementsRepository();

  List<CustomerMeasurementModel> measurements = [];
  String customerName = "";
  String clothOrPairName = "";

  void initArgs(Map<String, dynamic> args) {
    customerName = args['customerName'] ?? "";
    clothOrPairName = args['clothOrPairName'] ?? "";

    final all = _repository.getMeasurements();
    measurements = all.where((m) {
      return m.customerName.toLowerCase() == customerName.toLowerCase();
    }).toList();
    
    update();
  }

  void selectMeasurement(BuildContext context, CustomerMeasurementModel measurement) {
    Navigator.pop(context, measurement);
  }
}