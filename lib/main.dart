import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/order_list_screen.dart';
import 'screens/customer_list_screen.dart';
import 'screens/cloth_type_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TailorApp());
}

class TailorApp extends StatelessWidget {
  const TailorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Golden Stitch Tailors',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light, // Default to a gorgeous warm light theme
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          primary: Colors.indigo[900]!,
          secondary: const Color(0xFFD4AF37), // Tailoring Gold
          surface: const Color(0xFFFAF9F6), // Warm Alabaster
        ),
        scaffoldBackgroundColor: const Color(0xFFFAF9F6),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFFAF9F6),
          foregroundColor: Colors.indigo[900]!,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.indigo[900]!,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade100, width: 1),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(color: Colors.grey[700], fontSize: 14),
          floatingLabelStyle: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo[900]!,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.indigo[900]!,
            side: BorderSide(color: Colors.indigo[900]!, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.grey.shade100,
          selectedColor: Colors.indigo[50],
          checkmarkColor: Colors.indigo[900],
          side: BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
      home: const TailorAppShell(),
    );
  }
}

class TailorAppShell extends StatefulWidget {
  const TailorAppShell({super.key});

  @override
  State<TailorAppShell> createState() => _TailorAppShellState();
}

class _TailorAppShellState extends State<TailorAppShell> {
  int _currentIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(
        onViewOrders: () => _setIndex(1),
        onViewCustomers: () => _setIndex(2),
      ),
      const OrderListScreen(),
      const CustomerListScreen(),
      const ClothTypeListScreen(),
    ];
  }

  void _setIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width >= 720;

    final String appBarTitle;
    switch (_currentIndex) {
      case 0:
        appBarTitle = 'Golden Stitch';
        break;
      case 1:
        appBarTitle = 'Orders Worklist';
        break;
      case 2:
        appBarTitle = 'Customer Directory';
        break;
      case 3:
        appBarTitle = 'Cloth Blueprints';
        break;
      default:
        appBarTitle = 'Tailor App';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appBarTitle,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          // Theme toggles or static business branding
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Icon(Icons.brightness_1_rounded, color: theme.colorScheme.secondary, size: 10),
                const SizedBox(width: 4),
                Text(
                  'Live Mode',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // Navigation Rail for tablets/desktop
          if (isWide) ...[
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: _setIndex,
              labelType: NavigationRailLabelType.all,
              selectedIconTheme: IconThemeData(color: theme.colorScheme.primary),
              selectedLabelTextStyle: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              unselectedLabelTextStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.assignment_outlined),
                  selectedIcon: Icon(Icons.assignment_rounded),
                  label: Text('Orders'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people_outline_rounded),
                  selectedIcon: Icon(Icons.people_rounded),
                  label: Text('Customers'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.architecture_outlined),
                  selectedIcon: Icon(Icons.architecture_rounded),
                  label: Text('Garments'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
          ],
          // Main screen pane
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: _screens[_currentIndex],
            ),
          ),
        ],
      ),
      // Bottom navigation bar for mobile layout
      bottomNavigationBar: !isWide
          ? Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: _setIndex,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard_rounded),
                    label: 'Dashboard',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.assignment_outlined),
                    selectedIcon: Icon(Icons.assignment_rounded),
                    label: 'Orders',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.people_outline_rounded),
                    selectedIcon: Icon(Icons.people_rounded),
                    label: 'Customers',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.architecture_outlined),
                    selectedIcon: Icon(Icons.architecture_rounded),
                    label: 'Garments',
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
