// lib/features/scan/controllers/scan_controller.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../../data/services/scanner_service.dart';
import '../../../data/services/supabase_service.dart';
import '../widgets/success_dialog.dart';

class ScanController extends GetxController {
  final supabase = SupabaseService.instance;
  final scanner = ScannerService();

  final player = AudioPlayer();

  final isScanPageActive = false.obs;
  final isProcessing = false.obs;

  final Map<int, DateTime> _recent = {};
  final int threshold = 3;

  void setScanPageActive(bool v) {
    isScanPageActive.value = v;
  }

  // Membersihkan QR dari karakter aneh
  String cleanQR(String text) {
    return text.replaceAll(RegExp(r'[^0-9{}":,a-zA-Z]'), '').trim();
  }

  Future<void> playDing() async {
    try {
      await player.stop();
      await player.play(AssetSource("sounds/ding.mp3"));
    } catch (e) {
      print("Sound error: $e");
    }
  }

  Future<void> handleCapture(BarcodeCapture cap, int roomId) async {
    if (!isScanPageActive.value) return;

    final code = scanner.extract(cap);
    if (code.isEmpty) return;

    await handleBarcode(code, roomId);
  }

  Future<void> handleBarcode(String code, int roomId) async {
    if (isProcessing.value) return;
    isProcessing.value = true;

    try {
      // 🔧 BERSIHKAN QR
      code = cleanQR(code);

      int? id;

      // 🔧 QR JSON format → {"student_id":3001}
      if (code.startsWith('{') && code.endsWith('}')) {
        try {
          final json = jsonDecode(code);
          if (json is Map && json['student_id'] != null) {
            id = int.tryParse(json['student_id'].toString());
          }
        } catch (_) {}
      }

      // 🔧 Fallback QR angka biasa → "3001"
      id ??= int.tryParse(code);

      if (id == null) {
        return showMsg("QR Tidak Valid", "Gunakan QR resmi.");
      }

      // 🔧 CEGAH SPAM SCAN
      final now = DateTime.now();
      if (_recent.containsKey(id)) {
        if (now.difference(_recent[id]!).inSeconds < threshold) {
          return;
        }
      }
      _recent[id] = now;

      // 🔧 CEK DATA SISWA
      final st = await supabase.getStudentById(id);
      if (st == null) {
        return showMsg("Tidak ditemukan", "Siswa tidak ada.");
      }

      // 🔧 CEK RUANGAN SESUAI
      if (st['room_id'].toString() != roomId.toString()) {
        return showMsg(
          "Ruangan Salah",
          "Siswa berada di ruangan ${st['room_name']}.",
        );
      }

      // 🔧 SIMPAN ABSEN
      final res = await supabase.insertAttendance(
        studentId: id,
        roomId: roomId,
      );

      // 🔔 SUKSES
      if (res.contains("✅")) {
        await playDing();
        Get.dialog(
          SuccessDialog(
            title: "Absen Berhasil",
            subtitle:
                "${st['name']}\nKelas: ${st['class_name']}\nRuangan: ${st['room_name']}",
          ),
          barrierDismissible: true,
        );
      } else {
        showMsg("Sudah Absen", "${st['name']} sudah absen.");
      }
    } finally {
      isProcessing.value = false;
    }
  }

  void showMsg(String t, String m) {
    if (!Get.isSnackbarOpen) {
      Get.snackbar(
        t,
        m,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }
}
