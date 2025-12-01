// lib/features/main_shell/controllers/nav_controller.dart
import 'package:get/get.dart';

class NavController extends GetxController {
  RxInt index = 0.obs;

  void change(int i) {
    index.value = i;
  }
}
