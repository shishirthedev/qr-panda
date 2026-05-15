import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/app_theme.dart';
import '../../services/ad_service.dart';
import '../../services/premium_service.dart';
import '../about/about_screen.dart';
import '../premium/paywall_screen.dart';
import '../history/history_screen.dart';
import '../qr_generator/qr_generator.dart';
import '../qr_scanner/qr_scanner.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isPremium = false;
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _isPremium = PremiumService.instance.isPremium;
    PremiumService.instance.isPremiumNotifier.addListener(_onPremiumChanged);

    // Load banner if ads are already ready; otherwise wait for them.
    if (AdService.instance.adsReadyNotifier.value) {
      _loadBanner();
    } else {
      AdService.instance.adsReadyNotifier.addListener(_onAdsReady);
    }
  }

  @override
  void dispose() {
    PremiumService.instance.isPremiumNotifier.removeListener(_onPremiumChanged);
    AdService.instance.adsReadyNotifier.removeListener(_onAdsReady);
    _bannerAd?.dispose();
    super.dispose();
  }

  void _onPremiumChanged() {
    if (!mounted) return;
    setState(() {
      _isPremium = PremiumService.instance.isPremium;
    });
    // Remove banner when user upgrades to premium
    if (_isPremium) {
      _bannerAd?.dispose();
      setState(() => _bannerAd = null);
    }
  }

  void _onAdsReady() {
    AdService.instance.adsReadyNotifier.removeListener(_onAdsReady);
    _loadBanner();
  }

  void _loadBanner() {
    if (_isPremium) return;

    final config = AdService.instance.config;
    if (!config.bannerAdsEnabled || config.bannerAdUnitId.isEmpty) return;

    final ad = BannerAd(
      adUnitId: config.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() {});
        },
        onAdFailedToLoad: (failedAd, error) {
          debugPrint('[HomePage] Banner failed: ${error.message}');
          failedAd.dispose();
          if (mounted) setState(() => _bannerAd = null);
        },
      ),
    );
    _bannerAd = ad;
    ad.load();
  }

  @override
  Widget build(BuildContext context) {
    final bannerHeight = _bannerAd?.size.height.toDouble() ?? 0;

    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          // Radial glow background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 320,
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
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 32 + bannerHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildTopBar(),
                  if (!_isPremium) ...[
                    const SizedBox(height: 16),
                    _buildPremiumBanner(),
                  ],
                  const SizedBox(height: 28),
                  _buildHeroText(),
                  const SizedBox(height: 28),
                  _buildFeatureCard(
                    accentColor: kGreen,
                    icon: Icons.qr_code_scanner,
                    title: 'Scan QR Code',
                    subtitle: 'Point your camera at any QR code',
                    onTap: () => _navigateToQRScanner(context),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureCard(
                    accentColor: kPrimary,
                    icon: Icons.add_box_outlined,
                    title: 'Create QR Code',
                    subtitle: 'Create QR codes for text, URL, WiFi & more',
                    onTap: () => _navigateToQRGenerator(context),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureCard(
                    accentColor: kAmber,
                    icon: Icons.history,
                    title: 'History',
                    subtitle: 'Browse and reuse your past codes',
                    onTap: () => _navigateToHistory(context),
                  ),
                ],
              ),
            ),
          ),
          // Banner ad pinned at the bottom above the home indicator
          if (_bannerAd != null && !_isPremium)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                child: Container(
                  height: bannerHeight,
                  color: kBg,
                  alignment: Alignment.center,
                  child: AdWidget(ad: _bannerAd!),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/icon/icon_master_1024.png',
            width: 32,
            height: 32,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'QR Panda',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: kText,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.info_outline_rounded, color: kText2),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AboutScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumBanner() {
    return GestureDetector(
      onTap: () => _showPremiumSheet(context),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [kAmber, Color(0xFFF97316)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Text(
              '✦ GO PREMIUM — REMOVE ADS',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.8,
                color: const Color(0xFF1F1108),
              ),
            ),
            const Spacer(),
            Text(
              'Unlock ›',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1F1108),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Scan. Create. Manage.',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: kText,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Everything QR, in one place.',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: kText2,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required Color accentColor,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(22, 18, 18, 18),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 52,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 24, color: accentColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: kText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(fontSize: 13, color: kText2),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: kTextMuted),
          ],
        ),
      ),
    );
  }

  void _navigateToQRScanner(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => QRScannerBloc(),
          child: const QRScannerScreen(),
        ),
      ),
    );
  }

  void _navigateToQRGenerator(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRGeneratorScreen()),
    );
  }

  void _navigateToHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryScreen()),
    );
  }

  void _showPremiumSheet(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PaywallScreen()),
    );
  }
}
