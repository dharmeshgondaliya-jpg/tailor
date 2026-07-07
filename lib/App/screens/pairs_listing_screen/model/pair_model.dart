import '../../clothes_listing_screen/model/cloth_model.dart';

class PairModel {
  final String id;
  final String name;
  final List<ClothModel> clothes;

  PairModel({
    required this.id,
    required this.name,
    required this.clothes,
  });
}
