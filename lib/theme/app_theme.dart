// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFFC65D07);
  static const Color primaryDark = Color(0xFFA04D06);
  static const Color accent = Color(0xFFFF8C42);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color textDark = Color(0xFF212121);
  static const Color textGrey = Color(0xFF757575);
  static const Color bgLight = Color(0xFFF5F5F5);
  static const Color bgSurface = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFEEEEEE);

  static const Color darkBg = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2A2A2A);
  static const Color darkDivider = Color(0xFF333333);
  static const Color darkTextPrimary = Color(0xFFEEEEEE);
  static const Color darkTextSecondary = Color(0xFF9E9E9E);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
          primary: primary,
          secondary: accent,
          surface: bgSurface,
          onSurface: textDark,
        ),
        scaffoldBackgroundColor: bgLight,
        fontFamily: 'Roboto',
        cardColor: bgSurface,
        dividerColor: divider,
        canvasColor: bgSurface,
        appBarTheme: const AppBarTheme(
          backgroundColor: bgSurface,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: textDark),
          titleTextStyle: TextStyle(
              color: textDark, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: bgSurface,
          indicatorColor: primary.withOpacity(0.12),
          labelTextStyle: WidgetStateProperty.resolveWith((states) =>
              TextStyle(
                  fontSize: 12,
                  color: states.contains(WidgetState.selected) ? primary : textGrey,
                  fontWeight: states.contains(WidgetState.selected)
                      ? FontWeight.w700 : FontWeight.w400)),
          iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              color: states.contains(WidgetState.selected) ? primary : textGrey)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary, foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true, fillColor: bgSurface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: divider)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: divider)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: primary, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        chipTheme: ChipThemeData(
          selectedColor: primary, backgroundColor: bgSurface,
          labelStyle: const TextStyle(fontSize: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        listTileTheme: const ListTileThemeData(
          textColor: textDark, iconColor: textGrey),
        dialogTheme: const DialogThemeData(
          backgroundColor: bgSurface,
          titleTextStyle: TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: textDark),
          bodyMedium: TextStyle(color: textDark),
          bodySmall: TextStyle(color: textGrey),
          titleLarge: TextStyle(color: textDark, fontWeight: FontWeight.w700),
          titleMedium: TextStyle(color: textDark, fontWeight: FontWeight.w600),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.dark,
          primary: primary,
          secondary: accent,
          surface: darkSurface,
          onSurface: darkTextPrimary,
          onPrimary: Colors.white,
        ),
        scaffoldBackgroundColor: darkBg,
        fontFamily: 'Roboto',
        cardColor: darkCard,
        dividerColor: darkDivider,
        canvasColor: darkSurface,
        appBarTheme: const AppBarTheme(
          backgroundColor: darkSurface,
          elevation: 0, centerTitle: false,
          iconTheme: IconThemeData(color: darkTextPrimary),
          titleTextStyle: TextStyle(
              color: darkTextPrimary, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: darkSurface,
          indicatorColor: primary.withOpacity(0.2),
          labelTextStyle: WidgetStateProperty.resolveWith((states) =>
              TextStyle(
                  fontSize: 12,
                  color: states.contains(WidgetState.selected) ? primary : darkTextSecondary,
                  fontWeight: states.contains(WidgetState.selected)
                      ? FontWeight.w700 : FontWeight.w400)),
          iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              color: states.contains(WidgetState.selected) ? primary : darkTextSecondary)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary, foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true, fillColor: darkCard,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: darkDivider)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: darkDivider)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: primary, width: 1.5)),
          labelStyle: const TextStyle(color: darkTextSecondary),
          hintStyle: const TextStyle(color: darkTextSecondary),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        chipTheme: ChipThemeData(
          selectedColor: primary, backgroundColor: darkCard,
          labelStyle: const TextStyle(fontSize: 13, color: darkTextPrimary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        listTileTheme: const ListTileThemeData(
          textColor: darkTextPrimary, iconColor: darkTextSecondary),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected) ? primary : darkTextSecondary),
          trackColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? primary.withOpacity(0.5) : darkDivider),
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: darkSurface,
          titleTextStyle: TextStyle(
              color: darkTextPrimary, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: darkSurface,
          selectedItemColor: primary,
          unselectedItemColor: darkTextSecondary,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: darkTextPrimary),
          bodyMedium: TextStyle(color: darkTextPrimary),
          bodySmall: TextStyle(color: darkTextSecondary),
          titleLarge: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w700),
          titleMedium: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: darkTextPrimary),
        primaryIconTheme: const IconThemeData(color: primary),
      );
}