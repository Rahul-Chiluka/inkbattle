import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';
import 'package:inkbattle_frontend/utils/preferences/local_preferences.dart';
import 'package:inkbattle_frontend/widgets/custom_svg.dart';
import 'package:inkbattle_frontend/utils/lang.dart';
import 'package:inkbattle_frontend/widgets/persistent_banner_ad_widget.dart';
import 'dart:developer' as developer;

class InstructionsScreen extends StatefulWidget {
  const InstructionsScreen({super.key});

  @override
  State<InstructionsScreen> createState() => _InstructionsScreenState();
}

class _InstructionsScreenState extends State<InstructionsScreen> {
  final String _logTag = 'InstructionsScreen';
  // REMOVED: Ad variables
  // BannerAd? _bannerAd;
  // bool _isBannerAdLoaded = false;
  
  bool isToggleOn = false;
  late String randomInstruction;

  @override
  void initState() {
    super.initState();
    // REMOVED: _loadBannerAd();
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Add your code here
      isToggleOn = (await LocalStorageUtils.showTutorial()) ?? true;
      setState(() {});
    });
    randomInstruction = AppLocalizations.instructionsText;
  }

  // REMOVED: _loadBannerAd() function

  @override
  void dispose() {
    // REMOVED: _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Scaffold(
          key: ValueKey(AppLocalizations
              .getCurrentLanguage()), // Force rebuild on language change
          backgroundColor: const Color(0xFF1A2A44),
          body: SafeArea(
            bottom: true, // Protect bottom for ad visibility
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 15.h, horizontal: 8.w),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: const CustomSvgImage(
                                    imageUrl: AppImages.arrow_back,
                                    height: 25,
                                    width: 25,
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      AppLocalizations.instructions,
                                      style: GoogleFonts.lato(
                                        color: Colors.white,
                                        fontSize: 30.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                // Balance key for true centering
                                const SizedBox(width: 25, height: 25),
                              ],
                            )),
                        // Adjusted spacing to match visually with screenshot
                        SizedBox(height: 50.h), 
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  randomInstruction,
                                  style: GoogleFonts.lato(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w400,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.justify, // Better visuals for block text
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Removed Spacer to stick button to bottom area or use bottom padding
                        // Using Padding to push button up slightly from bottom
                        Padding(
                          padding: EdgeInsets.only(bottom: 30.h),
                          child: SizedBox(
                            width: 0.85.sw, // 85% of screen width (mobile & tablet)
                            height: 65.h,   // Consistent height scaling
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isToggleOn = !isToggleOn;
                                  developer.log('Toggle status changed: $isToggleOn', name: _logTag);
                                  LocalStorageUtils.setTutorialShown(isToggleOn);
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.r),
                                ),
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              child: Material(
                                type: MaterialType.transparency,
                                borderRadius: BorderRadius.circular(15.r),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(15.r),
                                  splashColor: Colors.blue.withOpacity(0.3),
                                  highlightColor: Colors.blue.withOpacity(0.1),
                                  onTap: () {
                                    setState(() {
                                      isToggleOn = !isToggleOn;
                                      LocalStorageUtils.setTutorialShown(isToggleOn);
                                    });
                                  },
                                  child: Container(
                                    width: 0.85.sw,
                                    height: 65.h,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12.w, vertical: 15.h),
                                    decoration: BoxDecoration(
                                      image: const DecorationImage(
                                        image: AssetImage(AppImages.bluebutton),
                                        fit: BoxFit.fill,
                                      ),
                                      borderRadius: BorderRadius.circular(15.r),
                                    ),
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          AppLocalizations.tutorialGuide,
                                          style: GoogleFonts.luckiestGuy(
                                            color: Colors.white,
                                            fontSize: 24.sp,
                                            fontWeight: FontWeight.w400,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        SizedBox(width: 15.w),
                                        Container(
                                          width: 28.w,
                                          height: 28.w,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(6.0),
                                            border: Border.all(
                                              color: isToggleOn
                                                  ? Colors.green
                                                  : Colors.grey.shade400,
                                              width: 2.0,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: isToggleOn
                                              ? Icon(
                                                  Icons.check,
                                                  size: 22.w,
                                                  color: Colors.green,
                                                )
                                              : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Persistent Banner Ad (app-wide, loaded once)
                const PersistentBannerAdWidget(),
              ],
            ),
          ),
        );
      },
    );
  }
}
