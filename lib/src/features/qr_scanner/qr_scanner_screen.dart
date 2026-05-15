import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickqr/constants/strings.dart';
import '../../core/app_theme.dart';
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

enum _CameraPermissionState { unknown, granted, denied, permanentlyDenied }

class _QRScannerScreenState extends State<QRScannerScreen>
    with WidgetsBindingObserver {
  MobileScannerController? controller;
  final QRHistoryService _historyService = QRHistoryService();
  _CameraPermissionState _permissionState = _CameraPermissionState.unknown;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = MobileScannerController();
    _requestCameraPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }

  // Re-check whenever app resumes and camera isn't running yet
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _permissionState != _CameraPermissionState.granted) {
      _checkCameraPermission();
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    await _applyPermissionStatus(status);
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    await _applyPermissionStatus(status);
  }

  Future<void> _applyPermissionStatus(PermissionStatus status) async {
    if (!mounted) return;
    final wasGranted = _permissionState == _CameraPermissionState.granted;

    setState(() {
      if (status.isGranted) {
        _permissionState = _CameraPermissionState.granted;
      } else if (status.isPermanentlyDenied || status.isRestricted) {
        _permissionState = _CameraPermissionState.permanentlyDenied;
      } else {
        _permissionState = _CameraPermissionState.denied;
      }
    });

    // Permission just became granted — ensure the controller is running
    if (!wasGranted && status.isGranted) {
      await controller?.start();
    }
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

        _saveToHistory(result.content);
        controller?.stop();

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
      debugPrint('Failed to save to history: $e');
    }
  }

  String _getScanTitle(String content) {
    if (content.startsWith('http')) return AppStrings.urlQRCode;
    if (content.startsWith('tel:')) return AppStrings.phoneQRCode;
    if (content.startsWith('WIFI:')) return AppStrings.wifiQRCode;
    if (content.startsWith('BEGIN:VCARD')) return AppStrings.contactQRCode;
    return AppStrings.textQRCode;
  }

  String _getScanDescription(String content) {
    if (content.startsWith('http')) return content;
    if (content.startsWith('tel:')) return content.substring(4);
    if (content.startsWith('WIFI:')) {
      final parts = content.split(';');
      for (final part in parts) {
        if (part.startsWith('S:')) return '${AppStrings.wifiPrefix}${part.substring(2)}';
      }
      return AppStrings.wifiNetwork;
    }
    if (content.startsWith('BEGIN:VCARD')) {
      final lines = content.split('\n');
      for (final line in lines) {
        if (line.startsWith('FN:')) return '${AppStrings.contactPrefix}${line.substring(3)}';
      }
      return AppStrings.contactInformation;
    }
    return content.length > 50 ? '${content.substring(0, 50)}...' : content;
  }

  Future<void> _scanFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );

        try {
          final result = await ImageQRScannerService().scanImageFromFile(image.path);
          if (!mounted) return;
          Navigator.of(context).pop();

          if (result != null) {
            context.read<QRScannerBloc>().add(QRCodeScanned(result));
            _saveToHistory(result.content);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No QR code found in the selected image')),
            );
          }
        } catch (e) {
          if (!mounted) return;
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error scanning image: $e')),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: BlocListener<QRScannerBloc, QRScannerState>(
        listener: (context, state) {
          if (state is QRScannerSuccess) {
            _showScanResultSheet(state.result);
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
    if (_permissionState != _CameraPermissionState.granted) {
      return _buildPermissionRequest();
    }

    return Stack(
      children: [
        // Camera feed
        Positioned.fill(
          child: MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),
        ),
        // Overlay
        const Positioned.fill(child: QRScannerOverlay()),
        // Top bar
        Positioned(
          top: 52,
          left: 16,
          right: 16,
          child: _buildTopBar(),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        _glassButton(
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
          onTap: () => Navigator.of(context).pop(),
        ),
        const Spacer(),
        Text(
          'Scan QR',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        _glassButton(
          child: const Icon(Icons.photo_library_outlined, color: Colors.white, size: 22),
          onTap: _scanFromGallery,
        ),
      ],
    );
  }

  Widget _glassButton({required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0x8C141420),
              borderRadius: BorderRadius.circular(22),
            ),
            child: child,
          ),
        ),
      ),
    );
  }


  Widget _buildPermissionRequest() {
    final isPermanent =
        _permissionState == _CameraPermissionState.permanentlyDenied;

    final description = isPermanent
        ? 'Camera access was denied. Please enable it in your device Settings to scan QR codes.'
        : 'QR Panda needs camera access to scan QR codes. Please allow access when prompted.';

    final buttonLabel = isPermanent ? 'Open Settings' : 'Allow Camera Access';

    return Container(
      color: kBg,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: kRose),
              const SizedBox(height: 24),
              Text(
                'Camera Access Required',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: kText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: GoogleFonts.inter(fontSize: 14, color: kText2, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: isPermanent ? openAppSettings : _requestCameraPermission,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment(-1, -1),
                      end: Alignment(1, 1),
                      colors: [kPrimaryDark, kPrimary, kPrimaryLight],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        color: kPrimaryGlow,
                        blurRadius: 28,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      buttonLabel,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              if (isPermanent) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Go Back',
                    style: GoogleFonts.inter(fontSize: 14, color: kText2),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showScanResultSheet(QRScanResult result) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => ScanResultDisplay(
        result: result,
        onContinueScanning: () {
          controller?.start();
        },
      ),
    );
  }
}
