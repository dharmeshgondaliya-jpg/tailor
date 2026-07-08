import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import 'package:tailor/App/routes/app_routes.dart';
import '../model/pair_model.dart';
import '../repository/pairs_listing_screen_repository.dart';
import '../binding/pairs_listing_screen_binding.dart';

class PairsListingScreenController extends StateController<PairsListingScreenBinding> {
  final PairsListingScreenRepository _repository = PairsListingScreenRepository();

  final TextEditingController searchController = TextEditingController();

  List<PairModel> allPairs = [];
  List<PairModel> filteredPairs = [];

  void fetchInitData() {
    allPairs = _repository.getPairs();
    _applyFilters();
  }

  void updateSearch(String query) {
    _applyFilters();
  }

  void _applyFilters() {
    final query = searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      filteredPairs = List.from(allPairs);
    } else {
      filteredPairs = allPairs.where((pair) {
        return pair.name.toLowerCase().contains(query);
      }).toList();
    }
    update();
  }

  Future<void> navigateToAddPairs(BuildContext context) async {
    await Navigator.pushNamed(context, Routes.addPairsScreen);
    fetchInitData();
  }

  Future<void> navigateToEditPairs(BuildContext context, PairModel pair) async {
    await Navigator.pushNamed(context, Routes.addPairsScreen, arguments: pair);
    fetchInitData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}