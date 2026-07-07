import '../model/cloth_model.dart';

class ClothesListingScreenRepository {
  static final List<ClothModel> _clothes = [
    ClothModel(
      id: "1",
      name: "Shirt",
      measurementFields: [
        ClothMeasurementField(name: "Length", type: "inches"),
        ClothMeasurementField(name: "Chest", type: "inches"),
        ClothMeasurementField(name: "Sleeve", type: "inches"),
        ClothMeasurementField(name: "Collar", type: "input"),
      ],
    ),
    ClothModel(
      id: "2",
      name: "Pant",
      measurementFields: [
        ClothMeasurementField(name: "Length", type: "inches"),
        ClothMeasurementField(name: "Waist", type: "inches"),
        ClothMeasurementField(name: "Hip", type: "inches"),
        ClothMeasurementField(name: "Bottom", type: "inches"),
      ],
    ),
    ClothModel(
      id: "3",
      name: "Suit",
      measurementFields: [
        ClothMeasurementField(name: "Shoulder", type: "inches"),
        ClothMeasurementField(name: "Chest", type: "inches"),
        ClothMeasurementField(name: "Waist", type: "inches"),
        ClothMeasurementField(name: "Length", type: "inches"),
        ClothMeasurementField(name: "Fit Type", type: "input"),
      ],
    ),
  ];

  List<ClothModel> getClothes() {
    return _clothes;
  }

  void addCloth(ClothModel cloth) {
    _clothes.add(cloth);
  }
}