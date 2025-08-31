import 'package:flutter_test/flutter_test.dart';
import 'package:quickqr/src/features/qr_scanner/models/qr_scan_result.dart';

void main() {
  group('QRScanResult Tests', () {
    test('should parse URL correctly', () {
      const url = 'https://example.com';
      final result = QRScanResult.fromScannedData(url);
      
      expect(result.type, QRType.url);
      expect(result.content, url);
      expect(result.title, 'Website Link');
    });

    test('should parse WiFi QR correctly', () {
      const wifiData = 'WIFI:S:MyWiFi;T:WPA;P:mypassword123;;';
      final result = QRScanResult.fromScannedData(wifiData);
      
      expect(result.type, QRType.wifi);
      expect(result.content, wifiData);
      expect(result.title, 'WiFi Network: MyWiFi');
      expect(result.metadata?['ssid'], 'MyWiFi');
      expect(result.metadata?['type'], 'WPA');
      expect(result.metadata?['password'], 'mypassword123');
    });

    test('should parse contact QR correctly', () {
      const contactData = 'BEGIN:VCARD\nFN:John Doe\nTEL:+1234567890\nEMAIL:john@example.com\nEND:VCARD';
      final result = QRScanResult.fromScannedData(contactData);
      
      expect(result.type, QRType.contact);
      expect(result.content, contactData);
      expect(result.title, 'Contact: John Doe');
      expect(result.metadata?['name'], 'John Doe');
      expect(result.metadata?['phone'], '+1234567890');
      expect(result.metadata?['email'], 'john@example.com');
    });

    test('should parse text QR correctly', () {
      const textData = 'Hello, this is a text QR code!';
      final result = QRScanResult.fromScannedData(textData);
      
      expect(result.type, QRType.text);
      expect(result.content, textData);
      expect(result.title, 'Text Content');
    });

    test('should handle empty string', () {
      const emptyData = '';
      final result = QRScanResult.fromScannedData(emptyData);
      
      expect(result.type, QRType.text);
      expect(result.content, emptyData);
      expect(result.title, 'Text Content');
    });
  });
}
