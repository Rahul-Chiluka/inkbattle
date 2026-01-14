import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';
import 'package:inkbattle_frontend/presentations/home/bloc/settings_bloc.dart';
import 'package:inkbattle_frontend/widgets/custom_svg.dart';
import 'package:inkbattle_frontend/utils/preferences/local_preferences.dart';
import 'package:inkbattle_frontend/utils/routes/routes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:inkbattle_frontend/repositories/user_repository.dart';
import 'package:inkbattle_frontend/utils/lang.dart';
import 'package:inkbattle_frontend/logic/auth/google_auth_service.dart';
import 'package:inkbattle_frontend/logic/auth/facebook_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inkbattle_frontend/widgets/persistent_banner_ad_widget.dart';
import 'package:inkbattle_frontend/services/ad_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double soundValue = 0.5;
  final UserRepository _userRepo = UserRepository();
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  final FacebookAuthService _facebookAuthService = FacebookAuthService();
  final instagramUrl = Uri.parse(
      'https://www.instagram.com/inkbattleofficial?igsh=MThvcDY5ZjhsbHRoaA==');

  final youtubeUrl = Uri.parse('https://www.youtube.com/@RLCommunity-sx6mt');

  final twitterUrl = Uri.parse('https://x.com/RLCommunity0');
  final deleteAccountUrl = Uri.parse('https://forms.gle/wpY1drhr76rHwBGU7');

  @override
  void initState() {
    super.initState();
    // Ensure banner ad is loaded when settings screen opens
    _loadBannerAd();
  }

  // Load banner ad if not already loaded
  Future<void> _loadBannerAd() async {
    try {
      // Check if banner ad is already loaded
      if (!AdService.isBannerAdLoaded()) {
        // Load the persistent banner ad
        await AdService.loadPersistentBannerAd();
      }
    } catch (e) {
      print('Error loading banner ad in settings screen: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 600;

    return BlocProvider(
      create: (context) => SettingsBloc()..add(SettingsInitialEvent()),
      child: Scaffold(
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
                                child: CustomSvgImage(
                                  imageUrl: AppImages.arrow_back,
                                  height: isTablet ? 32 : 25,
                                  width: isTablet ? 32 : 25,
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    AppLocalizations.settings,
                                    style: GoogleFonts.lato(
                                      color: Colors.white,
                                      fontSize: isTablet ? 32 : 30.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )),
                      SizedBox(height: 15.h),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Added spacers in scroll view might be tricky,
                              // better to use SizedBox for consistent spacing
                              SizedBox(height: 20.h),
                              
                              _buildButton(context, AppLocalizations.sound,
                                  AppImages.soundfull, () {}, true),
                              SizedBox(height: 15.h),
                              _buildButton(
                                  context,
                                  AppLocalizations.profileAndAccounts,
                                  AppImages.profile, () async {
                                final result =
                                    await context.push(Routes.profileEditScreen);
                                // If language was changed, trigger rebuild
                                if (result == true && mounted) {
                                  setState(() {});
                                }
                              }, false),
                              SizedBox(height: 15.h),
                              _buildButton(
                                  context,
                                  AppLocalizations.privacyAndSafety,
                                  AppImages.privacy, () {
                                context.push(Routes.privacySafetyScreen);
                              }, false),
                              SizedBox(height: 15.h),
                              _buildButton(context, AppLocalizations.contact,
                                  AppImages.contact, () {}, false),
                              SizedBox(height: 15.h),
                              _buildButton(context, AppLocalizations.deleteAccount,
                                  AppImages.exitgame, () async {
                                if (await canLaunchUrl(deleteAccountUrl)) {
                                  await launchUrl(deleteAccountUrl,
                                      mode: LaunchMode.externalApplication);
                                }
                              }, false),
                              SizedBox(height: 15.h),
                              _buildButton(context, AppLocalizations.logout,
                                  AppImages.exitgame, () {
                                _handleLogout(context);
                              }, false),
                              
                              SizedBox(height: 30.h),
                              
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                child: Column(
                                  children: [
                                    Text(
                                      AppLocalizations.connectUsAt,
                                      style: GoogleFonts.lato(
                                        color: const Color(0xFF90C1D6),
                                        fontSize: isTablet ? 24 : 20.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        CustomSvgImage(
                                          onTap: () async {
                                            if (await canLaunchUrl(twitterUrl)) {
                                              await launchUrl(twitterUrl,
                                                  mode: LaunchMode.externalApplication);
                                            }
                                          },
                                          imageUrl: AppImages.twitterSvg,
                                          width: isTablet ? 30 : 22.w,
                                          height: isTablet ? 30 : 22.h,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 15.w),
                                        CustomSvgImage(
                                          onTap: () async {
                                            if (await canLaunchUrl(youtubeUrl)) {
                                              await launchUrl(youtubeUrl,
                                                  mode: LaunchMode.externalApplication);
                                            }
                                          },
                                          imageUrl: AppImages.youtubeSvg,
                                          width: isTablet ? 30 : 22.w,
                                          height: isTablet ? 30 : 21.h,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 15.w),
                                        CustomSvgImage(
                                          onTap: () async {
                                            if (await canLaunchUrl(instagramUrl)) {
                                              await launchUrl(instagramUrl,
                                                  mode: LaunchMode.externalApplication);
                                            }
                                          },
                                          imageUrl: AppImages.instaSvg,
                                          width: isTablet ? 30 : 22.w,
                                          height: isTablet ? 30 : 22.h,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10.h),
                                    Text(
                                      '${AppLocalizations.version} 1.0.0',
                                      style: GoogleFonts.lato(
                                        color: const Color(0xFF869998),
                                        fontSize: isTablet ? 18 : 16.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Extra space for potential bottom navigation or ad overlap
                              SizedBox(height: 20.h),
                            ],
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
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String text,
    String imageUrl,
    VoidCallback onPressed,
    bool soundControl,
  ) {
    bool isTablet = MediaQuery.of(context).size.width > 600;

    // FIX: Use specific widths for tablet instead of ScreenUtil scaling (.w)
    // .w scales with screen width, which makes buttons massive on tablets.
    double containerWidth = isTablet ? 450 : 250.w;
    double containerHeight = isTablet ? 65 : 60.h;
    
    // For the inner image/content, we slightly adjust
    double contentWidth = isTablet ? 470 : 250.w; 
    double contentHeight = isTablet ? 80 : 60.h;

    return SizedBox(
      width: containerWidth,
      height: containerHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          overlayColor: Colors.blue.withOpacity(0.3),
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
              width: contentWidth,
              height: contentHeight,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppImages.bluebutton),
                  fit: BoxFit.fill,
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                children: [
                  // LEFT ICON
                  if (soundControl)
                    BlocBuilder<SettingsBloc, SettingsState>(
                      builder: (context, state) {
                        String soundImage;
                        if (state.soundValue == 0) {
                          soundImage = AppImages.soundmute;
                        } else if (state.soundValue > 0 &&
                            state.soundValue < 0.5) {
                          soundImage = AppImages.soundhalf;
                        } else {
                          soundImage = AppImages.soundfull;
                        }

                        return Image.asset(
                          soundImage,
                          height: isTablet ? 32 : 30.h,
                          width: isTablet ? 32 : 30.w,
                        );
                      },
                    )
                  else
                    Image.asset(
                      imageUrl,
                      height: isTablet ? 32 : 30.h,
                      width: isTablet ? 32 : 30.w,
                    ),

                  SizedBox(width: 12.w),

                  Text(
                    text,
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      // FIX: Use fixed size for tablet to prevent over-scaling
                      fontSize: isTablet ? 22 : 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  // SLIDER
                  if (soundControl)
                    Flexible(
                      child: BlocBuilder<SettingsBloc, SettingsState>(
                        builder: (context, state) {
                          return Slider(
                            value: state.soundValue,
                            onChanged: (value) {
                              context
                                  .read<SettingsBloc>()
                                  .add(UpdateSoundValue(value));
                            },
                            activeColor: Colors.white,
                            inactiveColor: Colors.white30,
                          );
                        },
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

  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A2A44),
          title: Text(
            AppLocalizations.logout,
            style: GoogleFonts.lato(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            AppLocalizations.areYouSureLogout,
            style: GoogleFonts.lato(
              color: Colors.white70,
              fontSize: 16.sp,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: Text(
                AppLocalizations.cancel,
                style: GoogleFonts.lato(
                  color: Colors.white70,
                  fontSize: 14.sp,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await _userRepo.logout();
                Navigator.of(dialogContext).pop(true);
              },
              child: Text(
                AppLocalizations.logout,
                style: GoogleFonts.lato(
                  color: Colors.red,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      // Sign out from Google and Facebook
      try {
        await _googleAuthService.signOut();
      } catch (e) {
        print('Error signing out from Google: $e');
      }
      try {
        await _facebookAuthService.signOut();
      } catch (e) {
        print('Error signing out from Facebook: $e');
      }

      // Clear all stored data - ensure everything is cleared
      await LocalStorageUtils.clear();

      // Force clear again to ensure all preferences are removed
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Reset language to default after clearing
      AppLocalizations.setLanguage('en');

      // Navigate to sign in screen
      if (context.mounted) {
        context.go(Routes.signInScreen);
      }
    }
  }
}
