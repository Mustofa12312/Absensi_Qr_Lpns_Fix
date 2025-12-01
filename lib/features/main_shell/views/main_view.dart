// lib/features/main_shell/views/main_view.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/nav_controller.dart';
import '../../dashboard/views/home_view.dart';
import '../../scan/views/scan_view.dart';
import '../../attendance/views/attendance_list_view.dart';
import '../../attendance/views/not_attendance_view.dart';
import '../../scan/controllers/scan_controller.dart';

class MainView extends StatelessWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navC = Get.find<NavController>();
    final scanC = Get.find<ScanController>();

    final dark = Get.isDarkMode;

    return Scaffold(
      extendBody: true,

      body: Stack(
        children: [
          /// 🌈 Background halus Apple
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: dark
                    ? const [
                        Color(0xFF0F2027),
                        Color(0xFF203A43),
                        Color(0xFF2C5364),
                      ]
                    : const [
                        Color(0xFFFFFFFF),
                        Color(0xFFF6F7FB),
                        Color(0xFFEFF1F5),
                      ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          /// PAGE VIEW (IndexedStack)
          Obx(() {
            final i = navC.index.value;
            scanC.setScanPageActive(i == 1);
            return IndexedStack(
              index: i,
              children: const [
                HomeView(),
                ScanView(),
                AttendanceListView(),
                NotAttendanceView(),
              ],
            );
          }),
        ],
      ),

      /// 🍎 iOS TAB BAR (Floating, Glassy)
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Obx(
                () => Container(
                  height: 78,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: dark
                        ? Colors.white.withOpacity(0.06)
                        : Colors.white.withOpacity(0.65),
                    border: Border.all(
                      color: dark
                          ? Colors.white.withOpacity(0.10)
                          : Colors.white.withOpacity(0.55),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),

                  child: BottomNavigationBar(
                    currentIndex: navC.index.value,
                    onTap: navC.change,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    type: BottomNavigationBarType.fixed,
                    selectedFontSize: 12,
                    unselectedFontSize: 12,
                    selectedItemColor: dark
                        ? Colors.white
                        : const Color(0xFF1C1C1E),
                    unselectedItemColor: dark
                        ? Colors.white.withOpacity(0.55)
                        : const Color(0xFF8E8E93),

                    showUnselectedLabels: true,

                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.dashboard_outlined, size: 24),
                        activeIcon: Icon(Icons.dashboard_rounded, size: 27),
                        label: "Dashboard",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.qr_code_scanner, size: 24),
                        activeIcon: Icon(Icons.qr_code_2, size: 27),
                        label: "Scan",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.people_alt_outlined, size: 24),
                        activeIcon: Icon(Icons.people_alt, size: 27),
                        label: "Hadir",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person_off_outlined, size: 24),
                        activeIcon: Icon(Icons.person_off, size: 27),
                        label: "Belum",
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
