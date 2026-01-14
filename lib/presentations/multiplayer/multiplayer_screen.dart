import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'package:go_router/go_router.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';
import 'package:inkbattle_frontend/widgets/blue_background_scaffold.dart';
import 'package:inkbattle_frontend/repositories/room_repository.dart';
import 'package:inkbattle_frontend/repositories/theme_repository.dart';
import 'package:inkbattle_frontend/repositories/user_repository.dart';
import 'package:inkbattle_frontend/models/room_model.dart';
import 'package:inkbattle_frontend/utils/lang.dart';
import 'package:inkbattle_frontend/widgets/persistent_banner_ad_widget.dart';

class MultiplayerScreen extends StatefulWidget {
  const MultiplayerScreen({super.key});

  @override
  State<MultiplayerScreen> createState() => _MultiplayerScreenState();
}

class _MultiplayerScreenState extends State<MultiplayerScreen> {
  final RoomRepository _roomRepository = RoomRepository();
  final UserRepository _userRepository = UserRepository();
  final ThemeRepository _themeRepository = ThemeRepository();

  String? selectedLanguage;
  String? selectedScript;
  String? selectedCountry;
  String? selectedPoints;
  // String? selectedCategory;
  List<String> selectedCategories = [];
  bool voiceEnabled = false;
  String? selectedGameMode = "team_vs_team";
  bool _isLoading = false;
  
  // REMOVED: Ad variables
  // BannerAd? _bannerAd;
  // bool _isBannerAdLoaded = false;

  List<RoomModel> _rooms = [];

  List<String> languages = [];
  final List<String> scripts = ["default", "english"];
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

  @override
  void initState() {
    super.initState();
    _loadLanguagesAndCategories();
    // Initialize default values to satisfy `allFilled` on load
    selectedScript = scripts.first;
    selectedPoints = points.first;
    // selectedCountry = countries.first; // No default country selection

    _loadRooms();
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
        if (mounted) {
          setState(() {
            languages = ["English", "Hindi", "Marathi", "Telugu"];
            selectedLanguage = languages.first;
          });
        }
      },
      (languagesList) {
        if (languagesList.isEmpty) {
          if (mounted) {
            setState(() {
              languages = ["English", "Hindi", "Marathi", "Telugu"];
              selectedLanguage = languages.first;
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
              // Set default language after loading
              selectedLanguage = languages.isNotEmpty ? languages.first : null;
            });
          }
        }
      },
    );

    // Load categories
    final categoriesResult = await _themeRepository.getCategories();
    categoriesResult.fold(
      (failure) {
        if (mounted) {
          setState(() {
            categories = ["Fruits", "Animals", "Food", "Movies"];
            // selectedCategory = categories.first;
            selectedCategories = categories;
          });
        }
      },
      (categoriesList) {
        if (categoriesList.isEmpty) {
          if (mounted) {
            setState(() {
              categories = ["Fruits", "Animals", "Food", "Movies"];
              // selectedCategory = categories.first;
              selectedCategories = categories;
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
            // Set default category after loading
            // selectedCategory = categories.isNotEmpty ? categories.first : null;
            selectedCategories = categories.isNotEmpty ? categories : [];
          });
        }
      },
    );
  }

  Future<void> _loadRooms() async {
    // Only load if essential filters are set
    if (!allFilled) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final categoriesToSend =
        selectedCategories.isEmpty ? null : selectedCategories;
      final result = await _roomRepository.listRooms(
          language: selectedLanguage,
          gameMode: selectedGameMode,
          country: selectedCountry == "All" ? null : selectedCountry,
          categories: categoriesToSend,
          script: selectedScript,
          targetPoints: int.tryParse(selectedPoints.toString()) ?? 250,
          voiceEnabled: voiceEnabled);

      result.fold(
        (failure) {
          print('Failed to load rooms: ${failure.message}');
        },
        (roomListResponse) {
          if (mounted) {
            setState(() {
              final rooms = roomListResponse.rooms ?? [];
              // Sort rooms by fill percentage (most filled first)
              // Fill percentage = participantCount / maxPlayers
              _rooms = rooms
                ..sort((a, b) {
                  final fillA = (a.participantCount ?? 0) / (a.maxPlayers ?? 1);
                  final fillB = (b.participantCount ?? 0) / (b.maxPlayers ?? 1);
                  // Sort in descending order (highest fill percentage first)
                  return fillB.compareTo(fillA);
                });
            });
          }
        },
      );
    } catch (e) {
      print('Error loading rooms: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _joinRoom(RoomModel room) async {
    final result = await _roomRepository.getRoomDetails(roomId: room.id.toString());
    final updatedRoom = result.fold(
      (failure) => room,
      (roomModel) => roomModel,
    );
    room.gameMode == 'team' || room.gameMode == 'team_vs_team'
        ? context.push(
            "/teamvsteam/${room.id}/${room.category}/${room.entryPoints}",
            extra: {
                "roomModel": updatedRoom,
                // Removed passing bannerAd as it is now persistent
              })
        : context.push(
            "/onevsone/${room.id}/${room.category}/${room.entryPoints}",
            extra: {
                "roomModel": room,
                // Removed passing bannerAd as it is now persistent
              });
  }

  Future<String?> _showTeamSelectionDialog() async {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'Select Your Team',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTeamOption('orange', Colors.orange),
            SizedBox(height: 16.h),
            _buildTeamOption('blue', Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamOption(String team, Color color) {
    return InkWell(
      onTap: () => Navigator.pop(context, team),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'Team ${team[0].toUpperCase()}${team.substring(1)}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // void _showInsufficientCoinsDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       backgroundColor: const Color(0xFF1A1A2E),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(20.r),
  //       ),
  //       title: Text(
  //         AppLocalizations.insufficientCoinsTitle,
  //         style: TextStyle(
  //           fontSize: 18.sp,
  //           fontWeight: FontWeight.bold,
  //           color: Colors.white,
  //         ),
  //       ),
  //       content: Text(
  //         AppLocalizations.insufficientCoinsMessage,
  //         style: TextStyle(
  //           fontSize: 14.sp,
  //           color: Colors.grey,
  //         ),
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
  //         // TextButton(
  //         //   onPressed: () {
  //         //     // Navigator.pop(context);
  //         //     // ScaffoldMessenger.of(context).showSnackBar(
  //         //     //   const SnackBar(content: Text('Buy coins feature coming soon!')),
  //         //     // );
  //         //   },
  //         //   child: Text(
  //         //     AppLocalizations.buyCoins,
  //         //     style: TextStyle(
  //         //       fontSize: 14.sp,
  //         //       color: Colors.green,
  //         //     ),
  //         //   ),
  //         // ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    return BlueBackgroundScaffold(
      child: SafeArea(
        bottom: true, // Protect bottom for ad visibility
        child: Center(
          child: SizedBox(
            width: isTablet ? 600 : MediaQuery.of(context).size.width,
            child: Column(
              children: [
                // Back button
                Padding(
                  padding: EdgeInsets.only(
                      left: isTablet ? 12.w : 8.w,
                      top: isTablet ? 12.h : 8.h,
                      bottom: isTablet ? 20.h : 16.h,
                      right: isTablet ? 12.w : 8.w),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: isTablet ? 28.sp : 24.sp,
                      ),
                    ),
                  ),
                ),

                // Filter Pills - Row 1
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: isTablet ? 20.w : 16.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildFilterPill(
                          image: AppImages.global,
                          icon: Icons.language,
                          value: selectedLanguage,
                          items: languages,
                          onChanged: (val) {
                            setState(() => selectedLanguage = val);
                            print(selectedLanguage);
                            _loadRooms();
                          },
                          hintText: AppLocalizations.language,
                          iconColor: Colors.lightBlueAccent,
                          isTablet: isTablet,
                        ),
                      ),
                      SizedBox(width: isTablet ? 12.w : 8.w),
                      Expanded(
                        child: _buildFilterPill(
                          image: AppImages.language,
                          icon: Icons.image,
                          value: selectedScript,
                          items: scripts,
                          onChanged: (val) {
                            setState(() => selectedScript = val);
                            _loadRooms();
                          },
                          hintText: AppLocalizations.script,
                          iconColor: Colors.deepPurpleAccent,
                          isTablet: isTablet,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: isTablet ? 12.h : 10.h),

                // Filter Pills - Row 2
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: isTablet ? 20.w : 16.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildFilterPill(
                          image: AppImages.country,
                          icon: Icons.public,
                          value: selectedCountry,
                          items: countries,
                          onChanged: (val) {
                            setState(() => selectedCountry = val);
                            _loadRooms();
                          },
                          hintText: AppLocalizations.country,
                          iconColor: Colors.lightGreenAccent,
                          isTablet: isTablet,
                        ),
                      ),
                      SizedBox(width: isTablet ? 12.w : 8.w),
                      Expanded(
                        child: _buildFilterPill(
                          image: AppImages.coinStar,
                          icon: Icons.star,
                          value: selectedPoints,
                          items: points,
                          onChanged: (val) {
                            setState(() => selectedPoints = val);
                            _loadRooms();
                          },
                          hintText: AppLocalizations.points,
                          iconColor: Colors.amber,
                          isTablet: isTablet,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: isTablet ? 12.h : 10.h),

                // Filter Pills - Row 3
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: isTablet ? 20.w : 16.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildFilterPill(
                          image: AppImages.category,
                          icon: Icons.category,
                          // value: selectedCategory,
                          value: selectedCategories.isEmpty ? null : selectedCategories.join(", "),
                          items: categories,
                          onChanged: (val) {
                            setState(() {
                              selectedCategories = val != null ? [val] : [];
                            });
                            _loadRooms();
                          },
                          hintText: AppLocalizations.category,
                          iconColor: Colors.orange,
                          isTablet: isTablet,
                        ),
                      ),
                      SizedBox(width: isTablet ? 12.w : 8.w),
                      Expanded(
                        child: _buildFilterPill(
                          image: AppImages.game,
                          icon: Icons.people,
                          value: selectedGameMode == "team_vs_team"
                              ? AppLocalizations.team
                              : AppLocalizations.individual,
                          onChanged: (val) {
                            if (val == AppLocalizations.team) {
                              setState(() {
                                selectedGameMode = "team_vs_team";
                              });
                            } else if (val == AppLocalizations.individual) {
                              setState(() {
                                selectedGameMode = "1v1";
                              });
                            }
                            _loadRooms();
                          },
                          hintText: AppLocalizations.mode,
                          items: [
                            AppLocalizations.team,
                            AppLocalizations.individual
                          ],
                          iconColor: Colors.blueAccent,
                          isStatic: false, // Make it static/unchangeable
                          isTablet: isTablet,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: isTablet ? 20.h : 16.h),

                // Rooms Container
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: isTablet ? 16.w : 12.w),
                    padding: EdgeInsets.symmetric(
                        vertical: isTablet ? 20.h : 16.h,
                        horizontal: isTablet ? 16.w : 12.w),
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            begin: AlignmentGeometry.topCenter,
                            end: AlignmentGeometry.bottomCenter,
                            colors: [
                              Color.fromARGB(255, 34, 52, 96),
                              Color.fromARGB(
                                255,
                                17,
                                29,
                                63,
                              ),
                              Color.fromARGB(
                                255,
                                17,
                                29,
                                63,
                              ),
                              Color.fromARGB(
                                255,
                                17,
                                29,
                                63,
                              ),
                              Color.fromARGB(
                                255,
                                22,
                                43,
                                81,
                              ),
                            ]),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                            color: const Color.fromARGB(255, 52, 91, 168), width: 1)),
                    child: allFilled
                        ? _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: Colors.white),
                              )
                            : _rooms.isEmpty
                                ? Center(
                                    child: Text(
                                      AppLocalizations.noRoomsAvailable,
                                      style: TextStyle(
                                        color: Colors.white60,
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    itemCount: _rooms.length,
                                    separatorBuilder: (_, __) =>
                                        SizedBox(height: 16.h),
                                    itemBuilder: (context, index) {
                                      final room = _rooms[index];
                                      return _buildRoomCard(room);
                                    },
                                  )
                        : Center(
                            child: Text(
                              AppLocalizations.selectAllFiltersToViewRooms,
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 16.sp,
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
        ),
      ),
    );
  }

  // Helper widget for handling both Dropdowns and Static Toggles
  Widget _buildFilterPill({
    required IconData icon,
    String? value,
    List<String>? items,
    ValueChanged<String?>? onChanged, // Used for dropdowns
    VoidCallback? onTap, // Used for static/toggle buttons
    required String hintText,
    Color iconColor = Colors.white,
    bool isStatic =
        false, // If true, ignore dropdown logic and just execute onTap
    bool isToggle = false,
    String? image, // If true, ignore dropdown logic and just execute onTap
    bool isTablet = false,
  }) {
    final GlobalKey tapKey = GlobalKey();
    final String displayValue = value ?? hintText;
    final bool isInteractive = onChanged != null || onTap != null;
    final bool isDropdown =
        !isStatic && !isToggle; // True if it should open a menu

    return Container(
      height: isTablet ? 52.h : 45.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.r),
        // Use a subtle gradient/border for styling
        border: Border.all(color: Colors.white, width: isTablet ? 1.5.w : 1.w),
        color: const Color(0xFF0E0E0E),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: tapKey,
          borderRadius: BorderRadius.circular(25.r),
          onTap: selectedLanguage == "English" && hintText == "Script"
              ? null
              : isDropdown
                  ? () async {
                      // If it's a dropdown, show the menu
                      final box = tapKey.currentContext!.findRenderObject()
                          as RenderBox;
                      final Offset pos = box.localToGlobal(Offset.zero);
                      final Size size = box.size;

                      final selected = await showMenu<String>(
                        context: context,
                        position: RelativeRect.fromLTRB(
                            pos.dx,
                            pos.dy + size.height,
                            pos.dx + size.width,
                            pos.dy + size.height * 2),
                        color: const Color(0xFF1E2A3A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        items: items!.map((item) {
                          return PopupMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: GoogleFonts.lato(
                                color: Colors.white,
                                fontSize: 14.sp,
                              ),
                            ),
                          );
                        }).toList(),
                      );
                      if (selected != null) onChanged!(selected);
                    }
                  : onTap, // If it's a static/toggle button, execute the direct onTap

          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 14.w : 10.w,
                vertical: isTablet ? 12.h : 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (image != null) ...[
                  Image.asset(
                    image,
                    height: isTablet ? 22.h : 18.h,
                    width: isTablet ? 22.w : 18.w,
                  ),
                  SizedBox(width: isTablet ? 10.w : 8.w),
                ],
                Expanded(
                  child: Text(
                    displayValue,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: isTablet ? 15.sp : 13.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),
                if (isDropdown) ...[
                  SizedBox(width: isTablet ? 8.w : 6.w),
                  Image.asset(
                    "asset/image/arrow_down.png",
                    height: isTablet ? 16.sp : 14.sp,
                    width: isTablet ? 16.sp : 14.sp,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientDropdown({
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String hintText,
    Color iconColor = Colors.white,
  }) {
    return _buildFilterPill(
      icon: icon,
      value: value,
      items: items,
      onChanged: onChanged,
      hintText: hintText,
      iconColor: iconColor,
    );
  }

  // Mapping the old filter pill calls to the new generic pill
  Widget _buildLanguagePill() => _buildGradientDropdown(
        icon: Icons.language,
        value: selectedLanguage,
        items: languages,
        onChanged: (val) {
          setState(() => selectedLanguage = val);
          _loadRooms();
        },
        hintText: "Language",
        iconColor: Colors.lightBlueAccent,
      );

  Widget _buildScriptPill() => _buildGradientDropdown(
        icon: Icons.image,
        value: selectedScript,
        items: scripts,
        onChanged: (val) {
          setState(() => selectedScript = val);
          _loadRooms();
        },
        hintText: "Script",
        iconColor: Colors.deepPurpleAccent,
      );

  Widget _buildPointsPill() => _buildGradientDropdown(
        icon: Icons.star,
        value: selectedPoints,
        items: points,
        onChanged: (val) {
          setState(() => selectedPoints = val);
          _loadRooms();
        },
        hintText: "Points",
        iconColor: Colors.amber,
      );

  Widget _buildCountryPill() => _buildGradientDropdown(
        icon: Icons.public,
        value: selectedCountry,
        items: countries,
        onChanged: (val) {
          setState(() => selectedCountry = val);
          _loadRooms();
        },
        hintText: "Country",
        iconColor: Colors.lightGreenAccent,
      );

  Widget _buildCategoryPill() => _buildGradientDropdown(
        icon: Icons.category,
        value: selectedCategories.isEmpty ? null : selectedCategories.join(", "),
        items: categories,
        onChanged: (val) {
          setState(() {
            selectedCategories = val != null ? [val] : [];
          });
          _loadRooms();
        },
        hintText: "Category",
        iconColor: Colors.orange,
      );

  // --- Existing logic (kept for completeness) ---

  Widget _buildRoomCard(RoomModel room) {
    const Color gradientStartColor =
        Color.fromRGBO(110, 136, 206, 1); // rgba(110, 136, 206, 1)
    const Color gradientEndColor =
        Color.fromRGBO(44, 61, 106, 1); // rgba(44, 61, 106, 1)

    // The thickness of the gradient border
    const double borderWidth = 1.2;
    return GestureDetector(
      onTap: room.isFull == true ? null : () => _joinRoom(room),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: BoxBorder.fromLTRB(
            bottom: const BorderSide(
              color: Color.fromRGBO(31, 48, 96, 1),
              width: borderWidth,
            ),
          ),
        ),
        child: Row(
          children: [
            // Icon Circle
            Container(
              // 1. Outer Container: Applies the Gradient
              height: 50.h,
              width: 50.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r + borderWidth),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [gradientStartColor, gradientEndColor],
                ),
              ),
              padding: const EdgeInsets.all(borderWidth), // Creates the border gap

              // 2. Inner Container: Holds the original content
              child: Container(
                decoration: BoxDecoration(
                  // Use the original solid background color
                  color: const Color.fromARGB(255, 26, 42, 81),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Center(
                  child: Image.asset(
                    _getCategoryIcon(room.category ?? 'Animals'),
                    width: 53.w,
                    height: 57.h,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.category,
                      color: Colors.white,
                      size: 32.sp,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(width: 12.w),

            // Room Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Row
                  SizedBox(
                    height: 24.h,
                    child: Row(
                      children: [
                        Text(
                          room.name ?? 'Room',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        VerticalDivider(
                          width: 24.h,
                          color: const Color.fromRGBO(76, 99, 162, 1),
                        ),
                        (room.gameMode != null &&
                                room.gameMode == 'team_vs_team')
                            ? Text(
                                '👥vs👥',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: const Color.fromRGBO(132, 156, 206, 1),
                                ),
                              )
                            : Text(
                                '👤vs👤',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: const Color.fromRGBO(132, 156, 206, 1),
                                ),
                              ),
                        SizedBox(
                          width: 15.w,
                        ),
                        Text(
                          _getCountryFlag(room.country ?? 'India'),
                          style: TextStyle(fontSize: 16.sp),
                        ),
                        const Spacer(),
                        if (room.voiceEnabled == true) ...[
                          SizedBox(height: 8.h),
                          Icon(
                            Icons.mic,
                            color: const Color.fromRGBO(132, 156, 206, 1),
                            size: 20.sp,
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Info Row
                  SizedBox(
                    height: 24.h,
                    child: Row(
                      children: [
                        Icon(Icons.people,
                            color: const Color.fromRGBO(132, 156, 206, 1),
                            size: 14.sp),
                        SizedBox(width: 4.w),
                        Text(
                          '${room.participantCount}/${room.maxPlayers}',
                          style: TextStyle(
                            color: const Color.fromRGBO(132, 156, 206, 1),
                            fontSize: 13.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Icon(Icons.star,
                            color: const Color.fromRGBO(132, 156, 206, 1),
                            size: 14.sp),
                        SizedBox(width: 4.w),
                        Text(
                          '${room.pointsTarget}',
                          style: TextStyle(
                            color: const Color.fromRGBO(132, 156, 206, 1),
                            fontSize: 13.sp,
                          ),
                        ),
                        SizedBox(width: 30.w),
                        _buildBadge(
                            room.language?.substring(0, 2).toUpperCase() ??
                                'EN'),
                        const VerticalDivider(
                            color: Color.fromRGBO(132, 156, 206, 1),
                            thickness: 1),
                        _buildBadge(
                            room.script?.substring(0, 2).toUpperCase() ?? 'TE'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Right Column
          ],
        ),
      ),
    );
  }

  Widget _buildMultiSelectCategoryPill() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Categories",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            final isSelected = selectedCategories.contains(category);
            return FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selected
                      ? selectedCategories.add(category)
                      : selectedCategories.remove(category);
                });
                _loadRooms();
              },
            );
          }).toList(),
        ),
      ],
    );
  }


  Widget _buildBadge(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      child: Text(
        text,
        style: TextStyle(
          color: const Color.fromRGBO(148, 175, 231, 1),
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getCountryFlag(String country) {
    Map<String, String> flags = {
      'India': '🇮🇳',
      'USA': '🇺🇸',
      'UK': '🇬🇧',
      'Russia': '🇷🇺',
      'Ukraine': '🇺🇦',
      'Canada': '🇨🇦',
    };
    return flags[country] ?? '🏳️';
  }

  bool get allFilled =>
      selectedLanguage != null &&
      selectedScript != null &&
      // selectedCountry != null && // Country is optional
      selectedPoints != null &&
      selectedCategories.isNotEmpty;

  String _getCategoryIcon(String category) {
    switch (category) {
      case "Fruits":
        return AppImages.fruit;
      case "Animals":
        return AppImages.animal;
      case "Food":
        return AppImages.food;
      case "Movies":
        return AppImages.movies;
      default:
        return AppImages.animal;
    }
  }

  Future<String?> _showDropdownMenu(List<String> items) async {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;

    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) return null;

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        renderBox.localToGlobal(Offset.zero, ancestor: overlay),
        renderBox.localToGlobal(renderBox.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    return showMenu<String>(
      context: context,
      position: position,
      color: const Color(0xFF1E3A5F),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      items: items.map((item) {
        return PopupMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
            ),
          ),
        );
      }).toList(),
    );
  }
}
