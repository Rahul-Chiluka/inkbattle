import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';

class TeamPlayer {
  final int rank;
  final String name;
  final String avatarPath;
  final String flagEmoji;

  TeamPlayer({
    required this.rank,
    required this.name,
    required this.avatarPath,
    required this.flagEmoji,
  });
}

class TeamDisplayPopup extends StatelessWidget {
  final String teamName;
  final List<TeamPlayer> players;

  const TeamDisplayPopup({
    super.key,
    required this.teamName,
    required this.players,
  });

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(360, 800));

    return Center(
      child: Container(
        width: 0.9.sw,
        height: 0.80.sh,
        decoration: BoxDecoration(
          color: const Color(0xFF131424),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: Colors.blueAccent.withOpacity(0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.4),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 100.h,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    // Blue = Team A, Orange = Team B (match game_room_screen mapping)
                    image: AssetImage((teamName == "Team A" || teamName == "A")
                        ? AppImages.redflg_teamA
                        : AppImages.redflg_teamB),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  teamName,
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.8),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  child: ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      final player = players[index];
                      return Container(
                        decoration: BoxDecoration(
                            border: BoxBorder.fromLTRB(
                                bottom: const BorderSide(
                                    color: Color.fromRGBO(36, 38, 63, 1)))),
                        margin: EdgeInsets.only(bottom: 10.h),
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 10.h),
                        child: Row(
                          children: [
                            Container(
                              height: 30.h,
                              width: 30.w,
                              padding: EdgeInsets.all(8.h),
                              decoration: BoxDecoration(
                                  color: const Color(0xFF1B1D33),
                                  borderRadius: BorderRadius.circular(7)),
                              child: Center(
                                child: Text(
                                  '${player.rank}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 20.w,
                            ),
                            Container(
                              width: 32.w,
                              height: 32.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: AssetImage(player.avatarPath),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // SizedBox(width: 50.w),
                            Row(
                              children: [
                                Text(
                                  player.name,
                                  style: GoogleFonts.lato(
                                    color: Colors.white,
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                SizedBox(
                                  width: 15.w,
                                ),
                                Text(
                                  player.flagEmoji,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RibbonTextPainter extends CustomPainter {
  final String text;
  final TextStyle textStyle;

  RibbonTextPainter({required this.text, required this.textStyle});

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final centerX = size.width / 2;
    final centerY = size.height / 2.3;
    const curveHeight = 10.0;

    final charCount = text.length;
    final charWidth = textPainter.width / charCount;

    for (int i = 0; i < charCount; i++) {
      final x =
          centerX - (textPainter.width / 2) + (i * charWidth) + (charWidth / 2);
      final y = centerY -
          curveHeight +
          (curveHeight * math.pow((i - charCount / 2) / (charCount / 2), 2));

      final charPainter = TextPainter(
        text: TextSpan(text: text[i], style: textStyle),
        textDirection: TextDirection.ltr,
      );
      charPainter.layout();

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(0);
      charPainter.paint(
          canvas, Offset(-charPainter.width / 2, -charPainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
