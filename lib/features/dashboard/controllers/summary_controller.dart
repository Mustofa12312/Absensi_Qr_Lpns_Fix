// lib/features/dashboard/controllers/summary_controller.dart
import 'package:get/get.dart';
import '../../../data/services/supabase_service.dart';

class SummaryController extends GetxController {
  final supabase = SupabaseService.instance;

  RxBool isLoading = false.obs;
  RxnString error = RxnString();

  RxInt hadir = 0.obs;
  RxInt tidakHadir = 0.obs;
  RxInt ruanganAktif = 0.obs;
  RxnString tanggal = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchSummary();
  }

  Future<void> fetchSummary() async {
    try {
      isLoading.value = true;
      error.value = null;
      final res = await supabase.getTodaySummary();
      if (res != null) {
        hadir.value = res['hadir'] ?? 0;
        tidakHadir.value = res['tidak_hadir'] ?? 0;
        ruanganAktif.value = res['ruangan_sudah_absen'] ?? 0;
        tanggal.value = res['tanggal']?.toString();
      } else {
        hadir.value = 0;
        tidakHadir.value = 0;
        ruanganAktif.value = 0;
        tanggal.value = null;
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
