import 'package:get/get.dart';
import '../../controller/profile_controller.dart';

class ProfileBindings implements Bindings {
  @override
  void dependencies() {
    Get.put(ProfileController());
  }
}
