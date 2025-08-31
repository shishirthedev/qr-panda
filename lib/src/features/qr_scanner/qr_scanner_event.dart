import 'package:equatable/equatable.dart';
import 'models/qr_scan_result.dart';

abstract class QRScannerEvent extends Equatable {
  const QRScannerEvent();

  @override
  List<Object?> get props => [];
}

class QRCodeScanned extends QRScannerEvent {
  final QRScanResult result;

  const QRCodeScanned(this.result);

  @override
  List<Object?> get props => [result];
}

class ScanFromGallery extends QRScannerEvent {
  final String imagePath;

  const ScanFromGallery(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class ResetScanner extends QRScannerEvent {
  const ResetScanner();
}
