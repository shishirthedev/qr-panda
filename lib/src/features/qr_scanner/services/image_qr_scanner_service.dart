import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/qr_scan_result.dart';

class ImageQRScannerService {
  static final ImageQRScannerService _instance = ImageQRScannerService._internal();
  factory ImageQRScannerService() => _instance;
  ImageQRScannerService._internal();

  final MobileScannerController _controller = MobileScannerController();

  Future<QRScanResult?> scanImageFromFile(String imagePath) async {
    try {
      final BarcodeCapture? capture = await _controller.analyzeImage(imagePath);

      if (capture != null && capture.barcodes.isNotEmpty) {
        final barcode = capture.barcodes.first;
        if (barcode.rawValue != null) {
          return QRScanResult.fromScannedData(barcode.rawValue!);
        }
      }

      return null;
    } catch (e) {
      throw Exception('Error scanning image: $e');
    }
  }

  void dispose() {
    _controller.dispose();
  }
}
