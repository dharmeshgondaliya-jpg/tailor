import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import 'package:tailor/App/core/constants/color_constants.dart';
import 'package:tailor/App/core/utils/app_text_style.dart';
import '../binding/profile_page_binding.dart';
import '../controller/profile_page_controller.dart';

class ProfilePage extends StatekitView<ProfilePageController> implements ProfilePageBinding {
  ProfilePage({super.key, super.tag});

  @override
  void initState() {
    controller.binding = this;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StateBuilder<ProfilePageController>(
      controller: controller,
      builder: (context, controller, child) {
        final initial = controller.userFirstName.isNotEmpty
            ? controller.userFirstName[0].toUpperCase()
            : '?';

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Profile Header & Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryColor, width: 3),
                ),
                child: CircleAvatar(
                  radius: 54,
                  backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    initial,
                    style: AppTextStyle.boldBlack(fontSize: 44).copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "${controller.userFirstName} ${controller.userLastName}",
                style: AppTextStyle.boldBlack(fontSize: 22),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  controller.userRole,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 2. Personal Information Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                        child: Text(
                          "PERSONAL INFORMATION",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade500,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.email_outlined, color: AppColors.primaryColor),
                        title: const Text("Email Address", style: TextStyle(fontSize: 13, color: Colors.grey)),
                        subtitle: Text(
                          controller.userEmail,
                          style: AppTextStyle.mediumBlack(fontSize: 14),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.phone_outlined, color: AppColors.primaryColor),
                        title: const Text("Phone Number", style: TextStyle(fontSize: 13, color: Colors.grey)),
                        subtitle: Text(
                          controller.userPhone,
                          style: AppTextStyle.mediumBlack(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Settings List Options
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                        child: Text(
                          "APP & STORE CONFIGURATION",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade500,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.store_outlined, color: Colors.black87),
                        title: Text("Store Settings", style: AppTextStyle.mediumBlack(fontSize: 14)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.notifications_none_outlined, color: Colors.black87),
                        title: Text("Notification Preferences", style: AppTextStyle.mediumBlack(fontSize: 14)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.support_agent_outlined, color: Colors.black87),
                        title: Text("Help & Support", style: AppTextStyle.mediumBlack(fontSize: 14)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void doSomething() {}
}
