// lib/features/scan/views/scan_view.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/theme/theme_helper.dart';
import '../controllers/scan_controller.dart';
import '../../rooms/controllers/room_controller.dart';

class ScanView extends StatefulWidget {
  const ScanView({Key? key}) : super(key: key);

  @override
  State<ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView> with WidgetsBindingObserver {
  final scanC = Get.find<ScanController>();
  final roomC = Get.find<RoomController>();

  final MobileScannerController camera = MobileScannerController(
    autoStart: false,
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool ready = false;
  bool torch = false;

  @override
  void initState() {
    super.initState();
    scanC.setScanPageActive(true);
    WidgetsBinding.instance.addObserver(this);
    initCamera();
  }

  Future<void> initCamera() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) status = await Permission.camera.request();

    if (status.isGranted) {
      setState(() => ready = true);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        camera.start();
      });
    }
  }

  @override
  void dispose() {
    scanC.setScanPageActive(false);
    camera.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = isDark();
    final txtPrimary = dark ? Colors.white : const Color(0xFF1C1C1E);
    final txtSecondary = dark ? Colors.white70 : const Color(0xFF3A3A3C);

    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        title: Text(
          "Scan QR",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.black26,
        elevation: 0,
        centerTitle: true,
      ),

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

        child: !ready
            ? const Center(
                child: CircularProgressIndicator(color: Colors.cyanAccent),
              )
            : Column(
                children: [
                  const SizedBox(height: 100),

                  /// CARD RUANGAN — Apple Wallet Style
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Obx(() {
                      final rooms = roomC.rooms;

                      if (rooms.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.cyanAccent,
                          ),
                        );
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: dark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: dark
                                  ? Colors.black.withOpacity(0.3)
                                  : Colors.black.withOpacity(0.08),
                              blurRadius: 22,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(
                            color: dark
                                ? Colors.white.withOpacity(0.18)
                                : Colors.white.withOpacity(0.9),
                            width: 1.2,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int?>(
                            value: roomC.selectedRoomId.value,
                            icon: Icon(
                              Icons.expand_more_rounded,
                              color: txtPrimary,
                              size: 30,
                            ),

                            style: GoogleFonts.poppins(
                              color: txtPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),

                            hint: Text(
                              "Pilih Ruangan",
                              style: GoogleFonts.poppins(
                                color: txtSecondary,
                                fontSize: 15,
                              ),
                            ),

                            dropdownColor: dark
                                ? const Color(0xFF1C1C1E)
                                : Colors.white,

                            items: [
                              DropdownMenuItem(
                                value: null,
                                child: Text(
                                  "Semua Ruangan",
                                  style: GoogleFonts.poppins(
                                    color: txtPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              ...rooms.map(
                                (r) => DropdownMenuItem(
                                  value: r["id"],
                                  child: Text(
                                    r["room_name"],
                                    style: GoogleFonts.poppins(
                                      color: txtPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (v) {
                              roomC.selectedRoomId.value = v;
                            },
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 30),

                  /// SCANNER AREA — Apple Wallet Clean Box
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        MobileScanner(
                          controller: camera,
                          onDetect: (cap) {
                            final roomId = roomC.selectedRoomId.value;

                            if (roomId == null) {
                              if (!Get.isSnackbarOpen) {
                                Get.snackbar(
                                  "Pilih Ruangan",
                                  "Silakan pilih ruangan dulu.",
                                  backgroundColor: Colors.redAccent.withOpacity(
                                    .85,
                                  ),
                                  colorText: Colors.white,
                                );
                              }
                              return;
                            }
                            scanC.handleCapture(cap, roomId);
                          },
                        ),

                        /// Clean white + aqua frame
                        Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            color: dark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              width: 3,
                              color: Colors.cyanAccent,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: dark
                                    ? Colors.black.withOpacity(0.3)
                                    : Colors.black.withOpacity(0.07),
                                blurRadius: 26,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                        ),

                        /// BUTTONS
                        Positioned(
                          bottom: 40,
                          child: Row(
                            children: [
                              _walletButton(
                                icon: torch ? Icons.flash_on : Icons.flash_off,
                                dark: dark,
                                onTap: () async {
                                  await camera.toggleTorch();
                                  setState(() => torch = !torch);
                                },
                              ),
                              const SizedBox(width: 18),
                              _walletButton(
                                icon: Icons.cameraswitch_rounded,
                                dark: dark,
                                onTap: camera.switchCamera,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                  Text(
                    "Arahkan kamera ke QR siswa",
                    style: GoogleFonts.poppins(
                      color: txtSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
      ),
    );
  }

  /// BUTTON ala Apple Wallet
  Widget _walletButton({
    required IconData icon,
    required Function() onTap,
    required bool dark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: dark ? Colors.white.withOpacity(0.10) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: dark
                ? Colors.white.withOpacity(0.25)
                : Colors.white.withOpacity(0.9),
          ),
          boxShadow: [
            BoxShadow(
              color: dark
                  ? Colors.black.withOpacity(0.35)
                  : Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 26,
          color: dark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}
