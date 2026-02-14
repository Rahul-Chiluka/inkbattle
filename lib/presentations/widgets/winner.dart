import 'package:audioplayers/audioplayers.dart';
import 'package:dotlottie_flutter/dotlottie_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';
import 'package:inkbattle_frontend/utils/preferences/local_preferences.dart';

// ---------------- DATA MODEL ----------------
class Team {
  final String name;
  final int score;
  final String avatar;
  final bool isCurrentUser;

  Team({
    required this.name,
    required this.score,
    required this.avatar,
    this.isCurrentUser = false,
  });
}

// ---------------- MAIN POPUP ----------------
class TeamWinnerPopup extends StatefulWidget {
  final List<Team> teams;
  final Function()? onNext;
  final bool isWinner;

  const TeamWinnerPopup({
    super.key,
    required this.teams,
    this.onNext,
    this.isWinner = false,
  });

  @override
  State<TeamWinnerPopup> createState() => _TeamWinnerPopupState();
}

class _TeamWinnerPopupState extends State<TeamWinnerPopup> {
  static const String _celebrationLottieUrl =
      'https://lottie.host/6fe4fdb6-3ca3-4e3e-82c5-f90de4c0be04/xn7qPAIzcf.lottie';

  final AudioPlayer _soundPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playResultSound();
  }

  @override
  void dispose() {
    _soundPlayer.dispose();
    super.dispose();
  }

  Future<void> _playResultSound() async {
    try {
      final volume = await LocalStorageUtils.getVolume();
      await _soundPlayer.setVolume(volume.clamp(0.0, 1.0));
      await _soundPlayer.play(
        AssetSource(
          widget.isWinner ? 'sounds/winner-sound.mp3' : 'sounds/lose-sound.mp3',
        ),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    // Sort teams by score
    final sortedTeams = List<Team>.from(widget.teams)
      ..sort((a, b) => b.score.compareTo(a.score));

    final first = sortedTeams.isNotEmpty ? sortedTeams[0] : null;
    final second = sortedTeams.length > 1 ? sortedTeams[1] : null;
    final third = sortedTeams.length > 2 ? sortedTeams[2] : null;

    final isTwoPlayers = sortedTeams.length == 2;

    final modalHeightFactor = isTablet ? 0.65 : 0.85;
    final maxWidth = isTablet ? 600.0 : double.infinity;

    // Dynamic heights based on screen size
    final basePodiumHeight = size.height * (isTablet ? 0.18 : 0.20);
    final rank1Height = basePodiumHeight;
    final rank2Height = basePodiumHeight * 0.75; // More distinct difference
    final rank3Height = basePodiumHeight * 0.55;

    // Dynamic widths to prevent overflow on small screens
    // We reserve some padding, then split remaining space
    final availableWidth = isTablet ? 550.0 : size.width * 0.9;
    final podiumWidth = availableWidth / 3.2; 

    return WillPopScope(
      onWillPop: () async => false,
      child: Stack(
        children: [
          Container(color: Colors.black.withOpacity(0.6)),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: FractionallySizedBox(
                heightFactor: modalHeightFactor,
                widthFactor: isTablet ? 0.92 : 0.95,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1C1C30), Color(0xFF0E0E1A)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.blueAccent,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 16 : 8, vertical: 16),
                    child: Column(
                      children: [
                        // ---------- RIBBON ----------
                        Container(
                          height: isTablet ? 90 : 70,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(AppImages.redflg),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(18),
                              topRight: Radius.circular(18),
                            ),
                          ),
                        ),

                        // Use Spacer to push podiums to the visually correct spot
                        const Spacer(), 

                        // ---------- PODIUM ROW ----------
                        // CrossAxisAlignment.end ensures they all start from the same Y-axis bottom
                        SizedBox(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (isTwoPlayers) ...[
                                _buildPodiumColumn(second, 2, rank2Height,
                                    podiumWidth, isTablet),
                                SizedBox(width: isTablet ? 20 : 10),
                                _buildPodiumColumn(first, 1, rank1Height,
                                    podiumWidth, isTablet),
                              ] else ...[
                                _buildPodiumColumn(second, 2, rank2Height,
                                    podiumWidth, isTablet),
                                _buildPodiumColumn(first, 1, rank1Height,
                                    podiumWidth, isTablet),
                                _buildPodiumColumn(third, 3, rank3Height,
                                    podiumWidth, isTablet),
                              ]
                            ],
                          ),
                        ),

                        const Spacer(),

                        // ---------- NEXT BUTTON ----------
                        GestureDetector(
                          onTap: () {
                            widget.onNext?.call();
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 180,
                            height: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.blueAccent,
                                  Colors.lightBlue
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "NEXT",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (widget.isWinner)
            Positioned.fill(
              child: IgnorePointer(
                child: DotLottieView(
                  sourceType: 'url',
                  source: _celebrationLottieUrl,
                  autoplay: true,
                  loop: false,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ---------- HELPER: SINGLE PODIUM COLUMN ----------
  Widget _buildPodiumColumn(
    Team? team,
    int rank,
    double height,
    double width,
    bool isTablet,
  ) {
    // If we have a slot but no player (rare edge case), return empty space
    if (team == null) return SizedBox(width: width);

    final asset = rank == 1
        ? AppImages.podium_1
        : rank == 2
            ? AppImages.podium_2_left
            : AppImages.podium_3;

    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min, // Shrink wrap vertically
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 1. AVATAR
          CircleAvatar(
            radius: isTablet ? (rank == 1 ? 35 : 28) : (rank == 1 ? 28 : 22),
            backgroundImage: AssetImage(team.avatar),
            backgroundColor: Colors.grey.shade800,
          ),
          const SizedBox(height: 6),

          // 2. NAME + STAR (Current User)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  team.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: isTablet ? 16 : 13,
                  ),
                ),
              ),
              if (team.isCurrentUser) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: isTablet ? 18 : 14,
                ),
              ]
            ],
          ),

          // 3. SCORE
          Text(
            "${team.score}",
            style: GoogleFonts.lato(
              fontWeight: FontWeight.bold,
              color: Colors.amber,
              fontSize: isTablet ? 18 : 15,
            ),
          ),
          const SizedBox(height: 4),

          // 4. PODIUM IMAGE (The Step)
          // This sits at the bottom of the column.
          // Because the parent Row is CrossAxis.end, these images align.
          SizedBox(
            height: height,
            width: width, // Fill the calculated width
            child: Image.asset(
              asset,
              fit: BoxFit.fill,
            ),
          ),
        ],
      ),
    );
  }
}