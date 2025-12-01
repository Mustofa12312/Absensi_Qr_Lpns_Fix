// lib/features/auth/controllers/auth_controller.dart
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/routing/app_pages.dart';

class AuthController extends GetxController {
  final isLoading = false.obs;
  final client = Supabase.instance.client;

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;

      final res = await client.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (res.user != null) {
        Get.offAllNamed(AppRoutes.main);
      } else {
        Get.snackbar('Gagal', 'Email atau password salah');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await client.auth.signOut();
    } finally {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
