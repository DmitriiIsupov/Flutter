import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iot_starter_kit_app/screens/help/help_screen.dart';
import 'package:iot_starter_kit_app/screens/home/home_screen.dart';
import 'package:iot_starter_kit_app/screens/splash/splash_screen.dart';
import 'package:iot_starter_kit_app/screens/about/about_screen.dart';
import 'package:iot_starter_kit_app/screens/settings/settings_screen.dart';
import 'package:iot_starter_kit_app/screens/demo/demo_screen.dart';

class ScreenRouter {
  static const String home = 'home';
  static const String splash = 'splash';
  static const String settings = 'settings';
  static const String help = 'help';
  static const String about = 'about';
  static const String demo = 'demo';

  /// not used
  static final routes = <String, WidgetBuilder>{
    home: (BuildContext context) => HomeScreen(),
    about: (BuildContext context) => AboutScreen(),
    demo: (BuildContext context) => DemoScreen(),
    settings: (BuildContext context) => SettingsScreen(),
    splash: (BuildContext context) {
      return SplashScreen(
        afterSplashRoute: ScreenRouter.home,
        secondsDelay: 1,
      );
    },
  };

  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case home:
        return MaterialPageRoute(
            builder: (_) => HomeScreen(), settings: routeSettings);
      case settings:
        return CupertinoPageRoute(
            builder: (_) => SettingsScreen(), settings: routeSettings);
      case help:
        return CupertinoPageRoute(
            builder: (_) => HelpScreen(), settings: routeSettings);
      case about:
        return CupertinoPageRoute(
            builder: (_) => AboutScreen(), settings: routeSettings);
      case demo:
        return CupertinoPageRoute(
            builder: (_) => DemoScreen(), settings: routeSettings);
      default:
        return MaterialPageRoute(
            builder: (_) => HomeScreen(), settings: routeSettings);
    }
  }
}
