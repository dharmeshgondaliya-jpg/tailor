import 'package:statekit/statekit.dart';
import '../binding/home_screen_binding.dart';

class HomeScreenController extends StateController<HomeScreenBinding> {
  int selectedIndex = 0;

  void changeIndex(int index) {
    selectedIndex = index;
    update();
  }
}
