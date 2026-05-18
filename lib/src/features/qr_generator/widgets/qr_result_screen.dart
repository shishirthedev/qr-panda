import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/app_theme.dart';
import '../../../models/qr_history_item.dart';
import '../../../services/ad_service.dart';
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

  Color get _accentColor {
    final c = widget.qrContent;
    if (c.startsWith('http')) return kTypeUrl;
    if (c.startsWith('tel:')) return kTypePhone;
    if (c.startsWith('WIFI:')) return kTypeWifi;
    if (c.startsWith('BEGIN:VCARD')) return kTypeContact;
    return kTypeText;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Stack(
          children: [
            // Radial glow
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 300,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.0,
                    colors: [
                      _accentColor.withValues(alpha: 0.16),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: kSurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: kBorder),
                          ),
                          child: const Icon(Icons.arrow_back, color: kText, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'QR Code',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: kText,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // QR code
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: _accentColor.withValues(alpha: 0.30),
                                  blurRadius: 32,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: RepaintBoundary(
                              key: _qrKey,
                              child: QrImageView(
                                data: _qrData.qrContent,
                                version: QrVersions.auto,
                                size: 260,
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

                        // Color dots
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _colorDot(_qrData.foregroundColor),
                            const SizedBox(width: 8),
                            _colorDot(_qrData.backgroundColor),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Summary card
                        Container(
                          decoration: BoxDecoration(
                            color: kSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: kBorder, width: 1),
                          ),
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _accentColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getContentIcon(),
                                  color: _accentColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getQRCodeTitle(),
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: kText2,
                                      ),
                                    ),
                                    Text(
                                      _getQRCodeDescription(),
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: kText,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Action buttons (2×2 grid)
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _actionButton(
                                    icon: Icons.save_outlined,
                                    label: 'Save',
                                    onTap: _saveQRCode,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _actionButton(
                                    icon: Icons.download_outlined,
                                    label: 'Download',
                                    onTap: _downloadQRCode,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _actionButton(
                                    icon: Icons.share_outlined,
                                    label: 'Share',
                                    onTap: _shareQRCode,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _actionButton(
                                    icon: Icons.edit_outlined,
                                    label: 'Edit',
                                    onTap: () => Navigator.of(context).pop(),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Customization panel
                        QRCustomizationPanel(
                          qrData: _qrData,
                          onDataChanged: (data) {
                            setState(() => _qrData = data);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _colorDot(Color color) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: kSurface2, width: 3),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kPrimary, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: kPrimaryLight, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: kPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getContentIcon() {
    final c = _qrData.qrContent;
    if (c.startsWith('http')) return Icons.link;
    if (c.startsWith('tel:')) return Icons.phone;
    if (c.startsWith('WIFI:')) return Icons.wifi;
    if (c.startsWith('BEGIN:VCARD')) return Icons.person;
    return Icons.text_fields;
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
      AdService.instance.recordAction();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR Code saved to history')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save QR code: $e')),
        );
      }
    }
  }

  Future<void> _downloadQRCode() async {
    try {
      final boundary = _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final result = await ImageGallerySaver.saveImage(
        pngBytes,
        quality: 100,
        name: 'qr_panda_${DateTime.now().millisecondsSinceEpoch}',
      );
      if (mounted) {
        final success = result['isSuccess'] == true || result['filePath'] != null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'QR code saved to gallery' : 'Failed to save image'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download: $e')),
        );
      }
    }
  }

  Future<void> _shareQRCode() async {
    try {
      final boundary = _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final pngBytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/qr_panda_share.png');
      await file.writeAsBytes(pngBytes);
      await SharePlus.instance.share(
        ShareParams(
          text: 'Check out this QR code!\n\nContent: ${_qrData.qrContent}',
          subject: 'QR Code from QR Panda',
          files: [XFile(file.path)],
        ),
      );
      AdService.instance.recordAction();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share QR code: $e')),
        );
      }
    }
  }

  String _getQRCodeTitle() {
    final c = _qrData.qrContent;
    if (c.startsWith('http')) return 'URL QR Code';
    if (c.startsWith('tel:')) return 'Phone QR Code';
    if (c.startsWith('WIFI:')) return 'WiFi QR Code';
    if (c.startsWith('BEGIN:VCARD')) return 'Contact QR Code';
    return 'Text QR Code';
  }

  String _getQRCodeDescription() {
    final c = _qrData.qrContent;
    if (c.startsWith('http')) return c;
    if (c.startsWith('tel:')) return c.substring(4);
    if (c.startsWith('WIFI:')) {
      for (final part in c.split(';')) {
        if (part.startsWith('S:')) return 'WiFi: ${part.substring(2)}';
      }
      return 'WiFi Network';
    }
    if (c.startsWith('BEGIN:VCARD')) {
      for (final line in c.split('\n')) {
        if (line.startsWith('FN:')) return 'Contact: ${line.substring(3)}';
      }
      return 'Contact Information';
    }
    return c.length > 50 ? '${c.substring(0, 50)}...' : c;
  }
}
