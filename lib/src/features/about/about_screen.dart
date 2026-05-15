import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_theme.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = info.version;
        _buildNumber = info.buildNumber;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          // Radial glow
          Positioned(
            top: 0, left: 0, right: 0, height: 280,
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.0,
                  colors: [kPrimaryGlow, Colors.transparent],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 44, height: 44,
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
                        'About',
                        style: GoogleFonts.inter(
                          fontSize: 20, fontWeight: FontWeight.w600, color: kText,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
                    child: Column(
                      children: [
                        // App icon + name
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.asset(
                            'assets/icon/icon_master_1024.png',
                            width: 96, height: 96,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'QR Panda',
                          style: GoogleFonts.inter(
                            fontSize: 26, fontWeight: FontWeight.w700,
                            letterSpacing: -0.5, color: kText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _version.isEmpty
                            ? const SizedBox(
                                width: 18, height: 18,
                                child: CircularProgressIndicator(
                                  color: kTextMuted, strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Version $_version ($_buildNumber)',
                                style: GoogleFonts.inter(
                                  fontSize: 13, color: kTextMuted,
                                ),
                              ),

                        const SizedBox(height: 32),

                        // About card
                        _infoCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _cardLabel('About'),
                              const SizedBox(height: 10),
                              Text(
                                'QR Panda is a clean, fast QR code tool built for everyday use. Scan any QR code with your camera or from your photo library, create custom QR codes for URLs, text, Wi-Fi, contacts and more, and manage your full history — all in one place.',
                                style: GoogleFonts.inter(
                                  fontSize: 14, color: kText2, height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Features card
                        _infoCard(
                          child: Column(
                            children: [
                              _featureRow(Icons.qr_code_scanner, kGreen, 'Scan QR Codes',
                                  'Camera & photo library support'),
                              _divider(),
                              _featureRow(Icons.add_box_outlined, kPrimary, 'Create QR Codes',
                                  'URL, Text, Wi-Fi, Phone & Contact'),
                              _divider(),
                              _featureRow(Icons.history, kAmber, 'History',
                                  'Browse and reuse past codes'),
                              _divider(),
                              _featureRow(Icons.star_rounded, kAmber, 'Premium',
                                  'One-time purchase — remove ads forever'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Links card
                        _infoCard(
                          child: Column(
                            children: [
                              _linkRow(
                                Icons.mail_outline_rounded,
                                kPrimary,
                                'Contact Support',
                                'mailto:dailysmartapps.info@gmail.com',
                              ),
                              _divider(),
                              _linkRow(
                                Icons.privacy_tip_outlined,
                                kTypeWifi,
                                'Privacy Policy',
                                'https://dailysmartapps.com/qr-panda/privacy-policy/',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        Text(
                          '© 2026 Daily Smart Apps\nAll rights reserved.',
                          style: GoogleFonts.inter(
                            fontSize: 12, color: kTextMuted, height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder, width: 1),
      ),
      child: child,
    );
  }

  Widget _cardLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w500,
        letterSpacing: 0.8, color: kTextMuted,
      ),
    );
  }

  Widget _divider() => Container(
        height: 1, color: kBorder,
        margin: const EdgeInsets.symmetric(vertical: 12),
      );

  Widget _featureRow(IconData icon, Color color, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w500, color: kText)),
              Text(subtitle,
                  style: GoogleFonts.inter(fontSize: 12, color: kText2)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _linkRow(IconData icon, Color color, String label, String url) {
    return GestureDetector(
      onTap: () => _launchUrl(url),
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w500, color: kText)),
          ),
          const Icon(Icons.chevron_right, color: kTextMuted, size: 18),
        ],
      ),
    );
  }
}
