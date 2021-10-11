import 'package:flutter/material.dart';

/// defines app colors
class AppThemeCustom {
  static final ThemeData lightTheme = AppThemeCustom._buildLightTheme();

  // ===== App Colors ========================================
  static const Color primaryColor = const Color(0xFF0091FF);
  static const Color primaryLightColor = const Color(0xFF4abdff);
  static const Color primaryDarkColor = const Color(0xFF0078ff);
  static const Color primaryTextColor = const Color(0xFFFFFFFF);

  static const Color secondaryColor = callOutOrange;

  static const Color secondaryLightColor = const Color(0xFF7a7cff);
  static const Color secondaryDarkColor = const Color(0xFF0026ca);
  static const Color secondaryTextColor = const Color(0xFF000000);

  static const Color highlightYellow = const Color(0xFFffff00);
  static const Color highlightGreen = const Color(0xFF00ffc7);
  static const Color highlightPink = const Color(0xFFffbdbd);

  static const Color callOutRed = const Color(0xFFff5f6d);
  static const Color callOutOrange = const Color(0xFFffa400);

  static const Color appGrey = const Color(0xFF6d7886);

  static const Color backgroundLight = const Color(0xFFF5F5F6);
  static const Color backgroundDark = const Color(0xFFE1E2E1);

  static const Color toastBgColor = secondaryColor;
  static const Color toastTextColor = Colors.white;

  // ===== Text Styles ========================================
  static const String fontFamily = "Montserrat";

  static const TextStyle textStyleSplash = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 30.0,
    color: Colors.white,
  );

  static const TextStyle textStyleAppBarLogo = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 30.0,
    color: primaryColor,
  );

  static const TextStyle textStyleHeading = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    color: Colors.black,
  );

  static const TextStyle textStylePageHeading = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle textStyleSectionHeading = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle textStyleBody = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    color: Colors.white,
  );

  static const TextStyle textStyleMenuItem = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    color: primaryColor,
  );

  static const TextStyle textStyleGridMenuButton = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    color: Colors.white,
  );

  static TextStyle textStyleNumericInput = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    color: Colors.grey[900],
  );

  static const TextStyle textStylePageResultYellow = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: highlightYellow,
  );

  static TextStyle textStylePageResultGreen =
      textStylePageResultYellow.copyWith(
    color: highlightGreen,
  );

  static TextStyle textStylePageResultPink = textStylePageResultYellow.copyWith(
    color: highlightPink,
  );

  static const TextStyle textStyleFootnote = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    color: Colors.white,
  );

  static TextStyle textPageInfoPopupHeader = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    color: primaryColor,
  );

  static TextStyle textPageInfoPopup = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    color: Colors.grey[800],
  );

  static TextStyle textStyleCustomDialogTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );

  static TextStyle textStyleCustomDialogMessage = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    color: Colors.black,
  );

  static TextStyle textStyleCustomDialogButton = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  // ===== App Theme ========================================
  static ThemeData _buildLightTheme() {
    final ThemeData base = ThemeData.light();
    return base.copyWith(
      accentColor: secondaryColor,
      primaryColor: primaryColor,
      errorColor: Colors.red,
      // scaffoldBackgroundColor: backgroundLight,
      // cardColor: backgroundLight,
      // buttonTheme: base.buttonTheme.copyWith(
      //   buttonColor: secondaryColor,
      //   textTheme: ButtonTextTheme.normal,
      // ),
      textTheme: _buildLightTextTheme(base.textTheme),
      primaryTextTheme: _buildLightTextTheme(base.primaryTextTheme),
      accentTextTheme: _buildLightTextTheme(base.accentTextTheme),
      primaryIconTheme: base.iconTheme.copyWith(
        color: Colors.white,
      ),
    );
  }

  /// Create Material Color (swatch)
  ///
  /// Usage: primarySwatch: createMaterialColor(Color(0xFF174378))
  ///
  /// Src: https://medium.com/@filipvk/creating-a-custom-color-swatch-in-flutter-554bcdcb27f3
  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    strengths.forEach((strength) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    });
    return MaterialColor(color.value, swatch);
  }

  static TextTheme _buildLightTextTheme(TextTheme base) {
    return base
        .copyWith(
          headline5: base.headline5.copyWith(
            fontWeight: FontWeight.w500,
          ),
          headline6: base.headline6.copyWith(
            fontSize: 22.0,
            color: Colors.white,
          ),
          caption: base.caption.copyWith(
            fontWeight: FontWeight.w400,
            fontSize: 16.0,
            color: Colors.white,
          ),
        )
        .apply(
          fontFamily: fontFamily,
          displayColor: Colors.black,
          bodyColor: Colors.black,
        );
  }
}
