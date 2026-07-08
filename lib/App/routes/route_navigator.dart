import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import './app_routes.dart';
import '../screens/home_screen/controller/home_screen_controller.dart';
import '../screens/home_screen/view/home_screen.dart';
import '../screens/splash_screen/view/splash_screen.dart';
import '../screens/dashboard_page/controller/dashboard_page_controller.dart';
import '../screens/orders_page/controller/orders_page_controller.dart';
import '../screens/customers_page/controller/customers_page_controller.dart';
import '../screens/add_order_screen/view/add_order_screen.dart';
import '../screens/add_order_screen/controller/add_order_screen_controller.dart';
import '../screens/add_customer_screen/view/add_customer_screen.dart';
import '../screens/add_customer_screen/controller/add_customer_screen_controller.dart';
import '../screens/profile_page/controller/profile_page_controller.dart';
import '../screens/add_clothes_screen/view/add_clothes_screen.dart';
import '../screens/add_clothes_screen/controller/add_clothes_screen_controller.dart';
import '../screens/clothes_listing_screen/view/clothes_listing_screen.dart';
import '../screens/clothes_listing_screen/controller/clothes_listing_screen_controller.dart';
import '../screens/add_pairs_screen/view/add_pairs_screen.dart';
import '../screens/add_pairs_screen/controller/add_pairs_screen_controller.dart';
import '../screens/pairs_listing_screen/view/pairs_listing_screen.dart';
import '../screens/pairs_listing_screen/controller/pairs_listing_screen_controller.dart';
import '../screens/measurement_screen/view/measurement_screen.dart';
import '../screens/measurement_screen/controller/measurement_screen_controller.dart';
import '../screens/measurement_history_screen/view/measurement_history_screen.dart';
import '../screens/measurement_history_screen/controller/measurement_history_screen_controller.dart';
import '../screens/customer_details_screen/view/customer_details_screen.dart';
import '../screens/customer_details_screen/controller/customer_details_screen_controller.dart';
import '../screens/bill_preview_screen/view/bill_preview_screen.dart';
import '../screens/bill_preview_screen/controller/bill_preview_screen_controller.dart';

abstract class RouteNavigator {
  static final Map<String, Widget Function(BuildContext)> routes = {
    Routes.splash: (BuildContext context) => const SplashScreen(),
    Routes.homeScreen: (BuildContext context) => StateProvider.multi(
      stateProviders: [
        StatekitProvider(create: () => HomeScreenController()),
        StatekitProvider(create: () => DashboardPageController()),
        StatekitProvider(create: () => OrdersPageController()),
        StatekitProvider(create: () => CustomersPageController()),
        StatekitProvider(create: () => ProfilePageController()),
      ],
      child: HomeScreen(),
    ),
    Routes.addOrderScreen: (BuildContext context) => StateProvider(
      stateProvider: StatekitProvider(create: () => AddOrderScreenController()),
      child: AddOrderScreen(),
    ),
    Routes.addCustomerScreen: (BuildContext context) => StateProvider(
      stateProvider: StatekitProvider(
        create: () => AddCustomerScreenController(),
      ),
      child: AddCustomerScreen(),
    ),
    Routes.addClothesScreen: (BuildContext context) => StateProvider(
      stateProvider: StatekitProvider(
        create: () => AddClothesScreenController(),
      ),
      child: AddClothesScreen(),
    ),
    Routes.clothesListingScreen: (BuildContext context) => StateProvider(
      stateProvider: StatekitProvider(
        create: () => ClothesListingScreenController(),
      ),
      child: ClothesListingScreen(),
    ),
    Routes.addPairsScreen: (BuildContext context) => StateProvider(
      stateProvider: StatekitProvider(create: () => AddPairsScreenController()),
      child: AddPairsScreen(),
    ),
    Routes.pairsListingScreen: (BuildContext context) => StateProvider(
      stateProvider: StatekitProvider(
        create: () => PairsListingScreenController(),
      ),
      child: PairsListingScreen(),
    ),
    Routes.measurementScreen: (BuildContext context) => StateProvider(
      stateProvider: StatekitProvider(
        create: () => MeasurementScreenController(),
      ),
      child: MeasurementScreen(),
    ),
    Routes.measurementHistoryScreen: (BuildContext context) => StateProvider(
      stateProvider: StatekitProvider(
        create: () => MeasurementHistoryScreenController(),
      ),
      child: MeasurementHistoryScreen(),
    ),
    Routes.customerDetailsScreen: (BuildContext context) => StateProvider(
      stateProvider: StatekitProvider(
        create: () => CustomerDetailsScreenController(),
      ),
      child: CustomerDetailsScreen(),
    ),
    Routes.billPreviewScreen: (BuildContext context) => StateProvider(
      stateProvider: StatekitProvider(
        create: () => BillPreviewScreenController(),
      ),
      child: BillPreviewScreen(),
    ),
  };
}
