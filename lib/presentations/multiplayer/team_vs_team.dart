import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';
import 'package:inkbattle_frontend/models/room_model.dart';
import 'package:inkbattle_frontend/repositories/room_repository.dart';
import 'package:inkbattle_frontend/repositories/user_repository.dart';
import 'package:inkbattle_frontend/utils/lang.dart';
import 'package:inkbattle_frontend/widgets/blue_background_scaffold.dart';
import 'package:inkbattle_frontend/widgets/custom_svg.dart';
import 'package:inkbattle_frontend/widgets/persistent_banner_ad_widget.dart';

class TeamVsTeamScreen extends StatefulWidget {
  final List<String> categories;
  final int points;
  final String roomId;
  final RoomModel? roomModel;

  const TeamVsTeamScreen({
    super.key,
    required this.categories,
    required this.points,
    required this.roomId,
    this.roomModel,
  });

  @override
  State<TeamVsTeamScreen> createState() => _TeamVsTeamScreenState();
}

class _TeamVsTeamScreenState extends State<TeamVsTeamScreen> {
  bool isButtonPressed = false;
  String? selectedTeam;

  final RoomRepository _roomRepository = RoomRepository();
  final UserRepository _userRepository = UserRepository();
  final TextEditingController _codeController = TextEditingController();

  bool _isLoading = false;
  bool showTeamSelection = false;

  /// Current room data (refreshed on init so participantCount and targetPoints are up to date).
  RoomModel? _roomModel;

  Future<void> _handleJoinRoom(String code) async {
    try {
      // Join room
      final result = await _roomRepository.joinRoomById(
        roomId: int.parse(code),
      );

      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to join room: '
                    '${failure.message ?? 'Please check the code and try again.'}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (roomResponse) async {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Successfully joined room! Entry cost: 250 coins'),
                backgroundColor: Colors.green,
              ),
            );

            // Navigate to game room
            context.push('/game-room/${roomResponse.room?.id}',
                extra: {"selectedTeam": selectedTeam});
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
  void initState() {
    super.initState();
    _roomModel = widget.roomModel;
    _refreshRoom();
  }

  Future<void> _refreshRoom() async {
    if (widget.roomId.isEmpty || widget.roomId == 'Unknown') return;
    final result = await _roomRepository.getRoomDetails(roomId: widget.roomId);
    result.fold(
      (_) {},
      (room) {
        if (mounted) setState(() => _roomModel = room);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final room = _roomModel ?? widget.roomModel;
    // Calculate team counts (Team A = blue, Team B = orange)
    int teamACount = 0;
    int teamBCount = 0;
    final maxPlayers = room?.maxPlayers ?? 2;
    int maxPlayersPerTeam = maxPlayers ~/ 2;
    if (room?.participants != null) {
      teamACount =
          room!.participants!.where((p) => p.team == 'blue').length;
      teamBCount = room.participants!
          .where((p) => p.team == 'orange')
          .length;
    }

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        final bool isTablet = MediaQuery.of(context).size.width > 600;
        return Scaffold(
          backgroundColor: const Color(0xFF0B2A50),
          body: BlueBackgroundScaffold(
            child: SafeArea(
              bottom: true, // Protect bottom for ad visibility
              child: Padding(
                padding: EdgeInsets.only(
                    left: 25.w,
                    right: 25.w,
                    top: isTablet ? 20.h : 15.h,
                    bottom: 0),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
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
                    ],
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 10.h),
                        CircleAvatar(
                          radius: 50.r,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          child: Image.asset(
                            _getCategoryIcon(
                                widget.categories.isNotEmpty
                                    ? widget.categories.first
                                    : 'Animals'),
                            width: 70.w,
                            height: 70.h,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          widget.categories.isEmpty
                              ? 'Animals'
                              : widget.categories.length == 1
                                  ? widget.categories.first
                                  : widget.categories.join(', '),
                          style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          "Which team do you want to start?",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            color: const Color(0xFF94AFE7),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 25.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(9),
                                  border: selectedTeam == "blue"
                                      ? Border.all(
                                          color: Colors.white, width: 2)
                                      : null),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (teamACount >= maxPlayersPerTeam) {
                                    _showTeamFullSnackBar("Team A");
                                    return;
                                  }
                                  if (mounted) {
                                    setState(() {
                                      selectedTeam = "blue";
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: teamACount >= maxPlayersPerTeam
                                        ? [
                                            Color(0xFF85CCE6).withOpacity(0.4),
                                            Color(0xFF39B7E5).withOpacity(0.4),
                                          ]
                                        : [
                                            Color(0xFF85CCE6),
                                            Color(0xFF39B7E5),
                                          ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 8.h,
                                      horizontal: 15.w,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Team A",
                                          style: GoogleFonts.lato(
                                            color: const Color(0xFF003143),
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          "($teamACount Players)",
                                          style: GoogleFonts.lato(
                                            color: const Color(0xFF003143)
                                                .withOpacity(0.7),
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 15.w),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(9),
                                  border: selectedTeam == "orange"
                                      ? Border.all(
                                          color: Colors.white, width: 2)
                                      : null),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (teamBCount >= maxPlayersPerTeam) {
                                    _showTeamFullSnackBar("Team B");
                                    return;
                                  }
                                  if (mounted) {
                                    setState(() {
                                      selectedTeam = "orange";
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: teamBCount >= maxPlayersPerTeam
                                        ? [
                                            Color(0xFFFFC28B).withOpacity(0.4),
                                            Color(0xFFFF8A00).withOpacity(0.4),
                                          ]
                                        : [
                                            Color(0xFFFFC28B),
                                            Color(0xFFFF8A00),
                                          ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 8.h,
                                      horizontal: 15.w,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Team B",
                                          style: GoogleFonts.lato(
                                            color: const Color(0xFF003143),
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          "($teamBCount Players)",
                                          style: GoogleFonts.lato(
                                            color: const Color(0xFF003143)
                                                .withOpacity(0.7),
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                CustomSvgImage(
                                  imageUrl: AppImages.userSvg,
                                  width: 16.w,
                                  height: 16.w,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  "Total Players: ${(_roomModel ?? widget.roomModel)?.participantCount ?? 0}/${(_roomModel ?? widget.roomModel)?.maxPlayers ?? 0}",
                                  style: GoogleFonts.lato(
                                    color: const Color(0xFFB9C7E7),
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 60.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.language,
                                        color: Colors.white, size: 28.sp),
                                    SizedBox(width: isTablet ? 6.w : 4.w),
                                    Text(
                                      (_roomModel ?? widget.roomModel)?.language?.isNotEmpty == true
                                          ? (_roomModel ?? widget.roomModel)!.language!
                                          : 'EN',
                                      style: GoogleFonts.lato(
                                        color: Colors.white,
                                        fontSize: isTablet ? 18.sp : 15.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            Container(
                              height: 25.h,
                              width: 1.w,
                              color: Colors.white.withOpacity(0.5),
                              margin: EdgeInsets.symmetric(horizontal: 16.w),
                            ),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.people,
                                        color: Colors.white, size: 21.sp),
                                    SizedBox(width: isTablet ? 6.w : 4.w),
                                    Text(
                                      "${(_roomModel ?? widget.roomModel)?.participantCount ?? 0}/${(_roomModel ?? widget.roomModel)?.maxPlayers ?? 0}",
                                      style: GoogleFonts.lato(
                                        color: Colors.white,
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            Container(
                              height: 25.h,
                              width: 1.w,
                              color: Colors.white.withOpacity(0.5),
                              margin: EdgeInsets.symmetric(horizontal: 16.w),
                            ),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.flag,
                                        color: Colors.amber, size: 21.sp),
                                    SizedBox(width: isTablet ? 6.w : 4.w),
                                    Text(
                                      "${(_roomModel ?? widget.roomModel)?.pointsTarget ?? 100}",
                                      style: GoogleFonts.lato(
                                        color: Colors.white,
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                        SizedBox(height: isTablet ? 44.h : 99.h),
                        GestureDetector(
                          onTap: () {
                            if (!isButtonPressed) {
                              _handleJoinRoom(widget.roomId);
                            }
                            if (mounted) {
                              setState(() {
                                isButtonPressed = !isButtonPressed;
                              });
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            height: 50.h,
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            decoration: BoxDecoration(
                              color: isButtonPressed
                                  ? Colors.green
                                  : const Color.fromARGB(255, 189, 16, 4),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                isButtonPressed
                                    ? Text(
                                        "🚀  Let's go!",
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Row(
                                        children: [
                                          Image.asset(
                                            AppImages.coin,
                                            height: 30.h,
                                            width: 30.w,
                                          ),
                                          Text(
                                            "250",
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      )
                              ],
                            ),
                          ),
                        ),
                      ],
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
      },
    );
  }

  void _showTeamFullSnackBar(String teamName) {
    String teamMessage = "";
    if (teamName == "Team A") {
      teamMessage = "${AppLocalizations.teamAIsFull} ${AppLocalizations.pleaseSelectTheOtherTeam}";
    } else if (teamName == "Team B") {
      teamMessage = "${AppLocalizations.teamBIsFull} ${AppLocalizations.pleaseSelectTheOtherTeam}";
    } else {
      teamMessage = AppLocalizations.pleaseSelectTheOtherTeam;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(teamMessage),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

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
        return AppImages.food;
    }
  }
}
