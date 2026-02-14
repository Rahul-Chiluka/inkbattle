import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:inkbattle_frontend/constants/app_colors.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';
import 'package:inkbattle_frontend/repositories/room_repository.dart';
import 'package:inkbattle_frontend/repositories/theme_repository.dart';
import 'package:inkbattle_frontend/repositories/user_repository.dart';
import 'package:inkbattle_frontend/utils/lang.dart';
import 'package:inkbattle_frontend/widgets/blue_background_scaffold.dart';
import 'package:inkbattle_frontend/widgets/custom_svg.dart';
import 'package:inkbattle_frontend/widgets/text_widget.dart';
import 'package:inkbattle_frontend/widgets/persistent_banner_ad_widget.dart';
import 'package:inkbattle_frontend/widgets/country_picker_widget.dart'; // Add this import
import 'package:google_fonts/google_fonts.dart'; // Added for typography
import 'widgets/selection_bottom_sheet.dart';

class RoomPreferencesScreen extends StatefulWidget {
  const RoomPreferencesScreen({super.key});

  @override
  State<RoomPreferencesScreen> createState() => _RoomPreferencesScreenState();
}

class _RoomPreferencesScreenState extends State<RoomPreferencesScreen> {
  final RoomRepository _roomRepository = RoomRepository();
  final UserRepository _userRepository = UserRepository();
  final ThemeRepository _themeRepository = ThemeRepository();

  String? selectedLanguage;
  String? selectedCountry;
  String? selectedCategory;
  int? selectedTargetPoints;
  bool voiceEnabled = false;
  bool _isLoading = false;

  // REMOVED: Ad variables
  // BannerAd? _bannerAd;
  // bool _isBannerAdLoaded = false;

  List<String> languages = [];
  final List<String> countries = [
    "🇮🇳 India",
    "🇺🇸 USA",
    "🇬🇧 UK",
    "🇯🇵 Japan",
    "🇪🇸 Spain",
    "🇵🇹 Portugal",
    "🇫🇷 France",
    "🇩🇪 Germany",
    "🇷🇺 Russia"
  ];
  List<String> categories = [];
  final List<int> targetPoints = [50, 100, 150, 200];

  @override
  void initState() {
    super.initState();
    _loadLanguagesAndCategories();
    // REMOVED: _loadBannerAd();
  }

  @override
  void dispose() {
    // REMOVED: _bannerAd?.dispose();
    super.dispose();
  }

  // REMOVED: _loadBannerAd() function

  Future<void> _loadLanguagesAndCategories() async {
    // Load languages
    final languagesResult = await _userRepository.getLanguages();
    languagesResult.fold(
          (failure) {
        // Fallback to default values on error
        if (mounted) {
          setState(() {
            languages = ["English", "Hindi", "Marathi", "Telugu"];
          });
        }
      },
          (languagesList) {
        if (languagesList.isEmpty) {
          // Fallback to default values if empty
          if (mounted) {
            setState(() {
              languages = ["English", "Hindi", "Marathi", "Telugu"];
            });
          }
          return;
        } else {
          if (mounted) {
            setState(() {
              languages = languagesList
                  .map((lang) => lang['languageName'] as String? ?? '')
                  .where((name) => name.isNotEmpty)
                  .toList();
            });
          }
        }
      },
    );

    // Load categories
    final categoriesResult = await _themeRepository.getCategories();
    categoriesResult.fold(
          (failure) {
        // Fallback to default values on error
        if (mounted) {
          setState(() {
            categories = ["Fruits", "Animals", "Food", "Movies"];
          });
        }
      },
          (categoriesList) {
        if (categoriesList.isEmpty) {
          // Fallback to default values if empty
          if (mounted) {
            setState(() {
              categories = ["Fruits", "Animals", "Food", "Movies"];
            });
          }
          return;
        }
        if (mounted) {
          setState(() {
            categories = categoriesList
                .map((cat) => cat['title'] as String? ?? '')
                .where((title) => title.isNotEmpty)
                .toList();
          });
        }
      },
    );
  }

  Future<void> _handlePlayRandom() async {
    // Validate required fields are selected
    if (selectedLanguage == null ||
        selectedCountry == null ||
        selectedCategory == null ||
        selectedTargetPoints == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.pleaseSelectAllFields),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Call play random API (backend will check coins)
      final category = selectedCategory;
      final result = await _roomRepository.playRandom(
        language: selectedLanguage,
        country: selectedCountry,
        categories: category != null ? [category] : null,
        targetPoints: selectedTargetPoints,
        voiceEnabled: voiceEnabled,
      );

      result.fold(
            (failure) {
          if (mounted) {
            // Check if it's insufficient coins error
            if (failure.message.contains('insufficient_coins')) {
              _showInsufficientCoinsSnackBar();
            }
            // Check if it's a "no matches found" error
            else if (failure.message.contains('no_matches_found')) {
              _showNoMatchesDialog();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${AppLocalizations.failedToFindMatch}: ${failure.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
            (roomResponse) async {
          // Check if match was found
          if (roomResponse.success == true) {
            if (mounted) {
              // Navigate to game room (coins already deducted by backend)
              context.push('/game-room/${roomResponse.room?.id}');
            }
          } else {
            // No matches found
            if (mounted) {
              _showNoMatchesDialog();
            }
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // void _showInsufficientCoinsDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       backgroundColor: const Color(0xFF1A1A2E),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(20.r),
  //       ),
  //       title: TextWidget(
  //         text: AppLocalizations.insufficientCoinsTitle,
  //         fontSize: 18.sp,
  //         fontWeight: FontWeight.bold,
  //         color: AppColors.whiteColor,
  //       ),
  //       content: TextWidget(
  //         text: AppLocalizations.insufficientCoinsMessage,
  //         fontSize: 14.sp,
  //         color: Colors.grey,
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: TextWidget(
  //             text: AppLocalizations.cancel,
  //             fontSize: 14.sp,
  //             color: Colors.grey,
  //           ),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             // TODO: Navigate to watch ads screen
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               SnackBar(content: Text(AppLocalizations.watchAdsComingSoon)),
  //             );
  //           },
  //           child: TextWidget(
  //             text: AppLocalizations.watchAds,
  //             fontSize: 14.sp,
  //             color: Colors.orange,
  //           ),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             // TODO: Navigate to buy coins screen
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               SnackBar(content: Text(AppLocalizations.buyCoinsComingSoon)),
  //             );
  //           },
  //           child: TextWidget(
  //             text: AppLocalizations.buyCoins,
  //             fontSize: 14.sp,
  //             color: Colors.green,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  void _showInsufficientCoinsSnackBar() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: TextWidget(
          text: "${AppLocalizations.insufficientCoinsTitle}. ${AppLocalizations.insufficientCoinsMessage}",
          fontSize: 14.sp,
          color: Colors.grey,
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }



  void _showNoMatchesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: TextWidget(
          text: AppLocalizations.noMatchesFound,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.whiteColor,
        ),
        content: TextWidget(
          text: AppLocalizations.noMatchesMessage,
          fontSize: 14.sp,
          color: Colors.grey,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: TextWidget(
              text: AppLocalizations.tryAgain,
              fontSize: 14.sp,
              color: Colors.blue,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/create-room');
            },
            child: TextWidget(
              text: AppLocalizations.createRoom,
              fontSize: 14.sp,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createPublicRoom() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final category = selectedCategory;
      final result = await _roomRepository.createPublicRoom(
        name: '${category!} Room',
        language: selectedLanguage,
        categories: category != null ? [category] : null,
        country: selectedCountry,
        targetPoints: selectedTargetPoints,
      );

      result.fold(
            (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to create room: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
            (roomResponse) async {
          // Deduct 250 coins
          await _userRepository.addCoins(amount: -250, reason: 'room_create');

          if (mounted) {
            // Navigate to game room
            context.push('/game-room/${roomResponse.room?.id}');
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Removed manual tablet checks - use ScreenUtil for consistent scaling
    
    return BlueBackgroundScaffold(
      child: SafeArea(
        bottom: true, // Protect bottom for ad visibility
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: EdgeInsets.all(8.w),
                      child: Icon(
                        Icons.arrow_back_ios, // Use simple arrow as requested
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        AppLocalizations.randomMatch,
                        style: GoogleFonts.russoOne( // Updated font
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.8),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 40.w), // Adjusted balance spacing
                ],
              ),
            ),

            SizedBox(height: 10.h),

            // MAIN CONTENT
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 500.w), // Re-introduced constraint
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width > 600
                          ? 550 // Increased max width for tablet
                          : 0.98.sw, // Increased width (reduced margins)
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Language
                          _buildGradientDropdown(
                            hint: AppLocalizations.selectLanguage,
                            value: selectedLanguage,
                            items: languages,
                            iconData: Icons.language,
                            onChanged: (v) => setState(() => selectedLanguage = v),
                          ),
                          SizedBox(height: 20.h),

                          // Country
                          // Country
                          // Country
                          CountryPickerWidget(
                            selectedCountryCode: selectedCountry,
                            onCountrySelected: (code) => setState(() => selectedCountry = code),
                            hintText: AppLocalizations.country,
                            icon: Icons.public,
                            iconColor: const Color(0xFF09BDFF),
                            useGradientDesign: true,
                            height: 58.h, // Explicit height to match other fields
                          ),
                          SizedBox(height: 20.h),

                          // Category
                          _buildGradientDropdown(
                            hint: AppLocalizations.selectCategory,
                            value: selectedCategory,
                            items: categories,
                            iconData: Icons.grid_view_rounded,
                            onChanged: (v) => setState(() => selectedCategory = v),
                          ),
                          SizedBox(height: 20.h),

                          // Target Points
                          _buildGradientDropdown(
                            hint: AppLocalizations.selectTargetPoints,
                            value: selectedTargetPoints?.toString(),
                            items: targetPoints.map((e) => e.toString()).toList(),
                            iconData: Icons.ads_click,
                            onChanged: (v) => setState(() =>
                            selectedTargetPoints = int.tryParse(v ?? '100')),
                          ),
                          SizedBox(height: 40.h),

                          // Join button
                          _buildJoinButton(),
                          
                          SizedBox(height: 20.h), // Bottom padding for scrolling
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Persistent Banner Ad (app-wide, loaded once)
            const PersistentBannerAdWidget(),
          ],
        ),
      ),
    );
  }

  // Widget _buildJoinButton() {
  //   return Container(
  //     width: double.infinity, // Fills the constrained parent
  //     height: 58.h, // Reduced from 65.h
  //     decoration: BoxDecoration(
  //       gradient: const LinearGradient(
  //         colors: [
  //           Color(0xFF00C6FF), // Cyan
  //           Color(0xFF0072FF), // Blue
  //         ],
  //       ),
  //       borderRadius: BorderRadius.circular(15.r), // Match dropdown radius
  //       boxShadow: [
  //         BoxShadow(
  //           color: const Color(0xFF0072FF).withOpacity(0.5),
  //           blurRadius: 20,
  //           offset: const Offset(0, 5),
  //         ),
  //       ],
  //     ),
  //     child: ElevatedButton(
  //       style: ElevatedButton.styleFrom(
  //         padding: EdgeInsets.zero, // Remove default padding
  //         backgroundColor: Colors.transparent,
  //         shadowColor: Colors.transparent,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(15.r),
  //         ),
  //       ),
  //       onPressed: _isLoading ? null : _handlePlayRandom,
  //       child: Center(
  //         child: _isLoading
  //             ? const CircularProgressIndicator(color: Colors.white)
  //             : Text(
  //           AppLocalizations.playRandomCoins,
  //           textAlign: TextAlign.center,
  //           style: GoogleFonts.exo2(
  //             fontSize: 18.sp, // Kept readable size for button
  //             fontWeight: FontWeight.bold,
  //             color: Colors.white,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildJoinButton() {
  return Container(
    width: double.infinity,
    height: 58.h,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
      ),
      borderRadius: BorderRadius.circular(15.r),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0072FF).withOpacity(0.5),
          blurRadius: 20,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      ),
      onPressed: _isLoading ? null : _handlePlayRandom,
      child: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  // Removed text "Play Random" as requested
                  // Text(
                  //   "Play Random", 
                  //   style: GoogleFonts.exo2(
                  //     fontSize: 18.sp,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.white,
                  //   ),
                  // ),
                  // SizedBox(width: 8.w),
                // Replace with your coin SVG or Icon
                Image.asset(
                  AppImages.coin, // Ensure this path exists in your constants
                  width: 20.w,
                  height: 20.w,
                ),
                SizedBox(width: 4.w),
                Text(
                  "250",
                  style: GoogleFonts.exo2(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
    ),
  );
}

  Widget _buildGradientDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required IconData iconData,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.r),
        gradient: const LinearGradient(
          colors: [
            Color.fromRGBO(255, 255, 255, 0.8),
            Color.fromRGBO(9, 189, 255, 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(1.2), // Border width
      child: Container(
        height: 58.h, // Match other fields height
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(13.r),
            onTap: () async {
              FocusScope.of(context).unfocus();
              final result = await showModalBottomSheet<String>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => SelectionBottomSheet(
                  title: hint,
                  items: items,
                  selectedItem: value,
                ),
              );
              if (result != null) {
                onChanged(result);
              }
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    iconData,
                    color: const Color(0xFF09BDFF),
                    size: 24.sp, // Match other fields icon size
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: Text(
                      value ?? hint,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: GoogleFonts.lato(
                        color: value == null ? Colors.white54 : Colors.white,
                        fontSize: 16.sp, // Match other fields font size
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 24.sp,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

  