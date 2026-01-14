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

  void _showRoomCodeDialog(String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: TextWidget(
          text: AppLocalizations.roomCreated,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.whiteColor,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextWidget(
              text: AppLocalizations.shareCodeWithFriends,
              fontSize: 14.sp,
              color: Colors.grey,
            ),
            SizedBox(height: 15.h),
            Container(
              padding: EdgeInsets.all(15.w),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextWidget(
                    text: code,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.whiteColor,
                  ),
                  SizedBox(width: 10.w),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.blue),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.codeCopiedClipboard),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Pass the actual room ID from the response
              final roomId = _lastCreatedRoomId;
              if (roomId != null) {
                context.go('/game-room/$roomId');
              }
            },
            child: TextWidget(
              text: AppLocalizations.enterRoom,
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
    final double controlWidth = mq.size.width - (isTablet ? 40.w : 24.w);

    return BlueBackgroundScaffold(
      child: SafeArea(
        bottom: true, // Protect bottom for ad visibility
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width > 600
                ? 600
                : MediaQuery.of(context).size.width,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
              child: Column(
                children: [
                  // Header
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
                        text: widget.isTeamMode
                            ? AppLocalizations.createTeamRoom
                            : AppLocalizations.createRoom,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.whiteColor,
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Form - Simplified to just room name (Flexible content)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(flex: 1),
                          
                          // Info text
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: TextWidget(
                              text: AppLocalizations.createRoomConfigureLobby,
                              fontSize: 14.sp,
                              color: Colors.white70,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 30.h),

                          // Room Name
                          TextformFieldWidget(
                            controller: _roomNameController,
                            height: 50.h,
                            rouneded: 25.r,
                            fontSize: 16.sp,
                            hintText: AppLocalizations.enterRoomNameHint,
                            hintTextColor:
                                const Color.fromRGBO(255, 255, 255, 0.52),
                          ),
                          SizedBox(height: 40.h),

                          // Create button
                          _buildCreateButton(),

                          SizedBox(height: 20.h),

                          // Additional info
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: TextWidget(
                              text: AppLocalizations.roomCodeShareInfo,
                              fontSize: 12.sp,
                              color: Colors.grey,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          
                          const Spacer(flex: 1),
                          SizedBox(height: 10.h), // Space above ad
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
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
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
        onPressed: _isLoading ? null : _handleCreateRoom,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : TextWidget(
                text: AppLocalizations.createRoom,
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
                  color: isFilled ? null : Colors.grey,
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
