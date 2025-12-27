import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

class AdService {
  // Android App ID: ca-app-pub-2111477197639109~2310576980
  // iOS App ID: ca-app-pub-2111477197639109~9891158883

  // Android Ad Unit IDs
  static const String androidBannerAdUnitId =
      'ca-app-pub-2111477197639109/9642912729';
  static const String androidRewardedAdUnitId =
      'ca-app-pub-2111477197639109/2275191348';

  // iOS Ad Unit IDs
  static const String iosBannerAdUnitId =
      'ca-app-pub-2111477197639109/6915256150';
  static const String iosRewardedAdUnitId =
      'ca-app-pub-2111477197639109/8649028008';

  // Track initialization status
  static bool _initialized = false;

  // Get platform-specific banner ad unit ID
  static String getBannerAdUnitId() {
    if (Platform.isAndroid) {
      return androidBannerAdUnitId;
    } else if (Platform.isIOS) {
      return iosBannerAdUnitId;
    }
    throw UnsupportedError('Unsupported platform');
  }

  // Get platform-specific interstitial ad unit ID
  static String getRewardedAdUnitId() {
    if (Platform.isAndroid) {
      return androidRewardedAdUnitId;
    } else if (Platform.isIOS) {
      return iosRewardedAdUnitId;
    }
    throw UnsupportedError('Unsupported platform');
  }

  // Initialize Google Mobile Ads SDK
  static Future<void> initializeMobileAds() async {
    if (_initialized) return;

    try {
      // On iOS we must request tracking authorization before initializing ads.
      await _requestTrackingAuthorizationIfNeeded();

      await MobileAds.instance.initialize();
      _initialized = true;
    } catch (e) {
      print('Error initializing mobile ads: $e');
      // Don't rethrow - allow app to continue without ads
    }
  }

  // Request App Tracking Transparency on iOS before accessing IDFA.
  static Future<void> _requestTrackingAuthorizationIfNeeded() async {
    if (!Platform.isIOS) return;

    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        // Small delay recommended before showing the system prompt.
        await Future.delayed(const Duration(milliseconds: 250));
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    } catch (e) {
      // Log and continue; ads will fall back to non-personalized if needed.
      print('ATT request failed: $e');
    }
  }

  // Load Rewarded Ad
  static Future<RewardedAd?> loadRewardedAd({
    required void Function(LoadAdError) onAdFailedToLoad,
    required void Function(RewardedAd) onAdLoaded,
  }) async {
    try {
      await RewardedAd.load(
        adUnitId: getRewardedAdUnitId(),
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: onAdLoaded,
          onAdFailedToLoad: onAdFailedToLoad,
        ),
      );
      return null; // Ad is loaded via callback
    } catch (e) {
      print('Error loading rewarded ad: $e');
      return null;
    }
  }

  // Load Banner Ad
  static Future<BannerAd?> loadBannerAd({
    required void Function(Ad) onAdLoaded,
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
  }) async {
    try {
      final bannerAd = BannerAd(
        adUnitId: getBannerAdUnitId(),
        request: const AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) => onAdLoaded(ad),
          onAdFailedToLoad: (Ad ad, LoadAdError error) =>
              onAdFailedToLoad(ad, error),
        ),
      );

      await bannerAd.load();
      return bannerAd;
    } catch (e) {
      print('Error loading banner ad: $e');
      return null;
    }
  }
}
