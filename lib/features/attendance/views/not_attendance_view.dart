// lib/features/attendance/views/not_attendance_view.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/attendance_controller.dart';
import '../../rooms/controllers/room_controller.dart';
import '../../../core/theme/theme_helper.dart';

class NotAttendanceView extends StatefulWidget {
  const NotAttendanceView({Key? key}) : super(key: key);

  @override
  State<NotAttendanceView> createState() => _NotAttendanceViewState();
}

class _NotAttendanceViewState extends State<NotAttendanceView>
    with SingleTickerProviderStateMixin {
  final AttendanceController attendanceC = Get.find<AttendanceController>();
  final RoomController roomCtrl = Get.find<RoomController>();

  int? selectedRoomId;
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    selectedRoomId = roomCtrl.selectedRoomId.value;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetch() {
    return attendanceC.getTodayNotAttendance(selectedRoomId);
  }

  @override
  Widget build(BuildContext context) {
    final dark = isDark();
    final txtPrimary = dark ? Colors.white : const Color(0xFF1C1C1E);
    final txtSecondary = dark ? Colors.white70 : const Color(0xFF3A3A3C);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.25),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Belum Hadir Hari Ini",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),

      /// BACKGROUND Apple Style
      body: Container(
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
                    Color(0xFFFDFDFD),
                    Color(0xFFF8F9FB),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              const SizedBox(height: 95),

              /// DROPDOWN Wallet Style
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Obx(() {
                  final rooms = roomCtrl.rooms;

                  if (rooms.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.cyanAccent,
                      ),
                    );
                  }

                  return WalletDropdownNotAttendance(
                    rooms: rooms,
                    selectedRoomId: selectedRoomId,
                    txtPrimary: txtPrimary,
                    txtSecondary: txtSecondary,
                    onChanged: (v) => setState(() => selectedRoomId = v),
                  );
                }),
              ),

              const SizedBox(height: 15),

              /// LIST BELUM HADIR
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetch(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Text(
                        "Terjadi kesalahan: ${snapshot.error}",
                        style: GoogleFonts.poppins(color: txtPrimary),
                      );
                    }

                    final data = snapshot.data ?? [];

                    if (data.isEmpty) {
                      return Center(
                        child: Text(
                          "Semua siswa sudah hadir ✅",
                          style: GoogleFonts.poppins(
                            color: txtSecondary,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async => setState(() {}),
                      color: Colors.yellow.shade600,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          16,
                          0,
                          16,
                          130,
                        ), // ⬅️ PENTING AGAR TIDAK KETUTUP TAB BAR
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final item = data[index];

                          return NotAttendanceCardWallet(
                            index: index + 1,
                            name: item['name'] ?? '-',
                            className: item['classes']?['class_name'] ?? '-',
                            roomName: item['rooms']?['room_name'] ?? '-',
                            txtPrimary: txtPrimary,
                            txtSecondary: txtSecondary,
                            dark: dark,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ----------------------
/// WIDGET DROPDOWN WALLET
/// ----------------------
class WalletDropdownNotAttendance extends StatelessWidget {
  final List rooms;
  final int? selectedRoomId;
  final Color txtPrimary;
  final Color txtSecondary;
  final Function(int?) onChanged;

  const WalletDropdownNotAttendance({
    super.key,
    required this.rooms,
    required this.selectedRoomId,
    required this.txtPrimary,
    required this.txtSecondary,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final dark = isDark();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: dark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: dark
              ? Colors.white.withOpacity(0.18)
              : Colors.white.withOpacity(0.9),
        ),
        boxShadow: [
          BoxShadow(
            color: dark
                ? Colors.black.withOpacity(0.35)
                : Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: selectedRoomId,
          icon: Icon(Icons.expand_more_rounded, size: 30, color: txtPrimary),
          dropdownColor: dark ? const Color(0xFF1C1C1E) : Colors.white,
          style: GoogleFonts.poppins(
            color: txtPrimary,
            fontWeight: FontWeight.w600,
          ),
          hint: Text(
            "Pilih Ruangan",
            style: GoogleFonts.poppins(color: txtSecondary, fontSize: 15),
          ),
          items: [
            DropdownMenuItem(
              value: null,
              child: Text(
                "Semua Ruangan",
                style: GoogleFonts.poppins(color: txtPrimary),
              ),
            ),
            ...rooms.map(
              (r) => DropdownMenuItem(
                value: r['id'],
                child: Text(
                  r['room_name'],
                  style: GoogleFonts.poppins(color: txtPrimary),
                ),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// ----------------------
/// WALLET PREMIUM CARD
/// ----------------------
class NotAttendanceCardWallet extends StatelessWidget {
  final int index;
  final String name;
  final String className;
  final String roomName;
  final Color txtPrimary;
  final Color txtSecondary;
  final bool dark;

  const NotAttendanceCardWallet({
    super.key,
    required this.index,
    required this.name,
    required this.className,
    required this.roomName,
    required this.txtPrimary,
    required this.txtSecondary,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    final yellowSoft = dark
        ? Colors.yellow.shade600.withOpacity(0.25)
        : Colors.yellow.shade600.withOpacity(0.15);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: dark ? Colors.white.withOpacity(0.07) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: yellowSoft, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: dark
                ? Colors.black.withOpacity(0.35)
                : Colors.black.withOpacity(0.10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),

        /// BADGE NOMOR
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(shape: BoxShape.circle, color: yellowSoft),
          child: Center(
            child: Text(
              index.toString(),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: txtPrimary,
              ),
            ),
          ),
        ),

        title: Text(
          name,
          style: GoogleFonts.poppins(
            color: txtPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          "Kelas: $className\nRuangan: $roomName",
          style: GoogleFonts.poppins(
            color: txtSecondary,
            fontSize: 13,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}
