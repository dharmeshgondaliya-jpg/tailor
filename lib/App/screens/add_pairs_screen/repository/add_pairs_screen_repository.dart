import '../../pairs_listing_screen/model/pair_model.dart';
import '../../pairs_listing_screen/repository/pairs_listing_screen_repository.dart';

class AddPairsScreenRepository {
  final PairsListingScreenRepository _listingRepository = PairsListingScreenRepository();

  void savePair(PairModel pair) {
    _listingRepository.addPair(pair);
  }
}