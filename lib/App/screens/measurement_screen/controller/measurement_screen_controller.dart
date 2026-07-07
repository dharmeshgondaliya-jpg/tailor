import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import '../../clothes_listing_screen/model/cloth_model.dart';
import '../../pairs_listing_screen/model/pair_model.dart';
import '../../add_order_screen/model/customer_measurement_model.dart';
import '../../add_order_screen/repository/measurements_repository.dart';
import '../binding/measurement_screen_binding.dart';

class FieldEntry {
  final ClothMeasurementField field;
  final TextEditingController controller;

  FieldEntry({required this.field, required this.controller});
}

class ClothMeasurementEntry {
  final ClothModel cloth;
  final List<FieldEntry> fields;

  ClothMeasurementEntry({required this.cloth, required this.fields});
}

class MeasurementScreenController extends StateController<MeasurementScreenBinding> {
  final MeasurementsRepository _measurementsRepository = MeasurementsRepository();

  List<ClothMeasurementEntry> entries = [];
  String customerName = "";
  String clothOrPairName = "";

  void initArgs(Map<String, dynamic> args) {
    customerName = args['customerName'] ?? "";
    final selectionType = args['selectionType'] ?? "cloth";
    final item = args['item'];

    entries.clear();
    if (selectionType == 'multi' && item is List<ClothModel>) {
      clothOrPairName = item.map((c) => c.name).join(', ');
      for (final cloth in item) {
        entries.add(_createEntry(cloth));
      }
    } else if (selectionType == 'cloth' && item is ClothModel) {
      clothOrPairName = item.name;
      entries.add(_createEntry(item));
    } else if (selectionType == 'pair' && item is PairModel) {
      clothOrPairName = item.name;
      for (final cloth in item.clothes) {
        entries.add(_createEntry(cloth));
      }
    }
    update();
  }

  ClothMeasurementEntry _createEntry(ClothModel cloth) {
    // If the cloth model has no fields, we can provide a default set of fields
    final fieldsList = cloth.measurementFields.isNotEmpty
        ? cloth.measurementFields
        : [
            ClothMeasurementField(name: "Length", type: "inches"),
            ClothMeasurementField(name: "Chest", type: "inches"),
            ClothMeasurementField(name: "Waist", type: "inches"),
          ];

    final fields = fieldsList.map((f) {
      return FieldEntry(
        field: f,
        controller: TextEditingController(),
      );
    }).toList();
    return ClothMeasurementEntry(cloth: cloth, fields: fields);
  }

  void saveMeasurement(BuildContext context) {
    // Validate that all fields have non-empty values
    for (final entry in entries) {
      for (final field in entry.fields) {
        if (field.controller.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Please enter value for ${entry.cloth.name} - ${field.field.name}")),
          );
          return;
        }
      }
    }

    final clothesMeasurements = entries.map((entry) {
      final values = entry.fields.map((f) {
        return MeasurementValue(
          fieldName: f.field.name,
          type: f.field.type,
          value: f.controller.text.trim(),
        );
      }).toList();
      return ClothMeasurement(
        clothName: entry.cloth.name,
        values: values,
      );
    }).toList();

    final newMeasurement = CustomerMeasurementModel(
      id: "m_${DateTime.now().millisecondsSinceEpoch}",
      customerName: customerName,
      clothOrPairName: clothOrPairName,
      dateAdded: DateTime.now(),
      clothesMeasurements: clothesMeasurements,
    );

    _measurementsRepository.addMeasurement(newMeasurement);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Measurement saved successfully")),
    );

    Navigator.pop(context, newMeasurement);
  }

  @override
  void dispose() {
    for (final entry in entries) {
      for (final field in entry.fields) {
        field.controller.dispose();
      }
    }
    super.dispose();
  }
}