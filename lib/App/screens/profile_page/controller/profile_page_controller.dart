import 'package:statekit/statekit.dart';
import '../binding/profile_page_binding.dart';

class ProfilePageController extends StateController<ProfilePageBinding> {
  final String userFirstName = "John";
  final String userLastName = "Doe";
  final String userEmail = "john.doe@example.com";
  final String userPhone = "+1 555-0100";
  final String userRole = "Master Tailor";
}
