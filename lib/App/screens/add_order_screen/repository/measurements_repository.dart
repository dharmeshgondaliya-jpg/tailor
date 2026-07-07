import '../model/customer_measurement_model.dart';

class MeasurementsRepository {
  static final List<CustomerMeasurementModel> _measurements = [
    CustomerMeasurementModel(
      id: "m1",
      customerName: "Sarah Connor",
      clothOrPairName: "Shirt & Pant",
      dateAdded: DateTime.now().subtract(const Duration(days: 5)),
      clothesMeasurements: [
        ClothMeasurement(
          clothName: "Shirt",
          values: [
            MeasurementValue(fieldName: "Length", type: "inches", value: "28"),
            MeasurementValue(fieldName: "Chest", type: "inches", value: "36"),
            MeasurementValue(fieldName: "Sleeve", type: "inches", value: "24"),
            MeasurementValue(fieldName: "Collar", type: "input", value: "Regular Fit"),
          ],
        ),
        ClothMeasurement(
          clothName: "Pant",
          values: [
            MeasurementValue(fieldName: "Length", type: "inches", value: "38"),
            MeasurementValue(fieldName: "Waist", type: "inches", value: "29"),
            MeasurementValue(fieldName: "Hip", type: "inches", value: "35"),
            MeasurementValue(fieldName: "Bottom", type: "inches", value: "15"),
          ],
        ),
      ],
    ),
    CustomerMeasurementModel(
      id: "m2",
      customerName: "Bruce Wayne",
      clothOrPairName: "Wedding Suit",
      dateAdded: DateTime.now().subtract(const Duration(days: 2)),
      clothesMeasurements: [
        ClothMeasurement(
          clothName: "Suit",
          values: [
            MeasurementValue(fieldName: "Shoulder", type: "inches", value: "19.5"),
            MeasurementValue(fieldName: "Chest", type: "inches", value: "43"),
            MeasurementValue(fieldName: "Waist", type: "inches", value: "37"),
            MeasurementValue(fieldName: "Length", type: "inches", value: "31"),
            MeasurementValue(fieldName: "Fit Type", type: "input", value: "Slim Tailored"),
          ],
        ),
      ],
    ),
    CustomerMeasurementModel(
      id: "m3",
      customerName: "Alice Smith",
      clothOrPairName: "Shirt",
      dateAdded: DateTime.now().subtract(const Duration(days: 10)),
      clothesMeasurements: [
        ClothMeasurement(
          clothName: "Shirt",
          values: [
            MeasurementValue(fieldName: "Length", type: "inches", value: "26"),
            MeasurementValue(fieldName: "Chest", type: "inches", value: "34"),
            MeasurementValue(fieldName: "Sleeve", type: "inches", value: "22"),
          ],
        ),
      ],
    ),
  ];

  List<CustomerMeasurementModel> getMeasurements() {
    return _measurements;
  }

  List<CustomerMeasurementModel> getMeasurementsForCustomer(String customerName) {
    return _measurements
        .where((m) => m.customerName.toLowerCase() == customerName.toLowerCase())
        .toList();
  }

  void addMeasurement(CustomerMeasurementModel measurement) {
    _measurements.add(measurement);
  }
}
