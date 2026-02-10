import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:inkbattle_frontend/widgets/textformfield_widget.dart';
import 'package:inkbattle_frontend/widgets/persistent_banner_ad_widget.dart';

class CreateRoomScreen extends StatefulWidget {
  final bool isTeamMode;

  const CreateRoomScreen({super.key, this.isTeamMode = false});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final RoomRepository _roomRepository = RoomRepository();
  final UserRepository _userRepository = UserRepository();
  final ThemeRepository _themeRepository = ThemeRepository();
  final TextEditingController _roomNameController = TextEditingController();

  String? selectedLanguage;
  String? selectedScript;
  String? selectedCountry;
  String? selectedPoints;
  String? selectedCategory;
  String? selectedMaxPlayers;
  String? selectedTeam; // For team mode
  bool voiceEnabled = true;
  bool isPublic = true;
  bool _isLoading = false;
  int? _lastCreatedRoomId;
  
  // REMOVED: BannerAd? _bannerAd;
  // REMOVED: bool _isBannerAdLoaded = false;

  List<String> languages = [];
  final List<String> scripts = ["Latin", "Devanagari", "Telugu"];
  // Countries are now handled via CountryPickerWidget with ISO-2 codes
  final List<String> points = ["50", "100", "150", "200"];
  List<String> categories = [];
  final List<String> maxPlayersOptions = ["5", "10", "15"];
  final List<String> teamMaxPlayers = [
    "8",
    "10",
    "14"
  ]; // For team mode (4v4, 5v5, 7v7)
  final List<String> teams = ["Team A", "Team B"];

  @override
  void initState() {
    super.initState();
    _loadLanguagesAndCategories();
    // REMOVED: _loadBannerAd(); - Now handled by persistent widget
  }

  @override
  void dispose() {
    _roomNameController.dispose();
    // REMOVED: _bannerAd?.dispose(); - Now handled by persistent widget
    super.dispose();
  }

  // REMOVED: _loadBannerAd() function completely

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

  Future<void> _handleCreateRoom() async {
    // Validate room name
    if (_roomNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.pleaseEnterRoomName),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create room with just name (settings will be in lobby)
      final result = await _roomRepository.createRoom(
        name: _roomNameController.text.trim(),
      );

      result.fold(
        (failure) {
          if (mounted) {
            // Check for authentication errors
            final errorMessage = failure.message.toLowerCase();
            if (errorMessage.contains('authentication') || 
                errorMessage.contains('unauthorized') ||
                errorMessage.contains('401') ||
                errorMessage.contains('missing_token')) {
              // Show authentication error and offer to sign in again
              _showAuthErrorDialog();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${AppLocalizations.failedToCreateRoom}: ${failure.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        (roomResponse) async {
          if (mounted) {
            // Store room ID
            _lastCreatedRoomId = roomResponse.room?.id;
            
            // Navigate directly to lobby
            context.go('/game-room/${roomResponse.room?.id}');
          }
        },
      );
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().toLowerCase();
        if (errorMessage.contains('authentication') || 
            errorMessage.contains('unauthorized') ||
            errorMessage.contains('missing_token')) {
          _showAuthErrorDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppLocalizations.error}: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _showAuthErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: TextWidget(
          text: AppLocalizations.error,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.whiteColor,
        ),
        content: TextWidget(
          text: 'Your session has expired. Please sign in again.',
          fontSize: 14.sp,
          color: Colors.white70,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate back to sign in screen
              context.go('/');
            },
            child: TextWidget(
              text: 'Sign In',
              fontSize: 16.sp,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final bool isTablet = mq.size.width > 600;

    return BlueBackgroundScaffold(
      child: SafeArea(
        bottom: true, // Protect bottom for ad visibility
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isTablet ? 18.w : 15.w, vertical: 15.h),
                    child: Column(
                      children: [
                        // Header (Stack for centering)
                        SizedBox(
                          height: 50.h,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Back Button (Aligned Left)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    color: Colors.transparent, // Hit test area
                                    padding: EdgeInsets.all(8.w),
                                    child: CustomSvgImage(
                                      imageUrl: AppImages.arrow_back,
                                      height: isTablet ? 30.h : 24.h,
                                      width: isTablet ? 30.w : 24.w,
                                    ),
                                  ),
                                ),
                              ),
                              // Title (Centered)
                              Align(
                                alignment: Alignment.center,
                                child: TextWidget(
                                  text: widget.isTeamMode
                                      ? AppLocalizations.createTeamRoom
                                      : AppLocalizations.createRoom,
                                  fontSize: isTablet ? 25.sp : 24.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.whiteColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Main Content (Centered Vertically)
                        Expanded(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: isTablet ? 500 : double.infinity),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Info text
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                                    child: TextWidget(
                                      text: AppLocalizations.createRoomConfigureLobby,
                                      fontSize: isTablet ? 18.sp : 16.sp,
                                      color: Colors.white70,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(height: 40.h),
                
                                  // Room Name Input
                                  TextformFieldWidget(
                                    controller: _roomNameController,
                                    height: isTablet ? 60.h : 55.h,
                                    rouneded: 30.r,
                                    fontSize: isTablet ? 18.sp : 16.sp,
                                    hintText: AppLocalizations.enterRoomNameHint,
                                    hintTextColor: const Color.fromRGBO(255, 255, 255, 0.52),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 15.h), // Better padding
                                  ),
                                  SizedBox(height: 40.h),
                
                                  // Create button
                                  _buildCreateButton(isTablet),
                
                                  SizedBox(height: 30.h),
                
                                  // Additional info
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                                    child: TextWidget(
                                      text: AppLocalizations.roomCodeShareInfo,
                                      fontSize: isTablet ? 14.sp : 12.sp,
                                      color: Colors.grey,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 20.h), // Space before ad
                        
                        // Persistent Banner Ad (app-wide, loaded once)
                        const PersistentBannerAdWidget(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCreateButton(bool isTablet) {
    return Container(
      width: double.infinity,
      height: isTablet ? 60.h : 55.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromRGBO(83, 128, 246, 1),
            Color.fromRGBO(79, 62, 207, 1),
          ],
        ),
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(83, 128, 246, 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
        ),
        onPressed: _isLoading ? null : _handleCreateRoom,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : TextWidget(
                text: AppLocalizations.createRoom,
                fontSize: isTablet ? 20.sp : 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.whiteColor,
              ),
      ),
    );
  }


}
