import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pill/bloc/theme/theme_block.dart';

class Utils {
  static bool isNumberGreaterThanZero(String? str) {
    if (str != null) {
      double? number = double.tryParse(str);
      if (number != null) {
        return number > 0;
      }
    }

    return false;
  }

  static Color getPillTakenImageColor(BuildContext context) {
    return context.read<ThemeBloc>().state == ThemeMode.light
        ? const Color(0xFF000000)
        : const Color(0xFFFFFFFF);
  }
}
