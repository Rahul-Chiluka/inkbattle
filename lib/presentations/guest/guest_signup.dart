import 'dart:math';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inkbattle_frontend/constants/app_colors.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';
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
import 'package:inkbattle_frontend/utils/preferences/local_preferences.dart';
import 'package:inkbattle_frontend/widgets/country_picker_widget.dart';

class GuestSignUpScreen extends StatefulWidget {
  const GuestSignUpScreen({super.key});

  @override
  State<GuestSignUpScreen> createState() => _GuestSignUpScreenState();
}

class _GuestSignUpScreenState extends State<GuestSignUpScreen>
    with TickerProviderStateMixin {
  final String _logTag = 'GuestSignUpScreen';
  final UserRepository _userRepository = UserRepository();
  late final TextEditingController _usernameController;
  final FocusNode _usernameFocusNode = FocusNode();
  String? selectedLanguage;
  String? selectedCountry;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int selectedAvatarIndex = 2;
  String? selectedProfilePhoto = AppImages.av3;
  bool showAvatarSelection = false;
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

  // Avatar animation variables
  int? _movingAvatarIndex;
  final GlobalKey _centerAvatarKey = GlobalKey();

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

  void _selectAvatar(int index) {
    if (_movingAvatarIndex != null) return; // Prevent multiple animations

    setState(() {
      _movingAvatarIndex = index;
      selectedAvatarIndex = index;
    });

    // Reset the controller before starting animation
    _avatarMoveController.reset();

    // Start the move animation
    _avatarMoveController.forward().then((_) {
      // Update the profile photo after animation completes
      setState(() {
        if (index <= avatarsURLs.length - 1) {
          selectedProfilePhoto = avatarsURLs[index];
        } else {
          selectedProfilePhoto = null;
        }
        _movingAvatarIndex = null;
        // showAvatarSelection = false;  // COMMENT THIS LINE TO KEEP SELECTION OPEN
      });
      // Trigger rebuild to update button state
      if (mounted) setState(() {});
    });
  }

  void _toggleAvatarSelection() {
    setState(() {
      showAvatarSelection = !showAvatarSelection;
    });
  }

  void _loadLanguage() {
    final savedLanguage = LocalStorageUtils.getLanguage();
    // Don't call setLanguage here - it's already set in main.dart
    // Just map the language code to display name for the dropdown

    // Map language codes to display names
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
    // Trigger rebuild to update button state
    if (mounted) setState(() {});

    // Map display name to language code
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
    // Add listener to update button state when username changes
    _usernameController.addListener(() {
      if (mounted) setState(() {});
    });

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

    // Avatar move animation controller
    _avatarMoveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
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
    _avatarMoveController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
    double size = isTablet ? contentWidth * 0.12 : contentWidth * 0.15;
    List<Widget> avatars = List.generate(5, (index) {
      return Container();
    });
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 10.h),
        child: Center(
          child: SizedBox(
            width: contentWidth,
            child: Column(
              children: [
                // Coin Container at top
                const CoinContainer(coins: 0),
                
                // Dynamic spacer
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
                          // Avatar Section - Flexible with FittedBox for small screens
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Main Profile Avatar
                                  Container(
                                    key: _centerAvatarKey,
                                    child: GestureDetector(
                                      onTap: _toggleAvatarSelection,
                                      child: Container(
                                        clipBehavior: Clip.hardEdge,
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
                                            clipBehavior: Clip.hardEdge,
                                            child: SizedBox(
                                              width: isTablet ? 170.r : 140.r,
                                              height: isTablet ? 170.r : 140.r,
                                              child: selectedProfilePhoto != null
                                                  ? Padding(
                                                      padding: EdgeInsets.all(
                                                          isTablet ? 30.0 : 20.0),
                                                      child: Image.asset(
                                                        selectedProfilePhoto!,
                                                        fit: BoxFit.contain,
                                                      ),
                                                    )
                                                  : Center(
                                                      child: Icon(Icons.person,
                                                          size:
                                                              isTablet ? 60.sp : 50.sp,
                                                          color: Colors.grey),
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  if (!showAvatarSelection)
                                    Positioned(
                                      bottom: isTablet ? 25.h : 20.h,
                                      right: 0.w,
                                      child: GestureDetector(
                                        onTap: _toggleAvatarSelection,
                                        child: Container(
                                          height: isTablet ? 50.h : 40.h,
                                          width: isTablet ? 50.w : 40.w,
                                          decoration: const BoxDecoration(
                                            color: Color.fromRGBO(217, 217, 217, 1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Image.asset(
                                            AppImages.pencil,
                                            height: isTablet ? 35.h : 30.h,
                                            width: isTablet ? 35.w : 30.w,
                                          ),
                                        ),
                                      ),
                                    ),

                                  // Avatar Selection Options
                                  if (showAvatarSelection)
                                    _buildAvatarSelectionStack(
                                        avatars, size, contentWidth, isTablet),

                                  // Moving Avatar Animation
                                  if (_movingAvatarIndex != null)
                                    _buildMovingAvatar(
                                        _movingAvatarIndex!, contentWidth, isTablet),
                                ],
                              ),
                            ),
                          ),
                          
                          SizedBox(height: isTablet ? 30.h : 20.h),
                          
                          // Form Fields Section
                          SizedBox(
                            width:
                                isTablet ? contentWidth * 0.5 : contentWidth * 0.6,
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
                                      : Flexible(
                                          child: FittedBox(
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

  Widget _buildAvatarSelectionStack(
      List<Widget> avatars, double size, double contentWidth, bool isTablet) {
    double centerX = contentWidth * 0.5;
    double centerY = isTablet ? 0.12.sh : 0.17.sh;

    // 4 bubble positions - adjusted for tablet view
    final bubblePositions = isTablet
        ? [
            {'x': centerX - contentWidth * 0.28, 'y': centerY}, // Top left
            {
              'x': centerX - contentWidth * 0.35,
              'y': centerY + 40.h
            }, // Bottom left
            {
              'x': centerX + contentWidth * 0.18,
              'y': centerY + 5.h
            }, // Top right
            {
              'x': centerX + contentWidth * 0.30,
              'y': centerY + 45.h
            }, // Bottom right
          ]
        : [
            {'x': centerX - contentWidth * 0.35, 'y': centerY}, // Top left
            {
              'x': centerX - contentWidth * 0.44,
              'y': centerY + 31.h
            }, // Bottom left
            {
              'x': centerX + contentWidth * 0.22,
              'y': centerY + 2.h
            }, // Top right
            {
              'x': centerX + contentWidth * 0.38,
              'y': centerY + 32.h
            }, // Bottom right
          ];

    return SizedBox(
      height: 0.3.sh,
      width: double.infinity,
      child: Stack(
        children: List.generate(5, (index) {
          // Don't show the moving avatar in the selection stack
          if (index == _movingAvatarIndex) return const SizedBox.shrink();
          // Don't show the selected avatar in the surrounding positions
          if (index == selectedAvatarIndex && _movingAvatarIndex == null) {
            return const SizedBox.shrink();
          }

          // Map avatar index to bubble position (skip center avatar index 2)
          int bubbleIndex = index;
          if (index > selectedAvatarIndex) {
            bubbleIndex = index - 1;
          }
          // Safety clamp to prevent out of range
          bubbleIndex = bubbleIndex.clamp(0, bubblePositions.length - 1);

          double x = bubblePositions[bubbleIndex]['x']!;
          double y = bubblePositions[bubbleIndex]['y']!;

          double bubbleSize = (bubbleIndex % 2 == 0) ? size : size / 2;

          return Positioned(
            left: x,
            top: y,
            child: GestureDetector(
              onTap: () => _selectAvatar(index),
              child: Container(
                width: bubbleSize,
                height: bubbleSize,
                padding: EdgeInsets.all(1.w),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [
                    Color(0xFF09BDFF),
                    Color(0xFF09BDFF),
                    Color(0xFF4A4A4A)
                  ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                  child: ClipOval(
                    child: SizedBox(
                      width: bubbleSize - 4.w,
                      height: bubbleSize - 4.w,
                      child: Image.asset(
                        avatarsURLs[index],
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMovingAvatar(int index, double contentWidth, bool isTablet) {
    double centerX = contentWidth * 0.5;
    double centerY = isTablet ? 0.12.sh : 0.17.sh;
    double size = isTablet ? contentWidth * 0.12 : contentWidth * 0.15;

    // 4 bubble positions - adjusted for tablet view
    final bubblePositions = isTablet
        ? [
            {'x': centerX - contentWidth * 0.30, 'y': centerY}, // Top left
            {
              'x': centerX - contentWidth * 0.37,
              'y': centerY + 40.h
            }, // Bottom left
            {
              'x': centerX + contentWidth * 0.20,
              'y': centerY + 5.h
            }, // Top right
            {
              'x': centerX + contentWidth * 0.32,
              'y': centerY + 45.h
            }, // Bottom right
          ]
        : [
            {'x': centerX - contentWidth * 0.37, 'y': centerY}, // Top left
            {
              'x': centerX - contentWidth * 0.44,
              'y': centerY + 31.h
            }, // Bottom left
            {
              'x': centerX + contentWidth * 0.22,
              'y': centerY + 2.h
            }, // Top right
            {
              'x': centerX + contentWidth * 0.36,
              'y': centerY + 32.h
            }, // Bottom right
          ];

    // Map avatar index to bubble position (skip center avatar index 2)
    int bubbleIndex = index;
    if (index > selectedAvatarIndex) {
      bubbleIndex = index - 1;
    }
    // Safety clamp to prevent out of range
    bubbleIndex = bubbleIndex.clamp(0, bubblePositions.length - 1);

    double startX = bubblePositions[bubbleIndex]['x']!;
    double startY = bubblePositions[bubbleIndex]['y']!;

    // Calculate center position (where the main avatar is)
    double endX = contentWidth * 0.5 -
        (isTablet ? 50.w : 40.w); // Center minus half width
    double endY = (isTablet ? 0.12.sh : 0.17.sh) -
        (isTablet ? 50.h : 40.h); // Center minus half height

    return AnimatedBuilder(
      animation: _avatarMoveController,
      builder: (context, child) {
        double animatedX =
            startX + (endX - startX) * _avatarMoveController.value;
        double animatedY =
            startY + (endY - startY) * _avatarMoveController.value;

        // Scale down as it moves to center
        double scale = 1.0 - (0.7 * _avatarMoveController.value);

        double bubbleSize = (bubbleIndex % 2 == 0) ? size : size / 2;

        return Positioned(
          left: animatedX,
          top: animatedY,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: bubbleSize,
              height: bubbleSize,
              padding: EdgeInsets.all(1.w),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [
                  Color(0xFF09BDFF),
                  Color(0xFF09BDFF),
                  Color(0xFF4A4A4A)
                ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                ),
                child: ClipOval(
                  child: SizedBox(
                    width: bubbleSize - 4.w,
                    height: bubbleSize - 4.w,
                    child: Image.asset(
                      avatarsURLs[index],
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
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

    // Dismiss Keyboard immediately to prevent layout resize glitch
    FocusManager.instance.primaryFocus?.unfocus();

    final nameInput = _usernameController.text.trim();
    final username = nameInput;

    setState(() => _isSubmitting = true);

    try {
      String languageCode = 'en';

      if (selectedLanguage != null) {
        // Map Native -> Code
        if (selectedLanguage == 'हिंदी') languageCode = 'hi';
        else if (selectedLanguage == 'తెలుగు') languageCode = 'te';
        else if (selectedLanguage == 'தமிழ்') languageCode = 'ta';
        else if (selectedLanguage == 'मराठी') languageCode = 'mr';
        else if (selectedLanguage == 'ಕನ್ನಡ') languageCode = 'kn';
        else if (selectedLanguage == 'മലയാളം') languageCode = 'ml';
        else if (selectedLanguage == 'বাংলা') languageCode = 'bn';
        else if (selectedLanguage == 'العربية') languageCode = 'ar';
        else if (selectedLanguage == 'Español') languageCode = 'es';
        else if (selectedLanguage == 'Português') languageCode = 'pt';
        else if (selectedLanguage == 'Français') languageCode = 'fr';
        else if (selectedLanguage == 'Deutsch') languageCode = 'de';
        else if (selectedLanguage == 'Русский') languageCode = 'ru';
        else if (selectedLanguage == '日本語') languageCode = 'ja';
        else if (selectedLanguage == 'ਪੰਜਾਬੀ') languageCode = 'pa';
        else if (selectedLanguage == 'ગુજરાતી') languageCode = 'gu';
        else if (selectedLanguage == 'Italiano') languageCode = 'it';
        else if (selectedLanguage == '한국어') languageCode = 'ko';
        else if (selectedLanguage == '中文') languageCode = 'zh';

        // Save locally for immediate UI update
        await LocalStorageUtils.saveLanguage(languageCode);
        AppLocalizations.setLanguage(languageCode);
      }

      final result = await _userRepository.guestSignup(
        name: username,
        avatar: selectedProfilePhoto,
        language: languageCode,
        country: selectedCountry,
      );

      result.fold(
        (failure) {
          if (!mounted) return;
          developer.log('Guest signup failed: ${failure.message}', name: _logTag);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message)),
          );
        },
        (authResponse) {
          if (!mounted) return;
          _pageController.nextPage(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        },
      );
    } catch (e) {
      if (mounted) {
        developer.log('Guest signup error: $e', name: _logTag);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.error}: $e')),
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

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-screen video without cutting
          Center(
            child: _videoController != null &&
                    _videoController!.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.contain, // Ensures entire video is visible
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: _videoController!.value.size.width,
                      height: _videoController!.value.size.height,
                      child: VideoPlayer(_videoController!),
                    ),
                  )
                : const CircularProgressIndicator(color: Colors.white),
          ),

          // Overlay content
          SafeArea(
            child: Column(
              children: [
                // Top coin container
                const CoinContainer(coins: coinReward),

                const Spacer(),

                // Animated coins count
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final count = (coinReward * _controller.value)
                        .round()
                        .clamp(0, coinReward);
                    return TextWidget(
                      text: "+ $count Coins",
                      fontSize: 28.sp,
                      color: AppColors.whiteColor,
                      fontWeight: FontWeight.bold,
                    );
                  },
                ),

                const Spacer(),

                // Skip button at bottom
                Padding(
                  padding: EdgeInsets.only(bottom: 20.h),
                  child: TextButton(
                    onPressed: () => context.go(Routes.homeScreen),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Skip ",
                          style:
                              TextStyle(color: Colors.white70, fontSize: 16.sp),
                        ),
                        Icon(Icons.arrow_forward_ios,
                            size: 18.sp, color: Colors.white70),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
