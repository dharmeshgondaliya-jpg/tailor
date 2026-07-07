import 'package:statekit/statekit.dart';
import 'package:flutter/material.dart';
import 'package:tailor/App/screens/base_screen/view/custom_appbar.dart';
import '../../../widgets/app_drawer.dart';
import '../../base_screen/view/base_screen.dart';
import '../../profile_page/view/profile_page.dart';
import '../binding/home_screen_binding.dart';
import '../controller/home_screen_controller.dart';
import '../../dashboard_page/view/dashboard_page.dart';
import '../../orders_page/view/orders_page.dart';
import '../../customers_page/view/customers_page.dart';

class HomeScreen extends StatekitView<HomeScreenController> implements HomeScreenBinding {
  HomeScreen({super.key, super.tag});

  @override
  void initState() {
    controller.binding = this;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      padding: EdgeInsets.zero,
      appBar: CustomAppbar(
        title: StateBuilder<HomeScreenController>(
          controller: controller,
          builder: (context, controller, child) {
            return Text(switch (controller.selectedIndex) {
              0 => "Dashboard",
              1 => "Orders",
              2 => "Customers",
              3 => "Profile",
              _ => "Dashboard",
            });
          },
        ),
      ),
      drawer: const AppDrawer(),
      body: StateBuilder<HomeScreenController>(
        controller: controller,
        builder: (context, controller, child) {
          return AnimatedSwitcher(
            duration: Duration(milliseconds: 400),
            child: switch (controller.selectedIndex) {
              0 => DashboardPage(),
              1 => OrdersPage(),
              2 => CustomersPage(),
              3 => ProfilePage(),
              _ => DashboardPage(),
            },
          );
        },
      ),
      bottomNavigationBar: StateBuilder<HomeScreenController>(
        controller: controller,
        builder: (context, controller, child) {
          return AnimatedSwitcher(
            duration: Duration(milliseconds: 400),
            child: BottomNavigationBar(
              currentIndex: controller.selectedIndex,
              onTap: controller.changeIndex,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_bag_outlined),
                  activeIcon: Icon(Icons.shopping_bag),
                  label: 'Orders',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_outlined),
                  activeIcon: Icon(Icons.people),
                  label: 'Customers',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void doSomething() {}
}
