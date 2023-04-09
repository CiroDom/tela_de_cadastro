import 'package:flutter/material.dart';
import 'package:tela_de_cadastro/app_widget/sign_up/sign_up.dart';
import 'package:tela_de_cadastro/res/sign_up_theme.dart';

import '../res/strings.dart';

class AppWidget extends StatefulWidget {
  const AppWidget({super.key});

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  ThemeMode currentThemeMode = ThemeMode.light;

  void toogleThemeMode() {
    setState(() {
      currentThemeMode = currentThemeMode ==  ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Strings.appName,
      themeMode: currentThemeMode,
      theme: SignUpTheme.light,
      darkTheme: SignUpTheme.dark,
      home: SignUp(themeChange: toogleThemeMode),
    );
  }
}
