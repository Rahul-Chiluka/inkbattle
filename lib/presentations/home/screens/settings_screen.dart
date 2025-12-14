import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';
import 'package:inkbattle_frontend/presentations/home/bloc/settings_bloc.dart';
import 'package:inkbattle_frontend/services/ad_service.dart';
import 'package:inkbattle_frontend/widgets/custom_svg.dart';
import 'package:inkbattle_frontend/utils/preferences/local_preferences.dart';
import 'package:inkbattle_frontend/utils/routes/routes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:inkbattle_frontend/repositories/user_repository.dart';
import 'package:inkbattle_frontend/utils/lang.dart';
import 'package:inkbattle_frontend/logic/auth/google_auth_service.dart';
import 'package:inkbattle_frontend/logic/auth/facebook_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
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
    // TODO: implement initState
    super.initState();
    _loadBannerAd();
  }

  Future<void> _loadBannerAd() async {
    try {
      // Initialize Mobile Ads SDK first
      await AdService.initializeMobileAds();

      // Load banner ad
      await AdService.loadBannerAd(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _bannerAd = ad as BannerAd;
              _isBannerAdLoaded = true;
            });
            print('✅ Banner ad loaded successfully');
          }
        },
        onAdFailedToLoad: (ad, error) {
          print('❌ Banner ad failed to load: $error');
          if (mounted) {
            setState(() {
              _isBannerAdLoaded = false;
            });
          }
        },
      );
    } catch (e) {
      print('Error loading banner ad: $e');
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsBloc()..add(SettingsInitialEvent()),
      child: Scaffold(
        key: ValueKey(AppLocalizations
            .getCurrentLanguage()), // Force rebuild on language change
        backgroundColor: const Color(0xFF1A2A44),
        body: SafeArea(
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
                                    AppLocalizations.settings,
                                    style: GoogleFonts.lato(
                                      color: Colors.white,
                                      fontSize: 30.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )),
                      SizedBox(height: 15.h),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildButton(context, AppLocalizations.sound,
                                AppImages.soundfull, () {}, true),
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
                            _buildButton(
                                context,
                                AppLocalizations.privacyAndSafety,
                                AppImages.privacy, () {
                              context.push(Routes.privacySafetyScreen);
                            }, false),
                            _buildButton(context, AppLocalizations.contact,
                                AppImages.contact, () {}, false),
                            _buildButton(context, AppLocalizations.deleteAccount,
                                AppImages.exitgame, () async {
                              if (await canLaunchUrl(deleteAccountUrl)) {
                                await launchUrl(deleteAccountUrl,
                                    mode: LaunchMode.externalApplication);
                              }
                            }, false),
                            _buildButton(context, AppLocalizations.logout,
                                AppImages.exitgame, () {
                              _handleLogout(context);
                            }, false),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        child: Column(
                          children: [
                            Text(
                              AppLocalizations.connectUsAt,
                              style: GoogleFonts.lato(
                                color: const Color(0xFF90C1D6),
                                fontSize: 20.sp,
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
                                  width: 22.w,
                                  height: 22.h,
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
                                  width: 22.w,
                                  height: 21.h,
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
                                  width: 22.w,
                                  height: 22.h,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              '${AppLocalizations.version} 1.0.0',
                              style: GoogleFonts.lato(
                                color: const Color(0xFF869998),
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              if (_isBannerAdLoaded && _bannerAd != null)
                Container(
                  width: double.infinity,
                  height: 60.h,
                  color: Colors.black.withOpacity(0.3),
                  child: AdWidget(ad: _bannerAd!),
                )
              else
                Container(
                  width: double.infinity,
                  height: 60.h,
                  color: Colors.grey.withOpacity(0.2),
                  child: Center(
                    child: Text(
                      AppLocalizations.loadingAds,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 10.h),
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
    return SizedBox(
      width: MediaQuery.of(context).size.width > 600 ? 252.w : 250.w,
      height: MediaQuery.of(context).size.width > 600 ? 50.h : 60.h,
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
              width: MediaQuery.of(context).size.width > 600 ? 270.w : 250.w,
              height: MediaQuery.of(context).size.width > 600 ? 75.h : 60.h,
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
                          height: 30.h,
                          width: 30.w,
                        );
                      },
                    )
                  else
                    Image.asset(
                      imageUrl,
                      height: 30.h,
                      width: 30.w,
                    ),

                  SizedBox(width: 12.w),

                  Text(
                    text,
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 18.sp,
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
