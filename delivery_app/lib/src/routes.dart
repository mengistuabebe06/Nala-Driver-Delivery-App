import 'package:get/get.dart';
import 'helper/bindings/login_bindings.dart';
import 'helper/bindings/main_menu_bindings.dart';
import 'helper/bindings/signup_bindings.dart';
import 'screens/login.dart';
import 'screens/main_menu.dart';
import 'screens/sign_up.dart';

class RoutesConstant {
  static const String login = "/login";
  static const String signUp = "/signUp";
  static const String mainMenu = "/mainMenu";
  static const String root = "/";
}

class Routes {
  static final pages = [
    GetPage(
      name: RoutesConstant.signUp,
      page: () => const SignUpPage(),
      binding: SignUpBindings(),
    ),
    GetPage(
      name: RoutesConstant.login,
      page: () => const LoginPage(),
      binding: LoginBindings(),
    ),
    GetPage(
      name: RoutesConstant.mainMenu,
      page: () => MainMenu(),
      binding: MainMenuBindings(),
    ),
  ];
}
