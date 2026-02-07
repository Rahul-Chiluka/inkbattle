import 'dart:async'; // Required for Timer
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dotlottie_flutter/dotlottie_flutter.dart';

class CoinAnimationDialog extends StatefulWidget {
  static const String _logTag = 'CoinAnimationDialog';
  final int coinsAwarded;
  final VoidCallback? onComplete;

  const CoinAnimationDialog({
    super.key,
    required this.coinsAwarded,
    this.onComplete,
  });

  static void show(
    BuildContext context, {
    required int coinsAwarded,
    VoidCallback? onComplete,
  }) {
    developer.log('Showing rewarded animation dialog', name: _logTag);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      barrierColor: Colors.black54, 
      builder: (ctx) => CoinAnimationDialog(
        coinsAwarded: coinsAwarded,
        onComplete: onComplete,
      ),
    );
  }

  @override
  State<CoinAnimationDialog> createState() => _CoinAnimationDialogState();
}

class _CoinAnimationDialogState extends State<CoinAnimationDialog> {
  bool _isClosing = false;
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();
    // Start a timer to close the dialog automatically after 5 seconds
    _autoCloseTimer = Timer(const Duration(seconds: 5), () {
      _close();
    });
  }

  @override
  void dispose() {
    _autoCloseTimer?.cancel(); // Clean up timer to prevent memory leaks
    super.dispose();
  }

  void _close() {
    if (_isClosing || !mounted) return;
    _isClosing = true;
    developer.log('Closing dialog automatically or by tap', name: CoinAnimationDialog._logTag);
    
    Navigator.of(context, rootNavigator: true).pop();
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _close();
      },
      child: GestureDetector(
        onTap: _close,
        behavior: HitTestBehavior.opaque,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: _CelebrationContent(
              coinsAwarded: widget.coinsAwarded,
            ),
          ),
        ),
      ),
    );
  }
}

class _CelebrationContent extends StatefulWidget {
  final int coinsAwarded;

  const _CelebrationContent({required this.coinsAwarded});

  @override
  State<_CelebrationContent> createState() => _CelebrationContentState();
}

class _CelebrationContentState extends State<_CelebrationContent> {
  /// Lottie plays first; after it completes, points animation runs.
  static const Duration _lottieDuration = Duration(milliseconds: 2200);
  bool _lottieComplete = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(_lottieDuration, () {
      if (mounted) setState(() => _lottieComplete = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300.w,
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 180.h,
            width: 180.w,
            child: DotLottieView(
              sourceType: 'url',
              source: 'https://lottie.host/18f7461e-8095-4781-b33a-1a24a6e26f2a/KhBAQIzoNw.lottie',
              autoplay: true,
              loop: false,
            ),
          ),
          SizedBox(height: 10.h),
          // Points animation starts only after Lottie has finished
          _lottieComplete
              ? TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: widget.coinsAwarded),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOutExpo,
                  builder: (context, value, child) {
                    return Text(
                      '+$value',
                      style: TextStyle(
                        color: const Color(0xFFFFD700),
                        fontSize: 48.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                )
              : Text(
                  '+0',
                  style: TextStyle(
                    color: const Color(0xFFFFD700).withOpacity(0.5),
                    fontSize: 48.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          Text(
            'COINS EARNED',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 16.h),
          const Text(
            'Closing automatically...',
            style: TextStyle(color: Colors.white30, fontSize: 11),
          ),
        ],
      ),
    );
  }
}