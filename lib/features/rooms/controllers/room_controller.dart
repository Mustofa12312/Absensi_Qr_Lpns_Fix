// lib/features/rooms/controllers/room_controller.dart
import 'package:get/get.dart';
import '../../../data/services/supabase_service.dart';

class RoomController extends GetxController {
  final supabase = SupabaseService.instance;

  RxList<Map<String, dynamic>> rooms = <Map<String, dynamic>>[].obs;
  RxnInt selectedRoomId = RxnInt();

  @override
  void onInit() {
    super.onInit();
    loadRooms();
  }
  

  Future<void> loadRooms() async {
    try {
      final data = await supabase.getRooms();
      rooms.assignAll(data);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  void selectRoom(int? id) {
    selectedRoomId.value = id;
  }
}
