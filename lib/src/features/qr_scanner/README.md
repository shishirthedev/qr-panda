# QR Code Scanner Feature

This feature provides comprehensive QR code scanning functionality for the QuickQR app.

## Features

- **Camera-based QR scanning** using device camera
- **Gallery image scanning** for QR codes in saved images
- **Multiple QR format support**:
  - URLs (http/https)
  - WiFi network credentials
  - Contact information (vCard format)
  - Plain text
- **Smart result parsing** with metadata extraction
- **Action options** for each QR type:
  - Copy to clipboard
  - Share content
  - Open links (for URLs)
  - Save contacts (for contact QR codes)
  - Connect to WiFi (for WiFi QR codes)

## Components

### Core Files
- `qr_scanner_screen.dart` - Main scanner interface
- `qr_scanner_bloc.dart` - Business logic controller
- `qr_scanner_event.dart` - Event definitions
- `qr_scanner_state.dart` - State definitions
- `models/qr_scan_result.dart` - QR result data model

### Services
- `image_qr_scanner_service.dart` - Image-based QR detection using Google ML Kit

### Widgets
- `scan_result_display.dart` - Enhanced result display with type-specific actions

## Usage

### Basic Implementation

```dart
import 'package:quickqr/src/features/qr_scanner/qr_scanner.dart';

// In your app's navigation
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BlocProvider(
      create: (context) => QRScannerBloc(),
      child: const QRScannerScreen(),
    ),
  ),
);
```

### Customization

The scanner can be customized by modifying:
- Camera overlay appearance in `_buildQRScanner()`
- Result display layout in `ScanResultDisplay`
- QR type parsing logic in `QRScanResult.fromScannedData()`

## Dependencies

- `camera` - Camera access
- `qr_code_scanner` - Real-time QR scanning
- `image_picker` - Gallery image selection
- `google_ml_kit` - Image-based QR detection
- `permission_handler` - Camera permissions
- `url_launcher` - Opening URLs
- `share_plus` - Sharing content

## Permissions

The app requires camera permission for scanning. This is handled automatically with a user-friendly permission request dialog.

## Testing

Run the tests with:
```bash
flutter test test/qr_scanner_test.dart
```

## Future Enhancements

- Contact saving to phone book
- WiFi network connection
- QR code history
- Batch scanning
- Custom QR format support
