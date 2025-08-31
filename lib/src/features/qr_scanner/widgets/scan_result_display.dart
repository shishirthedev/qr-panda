import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import '../models/qr_scan_result.dart';

class ScanResultDisplay extends StatelessWidget {
  final QRScanResult result;
  final VoidCallback onContinueScanning;

  const ScanResultDisplay({
    super.key,
    required this.result,
    required this.onContinueScanning,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(result.title ?? 'QR Code Detected'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTypeIndicator(),
            const SizedBox(height: 16),
            _buildContentDisplay(),
            if (result.metadata != null && result.metadata!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildMetadataDisplay(),
            ],
          ],
        ),
      ),
      actions: _buildActions(context),
    );
  }

  Widget _buildTypeIndicator() {
    IconData iconData;
    Color color;
    
    switch (result.type) {
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

    return Row(
      children: [
        Icon(iconData, color: color, size: 24),
        const SizedBox(width: 8),
        Text(
          result.type.name.toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildContentDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Content:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: SelectableText(
            result.content,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Details:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...result.metadata!.entries.map((entry) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  '${entry.key}:',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: Text(entry.value.toString()),
              ),
            ],
          ),
        )),
      ],
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final actions = <Widget>[];

    // Copy action
    actions.add(
      TextButton.icon(
        onPressed: () => _copyToClipboard(result.content),
        icon: const Icon(Icons.copy),
        label: const Text('Copy'),
      ),
    );

    // Share action
    actions.add(
      TextButton.icon(
        onPressed: () => _shareResult(result),
        icon: const Icon(Icons.share),
        label: const Text('Share'),
      ),
    );

    // Type-specific actions
    switch (result.type) {
      case QRType.url:
        actions.add(
          TextButton.icon(
            onPressed: () => _openLink(result.content),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open Link'),
          ),
        );
        break;
      case QRType.contact:
        actions.add(
          TextButton.icon(
            onPressed: () => _saveContact(result),
            icon: const Icon(Icons.person_add),
            label: const Text('Save Contact'),
          ),
        );
        break;
      case QRType.wifi:
        actions.add(
          TextButton.icon(
            onPressed: () => _connectToWifi(result),
            icon: const Icon(Icons.wifi),
            label: const Text('Connect'),
          ),
        );
        break;
      default:
        break;
    }

    // Continue scanning action
    actions.add(
      TextButton.icon(
        onPressed: onContinueScanning,
        icon: const Icon(Icons.camera_alt),
        label: const Text('Continue'),
      ),
    );

    return actions;
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    // Note: You might want to show a snackbar here, but it requires a BuildContext
    // Consider using a callback or different approach for user feedback
  }

  void _shareResult(QRScanResult result) {
    String shareText = 'QR Code Content: ${result.content}';
    if (result.title != null) {
      shareText = '${result.title}\n$shareText';
    }
    
    Share.share(shareText, subject: 'QR Code Scan Result');
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Handle error - you might want to show a snackbar or dialog
    }
  }

  void _saveContact(QRScanResult result) {
    // Implementation for saving contact to phone book
    // This would require additional packages like contacts_service
  }

  void _connectToWifi(QRScanResult result) {
    // Implementation for connecting to WiFi
    // This would require additional packages and platform-specific code
  }
}
