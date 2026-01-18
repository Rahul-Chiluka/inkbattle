import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';

class SubmittedPopup extends StatefulWidget {
  const SubmittedPopup({super.key});

  @override
  State<SubmittedPopup> createState() => _SubmittedPopupState();
}

class _SubmittedPopupState extends State<SubmittedPopup> {
  @override
  void initState() {
    super.initState();
    // Optimal delay: 2 seconds is enough for the brain to process the checkmark
    Timer(const Duration(seconds: 2), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(); 
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width > 600;

    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 8, 8, 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AppImages.submitted,
            height: isTablet ? 120.h : 80.h,
            width: isTablet ? 120.w : 80.w,
          ),
          SizedBox(height: 40.h),
          FittedBox(
            child: Text(
              'Submitted',
              style: GoogleFonts.lato(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: isTablet ? 30.sp : 20.sp,
              ),
            ),
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }
}
