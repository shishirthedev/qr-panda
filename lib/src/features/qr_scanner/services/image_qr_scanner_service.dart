import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import '../models/qr_scan_result.dart';

class ImageQRScannerService {
  static final ImageQRScannerService _instance = ImageQRScannerService._internal();
  factory ImageQRScannerService() => _instance;
  ImageQRScannerService._internal();

  final BarcodeScanner _barcodeScanner = GoogleMlKit.vision.barcodeScanner();

  Future<QRScanResult?> scanImageFromFile(String imagePath) async {
    try {
      final inputImage = InputImage.fromFile(File(imagePath));
      final List<Barcode> barcodes = await _barcodeScanner.processImage(inputImage);

      if (barcodes.isNotEmpty) {
        final barcode = barcodes.first;
        if (barcode.rawValue != null) {
          return QRScanResult.fromScannedData(barcode.rawValue!);
        }
      }

      return null;
    } catch (e) {
      throw Exception('Error scanning image: $e');
    }
  }

  Future<QRScanResult?> scanImageFromBytes(Uint8List imageBytes) async {
    try {
      final inputImage = InputImage.fromBytes(
        bytes: imageBytes,
        metadata: InputImageMetadata(
          size: const Size(0, 0), // Size will be determined automatically
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.bgra8888,
          bytesPerRow: 0,
        ),
      );

      final List<Barcode> barcodes = await _barcodeScanner.processImage(inputImage);

      if (barcodes.isNotEmpty) {
        final barcode = barcodes.first;
        if (barcode.rawValue != null) {
          return QRScanResult.fromScannedData(barcode.rawValue!);
        }
      }

      return null;
    } catch (e) {
      throw Exception('Error scanning image bytes: $e');
    }
  }

  void dispose() {
    _barcodeScanner.close();
  }
}
