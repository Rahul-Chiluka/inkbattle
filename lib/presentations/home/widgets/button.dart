import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';

class CustomRoomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomRoomButton(
      {super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 600;
    double buttonWidth = isTablet ? 0.45.sw : 0.6.sw;
    double buttonHeight = 0.08.sh;

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: AspectRatio(
        aspectRatio: 3.5,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            overlayColor: Colors.blue.withOpacity(1),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.r),
            ),
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
          ),
          child: Material(
            type: MaterialType.transparency,
            borderRadius: BorderRadius.circular(10.r),
            child: InkWell(
              borderRadius: BorderRadius.circular(10.r),
              splashColor: Colors.blue,
              highlightColor: Colors.blue,
              onTap: onPressed,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage(AppImages.homebutton),
                    fit: BoxFit.fill,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.2),
                      BlendMode.srcATop,
                    ),
                  ),
                ),
                alignment: Alignment.center,
                // ADD PADDING so text doesn't touch the edges
                padding: EdgeInsets.symmetric(horizontal: 10.w), 
                child: FittedBox(
                  fit: BoxFit.scaleDown, // Shrinks text if it's too big, but won't expand it excessively
                  child: Stack(
                    children: [
                      Text(
                        text,
                        style: GoogleFonts.luckiestGuy(
                          fontSize: 18.sp, // Target size
                          fontWeight: FontWeight.w400,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 2
                            ..color = Colors.black,
                        ),
                      ),
                      Text(
                        text,
                        style: GoogleFonts.luckiestGuy(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}