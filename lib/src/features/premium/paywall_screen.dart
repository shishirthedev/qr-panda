import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_theme.dart';
import '../../services/ad_service.dart';
import '../../services/premium_service.dart';


class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  @override
  void initState() {
    super.initState();
    PremiumService.instance.isPremiumNotifier.addListener(_onPremiumChanged);
    PremiumService.instance.isPurchasingNotifier.addListener(_rebuild);
    PremiumService.instance.priceNotifier.addListener(_rebuild);
    // Re-fetch price if not yet loaded (e.g. store was slow on app launch)
    if (PremiumService.instance.localizedPrice == null) {
      PremiumService.instance.fetchProductDetails();
    }
  }

  @override
  void dispose() {
    PremiumService.instance.isPremiumNotifier.removeListener(_onPremiumChanged);
    PremiumService.instance.isPurchasingNotifier.removeListener(_rebuild);
    PremiumService.instance.priceNotifier.removeListener(_rebuild);
    super.dispose();
  }

  void _onPremiumChanged() {
    if (!mounted) return;
    if (PremiumService.instance.isPremium) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🎉 You\'re now Premium! Ads removed.',
            style: GoogleFonts.inter(color: kText),
          ),
          backgroundColor: kSurface2,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isPurchasing = PremiumService.instance.isPurchasingNotifier.value;
    final price = PremiumService.instance.localizedPrice;

    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          // Background glow
          Positioned(
            top: -100,
            left: -60,
            right: -60,
            height: 420,
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 0.9,
                  colors: [Color(0x33F5A623), Colors.transparent],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
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
                          child: const Icon(Icons.close,
                              color: kText2, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [kAmber, Color(0xFFF97316)],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: kAmber.withValues(alpha: 0.35),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.star_rounded,
                              color: Colors.white, size: 40),
                        ),
                        const SizedBox(height: 20),

                        // Title
                        Text(
                          'QR Panda Premium',
                          style: GoogleFonts.inter(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                            color: kText,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'One-time purchase. No subscriptions, ever.',
                          style: GoogleFonts.inter(
                              fontSize: 14, color: kText2, height: 1.5),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),

                        // Feature list
                        _buildFeatureRow(
                          Icons.block,
                          kRose,
                          'Remove Ads',
                          'Clean, distraction-free experience forever',
                        ),
                        const SizedBox(height: 14),
                        _buildFeatureRow(
                          Icons.all_inclusive_rounded,
                          kPrimary,
                          'Lifetime Access',
                          'Pay once, use forever — no renewals',
                        ),
                        const SizedBox(height: 14),
                        _buildFeatureRow(
                          Icons.devices_rounded,
                          kGreen,
                          'All Devices',
                          'Restore your purchase on any device',
                        ),

                        const SizedBox(height: 32),

                        // Price card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                          decoration: BoxDecoration(
                            color: kSurface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: kAmber.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: kAmber.withValues(alpha: 0.10),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Remove Ads',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: kText,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'One-time purchase',
                                      style: GoogleFonts.inter(
                                          fontSize: 12, color: kText2),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  price != null
                                      ? Text(
                                          price,
                                          style: GoogleFonts.inter(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w700,
                                            color: kAmber,
                                          ),
                                        )
                                      : const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            color: kAmber,
                                            strokeWidth: 2.5,
                                          ),
                                        ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'lifetime',
                                    style: GoogleFonts.inter(
                                        fontSize: 11, color: kText2),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Buy button
                        GestureDetector(
                          onTap: isPurchasing
                              ? null
                              : () => PremiumService.instance.purchase(),
                          child: Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [kAmber, Color(0xFFF97316)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: kAmber.withValues(alpha: 0.40),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: isPurchasing
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      price != null
                                          ? 'Buy — $price'
                                          : 'Buy',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Watch rewarded ad for 24h ad-free
                        if (!isPurchasing &&
                            AdService.instance.config.rewardedAdsEnabled)
                          TextButton(
                            onPressed: () {
                              AdService.instance.showRewarded(
                                context,
                                onRewarded: () {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Ads removed for 24 hours!',
                                          style: GoogleFonts.inter(color: kText),
                                        ),
                                        backgroundColor: kSurface2,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    );
                                    Navigator.of(context).pop();
                                  }
                                },
                              );
                            },
                            child: Text(
                              'Watch a short video instead',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: kText2,
                              ),
                            ),
                          ),

                        // Restore link
                        TextButton(
                          onPressed: isPurchasing
                              ? null
                              : () async {
                                  await PremiumService.instance.purchase();
                                },
                          child: Text(
                            'Restore Purchase',
                            style: GoogleFonts.inter(
                                fontSize: 13, color: kText2),
                          ),
                        ),

                        const SizedBox(height: 8),
                        Text(
                          'Payment will be charged to your account at\nconfirmation of purchase.',
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              color: kTextMuted,
                              height: 1.5),
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

  Widget _buildFeatureRow(
      IconData icon, Color color, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: kText,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(fontSize: 13, color: kText2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
