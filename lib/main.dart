

import 'package:consumir_api/screens/home_login.dart';
import 'package:flutter/material.dart';

import 'styles/color_scheme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) =>
    context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  bool _isDartTheme = false;

void changeTheme(){
  setState(() {
  _isDartTheme = !_isDartTheme;

  });
}
  @override
  Widget build(BuildContext context) {
    final currentTheme=_isDartTheme ? darkColorScheme : lightColorScheme;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(
        useMaterial3: true,
        colorScheme: currentTheme
      ),
      home: const LoginScreen()
);
  }
}