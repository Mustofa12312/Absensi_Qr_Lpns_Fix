import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  /// simpan status dark / light
  final _isDark = false.obs;

  bool get isDark => _isDark.value;

  /// ini yang dipakai di GetMaterialApp
  ThemeMode get themeMode => _isDark.value ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDark.toggle();

    // supaya Get.isDarkMode juga ikut berubah (kalau dipakai)
    Get.changeThemeMode(themeMode);

    // trigger rebuild untuk GetBuilder<ThemeController>
    update();
  }
}
