import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';
import 'package:inkbattle_frontend/models/room_model.dart';
import 'package:inkbattle_frontend/presentations/widgets/form.dart';
import 'package:inkbattle_frontend/presentations/widgets/submitted.dart';
import 'package:inkbattle_frontend/repositories/user_repository.dart';
import 'dart:developer' as developer;

class ErrorPopup extends StatelessWidget {
  ErrorPopup({
    super.key,
    required this.participants,
    required this.roomId,
    this.currentDrawerId,
  });
  List<RoomParticipant> participants;
  final int roomId;
  /// Current drawer's user id; required for "Report Drawing" to target the drawer.
  final int? currentDrawerId;

  @override
  Widget build(BuildContext context) {
    final String _logTag = 'ReportPopupScreen';
    final bool isTablet = MediaQuery.of(context).size.width > 600;
    return AlertDialog(
      backgroundColor: const Color(0xFF000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: const BorderSide(
            color: Color.fromARGB(255, 248, 227, 108), width: 2),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: isTablet ? 28.r : 24.r,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AppImages.reportlogo,
                width: 40.w,
                height: 40.w,
              ),
            ],
          ),
          SizedBox(height: 25.h),
          Text(
            'Report an Issue',
            style: GoogleFonts.lato(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 22.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Help us keep the game fun and safe',
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
                color: const Color(0xFF979595),
                fontSize: 13.sp,
                fontWeight: FontWeight.w400),
          ),
          SizedBox(height: 20.h),
          Column(
            children: [
              _buildOptionButton(
                context,
                title: 'Report Member',
                subtitle: 'Report inappropriate chat, name, or behavior',
                imagePath: AppImages.reportmember,
                onPressed: () {
                  developer.log('Report Member button pressed', name: _logTag);
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) => FormPopup(
                      roomId: roomId,
                      participants: participants,
                    ),
                  );
                },
              ),
              SizedBox(height: 20.h),
              _buildOptionButton(
                context,
                title: 'Report Drawing',
                subtitle:
                    'Report if someone draws answers or offensive content',
                imagePath: AppImages.reportdrawing,
                onPressed: () async {
                  developer.log('Report Drawing button pressed', name: _logTag);
                  if (currentDrawerId == null) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'You can report the drawer only during drawing or reveal phase.',
                          ),
                        ),
                      );
                    }
                    return;
                  }
                  Navigator.pop(context);
                  final repo = UserRepository();
                  final result = await repo.reportUser(
                    roomId: roomId.toString(),
                    userToBlockId: currentDrawerId!,
                    reportType: 'drawing',
                  );
                  if (!context.mounted) return;
                  result.fold(
                    (failure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(failure.message)),
                      );
                    },
                    (_) {
                      showDialog(
                        context: context,
                        builder: (context) => const SubmittedPopup(),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
    required String imagePath,
  }) {
    final bool isTablet = MediaQuery.of(context).size.width > 600;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0A0A0A),
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, isTablet ? 60.h : 50.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        elevation: 2,
      ),
      onPressed: onPressed,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: isTablet ? 30.r : 25.r,
            height: isTablet ? 30.r : 25.r,
            fit: BoxFit.cover,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  subtitle,
                  style: GoogleFonts.lato(
                      color: const Color(0xFF979595),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
