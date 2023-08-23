import 'package:get/get.dart';

import '../../controller/profile_controller.dart';

class MainMenuBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileController());
  }
}
