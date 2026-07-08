import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  ClothModel? editingCloth;

  void initData({ClothModel? cloth}) {
    nameController.clear();
    for (final field in fields) {
      field.dispose();
    }
    fields.clear();

    if (cloth != null) {
      editingCloth = cloth;
      nameController.text = cloth.name;
      for (final f in cloth.measurementFields) {
        fields.add(
          MeasurementFieldEdit(
            nameController: TextEditingController(text: f.name),
            type: f.type,
          ),
        );
      }
    } else {
      editingCloth = null;
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
    update();
  }

  void addField() {
    HapticFeedback.lightImpact();
    fields.add(MeasurementFieldEdit(nameController: TextEditingController(), type: "inches"));
    update();
  }

  void removeField(int index) {
    HapticFeedback.lightImpact();
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
    HapticFeedback.mediumImpact();
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

    final isEditing = editingCloth != null;

    final cloth = ClothModel(
      id: editingCloth?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: clothName,
      measurementFields: measurementFields,
    );

    _repository.saveCloth(cloth);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$clothName ${isEditing ? 'updated' : 'added'} successfully")),
    );

    Navigator.pop(context);
  }

  void deleteCloth(BuildContext context) {
    HapticFeedback.mediumImpact();
    final cloth = editingCloth;
    if (cloth != null) {
      _repository.deleteCloth(cloth);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${cloth.name} deleted successfully")),
      );
      Navigator.pop(context);
    }
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
