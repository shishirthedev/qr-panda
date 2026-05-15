import 'dart:io';

class AdConfig {
  final bool adsEnabled;
  final bool bannerAdsEnabled;
  final bool interstitialAdsEnabled;
  final bool rewardedAdsEnabled;
  final int interstitialFrequency;
  final bool useTestAds;
  final String bannerAdUnitId;
  final String interstitialAdUnitId;
  final String rewardedAdUnitId;

  // Official Google test ad unit IDs
  static const _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const _testInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const _testRewardedAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const _testBannerIos = 'ca-app-pub-3940256099942544/2934735716';
  static const _testInterstitialIos = 'ca-app-pub-3940256099942544/4411468910';
  static const _testRewardedIos = 'ca-app-pub-3940256099942544/1712485313';

  const AdConfig({
    required this.adsEnabled,
    required this.bannerAdsEnabled,
    required this.interstitialAdsEnabled,
    required this.rewardedAdsEnabled,
    required this.interstitialFrequency,
    required this.useTestAds,
    required this.bannerAdUnitId,
    required this.interstitialAdUnitId,
    required this.rewardedAdUnitId,
  });

  factory AdConfig.fromJson(Map<String, dynamic> json) {
    final app = (json['apps'] as Map<String, dynamic>?)?['qr_panda']
        as Map<String, dynamic>?;

    if (app == null) return AdConfig.disabled();

    final adsEnabled = (app['ads_enabled'] as bool?) ?? false;
    final bannerAdsEnabled = (app['banner_ads_enabled'] as bool?) ?? false;
    final interstitialAdsEnabled =
        (app['interstitial_ads_enabled'] as bool?) ?? false;
    final rewardedAdsEnabled = (app['rewarded_ads_enabled'] as bool?) ?? false;
    final interstitialFrequency = (app['interstitial_frequency'] as int?) ?? 3;
    final useTestAds = (app['use_test_ads'] as bool?) ?? true;

    final admob = app['admob'] as Map<String, dynamic>?;
    final platformKey = Platform.isIOS ? 'ios' : 'android';
    final platformIds =
        admob?[platformKey] as Map<String, dynamic>? ?? const {};

    String bannerAdUnitId;
    String interstitialAdUnitId;
    String rewardedAdUnitId;

    if (useTestAds) {
      if (Platform.isIOS) {
        bannerAdUnitId = _testBannerIos;
        interstitialAdUnitId = _testInterstitialIos;
        rewardedAdUnitId = _testRewardedIos;
      } else {
        bannerAdUnitId = _testBannerAndroid;
        interstitialAdUnitId = _testInterstitialAndroid;
        rewardedAdUnitId = _testRewardedAndroid;
      }
    } else {
      bannerAdUnitId =
          (platformIds['banner_ad_unit_id'] as String?) ?? '';
      interstitialAdUnitId =
          (platformIds['interstitial_ad_unit_id'] as String?) ?? '';
      rewardedAdUnitId =
          (platformIds['rewarded_ad_unit_id'] as String?) ?? '';
    }

    return AdConfig(
      adsEnabled: adsEnabled,
      bannerAdsEnabled: bannerAdsEnabled,
      interstitialAdsEnabled: interstitialAdsEnabled,
      rewardedAdsEnabled: rewardedAdsEnabled,
      interstitialFrequency: interstitialFrequency,
      useTestAds: useTestAds,
      bannerAdUnitId: bannerAdUnitId,
      interstitialAdUnitId: interstitialAdUnitId,
      rewardedAdUnitId: rewardedAdUnitId,
    );
  }

  factory AdConfig.disabled() {
    return const AdConfig(
      adsEnabled: false,
      bannerAdsEnabled: false,
      interstitialAdsEnabled: false,
      rewardedAdsEnabled: false,
      interstitialFrequency: 3,
      useTestAds: true,
      bannerAdUnitId: '',
      interstitialAdUnitId: '',
      rewardedAdUnitId: '',
    );
  }
}
