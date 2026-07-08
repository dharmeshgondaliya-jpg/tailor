import '../../clothes_listing_screen/model/cloth_model.dart';
import '../../clothes_listing_screen/repository/clothes_listing_screen_repository.dart';

class AddClothesScreenRepository {
  final ClothesListingScreenRepository _listingRepository = ClothesListingScreenRepository();

  void saveCloth(ClothModel cloth) {
    _listingRepository.addCloth(cloth);
  }

  void deleteCloth(ClothModel cloth) {
    _listingRepository.deleteCloth(cloth);
  }
}