import 'package:flutter/material.dart';

enum QRGeneratorType { text, url, phone, wifi, contact }

class QRGeneratorData {
  final String qrContent;
  final Color foregroundColor;
  final Color backgroundColor;
  final String wifiSecurityType;

  const QRGeneratorData({
    this.qrContent = '',
    this.foregroundColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.wifiSecurityType = 'WPA',
  });

  factory QRGeneratorData.defaultValues() {
    return const QRGeneratorData(
      foregroundColor: Colors.black,
      backgroundColor: Colors.white,
      wifiSecurityType: 'WPA',
    );
  }

  QRGeneratorData copyWith({
    String? qrContent,
    Color? foregroundColor,
    Color? backgroundColor,
    String? wifiSecurityType,
  }) {
    return QRGeneratorData(
      qrContent: qrContent ?? this.qrContent,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      wifiSecurityType: wifiSecurityType ?? this.wifiSecurityType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QRGeneratorData &&
        other.qrContent == qrContent &&
        other.foregroundColor == foregroundColor &&
        other.backgroundColor == backgroundColor &&
        other.wifiSecurityType == wifiSecurityType;
  }

  // Create from Map (for database storage)
  factory QRGeneratorData.fromMap(Map<String, dynamic> map) {
    return QRGeneratorData(
      qrContent: map['qrContent'] ?? '',
      foregroundColor: Color(map['foregroundColor'] ?? Colors.black.value),
      backgroundColor: Color(map['backgroundColor'] ?? Colors.white.value),
      wifiSecurityType: map['wifiSecurityType'] ?? 'WPA',
    );
  }

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'qrContent': qrContent,
      'foregroundColor': foregroundColor.value,
      'backgroundColor': backgroundColor.value,
      'wifiSecurityType': wifiSecurityType,
    };
  }

  @override
  int get hashCode {
    return qrContent.hashCode ^
        foregroundColor.hashCode ^
        backgroundColor.hashCode ^
        wifiSecurityType.hashCode;
  }
}
