import 'package:flutter_bloc/flutter_bloc.dart';
import 'qr_scanner_event.dart';
import 'qr_scanner_state.dart';

class QRScannerBloc extends Bloc<QRScannerEvent, QRScannerState> {
  QRScannerBloc() : super(const QRScannerInitial()) {
    on<QRCodeScanned>(_onQRCodeScanned);
    on<ScanFromGallery>(_onScanFromGallery);
    on<ResetScanner>(_onResetScanner);
  }

  void _onQRCodeScanned(QRCodeScanned event, Emitter<QRScannerState> emit) {
    try {
      emit(const QRScannerLoading());
      
      // Process the scanned result
      final result = event.result;
      
      // Emit success state
      emit(QRScannerSuccess(result));
      
      // After a delay, go back to idle state for continued scanning
      Future.delayed(const Duration(seconds: 3), () {
        if (state is QRScannerSuccess) {
          emit(const QRScannerIdle());
        }
      });
    } catch (e) {
      emit(QRScannerError('Error processing QR code: $e'));
    }
  }

  void _onScanFromGallery(ScanFromGallery event, Emitter<QRScannerState> emit) {
    try {
      emit(const QRScannerLoading());
      
      // TODO: Implement image QR code detection
      // This would require using google_ml_kit or similar package
      // For now, we'll emit an error
      emit(const QRScannerError('Gallery scanning not yet implemented'));
    } catch (e) {
      emit(QRScannerError('Error scanning from gallery: $e'));
    }
  }

  void _onResetScanner(ResetScanner event, Emitter<QRScannerState> emit) {
    emit(const QRScannerInitial());
  }
}
