import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inkbattle_frontend/constants/app_colors.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';
import 'package:inkbattle_frontend/utils/routes/routes.dart';
import 'package:inkbattle_frontend/widgets/backgroun_scafold.dart';
import 'package:inkbattle_frontend/widgets/text_widget.dart';
import 'package:inkbattle_frontend/logic/auth/google_auth_service.dart';
import 'package:inkbattle_frontend/logic/auth/apple_auth_service.dart';
import 'package:inkbattle_frontend/logic/auth/facebook_auth_service.dart';
import 'package:inkbattle_frontend/utils/preferences/local_preferences.dart';
import 'package:inkbattle_frontend/utils/lang.dart';
import 'package:inkbattle_frontend/widgets/video_reward_dialog.dart';
import 'package:inkbattle_frontend/repositories/user_repository.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  final AppleAuthService _appleAuthService = AppleAuthService();
  final FacebookAuthService _facebookAuthService = FacebookAuthService();
  final UserRepository _userRepository = UserRepository();
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;
  bool _isFacebookLoading = false;

  Future<void> _signInWithGoogle() async {
    if (_isGoogleLoading || _isFacebookLoading) {
      return; // Prevent multiple simultaneous sign-ins
    }

    setState(() => _isGoogleLoading = true);

    try {
      final authResponse = await _googleAuthService.signInWithGoogle();

      if (authResponse != null &&
          authResponse.token != null &&
          authResponse.token!.isNotEmpty) {
        // Save token and navigate to home
        await LocalStorageUtils.saveUserDetails(authResponse.token!);
        print('Google sign-in successful, token saved');

        // Fetch user profile and apply language preference
        await _applyUserLanguagePreference();

        if (mounted) {
          // Show coin animation if user is new
          if (authResponse.isNew == true) {
            VideoRewardDialog.show(
              context,
              coinsAwarded: 1000,
              onComplete: () {
                if (mounted) {
                  context.go(Routes.homeScreen);
                }
              },
            );
          } else {
            context.go(Routes.homeScreen);
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.googleSignInFailed)),
          );
        }
      }
    } catch (e) {
      print('Google sign-in error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('${AppLocalizations.signInError}: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  Future<void> _signInWithApple() async {
    if (_isAppleLoading || _isFacebookLoading) {
      return; // Prevent multiple simultaneous sign-ins
    }

    setState(() => _isAppleLoading = true);

    try {
      final authResponse = await _appleAuthService.signInWithApple();

      if (authResponse != null &&
          authResponse.token != null &&
          authResponse.token!.isNotEmpty) {
        await LocalStorageUtils.saveUserDetails(authResponse.token!);
        print('Apple sign-in successful, token saved');

        await _applyUserLanguagePreference();

        if (mounted) {
          if (authResponse.isNew == true) {
            VideoRewardDialog.show(
              context,
              coinsAwarded: 1000,
              onComplete: () {
                if (mounted) {
                  context.go(Routes.homeScreen);
                }
              },
            );
          } else {
            context.go(Routes.homeScreen);
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.googleSignInFailed)),
          );
        }
      }
    } catch (e) {
      print('Apple sign-in error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('${AppLocalizations.signInError}: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAppleLoading = false);
      }
    }
  }

  // Apply user's language preference from profile
  Future<void> _applyUserLanguagePreference() async {
    try {
      final result = await _userRepository.getMe();
      result.fold(
        (failure) {
          print('Failed to fetch user profile: ${failure.message}');
        },
        (user) async {
          // If user has a language preference, apply it
          if (user.language != null && user.language!.isNotEmpty) {
            // Map language value to language code
            // Handle both full names (Hindi, Telugu, English) and codes (hi, te, en)
            String languageCode = 'en';
            final userLang = user.language!.trim();

            // Check for full names first (case-insensitive)
            if (userLang.toLowerCase() == 'hindi' ||
                userLang.toLowerCase() == 'hi') {
              languageCode = 'hi';
            } else if (userLang.toLowerCase() == 'telugu' ||
                userLang.toLowerCase() == 'te') {
              languageCode = 'te';
            } else if (userLang.toLowerCase() == 'english' ||
                userLang.toLowerCase() == 'en') {
              languageCode = 'en';
            }

            // Save and apply language
            await LocalStorageUtils.saveLanguage(languageCode);
            AppLocalizations.setLanguage(languageCode);
            print(
                'Applied user language preference: $languageCode from user.language: ${user.language}');
          }
        },
      );
    } catch (e) {
      print('Error applying user language preference: $e');
    }
  }

  Future<void> _signInWithFacebook() async {
    if (_isGoogleLoading || _isFacebookLoading) {
      return; // Prevent multiple simultaneous sign-ins
    }

    setState(() => _isFacebookLoading = true);

    try {
      final authResponse = await _facebookAuthService.signInWithFacebook();

      if (authResponse != null &&
          authResponse.token != null &&
          authResponse.token!.isNotEmpty) {
        // Save token and navigate to home
        await LocalStorageUtils.saveUserDetails(authResponse.token!);
        print('Facebook sign-in successful, token saved');

        // Fetch user profile and apply language preference
        await _applyUserLanguagePreference();

        if (mounted) {
          // Show coin animation if user is new
          if (authResponse.isNew == true) {
            VideoRewardDialog.show(
              context,
              coinsAwarded: 1000,
              onComplete: () {
                if (mounted) {
                  context.go(Routes.homeScreen);
                }
              },
            );
          } else {
            context.go(Routes.homeScreen);
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.facebookSignInFailed)),
          );
        }
      }
    } catch (e) {
      print('Facebook sign-in error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('${AppLocalizations.signInError}: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isFacebookLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return BackgroundScaffold(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.015,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    AppImages.logo,
                    width: screenWidth * 0.9,
                    height: screenHeight * 0.5,
                    fit: BoxFit.contain,
                  ),
                  Positioned(
                    top: screenHeight * 0.41,
                    child: TextWidget(
                      text: AppLocalizations.inkBattle,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: AppColors.whiteColor,
                        fontSize: screenWidth * 0.05,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                child: Container(
                  height: screenHeight * 0.07,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromRGBO(255, 255, 255, 1),
                        Color.fromRGBO(0, 186, 255, 1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.018,
                      ),
                    ),
                    onPressed: Platform.isIOS
                        ? (_isAppleLoading ? null : _signInWithApple)
                        : (_isGoogleLoading ? null : _signInWithGoogle),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: 30.w),
                        if (Platform.isIOS)
                          (_isAppleLoading
                              ? SizedBox(
                                  height: screenHeight * 0.03,
                                  width: screenHeight * 0.03,
                                  child: const CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : Icon(
                                  Icons.apple,
                                  size: screenHeight * 0.03,
                                  color: Colors.black,
                                ))
                        else
                          (_isGoogleLoading
                              ? SizedBox(
                                  height: screenHeight * 0.03,
                                  width: screenHeight * 0.03,
                                  child: const CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : Image.asset(
                                  AppImages.googlePng,
                                  height: screenHeight * 0.03,
                                  width: screenHeight * 0.03,
                                )),
                        SizedBox(width: 30.w),
                        TextWidget(
                          text: Platform.isIOS
                              ? (_isAppleLoading
                                  ? AppLocalizations.signingIn
                                  : 'Sign in with Apple')
                              : (_isGoogleLoading
                                  ? AppLocalizations.signingIn
                                  : AppLocalizations.signInWithGoogle),
                          style: GoogleFonts.lato(
                            fontSize: 14.sp,
                            color: const Color(0xFF000000),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                child: Container(
                  height: screenHeight * 0.07,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(8, 102, 255, 1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.018,
                      ),
                    ),
                    onPressed: _isFacebookLoading ? null : _signInWithFacebook,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: 30.w),
                        _isFacebookLoading
                            ? SizedBox(
                                height: screenHeight * 0.03,
                                width: screenHeight * 0.03,
                                child: const CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : Image.asset(
                                AppImages.facebookSvg,
                                height: screenHeight * 0.03,
                                width: screenHeight * 0.03,
                              ),
                        SizedBox(width: 30.w),
                        TextWidget(
                          text: _isFacebookLoading
                              ? AppLocalizations.signingIn
                              : AppLocalizations.signInWithFacebook,
                          style: GoogleFonts.lato(
                            fontSize: 14.sp,
                            color: const Color(0xFFFFFFFF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              TextWidget(
                text: AppLocalizations.or,
                style: GoogleFonts.poppins(
                  color: AppColors.whiteColor,
                  fontWeight: FontWeight.w800,
                  fontSize: screenWidth * 0.04,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                child: Container(
                  height: screenHeight * 0.07,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromRGBO(83, 128, 246, 1),
                        Color.fromRGBO(79, 62, 207, 1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.018,
                      ),
                    ),
                    onPressed: () {
                      context.push(Routes.guestSignupScreen);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextWidget(
                          text: AppLocalizations.playAsGuest,
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: AppColors.whiteColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              TextWidget(
                text: AppLocalizations.progressNotSaved,
                style: GoogleFonts.lato(
                  fontSize: screenWidth * 0.03,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFB6B6B6),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              // RichText(
              //   text: TextSpan(
              //     text: "Don’t you have an account ? ",
              //     style: GoogleFonts.dmSans(
              //         color: AppColors.whiteColor,
              //         fontSize: 14.sp,
              //         fontWeight: FontWeight.w500),
              //     children: [
              //       TextSpan(
              //         text: ' Signup',
              //         style: GoogleFonts.dmSans(
              //           color: const Color.fromRGBO(9, 189, 255, 1),
              //           fontWeight: FontWeight.w500,
              //         ),
              //         recognizer: TapGestureRecognizer()
              //           ..onTap = () {
              //             context.push(Routes.signupScreen);
              //           },
              //       ),
              //     ],
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }
}
