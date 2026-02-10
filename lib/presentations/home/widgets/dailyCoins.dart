import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inkbattle_frontend/repositories/user_repository.dart';
import 'package:inkbattle_frontend/widgets/video_reward_dialog.dart';
import 'package:dotlottie_flutter/dotlottie_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:inkbattle_frontend/config/environment.dart';
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
  int _coinsToAward = Environment.dailyCoinsAwarded;
  bool _claimed = false;
  bool _playedOpenSound = false;

  static const String _lottieUrl =
      "https://lottie.host/c6429905-79d9-4218-89cc-c93d0ebe73a0/y2D2C9kxM4.lottie";

  @override
  void initState() {
    super.initState();
    _checkDailyBonusStatus();
    _playOpenSound();
  }

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
          final coinsAwarded = Environment.dailyCoinsAwarded;
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

  double _dialogHeightFactor(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w > 600 ? 0.58 : 0.72;
  }

  double _dialogWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w > 900) return 500;
    if (w > 600) return 420;
    return w * 0.92;
  }

  double _animationHeight(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return w > 600 ? h * 0.22 : h * 0.25;
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: FractionallySizedBox(
        heightFactor: _dialogHeightFactor(context),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: _dialogWidth(context),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1C1C30),
                  Color(0xFF0E0E1A),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(22.r),
              border: Border.all(
                color: Colors.blueAccent,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 18.h,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  // LOTTIE
                  SizedBox(
                    height: _animationHeight(context),
                    child: DotLottieView(
                      sourceType: 'url',
                      source: _lottieUrl,
                      autoplay: true,
                      loop: true,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // TEXT
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

                  SizedBox(height: 22.h),

                  // BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: isTablet ? 60.h : 52.h,
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
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _claimed
                              ? "AWESOME!"
                              : (_canClaim ? "CLAIM NOW!" : "OK"),
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
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
          fontSize: isTablet ? 24.sp : 20.sp,
          color: color,
        ),
      ),
    );
  }
}
