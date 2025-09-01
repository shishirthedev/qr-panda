import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import '../../models/qr_history_item.dart';
import '../../services/qr_history_service.dart';
import 'qr_scanner_bloc.dart';
import 'qr_scanner_state.dart';
import 'qr_scanner_event.dart';
import 'models/qr_scan_result.dart';
import 'services/image_qr_scanner_service.dart';
import 'widgets/scan_result_display.dart';
import 'widgets/qr_scanner_overlay.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController? controller;
  final QRHistoryService _historyService = QRHistoryService();
  bool _isCameraPermissionGranted = false;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
    _requestCameraPermission();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _isCameraPermissionGranted = status.isGranted;
    });
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning && capture.barcodes.isNotEmpty) {
      final barcode = capture.barcodes.first;
      if (barcode.rawValue != null) {
        setState(() {
          _isScanning = true;
        });
        
        final result = QRScanResult.fromScannedData(barcode.rawValue!);
        context.read<QRScannerBloc>().add(QRCodeScanned(result));
        
        // Save to history
        _saveToHistory(result.content);
        
        // Stop scanning temporarily
        controller?.stop();
        
        // Resume after a delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _isScanning = false;
            });
            controller?.start();
          }
        });
      }
    }
  }

  Future<void> _saveToHistory(String content) async {
    try {
      final historyItem = QRHistoryItem.fromScanned(
        content: content,
        title: _getScanTitle(content),
        description: _getScanDescription(content),
      );
      
      await _historyService.insertQRHistory(historyItem);
    } catch (e) {
      // Silently fail - don't interrupt the scanning experience
      debugPrint('Failed to save to history: $e');
    }
  }

  String _getScanTitle(String content) {
    if (content.startsWith('http')) {
      return 'URL QR Code';
    } else if (content.startsWith('tel:')) {
      return 'Phone QR Code';
    } else if (content.startsWith('WIFI:')) {
      return 'WiFi QR Code';
    } else if (content.startsWith('BEGIN:VCARD')) {
      return 'Contact QR Code';
    } else {
      return 'Text QR Code';
    }
  }

  String _getScanDescription(String content) {
    if (content.startsWith('http')) {
      return content;
    } else if (content.startsWith('tel:')) {
      return content.substring(4);
    } else if (content.startsWith('WIFI:')) {
      final parts = content.split(';');
      for (final part in parts) {
        if (part.startsWith('S:')) {
          return 'WiFi: ${part.substring(2)}';
        }
      }
      return 'WiFi Network';
    } else if (content.startsWith('BEGIN:VCARD')) {
      final lines = content.split('\n');
      for (final line in lines) {
        if (line.startsWith('FN:')) {
          return 'Contact: ${line.substring(3)}';
        }
      }
      return 'Contact Information';
    } else {
      return content.length > 50 ? '${content.substring(0, 50)}...' : content;
    }
  }

  Future<void> _scanFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        try {
          final result = await ImageQRScannerService().scanImageFromFile(image.path);
          
          // Hide loading dialog
          Navigator.of(context).pop();
          
          if (result != null) {
            context.read<QRScannerBloc>().add(QRCodeScanned(result));
            // Save to history
            _saveToHistory(result.content);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No QR code found in the selected image')),
            );
          }
        } catch (e) {
          // Hide loading dialog
          Navigator.of(context).pop();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error scanning image: $e')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'QR Scanner',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.photo_library, color: Color(0xFF3B82F6)),
              onPressed: _scanFromGallery,
              tooltip: 'Scan from Gallery',
            ),
          ),
        ],
      ),
      body: BlocListener<QRScannerBloc, QRScannerState>(
        listener: (context, state) {
          if (state is QRScannerSuccess) {
            _showScanResultDialog(state.result);
          } else if (state is QRScannerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (!_isCameraPermissionGranted) {
      return _buildPermissionRequest();
    }

    return Column(
      children: [
        Expanded(
          child: _buildQRScanner(),
        ),
        _buildScanInstructions(),
      ],
    );
  }

  Widget _buildPermissionRequest() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                size: 80,
                color: Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Camera Permission Required',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'This app needs camera access to scan QR codes',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _requestCameraPermission,
                  child: const Center(
                    child: Text(
                      'Grant Permission',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRScanner() {
    return MobileScanner(
      controller: controller,
      onDetect: _onDetect,
      overlay: const QRScannerOverlay(),
    );
  }

  Widget _buildScanInstructions() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Point your camera at a QR code',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Or tap the gallery icon to scan from an image',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showScanResultDialog(QRScanResult result) {
    showDialog(
      context: context,
      builder: (context) => ScanResultDisplay(
        result: result,
                 onContinueScanning: () {
           Navigator.of(context).pop();
           controller?.start();
         },
      ),
    );
  }


}
