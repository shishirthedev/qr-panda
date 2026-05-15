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

  /// Notifies listeners when ads have been fully initialised and are ready to
  /// display. UI widgets should listen to this before creating banner ads.
  final ValueNotifier<bool> adsReadyNotifier = ValueNotifier(false);

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  int _actionCount = 0;

  /// 24-hour ad-free period granted via rewarded ad.
  DateTime? _adFreeUntil;

  bool get _isAdFree =>
      _adFreeUntil != null && DateTime.now().isBefore(_adFreeUntil!);

  bool get _canShowAds =>
      _config.adsEnabled &&
      !PremiumService.instance.isPremium &&
      !_isAdFree;

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
      await rc.setDefaults({'app_ads_config': '{}'});
      await rc.fetchAndActivate();
      final raw = rc.getString('app_ads_config');
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
    if (_config.rewardedAdsEnabled) _preloadRewarded();

    // Clean up preloaded ads immediately when user upgrades to premium
    PremiumService.instance.isPremiumNotifier.addListener(_onPremiumChanged);
  }

  void _onPremiumChanged() {
    if (PremiumService.instance.isPremium) {
      _interstitialAd?.dispose();
      _interstitialAd = null;
      _rewardedAd?.dispose();
      _rewardedAd = null;
      adsReadyNotifier.value = false;
      debugPrint('[AdService] User upgraded to premium — ads disposed.');
    }
  }

  // ---------------------------------------------------------------------------
  // Banner
  // ---------------------------------------------------------------------------

  /// Creates and loads a new BannerAd. Returns null when ads should not be
  /// shown. The caller is responsible for disposing the returned ad.
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

  /// Call after a user-initiated action (scan dismissed, QR saved). Shows an
  /// interstitial every [AdConfig.interstitialFrequency] calls.
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
      // Ad not ready yet — preload for next time.
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
    _interstitialAd = null; // prevent double-show
  }

  // ---------------------------------------------------------------------------
  // Rewarded
  // ---------------------------------------------------------------------------

  void _preloadRewarded() {
    if (!_canShowAds || !_config.rewardedAdsEnabled) return;
    if (_config.rewardedAdUnitId.isEmpty) return;

    RewardedAd.load(
      adUnitId: _config.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          debugPrint('[AdService] Rewarded loaded.');
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdService] Rewarded failed: ${error.message}');
          _rewardedAd = null;
        },
      ),
    );
  }

  /// Shows the rewarded ad. [onRewarded] is called only when the user earns
  /// the reward. Always user-initiated — never call this automatically.
  Future<void> showRewarded(
    BuildContext context, {
    required VoidCallback onRewarded,
  }) async {
    if (!_canShowAds || !_config.rewardedAdsEnabled) return;

    if (_rewardedAd == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ad not ready yet, please try again.')),
        );
      }
      _preloadRewarded();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _preloadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdService] Rewarded show failed: ${error.message}');
        ad.dispose();
        _rewardedAd = null;
        _preloadRewarded();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        _adFreeUntil = DateTime.now().add(const Duration(hours: 24));
        debugPrint('[AdService] Reward earned — ad-free until $_adFreeUntil');
        onRewarded();
      },
    );
    _rewardedAd = null;
  }

  // ---------------------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------------------

  void dispose() {
    PremiumService.instance.isPremiumNotifier.removeListener(_onPremiumChanged);
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    adsReadyNotifier.dispose();
  }
}
