// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/controllers/theme_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_pages.dart';
import 'data/services/supabase_service.dart';

// controller fitur
import 'features/auth/controllers/auth_controller.dart';
import 'features/rooms/controllers/room_controller.dart';
import 'features/dashboard/controllers/summary_controller.dart';
import 'features/main_shell/controllers/nav_controller.dart';
import 'features/scan/controllers/scan_controller.dart';
import 'features/attendance/controllers/attendance_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Inisialisasi Supabase
  await Supabase.initialize(
    url: SupabaseService.supabaseUrl,
    anonKey: SupabaseService.supabaseAnonKey,
  );

  // 🔥 PATCH WAJIB: agar aplikasi SELALU logout saat dibuka
  // 1. Hapus session di RAM
  await Supabase.instance.client.auth.signOut();

  // 2. Hapus session yang tersimpan di storage (persistent)
  await Supabase.instance.client.auth.signOut(scope: SignOutScope.local);

  await initializeDateFormatting('id_ID', null);

  // 🔧 Register semua controller
  Get.put<ThemeController>(ThemeController(), permanent: true);
  Get.put<AuthController>(AuthController(), permanent: true);
  Get.put<RoomController>(RoomController(), permanent: true);
  Get.put<SummaryController>(SummaryController(), permanent: true);
  Get.put<NavController>(NavController(), permanent: true);
  Get.put<ScanController>(ScanController(), permanent: true);
  Get.put<AttendanceController>(AttendanceController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeC) {
        // Karena kita memaksa logout di atas,
        // session SELALU null setiap app dibuka
        final session = Supabase.instance.client.auth.currentSession;

        final initialRoute = session == null ? AppRoutes.login : AppRoutes.main;

        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Absensi Sekolah',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeC.themeMode,
          initialRoute: initialRoute,
          getPages: AppPages.routes,
        );
      },
    );
  }
}
