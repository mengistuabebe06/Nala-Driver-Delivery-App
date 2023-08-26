// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'src/helper/storage/secure_store.dart';
import 'src/routes.dart';
import 'src/screens/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    final GoogleMapsFlutterPlatform mapsImplementation =
        GoogleMapsFlutterPlatform.instance;
    if (mapsImplementation is GoogleMapsFlutterAndroid) {
      mapsImplementation.useAndroidViewSurface = false;
    }
  }

  if (Platform.isWindows) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(355, 760),
      center: false,
      alwaysOnTop: true,
      skipTaskbar: false,
      title: "NalaDelivery",
      backgroundColor: Colors.transparent,
      maximumSize: Size(355, 760),
      minimumSize: Size(355, 760),
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  AwesomeNotifications().initialize(
    'resource://drawable/res_notification_app_icon',
    [
      NotificationChannel(
          channelKey: 'delivery_notifier',
          channelName: 'Delivery Notifier',
          importance: NotificationImportance.High,
          defaultColor: Colors.teal,
          channelShowBadge: true,
          channelDescription: 'Notifies the time of Delivery')
    ],
  );

  // await SecuredStorage.clear();
  final isLoggedIn = await SecuredStorage.check(key: SharedKeys.token);

  String initialRoute =
      isLoggedIn ? RoutesConstant.mainMenu : RoutesConstant.login;

  await dotenv.load();
  runApp(NalaDelivery(initialRoute: initialRoute));
}

class NalaDelivery extends StatelessWidget {
  final String initialRoute;
  const NalaDelivery({super.key, required this.initialRoute});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(1440, 2960),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return GetMaterialApp(
            initialRoute: initialRoute,
            getPages: Routes.pages,
            title: 'NalaDelivery',
            theme: FlexThemeData.light(
              colors: const FlexSchemeColor(
                primary: Color(0xff004881),
                primaryContainer: Color(0xffd0e4ff),
                secondary: Color(0xffac3306),
                secondaryContainer: Color(0xffffdbcf),
                tertiary: Color(0xff006875),
                tertiaryContainer: Color(0xff95f0ff),
                appBarColor: Color(0xffffdbcf),
                error: Color(0xffb00020),
              ),
              surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
              blendLevel: 7,
              subThemesData: const FlexSubThemesData(
                blendOnLevel: 10,
                blendOnColors: false,
                useTextTheme: true,
                useM2StyleDividerInM3: true,
              ),
              visualDensity: FlexColorScheme.comfortablePlatformDensity,
              useMaterial3: true,
              swapLegacyOnMaterial3: true,
            ),
            darkTheme: FlexThemeData.dark(
              colors: const FlexSchemeColor(
                primary: Color(0xff003259),
                primaryContainer: Color(0xff00325b),
                secondary: Color(0xffffb59d),
                secondaryContainer: Color(0xff872100),
                tertiary: Color(0xff86d2e1),
                tertiaryContainer: Color(0xff004e59),
                appBarColor: Color(0xff872100),
                error: Color(0xffcf6679),
              ),
              surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
              blendLevel: 13,
              subThemesData: const FlexSubThemesData(
                blendOnLevel: 20,
                useTextTheme: true,
                useM2StyleDividerInM3: true,
              ),
              visualDensity: FlexColorScheme.comfortablePlatformDensity,
              useMaterial3: true,
              swapLegacyOnMaterial3: true,
              // To use the Playground font, add GoogleFonts package and uncomment
              // fontFamily: GoogleFonts.notoSans().fontFamily,
            ),
            themeMode: ThemeMode.light,
            debugShowCheckedModeBanner: false,
          );
        });
  }
}

class GetStarted extends StatelessWidget {
  const GetStarted({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: LoginPage(),
      ),
    );
  }
}
