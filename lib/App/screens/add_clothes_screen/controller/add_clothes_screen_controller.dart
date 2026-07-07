import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import '../../clothes_listing_screen/model/cloth_model.dart';
import '../repository/add_clothes_screen_repository.dart';
import '../binding/add_clothes_screen_binding.dart';

class MeasurementFieldEdit {
  final TextEditingController nameController;
  String type; // 'inches' or 'input'

  MeasurementFieldEdit({required this.nameController, required this.type});

  void dispose() {
    nameController.dispose();
  }
}

class AddClothesScreenController extends StateController<AddClothesScreenBinding> {
  final AddClothesScreenRepository _repository = AddClothesScreenRepository();

  final TextEditingController nameController = TextEditingController();
  final List<MeasurementFieldEdit> fields = [];

  void initData() {
    // Initially 3 fields with 'inches' type
    fields.addAll([
      MeasurementFieldEdit(
        nameController: TextEditingController(text: "Length"),
        type: "inches",
      ),
      MeasurementFieldEdit(
        nameController: TextEditingController(text: "Chest"),
        type: "inches",
      ),
      MeasurementFieldEdit(
        nameController: TextEditingController(text: "Waist"),
        type: "inches",
      ),
    ]);
  }

  void addField() {
    fields.add(MeasurementFieldEdit(nameController: TextEditingController(), type: "inches"));
    update();
  }

  void removeField(int index) {
    if (index >= 0 && index < fields.length) {
      fields[index].dispose();
      fields.removeAt(index);
      update();
    }
  }

  void updateFieldType(int index, String type) {
    if (index >= 0 && index < fields.length) {
      fields[index].type = type;
      update();
    }
  }

  void saveCloth(BuildContext context) {
    final clothName = nameController.text.trim();
    if (clothName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter cloth name")));
      return;
    }

    if (fields.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("At least 1 measurement field is required")));
      return;
    }

    // Check for any empty field names
    for (int i = 0; i < fields.length; i++) {
      if (fields[i].nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Field #${i + 1} name cannot be empty")));
        return;
      }
    }

    final measurementFields = fields
        .map((f) => ClothMeasurementField(name: f.nameController.text.trim(), type: f.type))
        .toList();

    final cloth = ClothModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: clothName,
      measurementFields: measurementFields,
    );

    _repository.saveCloth(cloth);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$clothName added successfully")));

    Navigator.pop(context);
  }

  @override
  void dispose() {
    nameController.dispose();
    for (final field in fields) {
      field.dispose();
    }
    super.dispose();
  }
}
