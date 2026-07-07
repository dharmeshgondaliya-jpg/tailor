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
          // Drawer Header
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primaryColor,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                initial,
                style: AppTextStyle.boldBlack(fontSize: 28).copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ),
            accountName: Text(
              "$userFirstName $userLastName",
              style: AppTextStyle.boldBlack(fontSize: 16).copyWith(color: Colors.white),
            ),
            accountEmail: Text(
              userEmail,
              style: AppTextStyle.regularBlack(fontSize: 14).copyWith(color: Colors.white.withValues(alpha: 0.8)),
            ),
          ),

          // Menu Items
          ListTile(
            leading: const Icon(Icons.checkroom, color: Colors.black87),
            title: Text(
              "Clothes",
              style: AppTextStyle.mediumBlack(fontSize: 14),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, Routes.clothesListingScreen);
            },
          ),
          ListTile(
            leading: const Icon(Icons.style, color: Colors.black87),
            title: Text(
              "Cloth Pairs",
              style: AppTextStyle.mediumBlack(fontSize: 14),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, Routes.pairsListingScreen);
            },
          ),

          const Spacer(),
          const Divider(),

          // Logout Item
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              "Logout",
              style: AppTextStyle.mediumBlack(fontSize: 14).copyWith(color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context); // Close drawer
              _showLogoutConfirmation(context);
            },
          ),
          const SizedBox(height: 12),
        ],
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
                Navigator.pop(context); // close dialog
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.splash,
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                "Logout",
                style: AppTextStyle.mediumBlack(fontSize: 14).copyWith(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
