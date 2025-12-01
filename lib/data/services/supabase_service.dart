// lib/data/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  // GANTI dengan URL & KEY kamu sendiri
  static const String supabaseUrl = 'https://umwvjkgiabdhjdaafsvr.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVtd3Zqa2dpYWJkaGpkYWFmc3ZyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MDQzNDAsImV4cCI6MjA3MTk4MDM0MH0.D7k18xqk_V4yT2n7PwYHpYJHaUkgTAwzVzVnF6IU3hY';

  final SupabaseClient client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getRooms() async {
    final res = await client.from('rooms').select();
    return (res as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>?> getStudentById(int id) async {
    final res = await client
        .from('student_view')
        .select()
        .eq('id', id)
        .maybeSingle();
    return res;
  }

  Future<String> insertAttendance({
    required int studentId,
    required int roomId,
  }) async {
    final res = await client.rpc(
      'insert_attendance',
      params: {'p_student_id': studentId, 'p_room_id': roomId},
    );
    return res as String;
  }

  Future<Map<String, dynamic>?> getTodaySummary() async {
    final res = await client
        .from('attendance_summary_today')
        .select()
        .maybeSingle();
    return res;
  }

  Future<List<Map<String, dynamic>>> getTodayAttendanceByRoom(
    int? roomId,
  ) async {
    final query = client.from('attendance_today_by_room').select('*');

    final res = roomId != null
        ? await query
              .eq('room_id', roomId)
              .order('created_at', ascending: false)
        : await query.order('created_at', ascending: false);

    return (res as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getTodayNotAttendance(int? roomId) async {
    // contoh sederhana: silakan sesuaikan dengan view/function di Supabase kamu
    final today = DateTime.now();

    final result = await client
        .from('students')
        .select(
          'id, name, class_id, room_id, classes(class_name), rooms(room_name)',
        )
        .neq('id', 0)
        .order('id', ascending: true);

    final attended = await client
        .from('attendance')
        .select('student_id')
        .gte(
          'created_at',
          DateTime(today.year, today.month, today.day).toIso8601String(),
        );

    final attendedIds = (attended as List)
        .map((e) => e['student_id'] as int)
        .toSet();

    final allStudents = (result as List).cast<Map<String, dynamic>>();

    final filtered = allStudents.where((s) {
      final roomMatch = roomId == null || s['room_id'] == roomId;
      final notAttended = !attendedIds.contains(s['id']);
      return roomMatch && notAttended;
    }).toList();

    return filtered;
  }
}
