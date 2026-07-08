import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import 'package:tailor/App/core/constants/color_constants.dart';
import 'package:tailor/App/core/utils/app_text_style.dart';
import '../../base_screen/view/base_screen.dart';
import '../../base_screen/view/custom_appbar.dart';
import '../../../widgets/empty_view.dart';
import '../../../widgets/search_field.dart';
import '../../../widgets/animated_list_item.dart';
import '../binding/clothes_listing_screen_binding.dart';
import '../controller/clothes_listing_screen_controller.dart';
import '../model/cloth_model.dart';

class ClothesListingScreen extends StatekitView<ClothesListingScreenController> implements ClothesListingScreenBinding {
  ClothesListingScreen({super.key, super.tag});

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
          "Clothes",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.navigateToAddClothes(context),
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          "Add Cloth",
          style: AppTextStyle.boldBlack(fontSize: 14).copyWith(color: Colors.white),
        ),
      ),
      body: StateBuilder<ClothesListingScreenController>(
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
                child: _buildClothesContent(controller),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildClothesContent(ClothesListingScreenController controller) {
    if (controller.allClothes.isEmpty) {
      return const EmptyView(
        titleText: "No clothes yet",
      );
    }

    if (controller.filteredClothes.isEmpty) {
      return const EmptyView(
        titleText: "Data not found",
      );
    }

    return ListView.builder(
      itemCount: controller.filteredClothes.length,
      padding: const EdgeInsets.only(bottom: 80),
      itemBuilder: (context, index) {
        final cloth = controller.filteredClothes[index];
        return AnimatedListItem(
          index: index,
          child: ClothCard(
            cloth: cloth,
            onTap: () => controller.navigateToEditClothes(context, cloth),
          ),
        );
      },
    );
  }

  @override
  void doSomething() {}
}

class ClothCard extends StatelessWidget {
  final ClothModel cloth;
  final VoidCallback onTap;
  const ClothCard({super.key, required this.cloth, required this.onTap});

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
              Text(
                cloth.name,
                style: AppTextStyle.boldBlack(fontSize: 16),
              ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              "Measurement Fields (${cloth.measurementFields.length})",
              style: AppTextStyle.mediumBlack(fontSize: 12).copyWith(color: Colors.grey.shade500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: cloth.measurementFields.map((field) {
                final isInches = field.type.toLowerCase() == 'inches';
                final chipColor = isInches ? Colors.teal : Colors.blue;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: chipColor.withValues(alpha: 0.1),
                    border: Border.all(color: chipColor.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isInches ? Icons.square_foot : Icons.edit_note,
                        size: 14,
                        color: chipColor.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${field.name} (${isInches ? 'in' : 'txt'})",
                        style: AppTextStyle.mediumBlack(fontSize: 12).copyWith(
                          color: chipColor.shade700,
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