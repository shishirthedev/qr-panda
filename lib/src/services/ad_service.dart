import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../models/ad_config.dart';
import 'premium_service.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  AdConfig _config = AdConfig.disabled();
  AdConfig get config => _config;

  final ValueNotifier<bool> adsReadyNotifier = ValueNotifier(false);

  InterstitialAd? _interstitialAd;
  int _actionCount = 0;

  bool get _canShowAds =>
      _config.adsEnabled && !PremiumService.instance.isPremium;

  // ---------------------------------------------------------------------------
  // Initialisation
  // ---------------------------------------------------------------------------

  Future<void> init() async {
    try {
      final rc = FirebaseRemoteConfig.instance;
      await rc.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await rc.setDefaults({'qr_panda_ads_config': '{}'});
      await rc.fetchAndActivate();
      final raw = rc.getString('qr_panda_ads_config');
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _config = AdConfig.fromJson(decoded);
    } catch (e) {
      debugPrint('[AdService] Remote config fetch failed: $e');
      _config = AdConfig.disabled();
    }

    if (!_canShowAds) {
      debugPrint('[AdService] Ads disabled or user is premium — skipping init.');
      return;
    }

    await MobileAds.instance.initialize();
    adsReadyNotifier.value = true;

    if (_config.interstitialAdsEnabled) _preloadInterstitial();

    PremiumService.instance.isPremiumNotifier.addListener(_onPremiumChanged);
  }

  void _onPremiumChanged() {
    if (PremiumService.instance.isPremium) {
      _interstitialAd?.dispose();
      _interstitialAd = null;
      adsReadyNotifier.value = false;
      debugPrint('[AdService] User upgraded to premium — ads disposed.');
    }
  }

  // ---------------------------------------------------------------------------
  // Banner
  // ---------------------------------------------------------------------------

  BannerAd? createBannerAd() {
    if (!_canShowAds || !_config.bannerAdsEnabled) return null;
    if (_config.bannerAdUnitId.isEmpty) return null;

    return BannerAd(
      adUnitId: _config.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, error) {
          debugPrint('[AdService] Banner failed: ${error.message}');
          ad.dispose();
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Interstitial
  // ---------------------------------------------------------------------------

  void _preloadInterstitial() {
    if (!_canShowAds || !_config.interstitialAdsEnabled) return;
    if (_config.interstitialAdUnitId.isEmpty) return;

    InterstitialAd.load(
      adUnitId: _config.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          debugPrint('[AdService] Interstitial loaded.');
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdService] Interstitial failed: ${error.message}');
          _interstitialAd = null;
        },
      ),
    );
  }

  void recordAction() {
    if (!_canShowAds || !_config.interstitialAdsEnabled) return;

    _actionCount++;
    final freq = _config.interstitialFrequency;
    if (freq > 0 && _actionCount % freq == 0) {
      _showInterstitial();
    }
  }

  void _showInterstitial() {
    if (_interstitialAd == null) {
      _preloadInterstitial();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _preloadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdService] Interstitial show failed: ${error.message}');
        ad.dispose();
        _interstitialAd = null;
        _preloadInterstitial();
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null;
  }

  // ---------------------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------------------

  void dispose() {
    PremiumService.instance.isPremiumNotifier.removeListener(_onPremiumChanged);
    _interstitialAd?.dispose();
    adsReadyNotifier.dispose();
  }
}