import '../model/pair_model.dart';
import '../../clothes_listing_screen/model/cloth_model.dart';

class PairsListingScreenRepository {
  static final List<PairModel> _pairs = [
    PairModel(
      id: "1",
      name: "Office Formal",
      clothes: [
        ClothModel(
          id: "1",
          name: "Shirt",
          measurementFields: [],
        ),
        ClothModel(
          id: "2",
          name: "Pant",
          measurementFields: [],
        ),
      ],
    ),
    PairModel(
      id: "2",
      name: "Wedding Suit",
      clothes: [
        ClothModel(
          id: "1",
          name: "Shirt",
          measurementFields: [],
        ),
        ClothModel(
          id: "3",
          name: "Suit",
          measurementFields: [],
        ),
      ],
    ),
  ];

  List<PairModel> getPairs() {
    return _pairs;
  }

  void addPair(PairModel pair) {
    _pairs.add(pair);
  }
}