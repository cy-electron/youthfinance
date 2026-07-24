import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

class YouthFinanceApp extends StatelessWidget {
  const YouthFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "YouthFinance",

      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,
      routerConfig: appRouter,

      //home: const Scaffold(body: Center(child: Text("YouthFinance"))),
    );
  }
}
