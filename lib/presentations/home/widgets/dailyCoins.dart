import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inkbattle_frontend/repositories/user_repository.dart';
import 'package:inkbattle_frontend/widgets/video_reward_dialog.dart';
import 'package:dotlottie_flutter/dotlottie_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:inkbattle_frontend/utils/preferences/local_preferences.dart';

class DailyCoinsPopup extends StatefulWidget {
  final Function(dynamic)? onClaimed;

  const DailyCoinsPopup({super.key, this.onClaimed});

  @override
  State<DailyCoinsPopup> createState() => _DailyCoinsPopupState();
}

class _DailyCoinsPopupState extends State<DailyCoinsPopup> {
  final UserRepository _userRepository = UserRepository();
  final AudioPlayer _soundPlayer = AudioPlayer();

  bool _isLoading = true;
  bool _canClaim = false;
  int _hoursRemaining = 0;
  int _coinsToAward = 1000;
  bool _claimed = false;
  bool _playedOpenSound = false;

  @override
  void initState() {
    super.initState();
    _checkDailyBonusStatus();
    _playOpenSound();
  }

  // ================= SOUND =================

  Future<void> _playOpenSound() async {
    if (_playedOpenSound) return;
    _playedOpenSound = true;

    try {
      final volume = await LocalStorageUtils.getVolume();
      await _soundPlayer.setVolume(volume.clamp(0.0, 1.0));
      await _soundPlayer.play(
        AssetSource('sounds/treasure-open.mp3'),
      );
    } catch (_) {}
  }

  Future<void> _playRewardSound() async {
    try {
      final volume = await LocalStorageUtils.getVolume();
      await _soundPlayer.setVolume(volume.clamp(0.0, 1.0));
      await _soundPlayer.play(
        AssetSource('sounds/coin-reward.mp3'),
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _soundPlayer.stop();
    _soundPlayer.dispose();
    super.dispose();
  }

  // ================= API =================

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

    setState(() => _isLoading = true);

    final result = await _userRepository.claimDailyBonus();
    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(failure.message)));
          setState(() => _isLoading = false);
        }
      },
      (data) async {
        if (mounted) {
          const coinsAwarded = 1000;
          _coinsToAward = coinsAwarded;
          _claimed = true;

          await _playRewardSound();
          Navigator.pop(context);

          VideoRewardDialog.show(
            context,
            coinsAwarded: coinsAwarded,
            onComplete: () => widget.onClaimed?.call(coinsAwarded),
          );
        }
      },
    );
  }

  // ================= UI =================

  double _animationHeight(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final isTablet = w > 600;

    if (isTablet) return h * 0.30;      // tablets
    if (h < 700) return h * 0.32;       // small phones
    return h * 0.35;                    // normal phones
  }

  double _dialogWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w > 900) return w * 0.45;       // large tablet
    if (w > 600) return w * 0.65;       // tablet
    return w * 0.92;                    // phone
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: _dialogWidth(context),
        ),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22.r),
          ),
          backgroundColor: Colors.black,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 18.w,
            vertical: 22.h,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// ===== BIGGER LOTTIE =====
              SizedBox(
                height: _animationHeight(context),
                width: double.infinity,
                child: DotLottieView(
                  sourceType: 'url',
                  source:
                      'https://lottie.host/5b680b27-3ad1-4101-a9a9-0a85fac47ede/XJlDHgYasP.lottie',
                  autoplay: true,
                  loop: false,
                ),
              ),

              SizedBox(height: 18.h),

              if (_claimed) ...[
                _title("YOU GOT", Colors.blue, isTablet),
                _title("$_coinsToAward COINS!", Colors.yellow, isTablet),
              ] else if (_canClaim) ...[
                _title("DAILY BONUS", Colors.blue, isTablet),
                _title("1000 COINS!", Colors.yellow, isTablet),
              ] else ...[
                _title("COME BACK IN", Colors.blue, isTablet),
                _title("$_hoursRemaining HOURS", Colors.orange, isTablet),
              ],

              SizedBox(height: 26.h),

              /// ===== BUTTON =====
              SizedBox(
                width: double.infinity,
                height: isTablet ? 70.h : 60.h,
                child: ElevatedButton(
                  onPressed: _claimed
                      ? () => Navigator.pop(context)
                      : (_canClaim
                          ? _claimDailyBonus
                          : () => Navigator.pop(context)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2a6bff),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28.r),
                    ),
                  ),
                  child: Text(
                    _claimed ? "AWESOME!" : (_canClaim ? "CLAIM NOW!" : "OK"),
                    style: TextStyle(
                      fontSize: isTablet ? 22.sp : 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _title(String text, Color color, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.luckiestGuy(
          fontSize: isTablet ? 26.sp : 24.sp,
          color: color,
        ),
      ),
    );
  }
}
