import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'package:inkbattle_frontend/constants/app_colors.dart';
import 'package:inkbattle_frontend/utils/preferences/local_preferences.dart';
import 'package:inkbattle_frontend/widgets/text_widget.dart';
import 'package:inkbattle_frontend/widgets/topCoins.dart';

class VideoRewardDialog extends StatefulWidget {
  final int coinsAwarded;
  final VoidCallback? onComplete;

  const VideoRewardDialog({
    super.key,
    required this.coinsAwarded,
    this.onComplete,
  });

  static void show(
      BuildContext context, {
        required int coinsAwarded,
        VoidCallback? onComplete,
      }) {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            VideoRewardDialog(
              coinsAwarded: coinsAwarded,
              onComplete: onComplete,
            ),
        opaque: false,
        barrierColor: Colors.black,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  State<VideoRewardDialog> createState() => _VideoRewardDialogState();
}

class _VideoRewardDialogState extends State<VideoRewardDialog>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  late AnimationController _controller;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            Navigator.of(context).pop();
            widget.onComplete?.call();
          }
        });
      }
    });

    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.asset(
      'asset/animationVideos/coin_reward_animation.mp4',
    );

    await _videoController!.initialize();

    final volume = await LocalStorageUtils.getVolume();
    await _videoController!.setVolume(volume.clamp(0.0, 1.0));

    _videoController!.setLooping(false);
    _videoController!.seekTo(Duration.zero);
    _videoController!.play();

    _controller.forward(from: 0);

    if (mounted) {
      setState(() {
        _isVideoInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full screen video
          Center(
            child: _isVideoInitialized &&
                _videoController != null &&
                _videoController!.value.isInitialized
                ? FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoController!.value.size.width,
                    height: _videoController!.value.size.height,
                    child: VideoPlayer(_videoController!),
                  ),
                )
                : const CircularProgressIndicator(color: Colors.white),
          ),
          // Overlay content
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  // Coin container on top
                  CoinContainer(coins: widget.coinsAwarded),
                  const Spacer(),
                  // Animated coins count
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final count = (widget.coinsAwarded * _controller.value)
                          .round()
                          .clamp(0, widget.coinsAwarded);
                      return TextWidget(
                        text: "+ $count Coins",
                        fontSize: 25.sp,
                        color: AppColors.whiteColor,
                        fontWeight: FontWeight.bold,
                      );
                    },
                  ),
                  SizedBox(height: 30.h),
                  // Skip button at bottom
                  Padding(
                    padding: EdgeInsets.only(bottom: 20.h),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onComplete?.call();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Skip ",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 14.sp)),
                          Icon(Icons.arrow_forward_ios,
                              size: 16.sp, color: Colors.white70),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
