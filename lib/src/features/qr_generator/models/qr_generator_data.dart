import 'package:flutter/material.dart';
import 'dart:ui' as ui;

enum QRGeneratorType { text, url, phone, wifi, contact }

class QRGeneratorData {
  final String qrContent;
  final double size;
  final Color foregroundColor;
  final Color backgroundColor;
  final ui.Image? logoImage;
  final String wifiSecurityType;

  const QRGeneratorData({
    this.qrContent = '',
    this.size = 300.0,
    this.foregroundColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.logoImage,
    this.wifiSecurityType = 'WPA',
  });

  factory QRGeneratorData.defaultValues() {
    return const QRGeneratorData(
      size: 300.0,
      foregroundColor: Colors.black,
      backgroundColor: Colors.white,
      wifiSecurityType: 'WPA',
    );
  }

  QRGeneratorData copyWith({
    String? qrContent,
    double? size,
    Color? foregroundColor,
    Color? backgroundColor,
    ui.Image? logoImage,
    String? wifiSecurityType,
  }) {
    return QRGeneratorData(
      qrContent: qrContent ?? this.qrContent,
      size: size ?? this.size,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      logoImage: logoImage ?? this.logoImage,
      wifiSecurityType: wifiSecurityType ?? this.wifiSecurityType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QRGeneratorData &&
        other.qrContent == qrContent &&
        other.size == size &&
        other.foregroundColor == foregroundColor &&
        other.backgroundColor == backgroundColor &&
        other.logoImage == logoImage &&
        other.wifiSecurityType == wifiSecurityType;
  }

  // Create from Map (for database storage)
  factory QRGeneratorData.fromMap(Map<String, dynamic> map) {
    return QRGeneratorData(
      qrContent: map['qrContent'] ?? '',
      size: map['size']?.toDouble() ?? 300.0,
      foregroundColor: Color(map['foregroundColor'] ?? Colors.black.value),
      backgroundColor: Color(map['backgroundColor'] ?? Colors.white.value),
      wifiSecurityType: map['wifiSecurityType'] ?? 'WPA',
      // Note: logoImage cannot be serialized easily, so we'll skip it
    );
  }

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'qrContent': qrContent,
      'size': size,
      'foregroundColor': foregroundColor.value,
      'backgroundColor': backgroundColor.value,
      'wifiSecurityType': wifiSecurityType,
      // Note: logoImage is not included as it cannot be easily serialized
    };
  }

  @override
  int get hashCode {
    return qrContent.hashCode ^
        size.hashCode ^
        foregroundColor.hashCode ^
        backgroundColor.hashCode ^
        logoImage.hashCode ^
        wifiSecurityType.hashCode;
  }
}
