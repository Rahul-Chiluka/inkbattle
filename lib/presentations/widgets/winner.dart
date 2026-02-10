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
          widget.isWinner
              ? 'sounds/winner-sound.mp3'
              : 'sounds/lose-sound.mp3',
        ),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    final sortedTeams = List<Team>.from(widget.teams)
      ..sort((a, b) => b.score.compareTo(a.score));

    final first = sortedTeams.isNotEmpty ? sortedTeams[0] : null;
    final second = sortedTeams.length > 1 ? sortedTeams[1] : null;
    final third = sortedTeams.length > 2 ? sortedTeams[2] : null;

    final isTwoPlayers = sortedTeams.length == 2;

    final modalHeightFactor = isTablet ? 0.65 : 0.8;
    final maxWidth = isTablet ? 600.0 : double.infinity;

    final basePodiumHeight =
        size.height * (isTablet ? 0.18 : 0.22);

    final rank1Height = basePodiumHeight;
    final rank2Height = basePodiumHeight * 0.8;
    final rank3Height = basePodiumHeight * 0.6;

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
                widthFactor: isTablet ? 0.92 : 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1C1C30),
                        Color(0xFF0E0E1A)
                      ],
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
                    padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 12, vertical: 16),
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
                          // alignment: Alignment.center,
                          // child: Text(
                          //   "LEADERBOARD",
                          //   style: GoogleFonts.luckiestGuy(
                          //     color: Colors.white,
                          //     fontSize: isTablet ? 26 : 22,
                          //   ),
                          // ),
                        ),

                        const SizedBox(height: 30),

                        // ---------- PODIUM WITH TEXT ON TOP ----------
                        SizedBox(
                          width: isTablet ? 340 : 300,
                          height: basePodiumHeight + 90,
                          child: isTwoPlayers
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    if (first != null)
                                      _buildPodiumWithInfo(
                                          first, 1, rank1Height),
                                    if (second != null)
                                      _buildPodiumWithInfo(
                                          second, 2, rank2Height),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    _buildPodiumWithInfo(
                                        second, 2, rank2Height),
                                    _buildPodiumWithInfo(
                                        first, 1, rank1Height),
                                    _buildPodiumWithInfo(
                                        third, 3, rank3Height),
                                  ],
                                ),
                        ),

                        const Spacer(),

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
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "NEXT",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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

  // ---------- PODIUM + NAME + SCORE ----------
  Widget _buildPodiumWithInfo(
      Team? team, int rank, double height) {
    if (team == null) return const SizedBox(width: 80);

    final asset = rank == 1
        ? AppImages.podium_1
        : rank == 2
            ? AppImages.podium_2_left
            : AppImages.podium_3;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [

        // Name + Score (always above podium)
        Column(
          children: [
            CircleAvatar(
              radius: rank == 1 ? 28 : 24,
              backgroundImage: AssetImage(team.avatar),
            ),
            const SizedBox(height: 6),
            Text(
              team.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(
              "${team.score}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),

        SizedBox(
          width: 80,
          height: height,
          child: Image.asset(
            asset,
            fit: BoxFit.fill,
          ),
        ),
      ],
    );
  }
}
