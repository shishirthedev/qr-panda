import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/qr_generator_data.dart';

class QRGeneratorDemoPage extends StatelessWidget {
  const QRGeneratorDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Generator Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'QR Code Examples',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Here are examples of different types of QR codes you can generate:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            _buildQRExample(
              context,
              title: 'Text QR Code',
              subtitle: 'Simple text content',
              qrData: 'Hello World! This is a sample text QR code.',
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            _buildQRExample(
              context,
              title: 'URL QR Code',
              subtitle: 'Website link',
              qrData: 'https://flutter.dev',
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            _buildQRExample(
              context,
              title: 'Phone QR Code',
              subtitle: 'Phone number for easy dialing',
              qrData: 'tel:+1234567890',
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            _buildQRExample(
              context,
              title: 'WiFi QR Code',
              subtitle: 'Network credentials',
              qrData: 'WIFI:S:MyWiFi;T:WPA;P:mypassword123;;',
              color: Colors.purple,
            ),
            const SizedBox(height: 24),
            _buildQRExample(
              context,
              title: 'Contact QR Code',
              subtitle: 'vCard format contact information',
              qrData: '''BEGIN:VCARD
VERSION:3.0
FN:John Doe
TEL:+1234567890
EMAIL:john@example.com
END:VCARD''',
              color: Colors.teal,
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Home'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRExample(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String qrData,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.qr_code,
                    color: color,
                    size: 24,
                  ),
                ),
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
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: Colors.white,
                  foregroundColor: color,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'QR Content:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    qrData,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
