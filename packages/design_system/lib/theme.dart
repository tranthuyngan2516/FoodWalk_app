import 'package:flutter/material.dart';

ThemeData foodwalkLightTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0FA3B1)),
  brightness: Brightness.light,
);

ThemeData foodwalkDarkTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0FA3B1), brightness: Brightness.dark),
  brightness: Brightness.dark,
);
