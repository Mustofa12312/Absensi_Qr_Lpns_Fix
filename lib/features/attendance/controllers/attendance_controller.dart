// lib/features/attendance/controllers/attendance_controller.dart
import 'package:get/get.dart';
import '../../../data/services/supabase_service.dart';

class AttendanceController extends GetxController {
  final supabase = SupabaseService.instance;

  Future<List<Map<String, dynamic>>> getTodayAttendance(int? roomId) {
    return supabase.getTodayAttendanceByRoom(roomId);
  }

  Future<List<Map<String, dynamic>>> getTodayNotAttendance(int? roomId) {
    return supabase.getTodayNotAttendance(roomId);
  }
}
