import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:dotlottie_flutter/dotlottie_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';
import 'package:inkbattle_frontend/utils/preferences/local_preferences.dart';

// --- Data Model ---
class Team {
  final String name;
  final int score;
  final String avatar;
  final bool isCurrentUser;

  Team({
    required this.name,
    required this.score,
    required this.avatar,
    this.isCurrentUser = false,
  });
}

// --- Main Popup Widget ---
class TeamWinnerPopup extends StatefulWidget {
  final List<Team> teams;
  final bool isTeamvTeam;
  final Function()? onNext;
  final bool isWinner;

  const TeamWinnerPopup({
    super.key,
    this.onNext,
    required this.teams,
    this.isTeamvTeam = false,
    this.isWinner = false,
  });

  @override
  State<TeamWinnerPopup> createState() => _TeamWinnerPopupState();
}

class _TeamWinnerPopupState extends State<TeamWinnerPopup> {
  static const String _celebrationLottieUrl =
      'https://lottie.host/6fe4fdb6-3ca3-4e3e-82c5-f90de4c0be04/xn7qPAIzcf.lottie';

  final AudioPlayer _soundPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playResultSound();
  }

  @override
  void dispose() {
    _soundPlayer.dispose();
    super.dispose();
  }

  Future<void> _playResultSound() async {
    try {
      final volume = await LocalStorageUtils.getVolume();
      await _soundPlayer.setVolume(volume.clamp(0.0, 1.0));
      await _soundPlayer.play(
        AssetSource(
          widget.isWinner
              ? 'sounds/winner-sound.mp3'
              : 'sounds/lose-sound.mp3',
        ),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(360, 800));

    final isTablet = MediaQuery.of(context).size.width > 600;

    final sortedTeams = List<Team>.from(widget.teams)
      ..sort((a, b) => b.score.compareTo(a.score));

    final first = sortedTeams.isNotEmpty ? sortedTeams[0] : null;
    final second = sortedTeams.length > 1 ? sortedTeams[1] : null;
    final third = sortedTeams.length > 2 ? sortedTeams[2] : null;

    final isTwoWinners = sortedTeams.length == 2;

    final double podiumHeight = isTablet ? 200.h : 160.h;
    final double rank1Height = isTablet ? 150.h : 120.h;
    final double rank2Height = isTablet ? 120.h : 95.h;
    final double rank3Height = isTablet ? 90.h : 70.h;
    final double ribbonHeight = isTablet ? 90.h : 70.h;

    return Center(
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // ---------------- MAIN CARD ----------------
          Container(
            width: 0.92.sw,
            decoration: BoxDecoration(
              color: const Color(0xFF101020),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: Colors.blueAccent, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.3),
                  blurRadius: 8.r,
                  spreadRadius: 1,
                )
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ribbon
                  Container(
                    height: ribbonHeight,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(AppImages.redflg),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Podium
                  SizedBox(
                    width: 280.w,
                    height: podiumHeight,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        if (isTwoWinners)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (first != null)
                                _buildPodiumStep(
                                  team: first,
                                  rank: 1,
                                  podiumHeight: rank1Height,
                                  podiumAsset: AppImages.podium_1,
                                  context: context,
                                ),
                              if (second != null)
                                _buildPodiumStep(
                                  team: second,
                                  rank: 2,
                                  podiumHeight: rank2Height,
                                  podiumAsset: AppImages.podium_2,
                                  context: context,
                                ),
                            ],
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildPodiumStep(
                                team: second,
                                rank: 2,
                                podiumHeight: rank2Height,
                                podiumAsset: AppImages.podium_2_left,
                                context: context,
                              ),
                              _buildPodiumStep(
                                team: first,
                                rank: 1,
                                podiumHeight: rank1Height,
                                podiumAsset: AppImages.podium_1,
                                context: context,
                              ),
                              _buildPodiumStep(
                                team: third,
                                rank: 3,
                                podiumHeight: rank3Height,
                                podiumAsset: AppImages.podium_3,
                                context: context,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: 18.h),

                  // Next Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12.r),
                      onTap: () {
                        widget.onNext?.call();
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 160.w,
                        height: 52.h,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(AppImages.winnernextbutton),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ),

          // ---------------- CELEBRATION OVERLAY ----------------
          if (widget.isWinner)
            IgnorePointer(
              ignoring: true,
              child: SizedBox(
                width: 0.92.sw,
                height: podiumHeight + ribbonHeight + 60.h,
                child: DotLottieView(
                  sourceType: 'url',
                  source: _celebrationLottieUrl,
                  autoplay: true,
                  loop: false,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPodiumStep({
    required Team? team,
    required int rank,
    required double podiumHeight,
    required String podiumAsset,
    required BuildContext context,
  }) {
    if (team == null) {
      return const SizedBox(width: 90);
    }

    final isTablet = MediaQuery.of(context).size.width > 600;

    final List<Color> colors = rank == 1
        ? [const Color(0xFFEAB92D), const Color(0xFF363431)]
        : rank == 2
            ? [const Color(0xFF9B9B9B), const Color(0xFF363431)]
            : [const Color(0xFFBC6E45), const Color(0xFF363431)];

    final double avatarYOffset =
        rank == 1 ? -1 : rank == 2 ? -0.5 : 0;

    return SizedBox(
      width: isTablet ? 70.w : 90.w,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Align(
            alignment: Alignment(0, avatarYOffset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: colors,
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: rank == 1 ? 25.r : 23.r,
                    backgroundColor: Colors.black,
                    backgroundImage: AssetImage(team.avatar),
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (team.isCurrentUser)
                      Icon(Icons.star,
                          size: 14.r, color: Colors.amber),
                    Flexible(
                      child: Text(
                        team.name,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lato(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: team.name == 'Team A'
                              ? Colors.blue
                              : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  "${team.score}",
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: podiumHeight,
            child: Image.asset(
              podiumAsset,
              fit: BoxFit.fill,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Ribbon Painter (unchanged) ---
class RibbonTextPainter extends CustomPainter {
  final String text;
  final TextStyle textStyle;

  RibbonTextPainter({required this.text, required this.textStyle});

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    const curveHeight = 20.0;
    final charWidth = textPainter.width / text.length;

    for (int i = 0; i < text.length; i++) {
      final x = size.width / 2 -
          textPainter.width / 2 +
          i * charWidth +
          charWidth / 2;
      final y = size.height / 2 -
          curveHeight +
          curveHeight *
              math.pow((i - text.length / 2) / (text.length / 2), 2);

      final charPainter = TextPainter(
        text: TextSpan(text: text[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      canvas.translate(x, y);
      charPainter.paint(
        canvas,
        Offset(-charPainter.width / 2, -charPainter.height / 2),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
