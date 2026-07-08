import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tailor/App/core/constants/color_constants.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppbar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.bottom,
  });

  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: AppBar(
        backgroundColor: AppColors.backgroundColor,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        foregroundColor: const Color(0xFF1F2937),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: centerTitle,
        iconTheme: const IconThemeData(
          color: Color(0xFF1F2937),
        ),
        leading: leading,
        titleTextStyle: const TextStyle(
          color: Color(0xFF1F2937),
          fontWeight: FontWeight.w700,
          fontSize: 20,
          letterSpacing: -0.3,
        ),
        title: title,
        actions: actions != null
            ? [
                ...actions!.map(
                  (action) => _StyledAction(child: action),
                ),
                const SizedBox(width: 8),
              ]
            : null,
        bottom: bottom,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );
}

/// Wraps each action widget with consistent styling
class _StyledAction extends StatelessWidget {
  const _StyledAction({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // If it's an IconButton, we wrap so the icon inherits dark color
    return Theme(
      data: Theme.of(context).copyWith(
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
      ),
      child: child,
    );
  }
}