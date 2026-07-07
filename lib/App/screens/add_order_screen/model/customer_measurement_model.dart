class MeasurementValue {
  final String fieldName;
  final String type; // 'inches' or 'input'
  final String value;

  MeasurementValue({
    required this.fieldName,
    required this.type,
    required this.value,
  });
}

class ClothMeasurement {
  final String clothName;
  final List<MeasurementValue> values;

  ClothMeasurement({
    required this.clothName,
    required this.values,
  });
}

class CustomerMeasurementModel {
  final String id;
  final String customerName;
  final String clothOrPairName;
  final DateTime dateAdded;
  final List<ClothMeasurement> clothesMeasurements;

  CustomerMeasurementModel({
    required this.id,
    required this.customerName,
    required this.clothOrPairName,
    required this.dateAdded,
    required this.clothesMeasurements,
  });
}
