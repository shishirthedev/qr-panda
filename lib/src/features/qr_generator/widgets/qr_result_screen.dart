import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../models/qr_history_item.dart';
import '../../../services/qr_history_service.dart';
import '../models/qr_generator_data.dart';
import '../widgets/qr_customization_panel.dart';

class QRResultScreen extends StatefulWidget {
  final QRGeneratorData qrData;
  final String qrContent;

  const QRResultScreen({
    super.key,
    required this.qrData,
    required this.qrContent,
  });

  @override
  State<QRResultScreen> createState() => _QRResultScreenState();
}

class _QRResultScreenState extends State<QRResultScreen> {
  final _qrKey = GlobalKey();
  final QRHistoryService _historyService = QRHistoryService();
  late QRGeneratorData _qrData;

  @override
  void initState() {
    super.initState();
    _qrData = widget.qrData.copyWith(qrContent: widget.qrContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'QR Code Result',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.save, color: Color(0xFF10B981)),
              onPressed: _saveQRCode,
              tooltip: 'Save QR Code',
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.share, color: Color(0xFF3B82F6)),
              onPressed: _shareQRCode,
              tooltip: 'Share QR Code',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // QR Code Display
            _buildQRCodeDisplay(),
            const SizedBox(height: 24),
            
            // Customization Panel
            _buildCustomizationPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCodeDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Generated QR Code',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: RepaintBoundary(
            key: _qrKey,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: QrImageView(
                data: _qrData.qrContent,
                version: QrVersions.auto,
                size: 300.0,
                backgroundColor: _qrData.backgroundColor,
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: _qrData.foregroundColor,
                ),
                eyeStyle: QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: _qrData.foregroundColor,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        
        // Action Buttons
        Row(
          children: [
            Expanded(
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _saveQRCode,
                    child: const Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.save,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Save to History',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _shareQRCode,
                    child: const Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.share,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Share QR Code',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomizationPanel() {
    return QRCustomizationPanel(
      qrData: _qrData,
      onDataChanged: (data) {
        setState(() {
          _qrData = data;
        });
      },
    );
  }

  Future<void> _saveQRCode() async {
    try {
      final historyItem = QRHistoryItem.fromGenerated(
        content: _qrData.qrContent,
        qrData: _qrData,
        title: _getQRCodeTitle(),
        description: _getQRCodeDescription(),
      );
      
      await _historyService.insertQRHistory(historyItem);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('QR Code saved to history'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save QR code: $e'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _shareQRCode() async {
    try {
      String shareText = 'QR Code Content: ${_qrData.qrContent}';
      if (_qrData.qrContent.isNotEmpty) {
        shareText = 'Check out this QR code!\n\nContent: ${_qrData.qrContent}';
      }
      
      await Share.share(shareText, subject: 'QR Code from QuickQR');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share QR code: $e'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  String _getQRCodeTitle() {
    final content = _qrData.qrContent;
    if (content.startsWith('http')) {
      return 'URL QR Code';
    } else if (content.startsWith('tel:')) {
      return 'Phone QR Code';
    } else if (content.startsWith('WIFI:')) {
      return 'WiFi QR Code';
    } else if (content.startsWith('BEGIN:VCARD')) {
      return 'Contact QR Code';
    } else {
      return 'Text QR Code';
    }
  }

  String _getQRCodeDescription() {
    final content = _qrData.qrContent;
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
}
