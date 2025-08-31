enum QRType { url, text, contact, wifi, unknown }

class QRScanResult {
  final String content;
  final QRType type;
  final String? title;
  final Map<String, dynamic>? metadata;

  const QRScanResult({
    required this.content,
    required this.type,
    this.title,
    this.metadata,
  });

  factory QRScanResult.fromScannedData(String scannedData) {
    // Check if it's a URL
    if (_isUrl(scannedData)) {
      return QRScanResult(
        content: scannedData,
        type: QRType.url,
        title: 'Website Link',
      );
    }

    // Check if it's a WiFi network
    if (scannedData.startsWith('WIFI:')) {
      return _parseWifiQR(scannedData);
    }

    // Check if it's a contact (vCard format)
    if (scannedData.startsWith('BEGIN:VCARD')) {
      return _parseContactQR(scannedData);
    }

    // Default to text
    return QRScanResult(
      content: scannedData,
      type: QRType.text,
      title: 'Text Content',
    );
  }

  static bool _isUrl(String text) {
    try {
      final uri = Uri.parse(text);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  static QRScanResult _parseWifiQR(String wifiData) {
    final Map<String, String> wifiInfo = {};
    
    // Parse WIFI:S:<SSID>;T:<WPA|WEP|nopass>;P:<password>;;
    final parts = wifiData.substring(5).split(';');
    
    for (final part in parts) {
      if (part.startsWith('S:')) {
        wifiInfo['ssid'] = part.substring(2);
      } else if (part.startsWith('T:')) {
        wifiInfo['type'] = part.substring(2);
      } else if (part.startsWith('P:')) {
        wifiInfo['password'] = part.substring(2);
      }
    }

    return QRScanResult(
      content: wifiData,
      type: QRType.wifi,
      title: 'WiFi Network: ${wifiInfo['ssid'] ?? 'Unknown'}',
      metadata: wifiInfo,
    );
  }

  static QRScanResult _parseContactQR(String contactData) {
    final Map<String, String> contactInfo = {};
    
    // Parse vCard format
    final lines = contactData.split('\n');
    for (final line in lines) {
      if (line.startsWith('FN:')) {
        contactInfo['name'] = line.substring(3);
      } else if (line.startsWith('TEL:')) {
        contactInfo['phone'] = line.substring(4);
      } else if (line.startsWith('EMAIL:')) {
        contactInfo['email'] = line.substring(6);
      }
    }

    return QRScanResult(
      content: contactData,
      type: QRType.contact,
      title: 'Contact: ${contactInfo['name'] ?? 'Unknown'}',
      metadata: contactInfo,
    );
  }

  @override
  String toString() {
    return 'QRScanResult(content: $content, type: $type, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QRScanResult &&
        other.content == content &&
        other.type == type &&
        other.title == title;
  }

  @override
  int get hashCode {
    return content.hashCode ^ type.hashCode ^ title.hashCode;
  }
}
