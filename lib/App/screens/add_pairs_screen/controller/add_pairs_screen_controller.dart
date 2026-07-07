import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:statekit/statekit.dart';
import '../../clothes_listing_screen/model/cloth_model.dart';
import '../../clothes_listing_screen/repository/clothes_listing_screen_repository.dart';
import '../../pairs_listing_screen/model/pair_model.dart';
import '../repository/add_pairs_screen_repository.dart';
import '../binding/add_pairs_screen_binding.dart';

class AddPairsScreenController extends StateController<AddPairsScreenBinding> {
  final AddPairsScreenRepository _repository = AddPairsScreenRepository();
  final ClothesListingScreenRepository _clothesRepository = ClothesListingScreenRepository();

  final TextEditingController nameController = TextEditingController();
  List<ClothModel> availableClothes = [];
  List<ClothModel> selectedClothes = [];

  void initData() {
    availableClothes = _clothesRepository.getClothes();
    selectedClothes = [];
    nameController.clear();
    update();
  }

  void toggleClothSelection(ClothModel cloth) {
    HapticFeedback.lightImpact();
    final index = selectedClothes.indexWhere((c) => c.id == cloth.id);
    if (index >= 0) {
      selectedClothes.removeAt(index);
    } else {
      selectedClothes.add(cloth);
    }
    update();
  }

  void savePair(BuildContext context) {
    HapticFeedback.mediumImpact();
    final pairName = nameController.text.trim();
    if (pairName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter pair name")),
      );
      return;
    }

    if (selectedClothes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one cloth for the pair")),
      );
      return;
    }

    final pair = PairModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: pairName,
      clothes: List.from(selectedClothes),
    );

    _repository.savePair(pair);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$pairName pair added successfully")),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}