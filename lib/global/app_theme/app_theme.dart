import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Colors.black;
  static const Color secondaryColor = Color(0xFF00FF85);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const String fontFamily = 'JekoDEMO';

  static final ThemeData lightTheme = ThemeData(
    fontFamily: fontFamily,
    scaffoldBackgroundColor: backgroundColor,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: primaryColor,
      ),

      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: primaryColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Colors.grey,
      ),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),

      bodySmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Colors.black
      )
    ),
  );
}
