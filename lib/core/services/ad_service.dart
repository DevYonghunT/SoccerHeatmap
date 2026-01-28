import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  InterstitialAd? _interstitialAd;
  bool _isInterstitialReady = false;

  // Test Ad Unit IDs (replace with real IDs before release)
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Android test
    } else {
      return 'ca-app-pub-3940256099942544/4411468910'; // iOS test
    }
  }

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  void loadInterstitialAd({VoidAdCallback? onAdLoaded}) {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialReady = true;
          onAdLoaded?.call();
        },
        onAdFailedToLoad: (error) {
          _isInterstitialReady = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  void showInterstitialAd({
    required void Function() onAdDismissed,
  }) {
    if (!_isInterstitialReady || _interstitialAd == null) {
      onAdDismissed();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialReady = false;
        onAdDismissed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialReady = false;
        onAdDismissed();
      },
    );

    _interstitialAd!.show();
  }

  bool get isInterstitialReady => _isInterstitialReady;

  void dispose() {
    _interstitialAd?.dispose();
  }
}

typedef VoidAdCallback = void Function();
