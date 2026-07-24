import 'package:flutter/material.dart';

class AppAnimation {
  AppAnimation._();

  static const fast = Duration(milliseconds: 200);
  static const medium = Duration(milliseconds: 350);
  static const slow = Duration(milliseconds: 500);

  static const curve = Curves.easeOutCubic;
}
