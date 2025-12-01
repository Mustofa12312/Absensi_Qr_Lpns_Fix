// lib/features/attendance/views/attendance_list_view.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/attendance_controller.dart';
import '../../rooms/controllers/room_controller.dart';

class AttendanceListView extends StatefulWidget {
  const AttendanceListView({Key? key}) : super(key: key);

  @override
  State<AttendanceListView> createState() => _AttendanceListViewState();
}

class _AttendanceListViewState extends State<AttendanceListView>
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
    return attendanceC.getTodayAttendance(selectedRoomId);
  }

  @override
  Widget build(BuildContext context) {
    final dark = Get.isDarkMode;

    // Background iOS light & dark
    final backgroundGradient = LinearGradient(
      colors: dark
          ? const [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)]
          : const [Color(0xFFFFFFFF), Color(0xFFF7F8FA), Color(0xFFEFF1F5)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

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
              backgroundColor: dark
                  ? Colors.black.withOpacity(0.25)
                  : Colors.white70.withOpacity(0.25),
              elevation: 0,
              centerTitle: true,
              title: Text(
                'Daftar Hadir',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: txtPrimary,
                ),
              ),
              iconTheme: IconThemeData(color: txtPrimary),
            ),
          ),
        ),
      ),

      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              const SizedBox(height: 95),

              /// Dropdown Ruangan Wallet Style
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Obx(() {
                  final rooms = roomCtrl.rooms;
                  if (rooms.isEmpty) {
                    return const SizedBox(
                      height: 56,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: dark
                              ? Colors.white.withOpacity(0.08)
                              : Colors.white.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: dark
                                ? Colors.white.withOpacity(0.18)
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                        child: DropdownButtonFormField<int?>(
                          value: selectedRoomId,
                          dropdownColor: dark ? Colors.black87 : Colors.white,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Filter Ruangan',
                            labelStyle: TextStyle(color: Colors.grey),
                          ),
                          style: TextStyle(
                            color: txtPrimary,
                            fontFamily: GoogleFonts.poppins().fontFamily,
                          ),
                          iconEnabledColor: txtPrimary,
                          items: [
                            DropdownMenuItem<int?>(
                              value: null,
                              child: Text(
                                'Semua ruangan',
                                style: TextStyle(color: txtSecondary),
                              ),
                            ),
                            ...rooms.map(
                              (r) => DropdownMenuItem<int?>(
                                value: r['id'] as int,
                                child: Text(
                                  r['room_name'] as String,
                                  style: TextStyle(color: txtPrimary),
                                ),
                              ),
                            ),
                          ],
                          onChanged: (v) {
                            setState(() => selectedRoomId = v);
                          },
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 10),

              /// List Hadir
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetch(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Terjadi kesalahan: ${snapshot.error}',
                          style: GoogleFonts.poppins(color: txtPrimary),
                        ),
                      );
                    }

                    final data = snapshot.data ?? [];
                    if (data.isEmpty) {
                      return Center(
                        child: Text(
                          'Belum ada yang absen hari ini 📋',
                          style: GoogleFonts.poppins(
                            color: txtSecondary,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: Colors.cyan,
                      onRefresh: () async {
                        setState(() {});
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          12,
                          0,
                          12,
                          130,
                        ), // 🔥 FIX KETUTUP TAB BAR
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final item = data[index];
                          final no = index + 1;
                          final studentName =
                              item['student_name'] ?? item['name'] ?? '-';
                          final className = item['class_name'] ?? '-';
                          final roomName = item['room_name'] ?? '-';
                          final createdAt = item['created_at'] ?? '';

                          return AnimatedOpacity(
                            opacity: 1.0,
                            duration: Duration(
                              milliseconds: 200 + (index * 18),
                            ),
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 7),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 28,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 18,
                                    sigmaY: 18,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: dark
                                          ? Colors.white.withOpacity(0.08)
                                          : Colors.white.withOpacity(0.78),
                                      borderRadius: BorderRadius.circular(28),
                                      border: Border.all(
                                        color: dark
                                            ? Colors.white.withOpacity(0.15)
                                            : Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 18,
                                            vertical: 8,
                                          ),

                                      /// Badge nomor iOS
                                      leading: Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: dark
                                              ? Colors.white.withOpacity(0.15)
                                              : const Color(0xFFF2F2F7),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.10,
                                              ),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            no.toString(),
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: txtPrimary,
                                            ),
                                          ),
                                        ),
                                      ),

                                      title: Text(
                                        studentName,
                                        style: GoogleFonts.poppins(
                                          color: txtPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Kelas: $className\nRuangan: $roomName',
                                        style: GoogleFonts.poppins(
                                          color: txtSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                      trailing: Text(
                                        createdAt.toString().substring(11, 16),
                                        style: GoogleFonts.poppins(
                                          color: txtSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
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
