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
              _createPublicRoom();
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
    final mq = MediaQuery.of(context);
    final bool isTablet = mq.size.width > 600;
    final double controlWidth = mq.size.width - (isTablet ? 40.w : 24.w);

    return BlueBackgroundScaffold(
      child: SafeArea(
        bottom: true, // Protect bottom for ad visibility
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
          child: Column(
            children: [
              // Back button and title
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const CustomSvgImage(
                      imageUrl: AppImages.arrow_back,
                      height: 25,
                      width: 25,
                    ),
                  ),
                  SizedBox(width: 15.w),
                  TextWidget(
                    text: AppLocalizations.randomMatch,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.whiteColor,
                  ),
                ],
              ),
              SizedBox(height: 30.h),

              // Preferences form
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Language
                      _buildDropdown(
                        width: controlWidth,
                        hint: AppLocalizations.selectLanguage,
                        value: selectedLanguage,
                        items: languages,
                        imageurl: AppImages.mp1,
                        onChanged: (v) => setState(() => selectedLanguage = v),
                      ),
                      SizedBox(height: 15.h),

                      // Country
                      _buildDropdown(
                        width: controlWidth,
                        hint: AppLocalizations.country,
                        value: selectedCountry,
                        items: countries,
                        imageurl: AppImages.mp4,
                        onChanged: (v) => setState(() => selectedCountry = v),
                      ),
                      SizedBox(height: 15.h),

                      // Category
                      _buildDropdown(
                        width: controlWidth,
                        hint: AppLocalizations.selectCategory,
                        value: selectedCategory,
                        items: categories,
                        imageurl: AppImages.mp5,
                        onChanged: (v) => setState(() => selectedCategory = v),
                      ),
                      SizedBox(height: 15.h),

                      // Target Points
                      _buildDropdown(
                        width: controlWidth,
                        hint: AppLocalizations.selectTargetPoints,
                        value: selectedTargetPoints?.toString(),
                        items: targetPoints.map((e) => e.toString()).toList(),
                        imageurl: AppImages.mp3,
                        onChanged: (v) => setState(() =>
                            selectedTargetPoints = int.tryParse(v ?? '100')),
                      ),
                      SizedBox(height: 15.h),

                      SizedBox(height: 30.h),

                      // Join button
                      _buildJoinButton(),
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

  Widget _buildJoinButton() {
    return Container(
      width: double.infinity,
      height: 55.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromRGBO(83, 128, 246, 1),
            Color.fromRGBO(79, 62, 207, 1),
          ],
        ),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
        ),
        onPressed: _isLoading ? null : _handlePlayRandom,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : TextWidget(
                text: AppLocalizations.playRandomCoins,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.whiteColor,
              ),
      ),
    );
  }

  Widget _buildDropdown({
    required double width,
    required String hint,
    required String? value,
    required List<String> items,
    required String imageurl,
    required ValueChanged<String?> onChanged,
  }) {
    final GlobalKey tapKey = GlobalKey();
    final bool isFilled = value != null;

    return Container(
      width: width,
      height: 50.h,
      decoration: BoxDecoration(
        border: Border.all(
          color: isFilled ? Colors.white : Colors.grey,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(25.r),
        color: Colors.black.withOpacity(0.3),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: tapKey,
          borderRadius: BorderRadius.circular(25.r),
          onTap: () async {
            final box = tapKey.currentContext!.findRenderObject() as RenderBox;
            final Offset pos = box.localToGlobal(Offset.zero);
            final Size size = box.size;

            final selected = await showMenu<String>(
              context: context,
              position: RelativeRect.fromLTRB(
                pos.dx,
                pos.dy + size.height + 5,
                pos.dx + size.width,
                pos.dy + size.height + 5,
              ),
              color: Colors.transparent,
              constraints: BoxConstraints(
                minWidth: size.width,
                maxWidth: size.width,
              ),
              items: [
                PopupMenuItem<String>(
                  enabled: false,
                  padding: EdgeInsets.zero,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.r),
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromRGBO(255, 255, 255, 1),
                          Color.fromRGBO(9, 189, 255, 1),
                        ],
                      ),
                    ),
                    padding: EdgeInsets.all(2.w),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.r),
                        color: Colors.black,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: items.asMap().entries.map((entry) {
                          final index = entry.key;
                          final e = entry.value;
                          return Container(
                            decoration: BoxDecoration(
                              border: index < items.length - 1
                                  ? const Border(
                                      bottom: BorderSide(
                                        color:
                                            Color.fromRGBO(255, 255, 255, 0.2),
                                        width: 2,
                                      ),
                                    )
                                  : null,
                            ),
                            child: InkWell(
                              onTap: () => Navigator.pop(context, e),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 15.w,
                                  vertical: 12.h,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    e,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            );
            if (selected != null) onChanged(selected);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Row(
              children: [
                Image.asset(
                  imageurl,
                  width: 24.w,
                  height: 24.h,
                  color: Colors.white,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    value ?? hint,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      color: value == null
                          ? const Color.fromRGBO(255, 255, 255, 0.52)
                          : Colors.white,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  size: 24.sp,
                  color: const Color.fromRGBO(9, 189, 255, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox({
    required double width,
    required String title,
    required String imageurl,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      width: width,
      height: 50.h,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 2),
        borderRadius: BorderRadius.circular(25.r),
        color: Colors.black.withOpacity(0.3),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(25.r),
        onTap: () => onChanged(!value),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Row(
            children: [
              Image.asset(
                imageurl,
                width: 24.w,
                height: 24.h,
                color: value ? null : Colors.grey,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
              ),
              Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: const Color.fromARGB(255, 7, 182, 7),
                checkColor: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
