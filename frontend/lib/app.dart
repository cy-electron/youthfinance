import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

class YouthFinanceApp extends StatelessWidget {
  const YouthFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "YouthFinance",

      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,

      home: const Scaffold(body: Center(child: Text("YouthFinance"))),
    );
  }
}
