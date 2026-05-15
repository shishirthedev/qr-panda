import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/qr_scan_result.dart';

class QRDemoPage extends StatelessWidget {
  const QRDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Examples'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test QR Codes',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildQRExample(
              title: 'Website URL',
              subtitle: 'https://example.com',
              qrData: 'https://example.com',
              type: QRType.url,
            ),
            const SizedBox(height: 16),
            _buildQRExample(
              title: 'WiFi Network',
              subtitle: 'SSID: TestWiFi, Password: testpass123',
              qrData: 'WIFI:S:TestWiFi;T:WPA;P:testpass123;;',
              type: QRType.wifi,
            ),
            const SizedBox(height: 16),
            _buildQRExample(
              title: 'Contact Information',
              subtitle: 'John Doe - +1234567890',
              qrData: 'BEGIN:VCARD\nFN:John Doe\nTEL:+1234567890\nEMAIL:john@example.com\nEND:VCARD',
              type: QRType.contact,
            ),
            const SizedBox(height: 16),
            _buildQRExample(
              title: 'Plain Text',
              subtitle: 'Hello, this is a test QR code!',
              qrData: 'Hello, this is a test QR code!',
              type: QRType.text,
            ),
            const SizedBox(height: 32),
            const Text(
              'Instructions:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. Open the QR Scanner from the home page\n'
              '2. Point your camera at any of these QR codes\n'
              '3. Test the different result types and actions\n'
              '4. Try scanning from gallery by saving these QR codes as images',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRExample({
    required String title,
    required String subtitle,
    required String qrData,
    required QRType type,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                _buildTypeIcon(type),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeIcon(QRType type) {
    IconData iconData;
    Color color;
    
    switch (type) {
      case QRType.url:
        iconData = Icons.link;
        color = Colors.blue;
        break;
      case QRType.contact:
        iconData = Icons.person;
        color = Colors.green;
        break;
      case QRType.wifi:
        iconData = Icons.wifi;
        color = Colors.orange;
        break;
      case QRType.text:
      default:
        iconData = Icons.text_fields;
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: color, size: 24),
    );
  }
}
