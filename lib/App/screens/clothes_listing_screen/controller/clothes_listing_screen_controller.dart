import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import 'package:tailor/App/routes/app_routes.dart';
import '../model/cloth_model.dart';
import '../repository/clothes_listing_screen_repository.dart';
import '../binding/clothes_listing_screen_binding.dart';

class ClothesListingScreenController extends StateController<ClothesListingScreenBinding> {
  final ClothesListingScreenRepository _repository = ClothesListingScreenRepository();

  final TextEditingController searchController = TextEditingController();

  List<ClothModel> allClothes = [];
  List<ClothModel> filteredClothes = [];

  void fetchInitData() {
    allClothes = _repository.getClothes();
    _applyFilters();
  }

  void updateSearch(String query) {
    _applyFilters();
  }

  void _applyFilters() {
    final query = searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      filteredClothes = List.from(allClothes);
    } else {
      filteredClothes = allClothes.where((cloth) {
        return cloth.name.toLowerCase().contains(query);
      }).toList();
    }
    update();
  }

  Future<void> navigateToAddClothes(BuildContext context) async {
    await Navigator.pushNamed(context, Routes.addClothesScreen);
    fetchInitData();
  }

  Future<void> navigateToEditClothes(BuildContext context, ClothModel cloth) async {
    await Navigator.pushNamed(context, Routes.addClothesScreen, arguments: cloth);
    fetchInitData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}