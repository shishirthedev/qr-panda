import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../core/app_theme.dart';
import '../../../services/ad_service.dart';
import '../../../services/premium_service.dart';
import '../models/qr_scan_result.dart';

class ScanResultDisplay extends StatefulWidget {
  final QRScanResult result;
  final VoidCallback onContinueScanning;

  const ScanResultDisplay({
    super.key,
    required this.result,
    required this.onContinueScanning,
  });

  @override
  State<ScanResultDisplay> createState() => _ScanResultDisplayState();
}

class _ScanResultDisplayState extends State<ScanResultDisplay> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBanner() {
    if (PremiumService.instance.isPremium) return;
    final config = AdService.instance.config;
    if (!config.bannerAdsEnabled || config.bannerAdUnitId.isEmpty) return;
    BannerAd(
      adUnitId: config.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _bannerAd = ad as BannerAd);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    ).load();
  }

  QRScanResult get result => widget.result;
  VoidCallback get onContinueScanning => widget.onContinueScanning;

  Color get _typeColor {
    switch (result.type) {
      case QRType.url:
        return kTypeUrl;
      case QRType.contact:
        return kTypeContact;
      case QRType.wifi:
        return kTypeWifi;
      default:
        return kTypeText;
    }
  }

  String get _typeLabel {
    switch (result.type) {
      case QRType.url:
        return 'URL';
      case QRType.contact:
        return 'CONTACT';
      case QRType.wifi:
        return 'WIFI';
      default:
        return 'TEXT';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kSurface2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: kBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _typeColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _typeLabel,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.8,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Content heading
          Text(
            result.content,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: kText,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 16),

          // Banner ad above actions
          if (_bannerAd != null)
            SizedBox(
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),

          const SizedBox(height: 16),

          // Actions row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAction(
                context,
                icon: Icons.copy,
                label: 'Copy',
                onTap: () => _copyToClipboard(context, result.content),
              ),
              _buildAction(
                context,
                icon: Icons.open_in_new,
                label: 'Open',
                onTap: result.type == QRType.url
                    ? () => _openLink(context, result.content)
                    : null,
              ),
              _buildAction(
                context,
                icon: Icons.share,
                label: 'Share',
                onTap: () => _shareResult(result),
              ),
              _buildAction(
                context,
                icon: Icons.qr_code_scanner,
                label: 'Scan Again',
                onTap: () {
                  Navigator.of(context).pop();
                  onContinueScanning();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: kSurface,
              border: Border.all(color: kBorder, width: 1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: onTap != null ? kPrimary : kTextMuted,
              size: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 12, color: kText2),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  void _shareResult(QRScanResult result) {
    String shareText = 'QR Code Content: ${result.content}';
    if (result.title != null) {
      shareText = '${result.title}\n$shareText';
    }
    Share.share(shareText, subject: 'QR Code Scan Result');
  }

  Future<void> _openLink(BuildContext context, String url) async {
    try {
      String urlToLaunch = url.trim();
      if (urlToLaunch.isEmpty) throw Exception('Empty URL');

      if (!urlToLaunch.startsWith('http://') &&
          !urlToLaunch.startsWith('https://')) {
        if (urlToLaunch.contains('.') && !urlToLaunch.contains(' ')) {
          urlToLaunch = 'https://$urlToLaunch';
        } else {
          throw Exception('Invalid URL format');
        }
      }

      final uri = Uri.parse(urlToLaunch);
      if (uri.host.isEmpty) throw Exception('Invalid URL: no host found');

      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open: $urlToLaunch')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening link: $e')),
        );
      }
    }
  }
}
