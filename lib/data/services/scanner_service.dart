// lib/data/services/scanner_service.dart

import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerService {
  String extract(BarcodeCapture capture) {
    for (final b in capture.barcodes) {
      if (b.rawValue != null && b.rawValue!.trim().isNotEmpty) {
        return b.rawValue!.trim();
      }
    }
    return "";
  }
}
