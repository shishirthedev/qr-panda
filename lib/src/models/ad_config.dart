import 'dart:io';

class AdConfig {
  final bool adsEnabled;
  final bool bannerAdsEnabled;
  final bool interstitialAdsEnabled;
  final int interstitialFrequency;
  final bool useTestAds;
  final String bannerAdUnitId;
  final String interstitialAdUnitId;

  // Official Google test ad unit IDs
  static const _testBannerAndroid    = 'ca-app-pub-3940256099942544/6300978111';
  static const _testInterstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const _testBannerIos        = 'ca-app-pub-3940256099942544/2934735716';
  static const _testInterstitialIos  = 'ca-app-pub-3940256099942544/4411468910';

  const AdConfig({
    required this.adsEnabled,
    required this.bannerAdsEnabled,
    required this.interstitialAdsEnabled,
    required this.interstitialFrequency,
    required this.useTestAds,
    required this.bannerAdUnitId,
    required this.interstitialAdUnitId,
  });

  factory AdConfig.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) return AdConfig.disabled();

    final adsEnabled             = (json['ads_enabled'] as bool?) ?? false;
    final bannerAdsEnabled       = (json['banner_ads_enabled'] as bool?) ?? false;
    final interstitialAdsEnabled = (json['interstitial_ads_enabled'] as bool?) ?? false;
    final interstitialFrequency  = (json['interstitial_frequency'] as int?) ?? 3;
    final useTestAds             = (json['use_test_ads'] as bool?) ?? true;

    final admob       = json['admob'] as Map<String, dynamic>?;
    final platformKey = Platform.isIOS ? 'ios' : 'android';
    final platformIds = admob?[platformKey] as Map<String, dynamic>? ?? const {};

    final String bannerAdUnitId;
    final String interstitialAdUnitId;

    if (useTestAds) {
      bannerAdUnitId        = Platform.isIOS ? _testBannerIos        : _testBannerAndroid;
      interstitialAdUnitId  = Platform.isIOS ? _testInterstitialIos  : _testInterstitialAndroid;
    } else {
      bannerAdUnitId       = (platformIds['banner_ad_unit_id'] as String?)       ?? '';
      interstitialAdUnitId = (platformIds['interstitial_ad_unit_id'] as String?) ?? '';
    }

    return AdConfig(
      adsEnabled: adsEnabled,
      bannerAdsEnabled: bannerAdsEnabled,
      interstitialAdsEnabled: interstitialAdsEnabled,
      interstitialFrequency: interstitialFrequency,
      useTestAds: useTestAds,
      bannerAdUnitId: bannerAdUnitId,
      interstitialAdUnitId: interstitialAdUnitId,
    );
  }

  factory AdConfig.disabled() => const AdConfig(
    adsEnabled: false,
    bannerAdsEnabled: false,
    interstitialAdsEnabled: false,
    interstitialFrequency: 3,
    useTestAds: true,
    bannerAdUnitId: '',
    interstitialAdUnitId: '',
  );
}