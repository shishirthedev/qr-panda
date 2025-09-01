import 'package:flutter/material.dart';

enum QRGeneratorType { text, url, phone, wifi, contact }

class QRGeneratorData {
  final String qrContent;
  final Color foregroundColor;
  final Color backgroundColor;
  final String wifiSecurityType;
  
  // Original form data for reuse
  final QRGeneratorType? originalType;
  final String? originalText;
  final String? originalUrl;
  final String? originalPhone;
  final String? originalSsid;
  final String? originalPassword;
  final String? originalName;
  final String? originalEmail;

  const QRGeneratorData({
    this.qrContent = '',
    this.foregroundColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.wifiSecurityType = 'WPA',
    this.originalType,
    this.originalText,
    this.originalUrl,
    this.originalPhone,
    this.originalSsid,
    this.originalPassword,
    this.originalName,
    this.originalEmail,
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
    QRGeneratorType? originalType,
    String? originalText,
    String? originalUrl,
    String? originalPhone,
    String? originalSsid,
    String? originalPassword,
    String? originalName,
    String? originalEmail,
  }) {
    return QRGeneratorData(
      qrContent: qrContent ?? this.qrContent,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      wifiSecurityType: wifiSecurityType ?? this.wifiSecurityType,
      originalType: originalType ?? this.originalType,
      originalText: originalText ?? this.originalText,
      originalUrl: originalUrl ?? this.originalUrl,
      originalPhone: originalPhone ?? this.originalPhone,
      originalSsid: originalSsid ?? this.originalSsid,
      originalPassword: originalPassword ?? this.originalPassword,
      originalName: originalName ?? this.originalName,
      originalEmail: originalEmail ?? this.originalEmail,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QRGeneratorData &&
        other.qrContent == qrContent &&
        other.foregroundColor == foregroundColor &&
        other.backgroundColor == backgroundColor &&
        other.wifiSecurityType == wifiSecurityType &&
        other.originalType == originalType &&
        other.originalText == originalText &&
        other.originalUrl == originalUrl &&
        other.originalPhone == originalPhone &&
        other.originalSsid == originalSsid &&
        other.originalPassword == originalPassword &&
        other.originalName == originalName &&
        other.originalEmail == originalEmail;
  }

  // Create from Map (for database storage)
  factory QRGeneratorData.fromMap(Map<String, dynamic> map) {
    return QRGeneratorData(
      qrContent: map['qrContent'] ?? '',
      foregroundColor: Color(map['foregroundColor'] ?? Colors.black.toARGB32()),
      backgroundColor: Color(map['backgroundColor'] ?? Colors.white.toARGB32()),
      wifiSecurityType: map['wifiSecurityType'] ?? 'WPA',
      originalType: map['originalType'] != null ? QRGeneratorType.values[map['originalType']] : null,
      originalText: map['originalText'],
      originalUrl: map['originalUrl'],
      originalPhone: map['originalPhone'],
      originalSsid: map['originalSsid'],
      originalPassword: map['originalPassword'],
      originalName: map['originalName'],
      originalEmail: map['originalEmail'],
    );
  }

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'qrContent': qrContent,
      'foregroundColor': foregroundColor.toARGB32(),
      'backgroundColor': backgroundColor.toARGB32(),
      'wifiSecurityType': wifiSecurityType,
      'originalType': originalType?.index,
      'originalText': originalText,
      'originalUrl': originalUrl,
      'originalPhone': originalPhone,
      'originalSsid': originalSsid,
      'originalPassword': originalPassword,
      'originalName': originalName,
      'originalEmail': originalEmail,
    };
  }

  @override
  int get hashCode {
    return qrContent.hashCode ^
        foregroundColor.hashCode ^
        backgroundColor.hashCode ^
        wifiSecurityType.hashCode ^
        originalType.hashCode ^
        originalText.hashCode ^
        originalUrl.hashCode ^
        originalPhone.hashCode ^
        originalSsid.hashCode ^
        originalPassword.hashCode ^
        originalName.hashCode ^
        originalEmail.hashCode;
  }
}
