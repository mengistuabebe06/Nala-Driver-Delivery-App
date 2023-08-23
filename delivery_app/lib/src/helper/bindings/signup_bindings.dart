import 'package:get/get.dart';

import '../../controller/signup_controller.dart';

class SignUpBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SignUpController());
  }
}
