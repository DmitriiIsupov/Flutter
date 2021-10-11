import 'package:flutter/material.dart';

/// Define your light and dark theme colors here.
/// You can define as much details of theme data as you want to control the
/// look and feel of your app. Check [ThemeData] class docs for details.
class AppThemes {
  AppThemes._();

  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.grey,
    primaryColor: Colors.lightGreenAccent[700],
    brightness: Brightness.light,
    backgroundColor: const Color(0xFFFDF5E6),
    accentColor: Colors.black,
    accentIconTheme: IconThemeData(color: Colors.white),
    dividerColor: Colors.black26,
    buttonColor: Colors.amber[800],
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.red[700],
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.grey,
    primaryColor: Colors.teal,
    brightness: Brightness.dark,
    backgroundColor: const Color(0xFF212121),
    accentColor: Colors.white30,
    accentIconTheme: IconThemeData(color: Colors.black),
    dividerColor: Colors.white30,
    buttonColor: Colors.amber[800],
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.red[700],
    ),
  );
}
