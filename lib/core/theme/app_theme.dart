import 'package:flutter/material.dart';

import 'app_colors.dart';

ThemeData buildAppTheme(Brightness brightness) {
  final colors = brightness == Brightness.dark
      ? AppColors.dark
      : AppColors.light;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: 'PlusJakartaSans',
    scaffoldBackgroundColor: colors.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1B4332),
      brightness: brightness,
    ),
    extensions: [colors],
  );
}
