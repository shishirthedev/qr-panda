import 'package:equatable/equatable.dart';
import 'models/qr_scan_result.dart';

abstract class QRScannerState extends Equatable {
  const QRScannerState();

  @override
  List<Object?> get props => [];
}

class QRScannerInitial extends QRScannerState {
  const QRScannerInitial();
}

class QRScannerLoading extends QRScannerState {
  const QRScannerLoading();
}

class QRScannerSuccess extends QRScannerState {
  final QRScanResult result;

  const QRScannerSuccess(this.result);

  @override
  List<Object?> get props => [result];
}

class QRScannerError extends QRScannerState {
  final String message;

  const QRScannerError(this.message);

  @override
  List<Object?> get props => [message];
}

class QRScannerIdle extends QRScannerState {
  const QRScannerIdle();
}
