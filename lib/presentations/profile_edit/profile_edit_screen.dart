import 'dart:math';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inkbattle_frontend/constants/app_colors.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';
import 'package:inkbattle_frontend/models/user_model.dart';
import 'package:inkbattle_frontend/utils/preferences/local_preferences.dart';
import 'package:inkbattle_frontend/widgets/backgroun_scafold.dart';
import 'package:inkbattle_frontend/widgets/custom_svg.dart';
import 'package:inkbattle_frontend/widgets/text_widget.dart';
import 'package:inkbattle_frontend/widgets/textformfield_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:inkbattle_frontend/utils/routes/routes.dart';
import 'package:inkbattle_frontend/widgets/topCoins.dart';
import 'package:inkbattle_frontend/repositories/user_repository.dart';
import 'package:video_player/video_player.dart';
import 'package:inkbattle_frontend/utils/lang.dart';
import 'package:inkbattle_frontend/widgets/country_picker_widget.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({
    super.key,
  });

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen>
    with TickerProviderStateMixin {
  final String _logTag = 'ProfileEditScreen';
  final UserRepository _userRepository = UserRepository();
  bool nameLoaded = false;
  bool profileLoaded = false;
  late final TextEditingController _usernameController;
  final FocusNode _usernameFocusNode = FocusNode();
  UserModel? _user;
  String? selectedLanguage;
  String? selectedCountry;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int selectedAvatarIndex = 0;
  String? selectedProfilePhoto;
  bool _isSubmitting = false;
  List<String> avatarsURLs = [
    AppImages.av1,
    AppImages.av2,
    AppImages.av3,
    AppImages.av4,
    AppImages.av5,
  ];

  late AnimationController _controller;
  late AnimationController _avatarMoveController;
  late List<Animation<Offset>> _coinDrops;
  late Animation<double> _textOpacity;
  VideoPlayerController? _videoController;
  final random = Random();

  // Avatar swipe animation variables
  late AnimationController _avatarSwipeController;
  int _previousAvatarIndex = 0;
  double _swipeOffset = 0.0;
  bool _isSwiping = false;

final List<String> languages = [
    "English",    // English
    "हिंदी",      // Hindi
    "తెలుగు",     // Telugu
    "தமிழ்",      // Tamil
    "मराठी",      // Marathi
    "ಕನ್ನಡ",      // Kannada
    "മലയാളം",    // Malayalam
    "বাংলা",      // Bengali
    "العربية",    // Arabic
    "Español",    // Spanish
    "Português",  // Portuguese
    "Français",   // French
    "Deutsch",    // German
    "Русский",    // Russian
    "日本語",      // Japanese
    "ਪੰਜਾਬੀ",      // Punjabi
    "ગુજરાતી",     // Gujarati
    "Italiano",   // Italian
    "한국어",      // Korean
    "中文",        // Chinese
  ];
  // Countries are now handled via CountryPickerWidget with ISO-2 codes

  void _onAvatarSwipeLeft() {
    if (_isSwiping) return;
    
    setState(() {
      _isSwiping = true;
      _previousAvatarIndex = selectedAvatarIndex;
      selectedAvatarIndex = (selectedAvatarIndex + 1) % avatarsURLs.length;
      selectedProfilePhoto = avatarsURLs[selectedAvatarIndex];
    });
    
    _avatarSwipeController.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() {
          _isSwiping = false;
          _swipeOffset = 0.0;
        });
      }
    });
  }

  void _onAvatarSwipeRight() {
    if (_isSwiping) return;
    
    setState(() {
      _isSwiping = true;
      _previousAvatarIndex = selectedAvatarIndex;
      selectedAvatarIndex = (selectedAvatarIndex - 1 + avatarsURLs.length) % avatarsURLs.length;
      selectedProfilePhoto = avatarsURLs[selectedAvatarIndex];
    });
    
    _avatarSwipeController.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() {
          _isSwiping = false;
          _swipeOffset = 0.0;
        });
      }
    });
  }

  void _loadLanguage() {
    final savedLanguage = LocalStorageUtils.getLanguage();
    
    if (savedLanguage == 'hi') {
      selectedLanguage = 'हिंदी';
    } else if (savedLanguage == 'te') {
      selectedLanguage = 'తెలుగు';
    } else if (savedLanguage == 'ta') {
      selectedLanguage = 'தமிழ்';
    } else if (savedLanguage == 'mr') {
      selectedLanguage = 'मराठी';
    } else if (savedLanguage == 'kn') {
      selectedLanguage = 'ಕನ್ನಡ';
    } else if (savedLanguage == 'ml') {
      selectedLanguage = 'മലയാളം';
    } else if (savedLanguage == 'bn') {
      selectedLanguage = 'বাংলা';
    } else if (savedLanguage == 'ar') {
      selectedLanguage = 'العربية';
    } else if (savedLanguage == 'es') {
      selectedLanguage = 'Español';
    } else if (savedLanguage == 'pt') {
      selectedLanguage = 'Português';
    } else if (savedLanguage == 'fr') {
      selectedLanguage = 'Français';
    } else if (savedLanguage == 'de') {
      selectedLanguage = 'Deutsch';
    } else if (savedLanguage == 'ru') { 
      selectedLanguage = 'Русский';
    } else if (savedLanguage == 'ja') {
      selectedLanguage = '日本語';
    } else if (savedLanguage == 'pa') {
      selectedLanguage = 'ਪੰਜਾਬੀ';
    } else if (savedLanguage == 'gu') {
      selectedLanguage = 'ગુજરાતી';
    } else if (savedLanguage == 'it') {
      selectedLanguage = 'Italiano';
    } else if (savedLanguage == 'ko') {
      selectedLanguage = '한국어';
    } else if (savedLanguage == 'zh') {
      selectedLanguage = '中文';
    } else {
      selectedLanguage = 'English';
    }
  }

  Future<void> _changeLanguage(String? language) async {
    if (language == null) return;

    setState(() {
      selectedLanguage = language;
    });
    if (mounted) setState(() {});

    String languageCode = 'en';
    
    if (language == 'हिंदी') {
      languageCode = 'hi';
    } else if (language == 'తెలుగు') {
      languageCode = 'te';
    } else if (language == 'தமிழ்') {
      languageCode = 'ta';
    } else if (language == 'मराठी') {
      languageCode = 'mr';
    } else if (language == 'ಕನ್ನಡ') {
      languageCode = 'kn';
    } else if (language == 'മലയാളം') {
      languageCode = 'ml';
    } else if (language == 'বাংলা') {
      languageCode = 'bn';
    } else if (language == 'العربية') {
      languageCode = 'ar';
    } else if (language == 'Español') {
      languageCode = 'es';
    } else if (language == 'Português') {
      languageCode = 'pt';
    } else if (language == 'Français') {
      languageCode = 'fr';
    } else if (language == 'Deutsch') {
      languageCode = 'de';
    } else if (language == 'Русский') {
      languageCode = 'ru';
    } else if (language == '日本語') {
      languageCode = 'ja';
    } else if (language == 'ਪੰਜਾਬੀ') {
      languageCode = 'pa';
    } else if (language == 'ગુજરાતી') {
      languageCode = 'gu';
    } else if (language == 'Italiano') {
      languageCode = 'it';
    } else if (language == '한국어') {
      languageCode = 'ko';
    } else if (language == '中文') {
      languageCode = 'zh';
    }

    // Save and apply language
    await LocalStorageUtils.saveLanguage(languageCode);
    AppLocalizations.setLanguage(languageCode);

    // Trigger rebuild
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();

    // Load saved language
    _loadLanguage();

    _usernameController = TextEditingController(
      text: 'Guest_${random.nextInt(99999).toString().padLeft(5, '0')}',
    );

    // Main animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) context.go(Routes.homeScreen);
        });
      }
    });

    // Avatar swipe animation controller
    _avatarSwipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _coinDrops = [];
    _textOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.80, 1.0, curve: Curves.easeIn),
    );
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.asset(
      'asset/animationVideos/coin_reward_animation.mp4',
    );
    await _videoController!.initialize();
    _videoController!.setLooping(false);
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final random = Random();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final stackWidth = screenWidth * 0.6;
    final stackHeight = screenHeight * 0.4;
    final childSize = screenWidth * 0.1;
    final radius = min(stackWidth, stackHeight) * 0.15;

    _coinDrops = List.generate(20, (i) {
      final angle =
          (i * 2 * pi / 20) + (random.nextDouble() * pi / 10 - pi / 20);
      final endDx = (radius * cos(angle)) / childSize;
      final endDy = (radius * sin(angle)) / childSize;
      final beginDx = random.nextDouble() * 4 - 2;
      final beginDy = -(stackHeight / childSize) - (random.nextDouble() * 2);

      return Tween<Offset>(
        begin: Offset(beginDx, beginDy),
        end: Offset(endDx, endDy),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(i * 0.05, 1.0, curve: Curves.easeOut),
      ));
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _usernameFocusNode.dispose();
    _pageController.dispose();
    _controller.dispose();
    _avatarSwipeController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!profileLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        _user = await _userRepository.getUserLocally();
        if (!mounted) return;

        if (!nameLoaded && _user?.name != null) {
          _usernameController.text = _user!.name!;
          nameLoaded = true;
        }
        if (!profileLoaded) {
          if (mounted) {
            setState(() {
              // Default to av3.png if no avatar exists (same as home screen)
              selectedProfilePhoto =
                  _user?.avatar ?? _user?.profilePicture ?? AppImages.av3;
              selectedCountry = _user?.country ?? selectedCountry;
              if (_user?.language != null) {
                String code = _user!.language!;
                if (code == 'hi') selectedLanguage = 'हिंदी';
                else if (code == 'te') selectedLanguage = 'తెలుగు';
                else if (code == 'ta') selectedLanguage = 'தமிழ்';
                else if (code == 'mr') selectedLanguage = 'मराठी';
                else if (code == 'kn') selectedLanguage = 'ಕನ್ನಡ';
                else if (code == 'ml') selectedLanguage = 'മലയാളം';
                else if (code == 'bn') selectedLanguage = 'বাংলা';
                else if (code == 'ar') selectedLanguage = 'العربية';
                else if (code == 'es') selectedLanguage = 'Español';
                else if (code == 'pt') selectedLanguage = 'Português';
                else if (code == 'fr') selectedLanguage = 'Français';
                else if (code == 'de') selectedLanguage = 'Deutsch';
                else if (code == 'ru') selectedLanguage = 'Русский';
                else if (code == 'ja') selectedLanguage = '日本語';
                else if (code == 'pa') selectedLanguage = 'ਪੰਜਾਬੀ';
                else if (code == 'gu') selectedLanguage = 'ગુજરાતી';
                else if (code == 'it') selectedLanguage = 'Italiano';
                else if (code == 'ko') selectedLanguage = '한국어';
                else if (code == 'zh') selectedLanguage = '中文';
                else selectedLanguage = 'English'; // Default
              }

              // Set selectedAvatarIndex based on current avatar
              if (selectedProfilePhoto != null) {
                int index = avatarsURLs.indexOf(selectedProfilePhoto!);
                if (index >= 0) {
                  selectedAvatarIndex = index;
                } else {
                  // If avatar not found in list, default to av3 (index 2)
                  selectedAvatarIndex = 2;
                  selectedProfilePhoto = AppImages.av3;
                }
              } else {
                // Fallback to av3 if still null
                selectedProfilePhoto = AppImages.av3;
                selectedAvatarIndex = 2;
              }

              profileLoaded = true;
            });
          }
        }
      });
    }
    return BackgroundScaffold(
      child: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 2,
        onPageChanged: (index) {
          setState(() => _currentPage = index);
          if (index == 1) {
            _controller.forward(from: 0);
            if (_videoController != null &&
                _videoController!.value.isInitialized) {
              _videoController!.seekTo(Duration.zero);
              _videoController!.play();
            }
          }
        },
        itemBuilder: (context, index) {
          if (index == 0) return _buildFirstPage();
          return _buildSecondPage();
        },
      ),
    );
  }

  Widget _buildFirstPage() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    double contentWidth = isTablet ? 600 : screenWidth;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 10.h),
        child: Center(
          child: SizedBox(
            width: contentWidth,
            child: Column(
              children: [
                // Dynamic spacer at top
                const Spacer(flex: 1),
                
                // Main content - Flexible to adapt to screen size
                Flexible(
                  flex: 8,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Avatar Section - Swipe-based carousel
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: GestureDetector(
                                onHorizontalDragUpdate: (details) {
                                  if (!_isSwiping) {
                                    setState(() {
                                      _swipeOffset += details.delta.dx;
                                    });
                                  }
                                },
                                onHorizontalDragEnd: (details) {
                                  if (_isSwiping) return;
                                  
                                  // Determine swipe direction based on velocity and distance
                                  final velocity = details.velocity.pixelsPerSecond.dx;
                                  final dragDistance = _swipeOffset;
                                  
                                  // Threshold for swipe detection
                                  const swipeThreshold = 50.0;
                                  const velocityThreshold = 300.0;
                                  
                                  if (velocity.abs() > velocityThreshold || dragDistance.abs() > swipeThreshold) {
                                    if (velocity > 0 || dragDistance > 0) {
                                      // Swipe right - previous avatar
                                      _onAvatarSwipeRight();
                                    } else {
                                      // Swipe left - next avatar
                                      _onAvatarSwipeLeft();
                                    }
                                  } else {
                                    // Reset if swipe wasn't strong enough
                                    setState(() {
                                      _swipeOffset = 0.0;
                                    });
                                  }
                                },
                                child: AnimatedBuilder(
                                  animation: _avatarSwipeController,
                                  builder: (context, child) {
                                    // Determine swipe direction
                                    bool isMovingNext = false;
                                    if (_isSwiping) {
                                      if (selectedAvatarIndex > _previousAvatarIndex) {
                                        isMovingNext = true;
                                      } else if (selectedAvatarIndex == 0 && _previousAvatarIndex == avatarsURLs.length - 1) {
                                        isMovingNext = true; // Wrapped from last to first
                                      }
                                    }
                                    
                                    // Calculate slide offset during animation
                                    double slideOffset = 0.0;
                                    if (_isSwiping) {
                                      slideOffset = isMovingNext 
                                        ? -_avatarSwipeController.value * contentWidth * 0.4
                                        : _avatarSwipeController.value * contentWidth * 0.4;
                                    } else {
                                      // Use manual swipe offset when dragging
                                      slideOffset = _swipeOffset * 0.3;
                                    }
                                    
                                    return Stack(
                                      alignment: Alignment.center,
                                      clipBehavior: Clip.none,
                                      children: [
                                        // Previous avatar (slides out)
                                        if (_isSwiping)
                                          Transform.translate(
                                            offset: Offset(
                                              isMovingNext 
                                                ? -contentWidth * 0.4 * (1 - _avatarSwipeController.value)
                                                : contentWidth * 0.4 * (1 - _avatarSwipeController.value),
                                              0,
                                            ),
                                            child: Opacity(
                                              opacity: 1.0 - _avatarSwipeController.value,
                                              child: _buildAvatarCircle(
                                                avatarsURLs[_previousAvatarIndex],
                                                isTablet,
                                                contentWidth,
                                              ),
                                            ),
                                          ),
                                        
                                        // Current avatar (slides in from opposite side)
                                        Transform.translate(
                                          offset: Offset(slideOffset, 0),
                                          child: Opacity(
                                            opacity: _isSwiping 
                                              ? _avatarSwipeController.value 
                                              : 1.0,
                                            child: _buildAvatarCircle(
                                              avatarsURLs[selectedAvatarIndex],
                                              isTablet,
                                              contentWidth,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          
                          SizedBox(height: isTablet ? 30.h : 20.h),
                          
                          // Form Fields Section
                          SizedBox(
                            width: isTablet ? contentWidth * 0.5 : 0.6.sw,
                            child: TextformFieldWidget(
                              readOnly: false,
                              controller: _usernameController,
                              focusNode: _usernameFocusNode,
                              height: isTablet ? 55.h : 48.h,
                              rouneded: 15.r,
                              fontSize: isTablet ? 20.sp : 18.sp,
                              hintTextColor:
                                  const Color.fromRGBO(255, 255, 255, 0.52),
                              hintText: AppLocalizations.enterUsername,
                              prefixIcon: Padding(
                                padding: EdgeInsets.all(10.w),
                                child: CustomSvgImage(
                                  imageUrl: AppImages.userSvg,
                                  height: isTablet ? 24.h : 21.h,
                                  width: isTablet ? 24.w : 21.w,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: isTablet ? 20.h : 15.h),
                          SizedBox(
                            width: isTablet ? contentWidth * 0.5 : 0.6.sw,
                            child: _buildGradientDropdown(
                              hint: AppLocalizations.language,
                              value: selectedLanguage,
                              items: languages,
                              prefixIcon: Padding(
                                padding: EdgeInsets.all(12.w),
                                child: CustomSvgImage(
                                  imageUrl: AppImages.languageSvg,
                                  height: isTablet ? 24.h : 21.h,
                                  width: isTablet ? 24.w : 21.w,
                                ),
                              ),
                              onChanged: (val) => _changeLanguage(val),
                            ),
                          ),
                          SizedBox(height: isTablet ? 20.h : 15.h),
                          SizedBox(
                            width: isTablet ? contentWidth * 0.5 : 0.6.sw,
                            child: CountryPickerWidget(
                              selectedCountryCode: selectedCountry,
                              onCountrySelected: (countryCode) {
                                setState(() => selectedCountry = countryCode);
                                // Trigger rebuild to update button state
                                if (mounted) setState(() {});
                              },
                              hintText: AppLocalizations.country,
                              imageUrl: AppImages.coutrySvg,
                              isTablet: isTablet,
                              useGradientDesign: true, // Use gradient design to match _buildGradientDropdown
                            ),
                          ),
                          SizedBox(height: isTablet ? 30.h : 25.h),
                          InkWell(
                            onTap: (_isSubmitting || !_areAllFieldsFilled())
                                ? null
                                : _handleGuestSignup,
                            child: Opacity(
                              opacity: (_isSubmitting || !_areAllFieldsFilled())
                                  ? 0.5
                                  : 1.0,
                              child: Row(
                                children: [
                                  const Spacer(),
                                  _isSubmitting
                                      ? SizedBox(
                                          width: isTablet ? 20.sp : 18.sp,
                                          height: isTablet ? 20.sp : 18.sp,
                                          child: const CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Flexible( // Add Flexible
                                          child: FittedBox( // Add FittedBox
                                            fit: BoxFit.scaleDown,
                                            child: TextWidget(
                                              text: AppLocalizations.next,
                                              fontSize: isTablet ? 20.sp : 18.sp,
                                              color: AppColors.whiteColor,
                                            ),
                                          ),
                                        ),
                                  Icon(Icons.navigate_next_outlined,
                                      color: AppColors.whiteColor,
                                      size: isTablet ? 26.sp : 22.sp),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Dynamic spacer at bottom
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarCircle(String avatarPath, bool isTablet, double contentWidth) {
    return Container(
      height: isTablet ? 180.h : 150.h,
      width: isTablet ? 180.w : 150.w,
      padding: EdgeInsets.all(2.w),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Color(0xFF09BDFF),
            Color(0xFF6FE4FF),
            Color(0xFFFFFFFF),
          ],
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black,
        ),
        child: ClipOval(
          child: SizedBox(
            width: isTablet ? 170.r : 140.r,
            height: isTablet ? 170.r : 140.r,
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 30.0 : 24.0),
              child: Image.asset(
                avatarPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to av3.png if image fails to load
                  return Image.asset(
                    AppImages.av3,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Check if all required fields are filled
  bool _areAllFieldsFilled() {
    final nameInput = _usernameController.text.trim();
    return nameInput.isNotEmpty &&
        selectedLanguage != null &&
        selectedCountry != null &&
        selectedProfilePhoto != null;
  }

  Future<void> _handleGuestSignup() async {
    // Validate all fields are filled
    if (!_areAllFieldsFilled()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.pleaseFillAllFields),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final nameInput = _usernameController.text.trim();
    final username = nameInput;

    setState(() => _isSubmitting = true);

    try {
      // Save language to shared preferences if changed
      String languageCode = 'en';
      if (selectedLanguage != null) {
        if (selectedLanguage == 'हिंदी') {
          languageCode = 'hi';
        } else if (selectedLanguage == 'తెలుగు') {
          languageCode = 'te';
        } else if (selectedLanguage == 'தமிழ்') {
          languageCode = 'ta';
        } else if (selectedLanguage == 'मराठी') {
          languageCode = 'mr';
        } else if (selectedLanguage == 'ಕನ್ನಡ') {
          languageCode = 'kn';
        } else if (selectedLanguage == 'മലയാളം') {
          languageCode = 'ml';
        } else if (selectedLanguage == 'বাংলা') {
          languageCode = 'bn';
        } else if (selectedLanguage == 'العربية') {
          languageCode = 'ar';
        } else if (selectedLanguage == 'Español') {
          languageCode = 'es';
        } else if (selectedLanguage == 'Português') {
          languageCode = 'pt';
        } else if (selectedLanguage == 'Français') {
          languageCode = 'fr';
        } else if (selectedLanguage == 'Deutsch') {
          languageCode = 'de';
        } else if (selectedLanguage == 'Русский') {
          languageCode = 'ru';
        } else if (selectedLanguage == '日本語') {
          languageCode = 'ja';
        } else if (selectedLanguage == 'ਪੰਜਾਬੀ') {
          languageCode = 'pa';
        } else if (selectedLanguage == 'ગુજરાતી') {
          languageCode = 'gu';
        } else if (selectedLanguage == 'Italiano') {
          languageCode = 'it';
        } else if (selectedLanguage == '한국어') {
          languageCode = 'ko';
        } else if (selectedLanguage == '中文') {
          languageCode = 'zh';
        }
          await LocalStorageUtils.saveLanguage(languageCode);
          AppLocalizations.setLanguage(languageCode);
      }

      final result = await _userRepository.updateProfile(
        name: username,
        avatar: selectedProfilePhoto,
        language: languageCode,
        country: selectedCountry,
      );

      result.fold(
        (failure) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message)),
          );
        },
        (authResponse) {
          if (!mounted) return;
          // Pop with a flag to trigger rebuild
          context.pushReplacement(Routes.homeScreen);
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildGradientDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required Widget prefixIcon,
    required ValueChanged<String?> onChanged,
  }) {
    final GlobalKey tapKey = GlobalKey();
    return Builder(
      builder: (context) {
        return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.r),
            gradient: const LinearGradient(
              colors: [
                Color.fromRGBO(255, 255, 255, 1),
                Color.fromRGBO(9, 189, 255, 1)
              ],
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: tapKey,
              borderRadius: BorderRadius.circular(13.r),
              onTap: () async {
                final box =
                    tapKey.currentContext!.findRenderObject() as RenderBox;
                final Offset pos = box.localToGlobal(Offset.zero);
                final Size size = box.size;
                const double gap = -2.0;
                final selected = await showMenu<String>(
                  context: context,
                  position: RelativeRect.fromLTRB(
                      pos.dx,
                      pos.dy + size.height + gap,
                      pos.dx + size.width,
                      pos.dy + size.height + gap),
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
                              Color.fromRGBO(9, 189, 255, 1)
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
                                              color: Color.fromRGBO(
                                                  255, 255, 255, 0.2),
                                              width: 3))
                                      : null,
                                ),
                                child: InkWell(
                                  onTap: () => Navigator.pop(context, e),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 12.h,
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          e,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18.sp,
                                          ),
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
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13.r),
                  color: Colors.black,
                ),
                child: Row(
                  children: [
                    prefixIcon,
                    SizedBox(width: 8.w),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          value ?? hint,
                          style: TextStyle(
                            color: value == null
                                ? const Color.fromRGBO(255, 255, 255, 0.52)
                                : Colors.white,
                            fontSize: 18.sp,
                          ),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 35.sp,
                      color: const Color.fromRGBO(9, 189, 255, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSecondPage() {
    const int coinReward = 1000;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Full screen video
        Center(
          child:
              _videoController != null && _videoController!.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    )
                  : const CircularProgressIndicator(
                      color: Colors.white,
                    ),
        ),
        // Overlay content
        Positioned.fill(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Column(
                children: [
                  const CoinContainer(coins: coinReward),
                  const Spacer(),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final count = (coinReward * _controller.value)
                          .round()
                          .clamp(0, coinReward);
                      return TextWidget(
                        text: "+ $count Coins",
                        fontSize: 25.sp,
                        color: AppColors.whiteColor,
                        fontWeight: FontWeight.bold,
                      );
                    },
                  ),
                  const Spacer(),
                  // Skip button at bottom
                  TextButton(
                    onPressed: () => context.go(Routes.homeScreen),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("${AppLocalizations.skip} ",
                            style: TextStyle(
                                color: Colors.white70, fontSize: 14.sp)),
                        Icon(Icons.arrow_forward_ios,
                            size: 16. sp, color: Colors.white70),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
