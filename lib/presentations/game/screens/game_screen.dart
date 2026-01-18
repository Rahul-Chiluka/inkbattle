import 'dart:async';
import 'dart:math';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';
import 'package:inkbattle_frontend/presentations/widgets/exit.dart';
import 'package:inkbattle_frontend/presentations/widgets/report.dart';
import 'package:inkbattle_frontend/presentations/widgets/teamsview.dart';
import 'package:inkbattle_frontend/presentations/widgets/winner.dart';

class Player {
  final String id;
  final String name;
  final String avatarUrl;
  Player({required this.id, required this.name, this.avatarUrl = ''});
}

class RoomStatus {
  final String roomId;
  final List<Player> players;
  final Map<String, int> teamScores;
  final String status;
  RoomStatus({
    required this.roomId,
    required this.players,
    required this.teamScores,
    required this.status,
  });
}

class ChatMessage {
  final String user;
  final String text;
  final bool isCorrect;
  ChatMessage({required this.user, required this.text, this.isCorrect = false});
}

class GameScreen extends StatefulWidget {
  final bool debugSimulate;
  const GameScreen({super.key, this.debugSimulate = false});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final String _logTag = 'GameScreen';
  RoomStatus? _roomStatus;
  StreamSubscription<RoomStatus>? _roomSub;
  final List<ChatMessage> _generalChat = [];
  final List<ChatMessage> _answersChat = [];
  final TextEditingController _messageCtrl = TextEditingController();
  final TextEditingController _answerCtrl = TextEditingController();

  double _volume = 0.5;
  IconData _volumeIcon = Icons.volume_up;
  bool _showSlider = false;
  Timer? _sliderTimer;
  bool _isMicOn = false;
  bool _copied = false;

  final FocusNode _answerFocusNode = FocusNode();
  final FocusNode _messageFocusNode = FocusNode();

  final ScrollController _generalChatController = ScrollController();
  final ScrollController _answersChatController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchInitialRoomStatus();
    _subscribeRoomUpdates();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _roomStatus?.status == 'waiting') {
        setState(() {
          _roomStatus = RoomStatus(
            roomId: _roomStatus!.roomId,
            players: [
              Player(id: 'u1', name: 'Keeru'),
              Player(id: 'u2', name: 'June')
            ],
            teamScores: {'A': 0, 'B': 0},
            status: 'started',
          );
        });
        _onGameStarted();
      }
    });
  }

  @override
  void dispose() {
    _roomSub?.cancel();
    _messageCtrl.dispose();
    _answerCtrl.dispose();
    _sliderTimer?.cancel();
    _generalChatController.dispose();
    _answersChatController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialRoomStatus() async {
    setState(() {
      _roomStatus = RoomStatus(
        roomId: '12e6gh',
        players: [],
        teamScores: {'A': 0, 'B': 0},
        status: 'waiting',
      );
    });
  }

  Stream<RoomStatus> _roomUpdatesStream() => const Stream.empty();

  void _subscribeRoomUpdates() {
    _roomSub = _roomUpdatesStream().listen(
      (roomStatus) {
        final previous = _roomStatus;
        setState(() => _roomStatus = roomStatus);
        if ((previous?.status != 'started') &&
            (roomStatus.status == 'started')) {
          _onGameStarted();
        }
      },
      onError: (err) => developer.log('Room updates error: $err', name: _logTag),
    );
  }

  void _updateVolumeIcon(double volume) {
    if (!mounted) return;
    setState(() {
      _volume = volume.clamp(0.0, 1.0);
      _volumeIcon = _volume == 0.0
          ? Icons.volume_off
          : _volume < 0.3
              ? Icons.volume_down
              : Icons.volume_up;
    });
  }

  void _toggleSlider() {
    if (!mounted) return;
    setState(() {
      _showSlider = !_showSlider;
      _sliderTimer?.cancel();
      if (_showSlider) {
        _sliderTimer = Timer(const Duration(seconds: 10), () {
          if (mounted) setState(() => _showSlider = false);
        });
      }
    });
  }

  void _onGameStarted() {
    developer.log('Game started', name: _logTag);
    _generalChat.clear();
    _answersChat.clear();
    setState(() {});
  }

  bool get _isPlaying => _roomStatus?.status == 'started';

  void _addGeneralMessage(ChatMessage msg) {
    developer.log('Adding general message: ${msg.text}', name: _logTag);
    setState(() {
      _generalChat.add(msg);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generalChatController
          .jumpTo(_generalChatController.position.maxScrollExtent);
    });
  }

  void _addAnswerMessage(ChatMessage msg) {
    developer.log('Adding answer message: ${msg.text}', name: _logTag);
    setState(() {
      _answersChat.add(msg);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _answersChatController
          .jumpTo(_answersChatController.position.maxScrollExtent);
    });
  }

  void _sendAnswerMessage(String text) {
    developer.log('Sending answer message: $text', name: _logTag);
    if (text.trim().isNotEmpty) {
      final isCorrect = text.toLowerCase() == 'pen';
      final msg = ChatMessage(
        user: 'You',
        text: text.trim(),
        isCorrect: isCorrect,
      );
      _addAnswerMessage(msg);
      _answerCtrl.clear();
      _answerFocusNode.requestFocus();
    }
  }

  void _sendGeneralMessage(String text) {
    developer.log('Sending general message: $text', name: _logTag);
    if (text.trim().isNotEmpty) {
      final msg = ChatMessage(
        user: 'You',
        text: text.trim(),
        isCorrect: false,
      );
      _addGeneralMessage(msg);
      _messageCtrl.clear();
      _messageFocusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    developer.log('Building game screen', name: _logTag);
    ScreenUtil.init(context, designSize: const Size(360, 800));
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final double screenH = MediaQuery.of(context).size.height * 0.48;
    final double boardHeight =
        isKeyboardVisible ? 200.r : screenH.clamp(300.r, 520.r);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            SizedBox(height: 5.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: _buildBoardArea(boardHeight),
            ),
            _buildControlsRow(),
            _buildChatArea(),
            SizedBox(height: 5.h),
            Container(
              width: double.infinity,
              height: 45.h,
              padding: EdgeInsets.all(10.w),
              color: Colors.grey,
              child: const SizedBox.shrink(),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
      floatingActionButton: widget.debugSimulate ? _debugFab() : null,
    );
  }

  Widget _buildTopBar() {
    final roomId = _roomStatus?.roomId ?? '—';
    final showScore = _isPlaying;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color(0xFF000000),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          children: [
            _copyableRoomIdPill(roomId),
            SizedBox(width: 5.w),
            Expanded(
              child: Center(
                child: showScore ? _buildScoreboard() : _buildTeamsImage(),
              ),
            ),
            SizedBox(width: 5.w),
            GestureDetector(
              onTap: () {
                developer.log('Showing team winner popup', name: _logTag);
                List<Team> teams = [
                  Team(
                    name: "Alpha",
                    score: 90,
                    avatar: AppImages.profile,
                  ),
                  Team(
                    name: "Beta",
                    score: 75,
                    avatar: AppImages.profile,
                  ),
                ];

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: const EdgeInsets.all(16),
                      child: TeamWinnerPopup(teams: teams),
                    );
                  },
                );
              },
              child: _pill('Private',
                  color: const Color.fromARGB(255, 190, 30, 19),
                  textColor: Colors.white,
                  leading: Image.asset(
                    AppImages.circleprivate,
                    height: 18.h,
                    width: 18.w,
                  )),
            ),
            SizedBox(width: 5.w),
            GestureDetector(
              onTap: () {
                developer.log('Showing exit popup', name: _logTag);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const ExitPopUp(
                      imagePath: AppImages.inactive,
                    );
                  },
                );
              },
              child: Image.asset(AppImages.exitgame, width: 30.w, height: 30.h),
            ),
          ],
        ),
      ),
    );
  }

  Widget _copyableRoomIdPill(String roomId) {
    return GestureDetector(
      onTap: () async {
        developer.log('Copying room id: $roomId', name: _logTag);
        await Clipboard.setData(ClipboardData(text: roomId));
        setState(() => _copied = true);
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) setState(() => _copied = false);
        });
      },
      child: _pill(_copied ? 'Copied!' : roomId,
          color: const Color(0xFF1B1C2A),
          textColor: Colors.white,
          leading: Image.asset(
            AppImages.circleflag,
            height: 18.h,
            width: 18.w,
          )),
    );
  }

  Widget _pill(
    String text, {
    required Color color,
    required Color textColor,
    Widget? leading,
  }) {
    developer.log('Building pill: $text', name: _logTag);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            leading,
            SizedBox(width: 2.w),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamsImage() {
    developer.log('Building teams image', name: _logTag);
    return SizedBox(
      width: 120.w,
      height: 40.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            AppImages.tvst,
            fit: BoxFit.contain,
          ),
          Container(
            width: 24.w,
            height: 25.h,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Center(
              child: Image.asset(
                AppImages.trophy,
                width: 22.w,
                height: 22.h,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreboard() {
    final a = _roomStatus?.teamScores['A'] ?? 0;
    final b = _roomStatus?.teamScores['B'] ?? 0;
    developer.log('Building scoreboard: $a vs $b', name: _logTag);
    return SizedBox(
      width: 120.w,
      height: 40.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            AppImages.scoreboard,
            fit: BoxFit.contain,
          ),
          Positioned(
            left: 25.w,
            child: GestureDetector(
              onTap: () {
                developer.log('Showing team display popup for team A', name: _logTag);
                showDialog(
                  context: context,
                  barrierColor: Colors.black54,
                  builder: (context) => TeamDisplayPopup(
                    teamName: 'A',
                    players: [
                      TeamPlayer(
                          rank: 1,
                          name: 'Noah',
                          avatarPath: AppImages.profile,
                          flagEmoji: '🇮🇳'),
                    ],
                  ),
                );
              },
              child: Text(
                '$a',
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Positioned(
            right: 25.w,
            child: GestureDetector(
              onTap: () {
                developer.log('Showing team display popup for team B', name: _logTag);
                showDialog(
                  context: context,
                  barrierColor: Colors.black54,
                  builder: (context) => TeamDisplayPopup(
                    teamName: 'B',
                    players: [
                      TeamPlayer(
                        rank: 1,
                        name: 'Noah',
                        avatarPath: AppImages.profile,
                        flagEmoji: '🇮🇳',
                      ),
                      TeamPlayer(
                        rank: 2,
                        name: 'Noah',
                        avatarPath: AppImages.profile,
                        flagEmoji: '🇮🇳',
                      )
                    ],
                  ),
                );
              },
              child: Text(
                '$b',
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Container(
            width: 24.w,
            height: 25.h,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                AppImages.vs,
                width: 22.w,
                height: 22.h,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoardArea(double height) {
    developer.log('Building board area: $height', name: _logTag);
    final players = _roomStatus?.players ?? [];

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.black26),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: const Color(0xFF0F0F0F),
                child: Center(
                  child: !_isPlaying
                      ? _waitingForPlayersView(players)
                      : _drawingBoardPlaceholder(),
                ),
              ),
            ),
            if (_showSlider)
              Positioned(
                top: height - 50.h,
                left: 15.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: SizedBox(
                    width: 120.w,
                    child: Slider(
                      value: _volume,
                      min: 0.0,
                      max: 1.0,
                      activeColor: const Color.fromARGB(255, 160, 163, 165),
                      inactiveColor: Colors.grey[600],
                      onChanged: _updateVolumeIcon,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _waitingForPlayersView(List<Player> players) {
    developer.log('Waiting for players view', name: _logTag);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          AppImages.waiting,
          width: 100.w,
          height: 44.r,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 16.h),
        Text(
          'Waiting for players . . .',
          style: GoogleFonts.lato(
            color: Colors.white70,
            fontWeight: FontWeight.w500,
            fontSize: 20.sp,
          ),
        ),
      ],
    );
  }

  Widget _drawingBoardPlaceholder() {
    developer.log('Drawing board placeholder', name: _logTag);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF0B0B0B), width: 1),
        borderRadius: BorderRadius.circular(6.r),
        color: const Color(0xFF0B0B0B),
      ),
      child: const Center(
        child: Text(
          '🎨 Drawing board (replace with Canvas)',
          style: TextStyle(color: Colors.white54),
        ),
      ),
    );
  }

  Widget _buildControlsRow() {
    developer.log('Building controls row', name: _logTag);
    return Padding(
      padding: EdgeInsets.fromLTRB(10.w, 6.h, 10.w, 6.h),
      child: Row(
        children: [
          Container(
            height: 50.h,
            width: 120.w,
            padding: EdgeInsets.symmetric(horizontal: 1.w),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(width: 1, color: const Color(0xFF0B0B0B)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildIconBox(
                  child: Image.asset(
                    _isMicOn ? AppImages.micon : AppImages.micoff,
                    width: 25.w,
                    height: 25.w,
                  ),
                  onTap: () => setState(() => _isMicOn = !_isMicOn),
                ),
                _buildIconBox(
                  child: Icon(_volumeIcon, size: 25.w, color: Colors.white70),
                  onTap: _toggleSlider,
                ),
                _buildIconBox(
                  child: Icon(Icons.info_outline,
                      size: 25.w, color: Colors.yellow),
                  onTap: () {},
                ),
                _buildIconBox(
                  child: Image.asset(
                    AppImages.reporticon,
                    width: 25.w,
                    height: 25.w,
                  ),
                  onTap: () => showDialog(
                    context: context,
                    builder: (context) => ErrorPopup(
                      roomId: 0,
                      participants: const [],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Container(
              height: 50.h,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(width: 1, color: const Color(0xFF0B0B0B)),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Message :',
                  style: GoogleFonts.lato(
                    color: Colors.white38,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconBox({required Widget child, required VoidCallback onTap}) {
    developer.log('Building icon box', name: _logTag);
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 27.w,
        height: 35.h,
        margin: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: const Color(0xFF000000),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget _buildChatArea() {
    developer.log('Building chat area', name: _logTag);
    return Expanded(
      child: Container(
        padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 12.h),
        color: const Color(0xFF000000),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 120.w,
              margin: EdgeInsets.only(right: 8.w),
              decoration: BoxDecoration(
                color: const Color(0xFF121212),
                border: Border.all(width: 1, color: const Color(0xFF0B0B0B)),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 5.h,
                  ),
                  Container(
                    height: 30.h,
                    width: 100.w,
                    decoration: BoxDecoration(
                        color: const Color(0xFF202020),
                        border: Border.all(
                            width: 0.5, color: const Color(0xFF0B0B0B)),
                        borderRadius: BorderRadius.circular(20.r)),
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                    child: Text(
                      'Answers chat',
                      style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Divider(color: Colors.black26, height: 1),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              controller: _answersChatController,
                              itemCount: _answersChat.length,
                              itemBuilder: (context, i) {
                                final m = _answersChat[i];
                                return Container(
                                  margin: EdgeInsets.only(bottom: 8.h),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 12.r,
                                        backgroundColor: m.isCorrect
                                            ? Colors.green
                                            : Colors.red,
                                        child: Icon(
                                          m.isCorrect
                                              ? Icons.check
                                              : Icons.close,
                                          size: 14.r,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      Expanded(
                                        child: Text(
                                          '${m.user}: ${m.text}',
                                          style: TextStyle(
                                            color: m.isCorrect
                                                ? Colors.greenAccent
                                                : Colors.redAccent,
                                            fontSize: 11.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 5.h),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 12.r,
                                  backgroundColor: Colors.grey[600],
                                  child: Icon(
                                    Icons.person,
                                    size: 14.r,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: TextField(
                                    controller: _answerCtrl,
                                    focusNode: _answerFocusNode,
                                    minLines: 1,
                                    maxLines: 6,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.sp,
                                    ),
                                    textInputAction: TextInputAction.send,
                                    decoration: InputDecoration(
                                      hintText:
                                          'Type your answers here. If you\'re correct, it will be marked in green',
                                      hintStyle: GoogleFonts.lato(
                                        color: Colors.white38,
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 5.h),
                                    ),
                                    onSubmitted: (text) {
                                      _sendAnswerMessage(text);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF000000),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _generalChatController,
                        padding: EdgeInsets.all(10.w),
                        itemCount: _generalChat.length,
                        itemBuilder: (context, idx) {
                          final m = _generalChat[idx];
                          final isSystem = m.user == 'System';
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 14.r,
                                  backgroundColor: isSystem
                                      ? Colors.grey[700]
                                      : Colors.blueGrey,
                                  child: Text(
                                    m.user[0],
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        m.user,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        m.text,
                                        style: TextStyle(
                                          color: m.isCorrect
                                              ? Colors.greenAccent
                                              : Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(5.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF000000),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8.r),
                          bottomRight: Radius.circular(8.r),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 12.r,
                            backgroundColor: Colors.grey[600],
                            child: Icon(
                              Icons.person,
                              size: 14.r,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: TextField(
                              controller: _messageCtrl,
                              focusNode: _messageFocusNode,
                              minLines: 1,
                              maxLines: 3,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                              ),
                              decoration: InputDecoration(
                                hintText:
                                    'Welcome! This is your general chat area. Type below to start!',
                                hintStyle: GoogleFonts.lato(
                                  color: Colors.white38,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 8.h),
                              ),
                              textInputAction: TextInputAction.send,
                              onSubmitted: (text) {
                                _sendGeneralMessage(text);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _debugFab() {
    return FloatingActionButton(
      onPressed: () {
        final simulated = RoomStatus(
          roomId: '12e6gh',
          players: [
            Player(id: 'u1', name: 'Keeru'),
            Player(id: 'u2', name: 'June'),
            Player(id: 'u3', name: 'Arjun'),
          ],
          teamScores: {'A': 190, 'B': 140},
          status: 'started',
        );
        setState(() => _roomStatus = simulated);
        _onGameStarted();
        _generalChat.addAll([
          ChatMessage(user: 'Keeru', text: "I'm starting. No hints okay?"),
          ChatMessage(
              user: 'June',
              text: "Wait.. is that the head? It’s some animal, right?"),
          ChatMessage(user: 'Fred', text: "Lion", isCorrect: true),
          ChatMessage(user: 'Arjun', text: "Tiger? Cheetah?"),
        ]);
        _answersChat.clear();
        _answersChat.addAll(_generalChat.where((m) => m.isCorrect));
        setState(() {});
      },
      child: const Icon(Icons.play_arrow),
    );
  }
}

class DashedCircle extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;
  const DashedCircle({
    super.key,
    this.size = 40,
    this.color = Colors.white24,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DashedCirclePainter(color: color, strokeWidth: strokeWidth),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _DashedCirclePainter({required this.color, this.strokeWidth = 2});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = min(size.width, size.height) / 2 - strokeWidth;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const dashLength = 6;
    const gapLength = 6;
    final circumference = 2 * pi * radius;
    final dashCount = (circumference / (dashLength + gapLength)).floor();
    final sweepPerDash = 2 * pi / dashCount;
    for (int i = 0; i < dashCount; i++) {
      final start = i * sweepPerDash;
      final sweep = sweepPerDash * (dashLength / (dashLength + gapLength));
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start,
          sweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
