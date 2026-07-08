import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:statekit/statekit.dart';
import 'package:tailor/App/core/constants/color_constants.dart';
import 'package:tailor/App/core/utils/app_text_style.dart';
import '../../base_screen/view/base_screen.dart';
import '../../base_screen/view/custom_appbar.dart';
import '../../../widgets/app_textfield.dart';
import '../binding/add_order_screen_binding.dart';
import '../controller/add_order_screen_controller.dart';
import '../../customers_page/model/customer_model.dart';
import '../../orders_page/model/order_model.dart';

class AddOrderScreen extends StatekitView<AddOrderScreenController>
    implements AddOrderScreenBinding {
  AddOrderScreen({super.key, super.tag});

  @override
  void initState() {
    controller.binding = this;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is OrderModel) {
        controller.initData(order: args);
      } else {
        controller.initData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StateBuilder<AddOrderScreenController>(
      controller: controller,
      builder: (context, controller, child) {
        final isEditing = controller.editingOrder != null;
        return BaseScreen(
          appBar: CustomAppbar(
            title: Text(
              isEditing ? "Edit Order" : "Add Order",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            actions: isEditing
                ? [
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.white),
                      onPressed: () => _showDeleteConfirmation(context),
                    ),
                  ]
                : null,
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 16, bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── 1. Customer Selector ──────────────────────────────
                      Text("Select Customer", style: AppTextStyle.semiBoldBlack(fontSize: 14)),
                      const SizedBox(height: 8),
                      _CustomerDropdown(controller: controller),
                      const SizedBox(height: 20),

                      // ── 2. Clothes / Pairs Selector (tap → bottom sheet) ──
                      Text("Select Items", style: AppTextStyle.semiBoldBlack(fontSize: 14)),
                      const SizedBox(height: 8),
                      _ItemSelectorField(
                        controller: controller,
                        onTap: () => _showItemPickerBottomSheet(context, controller),
                      ),
                      const SizedBox(height: 20),

                      // ── 3. Measurements Section ───────────────────────────
                      if (controller.selectedCustomer != null &&
                          (controller.selectedClothes.isNotEmpty ||
                              controller.selectedPairs.isNotEmpty)) ...[
                        Text(
                          "Measurement Details",
                          style: AppTextStyle.semiBoldBlack(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        _MeasurementCard(controller: controller, context: context),
                        const SizedBox(height: 24),
                      ],

                      // ── 4. Date Pickers ───────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: _DateField(
                              label: "Order Date",
                              date: controller.orderDate,
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: controller.orderDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) controller.updateOrderDate(picked);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _DateField(
                              label: "Approx Delivery",
                              date: controller.completionDate,
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: controller.completionDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) controller.updateCompletionDate(picked);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── 5. Status and Quantity ────────────────────────────
                      Row(
                        children: [
                          Expanded(child: _StatusDropdown(controller: controller)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Quantity", style: AppTextStyle.semiBoldBlack(fontSize: 14)),
                                const SizedBox(height: 8),
                                AppTextField(
                                  controller: controller.quantityController,
                                  hintText: "1",
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── 6. Labor Cost and Advance Amount ──────────────────
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Labor Cost (₹)',
                                  style: AppTextStyle.semiBoldBlack(fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                AppTextField(
                                  controller: controller.laborCostController,
                                  hintText: "e.g. 500",
                                  keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  textInputAction: TextInputAction.next,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Advance Paid (₹)',
                                  style: AppTextStyle.semiBoldBlack(fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                AppTextField(
                                  controller: controller.advanceAmountController,
                                  hintText: "e.g. 200",
                                  keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  textInputAction: TextInputAction.next,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── 6.5 Payment Status ────────────────────────────────
                      _PaymentStatusDropdown(controller: controller),
                      const SizedBox(height: 20),

                      // ── 7. Urgent Switch ──────────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.flash_on_rounded,
                                    size: 16,
                                    color: Colors.red.shade600,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Urgent Order",
                                  style: AppTextStyle.semiBoldBlack(fontSize: 14),
                                ),
                              ],
                            ),
                            Switch(
                              value: controller.isUrgent,
                              activeThumbColor: Colors.red,
                              onChanged: controller.toggleUrgent,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── 8. Notes ──────────────────────────────────────────
                      Text("Notes (Optional)", style: AppTextStyle.semiBoldBlack(fontSize: 14)),
                      const SizedBox(height: 8),
                      AppTextField(
                        controller: controller.notesController,
                        hintText: "Special stitching instructions...",
                        height: 80,
                        maxLines: 3,
                        textInputAction: TextInputAction.done,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Bottom Save Button ─────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton(
                  onPressed: () => controller.saveOrder(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    isEditing ? "Update Order" : "Save Order",
                    style: AppTextStyle.semiBoldBlack(fontSize: 15, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Item Picker Bottom Sheet
  // ─────────────────────────────────────────────────────────────────────────
  void _showItemPickerBottomSheet(BuildContext context, AddOrderScreenController ctrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _ItemPickerSheet(controller: ctrl);
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Order", style: AppTextStyle.boldBlack(fontSize: 18)),
          content: Text(
            "Are you sure you want to delete order ${controller.editingOrder?.orderNumber}? This action cannot be undone.",
            style: AppTextStyle.regularBlack(fontSize: 14).copyWith(color: Colors.grey.shade700),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: AppTextStyle.mediumBlack(fontSize: 14).copyWith(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Pop dialog
                controller.deleteOrder(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                "Delete",
                style: AppTextStyle.mediumBlack(fontSize: 14).copyWith(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void doSomething() {}
}

// ═════════════════════════════════════════════════════════════════════════════
// Item Selector Field (tappable "pill" showing selected items)
// ═════════════════════════════════════════════════════════════════════════════

class _ItemSelectorField extends StatelessWidget {
  final AddOrderScreenController controller;
  final VoidCallback onTap;

  const _ItemSelectorField({required this.controller, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasItems = controller.selectedClothes.isNotEmpty || controller.selectedPairs.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: hasItems ? AppColors.primaryColor.withValues(alpha: 0.03) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasItems ? AppColors.primaryColor.withValues(alpha: 0.4) : Colors.grey.shade300,
          ),
        ),
        child: hasItems
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pairs chips
                  if (controller.selectedPairs.isNotEmpty) ...[
                    _SectionLabel(label: "Pairs", color: Colors.amber.shade700),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: controller.selectedPairs
                          .map(
                            (p) => _SelectedChip(
                              label: p.name,
                              color: Colors.amber.shade100,
                              textColor: Colors.amber.shade800,
                              icon: Icons.join_inner_rounded,
                              onRemove: () => controller.togglePairSelection(p, false),
                            ),
                          )
                          .toList(),
                    ),
                    if (controller.selectedClothes.isNotEmpty) const SizedBox(height: 10),
                  ],
                  // Clothes chips
                  if (controller.selectedClothes.isNotEmpty) ...[
                    _SectionLabel(label: "Clothes", color: AppColors.primaryColor),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: controller.selectedClothes
                          .map(
                            (c) => _SelectedChip(
                              label: c.name,
                              color: AppColors.primaryColor.withValues(alpha: 0.1),
                              textColor: AppColors.primaryColor,
                              icon: Icons.dry_cleaning_outlined,
                              onRemove: () => controller.toggleClothSelection(c, false),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 10),
                  // Tap-to-edit hint
                  Row(
                    children: [
                      Icon(Icons.touch_app_rounded, size: 13, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        "Tap to add or remove items",
                        style: AppTextStyle.captionBlack(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.add_rounded, size: 18, color: AppColors.primaryColor),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Tap to select clothes or pairs",
                    style: AppTextStyle.regularBlack(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
              ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyle.semiBoldBlack(fontSize: 11, color: color)),
      ],
    );
  }
}

class _SelectedChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final IconData icon;
  final VoidCallback onRemove;

  const _SelectedChip({
    required this.label,
    required this.color,
    required this.textColor,
    required this.icon,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyle.mediumBlack(fontSize: 12, color: textColor)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded, size: 13, color: textColor.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Item Picker Bottom Sheet
// ═════════════════════════════════════════════════════════════════════════════

class _ItemPickerSheet extends StatefulWidget {
  final AddOrderScreenController controller;
  const _ItemPickerSheet({required this.controller});

  @override
  State<_ItemPickerSheet> createState() => _ItemPickerSheetState();
}

class _ItemPickerSheetState extends State<_ItemPickerSheet> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.controller;
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Select Items", style: AppTextStyle.boldBlack(fontSize: 18)),
                          const SizedBox(height: 2),
                          StateBuilder<AddOrderScreenController>(
                            controller: ctrl,
                            builder: (_, c, _) {
                              final total = c.selectedPairs.length + c.selectedClothes.length;
                              return Text(
                                total == 0
                                    ? "No items selected"
                                    : "$total item${total > 1 ? 's' : ''} selected",
                                style: AppTextStyle.regularBlack(
                                  fontSize: 12,
                                  color: total == 0 ? Colors.grey.shade400 : AppColors.primaryColor,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, size: 18),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),
              Divider(color: Colors.grey.shade100),

              // Scrollable list — Pairs first, then Clothes
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.58),
                child: StateBuilder<AddOrderScreenController>(
                  controller: ctrl,
                  builder: (_, c, _) {
                    return ListView(
                      padding: EdgeInsets.only(left: 16, right: 16, bottom: bottomPad + 24),
                      shrinkWrap: true,
                      children: [
                        // ── PAIRS section ──────────────────────────────────
                        if (c.pairs.isNotEmpty) ...[
                          _SheetSectionHeader(
                            label: "Pairs",
                            count: c.selectedPairs.length,
                            color: Colors.amber.shade700,
                            bgColor: Colors.amber.shade50,
                            icon: Icons.join_inner_rounded,
                          ),
                          const SizedBox(height: 8),
                          ...c.pairs.map((pair) {
                            final isSelected = c.selectedPairs.any((p) => p.name == pair.name);
                            return _ItemTile(
                              label: pair.name,
                              subtitle: "${pair.clothes.length} clothes",
                              isSelected: isSelected,
                              selectedColor: Colors.amber.shade600,
                              selectedBgColor: Colors.amber.shade50,
                              icon: Icons.join_inner_rounded,
                              onTap: () => c.togglePairSelection(pair, !isSelected),
                            );
                          }),
                          const SizedBox(height: 16),
                        ],

                        // ── CLOTHES section ────────────────────────────────
                        if (c.clothes.isNotEmpty) ...[
                          _SheetSectionHeader(
                            label: "Clothes",
                            count: c.selectedClothes.length,
                            color: AppColors.primaryColor,
                            bgColor: AppColors.primaryColor.withValues(alpha: 0.08),
                            icon: Icons.dry_cleaning_outlined,
                          ),
                          const SizedBox(height: 8),
                          ...c.clothes.map((cloth) {
                            final isSelected = c.selectedClothes.any((cl) => cl.name == cloth.name);
                            return _ItemTile(
                              label: cloth.name,
                              subtitle: null,
                              isSelected: isSelected,
                              selectedColor: AppColors.primaryColor,
                              selectedBgColor: AppColors.primaryColor.withValues(alpha: 0.06),
                              icon: Icons.dry_cleaning_outlined,
                              onTap: () => c.toggleClothSelection(cloth, !isSelected),
                            );
                          }),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Sheet Section Header
// ─────────────────────────────────────────────────────────────────────────────

class _SheetSectionHeader extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final Color bgColor;
  final IconData icon;

  const _SheetSectionHeader({
    required this.label,
    required this.count,
    required this.color,
    required this.bgColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyle.semiBoldBlack(fontSize: 14)),
        const Spacer(),
        if (count > 0)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
            child: Text(
              "$count selected",
              style: AppTextStyle.semiBoldBlack(fontSize: 11, color: color),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Item Tile (animated selection)
// ─────────────────────────────────────────────────────────────────────────────

class _ItemTile extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool isSelected;
  final Color selectedColor;
  final Color selectedBgColor;
  final IconData icon;
  final VoidCallback onTap;

  const _ItemTile({
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.selectedColor,
    required this.selectedBgColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? selectedBgColor : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? selectedColor.withValues(alpha: 0.5) : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: isSelected ? selectedColor.withValues(alpha: 0.15) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: isSelected ? selectedColor : Colors.grey.shade500),
            ),
            const SizedBox(width: 12),
            // Label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyle.mediumBlack(
                      fontSize: 14,
                      color: isSelected ? selectedColor : const Color(0xFF111827),
                    ),
                  ),
                  if (subtitle != null)
                    Text(subtitle!, style: AppTextStyle.captionBlack(fontSize: 11)),
                ],
              ),
            ),
            // Checkmark
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: isSelected
                  ? Container(
                      key: const ValueKey(true),
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(color: selectedColor, shape: BoxShape.circle),
                      child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                    )
                  : Container(
                      key: const ValueKey(false),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Measurement Card
// ═════════════════════════════════════════════════════════════════════════════

class _MeasurementCard extends StatelessWidget {
  final AddOrderScreenController controller;
  final BuildContext context;
  const _MeasurementCard({required this.controller, required this.context});

  @override
  Widget build(BuildContext context) {
    final hasMeasurement = controller.selectedMeasurement != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasMeasurement ? AppColors.primaryColor.withValues(alpha: 0.05) : Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasMeasurement
              ? AppColors.primaryColor.withValues(alpha: 0.3)
              : Colors.red.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasMeasurement ? Icons.check_circle_outline_rounded : Icons.warning_amber_rounded,
                color: hasMeasurement ? AppColors.primaryColor : Colors.red.shade600,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hasMeasurement ? "Measurement Configured" : "Measurement required",
                  style: AppTextStyle.semiBoldBlack(
                    fontSize: 13,
                    color: hasMeasurement ? AppColors.primaryColor : Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ),
          if (hasMeasurement) ...[
            const SizedBox(height: 6),
            Text(
              "Date: ${DateFormat('dd MMM yyyy').format(controller.selectedMeasurement!.dateAdded)}",
              style: AppTextStyle.regularBlack(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => controller.navigateToSelectMeasurementHistory(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: hasMeasurement ? AppColors.primaryColor : Colors.red.shade300,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    "Select History",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: hasMeasurement ? AppColors.primaryColor : Colors.red.shade700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => controller.navigateToAddNewMeasurement(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasMeasurement ? AppColors.primaryColor : Colors.red.shade600,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text(
                    "Add New",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Small reusable widgets
// ═════════════════════════════════════════════════════════════════════════════

class _CustomerDropdown extends StatelessWidget {
  final AddOrderScreenController controller;
  const _CustomerDropdown({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CustomerModel>(
          value: controller.selectedCustomer,
          hint: Text(
            "Choose a customer",
            style: AppTextStyle.regularBlack(fontSize: 13, color: Colors.grey.shade400),
          ),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade500),
          items: () {
            final dropdownItems = controller.customers.map((customer) {
              return DropdownMenuItem<CustomerModel>(
                value: customer,
                child: Text(customer.name, style: AppTextStyle.regularBlack(fontSize: 14)),
              );
            }).toList();

            if (controller.selectedCustomer != null) {
              final hasSelected = controller.customers.any((c) => c.name == controller.selectedCustomer!.name);
              if (!hasSelected) {
                dropdownItems.add(DropdownMenuItem<CustomerModel>(
                  value: controller.selectedCustomer!,
                  child: Text(controller.selectedCustomer!.name, style: AppTextStyle.regularBlack(fontSize: 14)),
                ));
              }
            }
            return dropdownItems;
          }(),
          onChanged: controller.selectCustomer,
        ),
      ),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  final AddOrderScreenController controller;
  const _StatusDropdown({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Status", style: AppTextStyle.semiBoldBlack(fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300, width: 1),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.status,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade500),
              items: const [
                DropdownMenuItem(value: "Pending", child: Text("Pending")),
                DropdownMenuItem(value: "Processing", child: Text("Processing")),
                DropdownMenuItem(value: "Ready", child: Text("Ready")),
                DropdownMenuItem(value: "Completed", child: Text("Completed")),
                DropdownMenuItem(value: "Cancelled", child: Text("Cancelled")),
              ],
              onChanged: (val) {
                if (val != null) controller.updateStatus(val);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentStatusDropdown extends StatelessWidget {
  final AddOrderScreenController controller;
  const _PaymentStatusDropdown({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Payment Status", style: AppTextStyle.semiBoldBlack(fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300, width: 1),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.paymentStatus,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade500),
              items: const [
                DropdownMenuItem(value: "Unpaid", child: Text("Unpaid")),
                DropdownMenuItem(value: "Advance", child: Text("Advance")),
                DropdownMenuItem(value: "Partial Paid", child: Text("Partial Paid")),
                DropdownMenuItem(value: "Paid", child: Text("Paid")),
              ],
              onChanged: (val) {
                if (val != null) controller.updatePaymentStatus(val);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;
  const _DateField({required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyle.semiBoldBlack(fontSize: 14)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300, width: 1),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd/MM/yyyy').format(date),
                  style: AppTextStyle.regularBlack(fontSize: 13),
                ),
                Icon(Icons.calendar_month_rounded, size: 16, color: Colors.grey.shade500),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
