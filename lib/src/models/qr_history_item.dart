import 'package:flutter/material.dart';
import '../features/qr_generator/models/qr_generator_data.dart';

enum QRHistoryType { scanned, generated }

class QRHistoryItem {
  final String id;
  final String content;
  final QRHistoryType type;
  final DateTime timestamp;
  final String? title;
  final String? description;
  final Map<String, dynamic>? metadata;
  final String? qrImagePath; // Path to saved QR image
  final QRGeneratorData? qrData; // For generated QR codes

  const QRHistoryItem({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.title,
    this.description,
    this.metadata,
    this.qrImagePath,
    this.qrData,
  });

  // Create from scanned QR code
  factory QRHistoryItem.fromScanned({
    required String content,
    String? title,
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return QRHistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: QRHistoryType.scanned,
      timestamp: DateTime.now(),
      title: title,
      description: description,
      metadata: metadata,
    );
  }

  // Create from generated QR code
  factory QRHistoryItem.fromGenerated({
    required String content,
    required QRGeneratorData qrData,
    String? title,
    String? description,
  }) {
    return QRHistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: QRHistoryType.generated,
      timestamp: DateTime.now(),
      title: title,
      description: description,
      qrData: qrData,
    );
  }

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'type': type.index,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'title': title,
      'description': description,
      'metadata': metadata,
      'qrImagePath': qrImagePath,
      'qrData': qrData?.toMap(),
    };
  }

  // Create from Map (from database)
  factory QRHistoryItem.fromMap(Map<String, dynamic> map) {
    return QRHistoryItem(
      id: map['id'],
      content: map['content'],
      type: QRHistoryType.values[map['type']],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      title: map['title'],
      description: map['description'],
      metadata: map['metadata'],
      qrImagePath: map['qrImagePath'],
      qrData: map['qrData'] != null ? QRGeneratorData.fromMap(map['qrData']) : null,
    );
  }

  // Copy with method for updates
  QRHistoryItem copyWith({
    String? id,
    String? content,
    QRHistoryType? type,
    DateTime? timestamp,
    String? title,
    String? description,
    Map<String, dynamic>? metadata,
    String? qrImagePath,
    QRGeneratorData? qrData,
  }) {
    return QRHistoryItem(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      title: title ?? this.title,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
      qrImagePath: qrImagePath ?? this.qrImagePath,
      qrData: qrData ?? this.qrData,
    );
  }

  // Get display title
  String get displayTitle {
    if (title != null && title!.isNotEmpty) {
      return title!;
    }
    
    // Generate title from content
    if (content.startsWith('http')) {
      return 'URL';
    } else if (content.startsWith('tel:')) {
      return 'Phone Number';
    } else if (content.startsWith('WIFI:')) {
      return 'WiFi Network';
    } else if (content.startsWith('BEGIN:VCARD')) {
      return 'Contact';
    } else {
      return 'Text';
    }
  }

  // Get display description
  String get displayDescription {
    if (description != null && description!.isNotEmpty) {
      return description!;
    }
    
    // Generate description from content
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

  // Get icon based on content type
  IconData get icon {
    if (content.startsWith('http')) {
      return Icons.link;
    } else if (content.startsWith('tel:')) {
      return Icons.phone;
    } else if (content.startsWith('WIFI:')) {
      return Icons.wifi;
    } else if (content.startsWith('BEGIN:VCARD')) {
      return Icons.person;
    } else {
      return Icons.text_fields;
    }
  }

  // Get color based on content type
  Color get color {
    if (content.startsWith('http')) {
      return const Color(0xFF10B981);
    } else if (content.startsWith('tel:')) {
      return const Color(0xFFF59E0B);
    } else if (content.startsWith('WIFI:')) {
      return const Color(0xFF8B5CF6);
    } else if (content.startsWith('BEGIN:VCARD')) {
      return const Color(0xFF14B8A6);
    } else {
      return const Color(0xFF3B82F6);
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QRHistoryItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
