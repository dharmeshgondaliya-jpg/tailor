import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import 'package:tailor/App/core/constants/color_constants.dart';
import 'package:tailor/App/core/utils/app_text_style.dart';
import '../../base_screen/view/base_screen.dart';
import '../../base_screen/view/custom_appbar.dart';
import '../../../widgets/empty_view.dart';
import '../../../widgets/search_field.dart';
import '../../../widgets/animated_list_item.dart';
import '../binding/pairs_listing_screen_binding.dart';
import '../controller/pairs_listing_screen_controller.dart';
import '../model/pair_model.dart';

class PairsListingScreen extends StatekitView<PairsListingScreenController> implements PairsListingScreenBinding {
  PairsListingScreen({super.key, super.tag});

  @override
  void initState() {
    controller.binding = this;
    super.initState();
    controller.fetchInitData();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      appBar: const CustomAppbar(
        title: Text(
          "Cloth Pairs",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.navigateToAddPairs(context),
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          "Add Pair",
          style: AppTextStyle.boldBlack(fontSize: 14).copyWith(color: Colors.white),
        ),
      ),
      body: StateBuilder<PairsListingScreenController>(
        controller: controller,
        builder: (context, controller, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              SearchField(
                searchController: controller.searchController,
                onTextChange: (text) => controller.updateSearch(text),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _buildPairsContent(controller),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPairsContent(PairsListingScreenController controller) {
    if (controller.allPairs.isEmpty) {
      return const EmptyView(
        titleText: "No pairs yet",
      );
    }

    if (controller.filteredPairs.isEmpty) {
      return const EmptyView(
        titleText: "Data not found",
      );
    }

    return ListView.builder(
      itemCount: controller.filteredPairs.length,
      padding: const EdgeInsets.only(bottom: 80),
      itemBuilder: (context, index) {
        final pair = controller.filteredPairs[index];
        return AnimatedListItem(
          index: index,
          child: PairCard(
            pair: pair,
            onTap: () => controller.navigateToEditPairs(context, pair),
          ),
        );
      },
    );
  }

  @override
  void doSomething() {}
}

class PairCard extends StatelessWidget {
  final PairModel pair;
  final VoidCallback onTap;
  const PairCard({super.key, required this.pair, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.style, color: AppColors.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pair.name,
                      style: AppTextStyle.boldBlack(fontSize: 16),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              "Included Clothes (${pair.clothes.length})",
              style: AppTextStyle.mediumBlack(fontSize: 12).copyWith(color: Colors.grey.shade500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: pair.clothes.map((cloth) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.checkroom, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        cloth.name,
                        style: AppTextStyle.mediumBlack(fontSize: 12).copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    ),
  );
}
}