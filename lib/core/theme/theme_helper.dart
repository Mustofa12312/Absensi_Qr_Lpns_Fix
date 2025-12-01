import 'package:get/get.dart';
import '../controllers/theme_controller.dart';

bool isDark() {
  return Get.find<ThemeController>().isDark;
}
