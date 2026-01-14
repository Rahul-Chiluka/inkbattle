import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';
import 'package:inkbattle_frontend/repositories/user_repository.dart';
import 'package:inkbattle_frontend/widgets/video_reward_dialog.dart';
import 'package:video_player/video_player.dart';

class DailyCoinsPopup extends StatefulWidget {
  final Function(dynamic)? onClaimed;
  // final VoidCallback? onBuyClicked; // 1. Added callback for Buy button

  // const DailyCoinsPopup({
  //   super.key, 
  //   this.onClaimed, 
  //   this.onBuyClicked // 2. Added to constructor
  // });

  @override
  State<DailyCoinsPopup> createState() => _DailyCoinsPopupState();
}

class _DailyCoinsPopupState extends State<DailyCoinsPopup> {
  final UserRepository _userRepository = UserRepository();
  bool _isLoading = true;
  bool _canClaim = false;
  int _hoursRemaining = 0;
  int _coinsToAward = 1000;
  bool _claimed = false;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _checkDailyBonusStatus();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.asset(
      AppImages.treasureBoxVideo,
    );
    await _videoController!.initialize();
    _videoController!.setLooping(true);
    _videoController!.play();
    if (mounted) {
      setState(() {
        _isVideoInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _checkDailyBonusStatus() async {
    final result = await _userRepository.getDailyBonusStatus();
    result.fold(
      (failure) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _canClaim = false;
          });
        }
      },
      (data) {
        if (mounted) {
          setState(() {
            _canClaim = data['canClaim'] ?? false;
            _hoursRemaining = data['hoursRemaining'] ?? 0;
            _isLoading = false;
          });
        }
      },
    );
  }

  Future<void> _claimDailyBonus() async {
    if (!_canClaim || _claimed) return;

    setState(() {
      _isLoading = true;
    });

    final result = await _userRepository.claimDailyBonus();
    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message)),
          );
          setState(() {
            _isLoading = false;
          });
        }
      },
      (data) {
        if (mounted) {
          const coinsAwarded = 1000;
          _coinsToAward = coinsAwarded;
          _claimed = true;
          // widget.onClaimed?.call(coinsAwarded);
          // Close daily coins popup and show coin animation
          Navigator.pop(context);
          VideoRewardDialog.show(
            context,
            coinsAwarded: coinsAwarded,
            onComplete: () {
              widget.onClaimed?.call(coinsAwarded);
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    if (_isLoading) {
      return Center(
        child: Container(
          padding: EdgeInsets.all(40.w),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: const CircularProgressIndicator(color: Colors.blue),
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isTablet ? size.width * 0.7 : size.width * 0.9,
          maxHeight: isTablet ? size.height * 0.8 : size.height * 0.85, // Increased height slightly to fit new button
        ),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          backgroundColor: Colors.black,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _isVideoInitialized && _videoController != null
                    ? SizedBox(
                        width: isTablet ? 200.w : 160.w,
                        height: isTablet ? 250.h : 220.h,
                        child: AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        ),
                      )
                    : SizedBox(
                        width: isTablet ? 200.w : 160.w,
                        height: isTablet ? 250.h : 220.h,
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.blue),
                        ),
                      ),
                SizedBox(height: 16.h),
                if (_claimed) ...[
                  Text(
                    "YOU GOT",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.luckiestGuy(
                      fontSize: isTablet ? 25.sp : 24.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    "$_coinsToAward COINS!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.luckiestGuy(
                      fontSize: isTablet ? 25.sp : 24.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.yellow,
                    ),
                  ),
                ] else if (_canClaim) ...[
                  Text(
                    "DAILY BONUS",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.luckiestGuy(
                      fontSize: isTablet ? 25.sp : 24.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    "1000 COINS!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.luckiestGuy(
                      fontSize: isTablet ? 25.sp : 24.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.yellow,
                    ),
                  ),
                ] else ...[
                  Text(
                    "COME BACK IN",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.luckiestGuy(
                      fontSize: isTablet ? 25.sp : 24.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    "$_hoursRemaining HOURS",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.luckiestGuy(
                      fontSize: isTablet ? 25.sp : 24.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.orange,
                    ),
                  ),
                ],
                SizedBox(height: 24.h),
                
                // --- EXISTING CLAIM/OK BUTTON ---
                SizedBox(
                  width: double.infinity,
                  height: isTablet ? 75.h : 65.h,
                  child: ElevatedButton(
                    onPressed: _claimed
                        ? () => Navigator.pop(context)
                        : (_canClaim
                            ? _claimDailyBonus
                            : () => Navigator.pop(context)),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(AppImages.bluebutton),
                          fit: BoxFit.contain,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _claimed
                            ? "AWESOME!"
                            : (_canClaim ? "CLAIM NOW!" : "OK"),
                        style: TextStyle(
                          fontSize: isTablet ? 24.sp : 22.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}