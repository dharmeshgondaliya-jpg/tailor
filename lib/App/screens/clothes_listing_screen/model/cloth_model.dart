class ClothMeasurementField {
  String name;
  String type; // 'inches' or 'input'

  ClothMeasurementField({required this.name, this.type = 'inches'});
}

class ClothModel {
  final String id;
  final String name;
  final List<ClothMeasurementField> measurementFields;

  ClothModel({
    required this.id,
    required this.name,
    required this.measurementFields,
  });
}
