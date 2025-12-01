import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/theme_helper.dart';
import '../controllers/summary_controller.dart';
import '../../auth/controllers/auth_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  T _getOrPut<T extends GetxController>(T Function() builder) {
    if (Get.isRegistered<T>()) {
      return Get.find<T>();
    }
    return Get.put<T>(builder(), permanent: true);
  }

  @override
  Widget build(BuildContext context) {
    final summaryC = _getOrPut<SummaryController>(() => SummaryController());
    final authC = _getOrPut<AuthController>(() => AuthController());

    final dark = isDark();

    final now = DateTime.now();
    final hari = DateFormat('EEEE, d MMM yyyy', 'id_ID').format(now);

    // Warna teks iOS
    final txtPrimary = dark ? Colors.white : const Color(0xFF1C1C1E);
    final txtSecondary = dark ? Colors.white70 : const Color(0xFF3A3A3C);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: AppBar(
              title: Text(
                'Dashboard Absensi',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.black.withOpacity(0.15),
              elevation: 0,
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: authC.logout,
                ),
              ],
            ),
          ),
        ),
      ),

      body: Stack(
        children: [
          /// 🌈 BACKGROUND iOS PURE WHITE
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: dark
                      ? const [
                          Color(0xFF0F2027),
                          Color(0xFF203A43),
                          Color(0xFF2C5364),
                        ]
                      : const [
                          Color(0xFFFFFFFF), // pure white
                          Color(0xFFFDFEFF), // ultra-soft white
                          Color(0xFFF7F8FA), // slight lift
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          RefreshIndicator(
            onRefresh: summaryC.fetchSummary,
            child: Obx(
              () => ListView(
                padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
                children: [
                  Text(
                    'Hari ini ($hari)',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: txtPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (summaryC.isLoading.value)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 24),
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),

                  if (!summaryC.isLoading.value && summaryC.error.value != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        'Terjadi kesalahan: ${summaryC.error.value}',
                        style: GoogleFonts.poppins(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  if (!summaryC.isLoading.value &&
                      summaryC.error.value == null) ...[
                    const SizedBox(height: 8),

                    _statCard(
                      icon: Icons.check_circle_rounded,
                      title: 'Hadir: ${summaryC.hadir.value} siswa',
                      color: Colors.greenAccent,
                      dark: dark,
                      txtPrimary: txtPrimary,
                    ),

                    _statCard(
                      icon: Icons.close_rounded,
                      title: 'Tidak Hadir: ${summaryC.tidakHadir.value} siswa',
                      color: Colors.redAccent,
                      dark: dark,
                      txtPrimary: txtPrimary,
                    ),

                    _statCard(
                      icon: Icons.meeting_room_rounded,
                      title:
                          'Ruangan Sudah Absen: ${summaryC.ruanganAktif.value}',
                      color: Colors.cyanAccent,
                      dark: dark,
                      txtPrimary: txtPrimary,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🍎 CARD STATISTIK — iOS PURE WHITE (Rounded 22)
  Widget _statCard({
    required IconData icon,
    required String title,
    required Color color,
    required bool dark,
    required Color txtPrimary,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: dark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.white.withOpacity(0.78),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: dark
                    ? Colors.white.withOpacity(0.18)
                    : Colors.white.withOpacity(0.95),
              ),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dark
                      ? Colors.black.withOpacity(0.15)
                      : Colors.white.withOpacity(0.85),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              title: Text(
                title,
                style: GoogleFonts.poppins(
                  color: txtPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
