import 'package:flutter/material.dart';
import 'package:tailor/App/core/constants/color_constants.dart';
import 'package:tailor/App/core/utils/app_text_style.dart';
import 'package:tailor/App/routes/app_routes.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  final String userFirstName = "John";
  final String userLastName = "Doe";
  final String userEmail = "john.doe@example.com";

  @override
  Widget build(BuildContext context) {
    final String initial = userFirstName.isNotEmpty
        ? userFirstName[0].toUpperCase()
        : '?';

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Modern Premium Drawer Header
          Container(
            padding: const EdgeInsets.only(top: 60, bottom: 24, left: 24, right: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor,
                  AppColors.secondaryColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar representation
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: AppTextStyle.boldBlack(fontSize: 26, color: AppColors.primaryColor),
                  ),
                ),
                const SizedBox(height: 16),
                // User Details
                Text(
                  "$userFirstName $userLastName",
                  style: AppTextStyle.boldBlack(fontSize: 18, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: AppTextStyle.regularBlack(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Menu Listing
          _buildDrawerItem(
            icon: Icons.checkroom_rounded,
            label: "Clothes",
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, Routes.clothesListingScreen);
            },
          ),
          _buildDrawerItem(
            icon: Icons.style_rounded,
            label: "Cloth Pairs",
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, Routes.pairsListingScreen);
            },
          ),

          const Spacer(),
          const Divider(height: 1, indent: 20, endIndent: 20),

          // Logout Item
          _buildDrawerItem(
            icon: Icons.logout_rounded,
            label: "Logout",
            iconColor: Colors.red.shade600,
            textColor: Colors.red.shade600,
            onTap: () {
              Navigator.pop(context); // Close drawer
              _showLogoutConfirmation(context);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? const Color(0xFF374151), size: 20),
        title: Text(
          label,
          style: AppTextStyle.mediumBlack(
            fontSize: 14,
            color: textColor ?? const Color(0xFF111827),
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        hoverColor: AppColors.primaryColor.withValues(alpha: 0.05),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Logout",
            style: AppTextStyle.boldBlack(fontSize: 18),
          ),
          content: Text(
            "Are you sure you want to log out?",
            style: AppTextStyle.regularBlack(fontSize: 14, color: const Color(0xFF4B5563)),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: AppTextStyle.mediumBlack(fontSize: 14, color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.splash,
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: Text(
                "Logout",
                style: AppTextStyle.mediumBlack(fontSize: 14, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
