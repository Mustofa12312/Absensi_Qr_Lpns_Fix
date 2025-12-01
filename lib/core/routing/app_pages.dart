// lib/core/routing/app_pages.dart
import 'package:get/get.dart';

import '../../features/auth/views/login_view.dart';
import '../../features/main_shell/views/main_view.dart';

class AppRoutes {
  static const main = '/'; // halaman utama (shell)
  static const login = '/login'; // halaman login
}

class AppPages {
  static final routes = <GetPage>[
    GetPage(name: AppRoutes.login, page: () => const LoginView()),
    GetPage(name: AppRoutes.main, page: () => const MainView()),
  ];
}
