import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:inkbattle_frontend/constants/app_colors.dart';
import 'package:inkbattle_frontend/main.dart';
import 'package:inkbattle_frontend/presentations/home/widgets/round_announcement.dart';
import 'package:inkbattle_frontend/presentations/widgets/custom_slider.dart';
import 'package:inkbattle_frontend/presentations/widgets/selecting_drawer.dart';
import 'package:inkbattle_frontend/repositories/room_repository.dart';
import 'package:inkbattle_frontend/repositories/theme_repository.dart';
import 'package:inkbattle_frontend/repositories/user_repository.dart';
import 'package:inkbattle_frontend/services/ad_service.dart';
import 'package:inkbattle_frontend/services/socket_service.dart';
import 'package:inkbattle_frontend/widgets/blue_background_scaffold.dart';
import 'package:inkbattle_frontend/presentations/drawing_board/presentation/widgets/drawing_canvas.dart';
import 'package:inkbattle_frontend/presentations/drawing_board/domain/models/stroke.dart'
    as fdb;
import 'package:inkbattle_frontend/presentations/drawing_board/domain/models/drawing_tool.dart'
    as fdb_tool;
import 'package:inkbattle_frontend/presentations/drawing_board/domain/models/drawing_canvas_options.dart'
    as fdb;
import 'package:inkbattle_frontend/presentations/drawing_board/presentation/notifiers/current_stroke_value_notifier.dart'
    as fdb;
import 'package:inkbattle_frontend/presentations/drawing_board/domain/models/undo_redo_stack.dart'
    as fdb;
import 'package:inkbattle_frontend/widgets/coin_animation_dialog.dart';
import 'package:inkbattle_frontend/models/room_model.dart';
import 'package:inkbattle_frontend/models/user_model.dart';
import 'package:inkbattle_frontend/utils/preferences/local_preferences.dart';
import 'package:inkbattle_frontend/utils/lang.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';
import 'package:inkbattle_frontend/presentations/widgets/exit.dart';
import 'package:inkbattle_frontend/presentations/widgets/report.dart';
import 'package:inkbattle_frontend/presentations/widgets/teamsview.dart';
import 'package:inkbattle_frontend/presentations/widgets/winner.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:toastification/toastification.dart';
import 'package:video_player/video_player.dart';

class GameRoomScreen extends StatefulWidget {
  final String roomId;
  final String? selectedTeam;
  const GameRoomScreen({super.key, required this.roomId, this.selectedTeam});

  @override
  State<GameRoomScreen> createState() => _GameRoomScreenState();
}

enum DrawingTool {
  pencil,
  eraser,
  circle,
  filledCircle,
  rectangle,
  filledRectangle,
  colorPicker,
}

class _PhaseBorderPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final double borderRadius;

  const _PhaseBorderPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || strokeWidth <= 0) {
      return;
    }

    final double clampedProgress = progress.clamp(0.0, 1.0);
    final double inset = strokeWidth / 2;
    final double left = inset;
    final double top = inset;
    final double right = size.width - inset;
    final double bottom = size.height - inset;

    if (right <= left || bottom <= top) {
      return;
    }

    final double maxRadius = math.min((right - left), (bottom - top)) / 2;
    final double adjustedRadius = math.min(
      math.max(0.0, borderRadius - inset),
      maxRadius,
    );

    final double midX = (left + right) / 2;

    final Path path = Path()
      ..moveTo(midX, top)
      ..lineTo(right - adjustedRadius, top)
      ..quadraticBezierTo(right, top, right, top + adjustedRadius)
      ..lineTo(right, bottom - adjustedRadius)
      ..quadraticBezierTo(right, bottom, right - adjustedRadius, bottom)
      ..lineTo(left + adjustedRadius, bottom)
      ..quadraticBezierTo(left, bottom, left, bottom - adjustedRadius)
      ..lineTo(left, top + adjustedRadius)
      ..quadraticBezierTo(left, top, left + adjustedRadius, top)
      ..lineTo(midX, top);

    final PathMetrics metrics = path.computeMetrics();
    PathMetric? metric;
    for (final m in metrics) {
      metric = m;
      break;
    }

    if (metric == null) {
      return;
    }

    final double drawLength = metric.length * clampedProgress;
    final Path progressPath = metric.extractPath(0, drawLength);

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(progressPath, paint);
  }

  @override
  bool shouldRepaint(covariant _PhaseBorderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.borderRadius != borderRadius;
  }
}

class _DrawerMessageOption {
  final String key;
  final String label;
  final String iconPath;
  final Color accentColor;

  const _DrawerMessageOption({
    required this.key,
    required this.label,
    required this.iconPath,
    required this.accentColor,
  });
}

class _GameRoomScreenState extends State<GameRoomScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final RoomRepository _roomRepository = RoomRepository();
  final UserRepository _userRepository = UserRepository();
  final ThemeRepository _themeRepository = ThemeRepository();
  final SocketService _socketService = SocketService();
  // final VoiceService _voiceService = VoiceService();
  final TextEditingController _answerController = TextEditingController();
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  final ScrollController _answersChatScrollController = ScrollController();
  final FocusNode _answerFocusNode = FocusNode();
  final FocusNode _chatFocusNode = FocusNode();
  // final AgoraRepository _agoraRepository = AgoraRepository();
  final AudioPlayer _gameAudioPlayer = AudioPlayer();
  RoomModel? _room;
  UserModel? _currentUser;

  bool _isResuming = false;

  final ValueNotifier<List<fdb.Stroke>> _strokes = ValueNotifier([]);
  final fdb.CurrentStrokeValueNotifier _currentStroke =
      fdb.CurrentStrokeValueNotifier();
  late final fdb.UndoRedoStack _undoRedoStack;
  final GlobalKey _canvasKey = GlobalKey();
  final ValueNotifier<bool> _showGrid = ValueNotifier(false);
  final ValueNotifier<ui.Image?> _backgroundImage = ValueNotifier(null);
  final ValueNotifier<int> _polygonSides = ValueNotifier(3);

  final List<Map<String, dynamic>> _chatMessages = [];
  final List<Map<String, dynamic>> _answersChatMessages = [];
  List<RoomParticipant> _participants = [];
  RoomParticipant? _currentParticipant;
  DrawingTool _currentTool = DrawingTool.pencil;

  final GlobalKey _guesserBoardLayoutKey = GlobalKey();
  final GlobalKey _drawerBoardLayoutKey = GlobalKey();
  final GlobalKey showcasekey1 = GlobalKey();
  final GlobalKey showcasekey2 = GlobalKey();
  final GlobalKey showcasekey3 = GlobalKey();
  final GlobalKey showcasekey4 = GlobalKey();
  final GlobalKey showcasekey5 = GlobalKey();
  final GlobalKey showcasekey6 = GlobalKey();
  bool isShownShowcase = false;
  Size _drawerBoardSize = Size.zero;
  Size _guesserBoardSize = Size.zero;
  Size _lastKnownBoardSize = Size.zero;

  Size get _activeDrawingBoardSize {
    if (_isDrawer) {
      return _drawerBoardSize != Size.zero
          ? _drawerBoardSize
          : _lastKnownBoardSize;
    } else {
      return _guesserBoardSize != Size.zero
          ? _guesserBoardSize
          : _lastKnownBoardSize;
    }
  }

  Color _selectedColor = Colors.white;
  Color _baseColor = Colors.white;
  double _strokeWidth = 3.0;
  bool _isDrawer = false;
  String? _currentWord;
  bool _isLoading = true;
  bool _showDrawerInfo = false;
  bool _waitingForPlayers = true;
  double _volume = 0.5;
  IconData _volumeIcon = Icons.volume_up;
  bool _showSlider = false;
  Timer? _sliderTimer;
  bool _copied = false;
  final GlobalKey _gameScreenKey = GlobalKey();

  Map<String, dynamic>? _currentDrawerInfo;
  Map<String, dynamic>? _nextDrawerPreview;
  Timer? _nextDrawerTimer;
  int _nextDrawerCountdown = 0;

  Timer? _wordSelectionTimer;
  int _wordSelectionTimeLeft = 0;

  bool _isWordSelectionDialogVisible = false;
  bool _isWordSelectionLostTurn = false;

  bool _isIntervalPhase = false;
  String? missedTheirTurn;

  Timer? _teamScoreboardTimer;
  bool _showTeamScoreboard = false;
  bool _hasShownTeamScoreIntro = false;
  bool _isLeaderboardVisible = false;
  bool _showPencilTools = false;
  bool _isGameEnded = false;
  final GlobalKey _pencilKey = GlobalKey();
  bool _showOptionMenu = false;
  static const String _drawerMessagePrefix = 'drawer_message:';

  final List<_DrawerMessageOption> _drawerMessageOptions =
      const <_DrawerMessageOption>[
    _DrawerMessageOption(
      key: 'correct',
      label: 'Correct',
      iconPath: AppImages.messageCorrect,
      accentColor: Color(0xFF3EE07F),
    ),
    _DrawerMessageOption(
      key: 'wrong',
      label: 'Wrong',
      iconPath: AppImages.messageWrong,
      accentColor: Color(0xFFE53935),
    ),
    _DrawerMessageOption(
      key: 'break_word',
      label: 'Break Word',
      iconPath: AppImages.messageBreakWord,
      accentColor: Color(0xFF57C6FF),
    ),
    _DrawerMessageOption(
      key: 'alternate',
      label: 'Alternate',
      iconPath: AppImages.messageAlternate,
      accentColor: Color(0xFFFFC857),
    ),
  ];
  final universalBorder =
      BoxBorder.all(color: const Color.fromARGB(255, 38, 37, 37), width: 1);

  final List<Color> _colorPalette = [
    // Row 1: Bright Primaries, Secondaries, and Neon Accents
    Colors.white,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    const Color(0xFFFF00FF), // Neon Magenta

    // Row 2: Deep & Warm Tones
    Colors.pink,
    Colors.orange,
    Colors.cyan,
    Colors.lightGreen,
    const Color(0xFF6F3CFF), // Deep Violet
    const Color(0xFFE53935), // Crimson Red

    // Row 3: Dark & Neutral Bases
    Colors.black,
    const Color(0xFFC70039), // Raspberry
    const Color(0xFF900C3F), // Wine
    const Color(0xFF581845), // Dark Plum
    Colors.brown,
    Colors.teal,

    // Row 4: Pastels & Light Earth Tones
    Colors.indigo,
    Colors.amber,
    Colors.lime,
    Colors.deepOrange,
    Colors.blueGrey,
    Colors.grey,

    // Row 5: Blues and Sea Greens
    Colors.lightBlue,
    Colors.indigoAccent,
    const Color(0xFF00FFFF), // Electric Cyan
    const Color(0xFF00AAFF), // Azure Blue
    Colors.lightGreenAccent,
    Colors.tealAccent,

    // Row 6: Earthy and Muted Hues
    const Color(0xFFA0522D), // Sienna
    const Color(0xFFF0E68C), // Khaki
    const Color(0xFFDDA0DD), // Plum
    const Color(0xFF808000), // Olive
    const Color(0xFF483D8B), // Slate Blue
    const Color(0xFFD3D3D3), // Light Grey
  ];
  String? _currentDrawerMessageKey;

  bool get _shouldShowNextDrawerOverlay =>
      _nextDrawerPreview != null && _nextDrawerCountdown > 0;

  // Voice chat - track who is speaking
  final Set<String> _speakingUserIds = {};
  final Set<int> _speakingInGameUserIds = {};

  // Chat expansion state
  bool _isAnswersChatExpanded = false;
  bool _isGeneralChatExpanded = false;
  final Set<String> _usersWhoAnswered =
      {}; // Track users who have answered in current round

  // Round phase tracking
  String? _currentPhase;
  int _phaseTimeRemaining = 0;
  int _phaseMaxTime = 60; // Store max time for border calculation
  List<String>? _wordOptions;

  // Animation for smooth timer border
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;
  String? _wordHint;
  String? _currentWordForDashes; // Word length for dashes

  // Hint system
  int _hintsRemaining = 3;
  String? _revealedWord; // Word with revealed letters
  bool _showWordHint = false; // Whether to show dashes/hints

  // Drawing tools collapse state
  final bool _showDrawingTools = false;

  // Lobby settings
  String? selectedLanguage;
  String? selectedScript;
  String? selectedCountry;
  int? selectedPoints;
  String? selectedCategory;
  String? selectedGameMode = '1v1';
  bool voiceEnabled = false;
  bool isPublic = false;
  int maxPlayers = 5;
  String? selectedTeam;

  bool isShowCaseShown = false;
  bool isAnsweredCorrectly = false;
  // Ads
  //
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  RewardedAd? _closeRewardedAd;
  bool _isLoadingCloseAd = false;

  final Map<int, DateTime> _lastHeardAt = {};
  final Map<int, int> _currentVolumes = {};
  Timer? _speakingCleanupTimer;
  static const Duration _speakingTimeout = Duration(seconds: 2);
  static const int _speakingThreshold = 10; // Volume threshold (0-255 scale)

  // UI parity with CreateRoom screen
  int players = 5;
  String? selectedGamePlay; // "1 vs 1", "2 vs 2", "3 vs 3"
  int coins = 250; // display-only per UI

  List<String> languages = [];
  List<String> scripts = [
    'default',
    'english'
  ]; // Updated to new word_script options
  List<String> countries = [
    '🇮🇳 India',
    '🇺🇸 USA',
    '🇬🇧 UK',
    '🇯🇵 Japan',
    '🇪🇸 Spain',
    '🇵🇹 Portugal',
    '🇫🇷 France',
    '🇩🇪 Germany',
    '🇷🇺 Russia'
  ];
  List<int> pointsOptions = [10, 50, 100, 150, 200];
  List<String> categories = [];

  late RoundAnnouncementManager _announcementManager;

  // Preloaded video controllers for animations
  VideoPlayerController? _timeupVideoController;
  VideoPlayerController? _whosNextVideoController;
  VideoPlayerController? _welldoneVideoController;
  VideoPlayerController? _intervalVideoController;
  VideoPlayerController? _lostTurnVideoController;
  bool _videosPreloaded = false;
  BuildContext? showcasecontext;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _undoRedoStack = fdb.UndoRedoStack(
      strokesNotifier: _strokes,
      currentStrokeNotifier: _currentStroke,
    );

    /* points animation in gameArena UI  { */
    _pointsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _pointsOffsetAnimation = Tween<double>(begin: 0.0, end: -30.0).animate(
      CurvedAnimation(parent: _pointsAnimationController, curve: Curves.easeOut),
    );

    _pointsOpacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_pointsAnimationController);
    /*  } points animation in gameArena UI  */

    // Initialize progress animation controller
    _progressAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _progressAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _announcementManager = RoundAnnouncementManager(
      context: context,
      onAllComplete: () {},
      overlay1: _buildDrawerTimeUpWidget(),
      overlay2: _buildDrawerScoreWidget(),
      overlay3: _buildComplimentWidget(),
    );
    _preloadVideos();

    _initialize();
  }

  Future<void> _initialize() async {
    await _loadConfig();
    await _initializeRoom();
    await _loadBannerAd();
  }

  Future<void> _preloadVideos() async {
    try {
      

      // Preload timeup video
      
      _timeupVideoController =
          VideoPlayerController.asset(AppImages.timeupVideo);
      await _timeupVideoController!.initialize();
      _timeupVideoController!.setLooping(true);
      

      // Preload who's next video
      
      _whosNextVideoController =
          VideoPlayerController.asset(AppImages.whosNextVideo);
      await _whosNextVideoController!.initialize();
      _whosNextVideoController!.setLooping(true);
      

      // Preload well done video
      
      _welldoneVideoController =
          VideoPlayerController.asset(AppImages.welldoneVideo);
      await _welldoneVideoController!.initialize();
      _welldoneVideoController!.setLooping(true);
      

      // Preload interval video
      
      _intervalVideoController =
          VideoPlayerController.asset(AppImages.intervalVideo);
      await _intervalVideoController!.initialize();
      _intervalVideoController!.setLooping(true);
      

      // Preload lost turn video
      
      _lostTurnVideoController =
          VideoPlayerController.asset(AppImages.lostTurnVideo);
      await _lostTurnVideoController!.initialize();
      _lostTurnVideoController!.setLooping(true);
      

      if (mounted) {
        setState(() {
          _videosPreloaded = true;
        });
      }
      
    } catch (e) {
      
      
    }
  }

  Future<void> _loadBannerAd() async {
    try {
      // Initialize Mobile Ads SDK first
      await AdService.initializeMobileAds();

      // Load banner ad
      await AdService.loadBannerAd(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _bannerAd = ad as BannerAd;
              _isBannerAdLoaded = true;
            });
            
          }
        },
        onAdFailedToLoad: (ad, error) {
          
          if (mounted) {
            setState(() {
              _isBannerAdLoaded = false;
            });
          }
        },
      );
    } catch (e) {
      
    }
  }

  Future<void> _loadConfig() async {
    // Load languages
    final languagesResult = await _userRepository.getLanguages();
    languagesResult.fold(
      (failure) {
        // Fallback to default values on error
        if (mounted) {
          setState(() {
            languages = ['English', 'Hindi', 'Marathi', 'Telugu'];
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
        }
        if (mounted) {
          setState(() {
            languages = languagesList
                .map((lang) => lang['languageName'] as String? ?? '')
                .where((name) => name.isNotEmpty)
                .toList();
          });
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
            categories = ['Fruits', 'Animals', 'Food', 'Movies'];
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

  void _startNextDrawerCountdown(int seconds) {
    _nextDrawerTimer?.cancel();
    setState(() {
      _nextDrawerCountdown = seconds;
    });

    _nextDrawerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_nextDrawerCountdown <= 1) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _nextDrawerCountdown = 0;
            _nextDrawerPreview = null;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _nextDrawerCountdown -= 1;
          });
        }
      }
    });
  }

  void _cancelNextDrawerCountdown() {
    _nextDrawerTimer?.cancel();
    _nextDrawerTimer = null;
    if (mounted) {
      setState(() {
        _nextDrawerCountdown = 0;
        _nextDrawerPreview = null;
      });
    }
  }

  void _startWordSelectionCountdown(int seconds) {
    _wordSelectionTimer?.cancel();
    setState(() {
      _wordSelectionTimeLeft = seconds;
    });
    _isWordSelectionDialogVisible = true;

    _wordSelectionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_wordSelectionTimeLeft <= 1) {
        timer.cancel();
        _handleWordSelectionTimeout();
      } else {
        _updateWordSelectionTime(_wordSelectionTimeLeft - 1);
      }
    });
  }

  void _updateWordSelectionTime(int value) {
    if (!mounted) return;
    setState(() {
      _wordSelectionTimeLeft = value;
    });
  }

  void _cancelWordSelectionCountdown() {
    _wordSelectionTimer?.cancel();
    _wordSelectionTimer = null;
    _isWordSelectionDialogVisible = false;
  }

  void showLostTurnWidget(String name) {
    setState(() {
      missedTheirTurn = name;
      _isWordSelectionLostTurn = true; // show widget immediately
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isWordSelectionLostTurn = false; // hide after 2 seconds
        missedTheirTurn = null;
      });
    });
  }

  void _handleWordSelectionTimeout() {
    if (!mounted) return;
    final navigator = Navigator.of(context, rootNavigator: true);
    // if (_isWordSelectionDialogVisible && navigator.canPop()) {
    //   navigator.pop();
    // }

    _cancelWordSelectionCountdown();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _handleAppResumed();
    }
  }

  Future<void> _handleAppResumed() async {
    if (!mounted) return;
    setState(() => _isResuming = true);
    
    // Clear "catch-up" spam
    ScaffoldMessenger.of(context).clearSnackBars();

    // 1. Validate Room & User Status
    final roomResult = await _roomRepository.getRoomDetails(roomId: widget.roomId);
    
    roomResult.fold(
      (failure) => _showAdAndExit(), // Room gone? Exit.
      (room) {
        final isStillInRoom = room.participants?.any((p) => p.user?.id == _currentUser?.id) ?? false;
        
        if (!isStillInRoom) {
          _showAdAndExit(); // Removed for 3 skips? Exit.
        } else {
          setState(() {
            _room = room;
            _waitingForPlayers = room.status == 'lobby' || room.status == 'waiting';
            _isResuming = false;
          });
          // 2. Sync Drawing if playing
          if (room.status == 'playing') {
            _socketService.socket?.emit('request_canvas_data', {'roomCode': room.code});
          }
        }
      },
    );
  }

  Future<void> _showAdAndExit() async {
    // Show ad and force the "Go Home" behavior
    await _showCloseAdAndNavigate(shouldGoHome: true);
  }

  int _lastDrawingEmitTime = 0;
  // Buffer to hold the active drawing so we don't lose it when the finger lifts.
  fdb.Stroke? _lastInProgressStroke;

  // Drawer game points animation 
  int? _earnedPointsDisplay;
  late AnimationController _pointsAnimationController;
  late Animation<double> _pointsOffsetAnimation;
  late Animation<double> _pointsOpacityAnimation;

  Future<void> _initializeRoom() async {
    try {
      final userResult = await _userRepository.getMe();
      userResult.fold(
        (failure) => print('Failed to get user'),
        (user) => _currentUser = user,
      );

      final roomResult =
          await _roomRepository.getRoomDetails(roomId: widget.roomId);
      roomResult.fold(
        (failure) {
          if (mounted) {
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(
            //       content: Text('Failed to load room: ${failure.message}')),
            // );
            context.pop();
          }
        },
        (room) {
          setState(() {
            _room = room;
            _participants = room.participants ?? [];
            _isLoading = false;
            _waitingForPlayers =
                room.status == 'lobby' || room.status == 'waiting';
            selectedLanguage = room.language;
            // Apply word_script logic: If language is English, script must be 'english'
            if (_isEnglishLanguage(room.language)) {
              selectedScript = 'default';
            } else {
              // For non-English languages, use room.script or default to 'default'
              selectedScript = room.script ?? 'default';
            }
            selectedCountry = room.country;
            selectedPoints = pointsOptions.contains(room.entryPoints)
                ? room.entryPoints
                : pointsOptions.first;
            selectedCategory = room.category;
            selectedGameMode = room.gameMode ?? '1v1';
            voiceEnabled = room.voiceEnabled ?? false;
            isPublic = room.isPublic ?? false;
            // Default to 5 if maxPlayers is null or 0 (for UI display)
            maxPlayers = (room.maxPlayers != null && room.maxPlayers! > 0)
                ? room.maxPlayers!
                : 5;
            // Sync players variable with maxPlayers from room
            players = maxPlayers;
            selectedGamePlay =
                (selectedGameMode == '1v1') ? '1 vs 1' : '2 vs 2';
            _hasShownTeamScoreIntro = false;
            _showTeamScoreboard = false;
          });
          _connectSocket();
          
          // Initialize voice if enabled
          // if (voiceEnabled) {
          //   _initializeVoice();
          // }
          if (selectedGameMode == 'team_vs_team' &&
              !_waitingForPlayers &&
              room.status == 'playing') {
            _playTeamScoreboardIntro(reset: true);
          } else {
            _resetTeamScoreboardAnimation(withSetState: false);
          }
        },
      );

      if (widget.selectedTeam != null) {
        await Future.delayed(const Duration(seconds: 1));
        selectedTeam = widget.selectedTeam!;

        _selectTeam(selectedTeam!);
      }
    } catch (e) {
      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Error: $e')),
        // );
        context.pop();
      }
    }
  }

  // // Initialize voice chat
  // Future<void> _initializeVoice() async {
  //   if (_currentUser?.id == null) return;
  //   PermissionStatus status = await Permission.microphone.request();
  //   if (!(status.isGranted)) return;
  //   final initialized =
  //       await _voiceService.initializeAgoraVoiceSDK(_currentUser!.id!);

  //   (await _agoraRepository.getAgoraToken(
  //           widget.roomId, _currentUser!.id!.toString()))
  //       .fold((ifLeft) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text("Error: Unable to join Audio Channel"),
  //         backgroundColor: Colors.red,
  //         duration: Duration(seconds: 2),
  //       ),
  //     );
  //   }, (token) {
  //     _voiceService.token = token;
  //   });

  //   if (initialized) {
  //     _voiceService.engine!.registerEventHandler(RtcEngineEventHandler(
  //       onAudioVolumeIndication:
  //           (connection, speakers, speakerNumber, totalVolume) {
  //         if (!mounted) return;

  //         final now = DateTime.now();
  //         final Set<int> currentSpeaking = {};

  //         for (var speaker in speakers) {
  //           final uid = speaker.uid ?? 0;
  //           final volume = speaker.volume ?? 0;

  //           _currentVolumes[uid] = volume;

  //           if (volume > _speakingThreshold) {
  //             _lastHeardAt[uid] = now;
  //             currentSpeaking.add(uid);
  //           }
  //         }

  //         _lastHeardAt.removeWhere((uid, lastHeard) {
  //           final elapsed = now.difference(lastHeard);
  //           return elapsed > _speakingTimeout;
  //         });

  //         final newSpeakingSet = _lastHeardAt.keys.toSet();

  //         if (!_setEquals(_speakingInGameUserIds, newSpeakingSet)) {
  //           setState(() {
  //             _speakingInGameUserIds.clear();
  //             _speakingInGameUserIds.addAll(newSpeakingSet);
  //           });
  //         }
  //       },
  //       onUserJoined: (connection, remoteUid, elapsed) {
  //         
  //       },
  //       onJoinChannelSuccess: (connection, elapsed) {
  //         
  //         _voiceService.engine!.setEnableSpeakerphone(true);
  //         _voiceService.engine!.enableAudioVolumeIndication(
  //           interval: 200,
  //           smooth: 3,
  //           reportVad: true,
  //         );
  //       },
  //     ));

  //     // Join the appropriate team channel
  //     if (selectedGameMode == "team_vs_team") {
  //       if (selectedTeam == 'orange') {
  //         _voiceService.joinChannel("${widget.roomId}_orange");
  //       } else {
  //         _voiceService.joinChannel("${widget.roomId}_blue");
  //       }
  //     } else {
  //       _voiceService.joinChannel(widget.roomId);
  //     }

  //     _startSpeakingCleanupTimer();
  //   }
  // }

  // Update the drawer selection handler

// Helper method to compare sets
  bool _setEquals<T>(Set<T> a, Set<T> b) {
    if (a.length != b.length) return false;
    return a.difference(b).isEmpty;
  }

// Periodic cleanup timer for speaking states
  void _startSpeakingCleanupTimer() {
    _speakingCleanupTimer?.cancel();
    _speakingCleanupTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final now = DateTime.now();
      bool needsUpdate = false;

      _lastHeardAt.removeWhere((uid, lastHeard) {
        final elapsed = now.difference(lastHeard);
        if (elapsed > _speakingTimeout) {
          needsUpdate = true;
          return true;
        }
        return false;
      });

      if (needsUpdate) {
        setState(() {
          _speakingInGameUserIds.clear();
          _speakingInGameUserIds.addAll(_lastHeardAt.keys);
        });
      }
    });
  }

  bool _isParticipantSpeaking(RoomParticipant participant) {
    if (!voiceEnabled) return false;
    // Map the participant's user ID (or the participant's Agora UID if available)
    final agoraUid = participant.userId;
    if (agoraUid == null) return false;

    return _speakingInGameUserIds.contains(agoraUid);
  }

  Future<void> _connectSocket() async {
    final token = await LocalStorageUtils.fetchToken();
    if (token == null || token.isEmpty) return;

    _socketService.connect(token);
    _socketService.joinRoom(widget.roomId);

    _socketService.onRoomJoined((data) {
      if (mounted) {
        
        final room = data['room'];
        final participants = data['participants'] as List?;
        setState(() {
          if (participants != null && participants.isNotEmpty) {
            _participants =
                participants.map((p) => RoomParticipant.fromJson(p)).toList();
          }
          if (room != null && room['status'] != null) {
            _waitingForPlayers = room['status'] == 'waiting';
          }
        });
      }
    });

    _socketService.onRoomParticipants((data) {
      if (mounted) {
        
        final participantsData = data['participants'] as List?;
        if (participantsData != null && participantsData.isNotEmpty) {
          final newParticipants =
              participantsData.map((p) => RoomParticipant.fromJson(p)).toList();
          setState(() {
            _participants = newParticipants;
          });
          for (var participant in _participants) {
            if (participant.id == _currentUser?.id) {
              _currentParticipant = participant;
            }
          }
        }
      }
    });

    _socketService.onPlayerJoined((data) {
      if (_isResuming) return; // Prevent laggy snackbar flood during resume
      if (mounted) {
        setState(() {
          _chatMessages
              .add({'type': 'system', 'message': '${data['userName']} joined'});
        });
      }
    });
    _socketService.onPlayerRemoved((data){
      /* Data :
      {
      userId,
      name: user ? user.name : "Guest",
      reason: "failed_to_choose_word",
      }
       */
      if (mounted) {
        final userName = data['name'] ?? 'A player';
        setState(() {
          _chatMessages.add({'type': 'system', 'message': '$userName was removed from the game'});
        });
        // Show snackbar notification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$userName was removed from the game for not selecting a word in a row',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
        _leaveRoom();
      }
    });

    _socketService.onPlayerLeft((data) {
      if (_isResuming) return; // Prevent laggy snackbar flood during resume
      if (mounted) {
        final userName = data['userName'] ?? 'A player';
        setState(() {
          _chatMessages.add({'type': 'system', 'message': '$userName left'});
        });

        // Show snackbar notification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$userName left the game',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });

    _socketService.onDrawingData((data) {
      if (!mounted || _isDrawer) return;
      try {
        if (data is! Map<String, dynamic>) return;

        final strokeData = data['strokes'];
        // Check if this is a finished line or an in-progress one
        // (We will add this flag in the sender below)
        final bool isFinished = (data['isFinished'] as bool?) ?? true;

        if (strokeData is Map<String, dynamic>) {
          final stroke = fdb.Stroke.fromJson(strokeData);
          if (isFinished) {
            // 1. Finalize: Add to the permanent list and clear the temporary 'ghost' stroke
            _strokes.value = List<fdb.Stroke>.from(_strokes.value)..add(stroke);
            _currentStroke.clear();
          } else {
            // 2. Real-time: Update the 'ghost' stroke so guessers see it drawing live
            // We assume _currentStroke is a ValueNotifier<Stroke?> or similar
             // This assumes your CurrentStrokeValueNotifier exposes a setter for value,
             // or you can add a method to set the stroke directly.
             // If direct set isn't available, we force it:
            _currentStroke.value = stroke;
          }
          // _strokes.value = List<fdb.Stroke>.from(_strokes.value)..add(stroke);
        }
      } catch (e) {
        print("Error handling drawing data: $e");
      }
    });

    _socketService.onClearCanvas((data) {
      if (mounted) {
        setState(() {
          _strokes.value = [];
          _currentStroke.clear();
        });
      }
    });

    _socketService.onLobbyTimeExceeded((data) {
      
      final message = data["message"];
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ExitPopUp(
              text: message,
              imagePath: AppImages.inactive,
              onExit: () {
                _leaveRoom();
              },
              continueWaiting: () {
                if (_room != null) {
                  _socketService.continueWaiting(_room!.id.toString());
                }
              });
        },
      );
    });
    _socketService.onChatMessage((data) {
      if (_isResuming) return; // Prevent laggy snackbar flood during resume
      if (mounted) {
        setState(() {
          final user = data['user'];
          final String message = data['content'] ?? '';
          if (message.startsWith(_drawerMessagePrefix)) {
            final String key = message.substring(_drawerMessagePrefix.length);
            _applyDrawerMessage(key);
          } else {
            _chatMessages.add({
              'type': data['type'] ?? 'chat',
              'userName': user != null ? user['name'] : 'Unknown',
              'message': message,
              'avatar': user['avatar'],
              'team': user['team'], // Ensure team is parsed from user object
              'userId': user['id'],
            });
          }
        });
        final String message = data['content'] ?? '';

        final user = data['user'];

        // if (_isDrawer && !message.startsWith(_drawerMessagePrefix)) {
        //   showChatToast(user['name'] ?? 'Unknown', message);
        // }
        if (!message.startsWith(_drawerMessagePrefix)) {
          _scrollToBottom();
        }
      }
    });
    _socketService.onUserBannedFromGame((data) {
      if (_isResuming) return; // Prevent laggy snackbar flood during resume
      /*  message: `${userName} has been banned from the room for multiple reports`,
      bannedUserId: userToBlockId,
      roomId: roomId */
      final message = data['message'] ?? '';
      final user = data['user'];
      final roomId = data['roomId'] ?? '';
      // showChatToast('System', message);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("System: " + message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
    _socketService.onUserKickedFromGame((data) {
      if (_isResuming) return; // Prevent laggy snackbar flood during resume
      /* {
        message: `You have been banned from this room due to multiple reports`,
        roomId: roomId
      } */

      final message = data['message'] ?? '';
      final roomId = data['roomId'] ?? '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );

      _leaveRoom();
    });
    _socketService.onGuessResult((data) {
      if (_isResuming) return; // Prevent laggy snackbar flood during resume
      if (mounted) {
        final isCorrect = data['ok'] == true;
        final message = data['message'] ?? '';
        final guessText = data['guess'] ?? '';
        final avatar = data['avatar'] ?? '';

        if (isCorrect) {
        } else {
          // Update pending message for current user only (incorrect_guess handles broadcast)
          if (guessText.isNotEmpty && message != 'drawer_cannot_guess') {
            setState(() {
              // Remove pending message if exists
              _answersChatMessages.removeWhere((m) =>
                  m['type'] == 'pending' &&
                  m['userName'] == (_currentUser?.name ?? 'You') &&
                  m['message'] == guessText);
              // Add incorrect message (if not already added by incorrect_guess event)
              final existingIndex = _answersChatMessages.indexWhere((m) =>
                  m['message'] == guessText &&
                  m['userName'] == (_currentUser?.name ?? 'You') &&
                  m['type'] == 'incorrect');

              if (existingIndex == -1) {
                print(
                    '${_currentUser?.avatar ?? _currentUser?.profilePicture}');
                _answersChatMessages.add({
                  'type': 'incorrect',
                  'userName': _currentUser?.name ?? 'You',
                  'avatar': avatar,
                  'team': selectedTeam,
                  'message': guessText,
                  'isCorrect': false,
                  'userId': _currentUser?.id?.toString(),
                });
              }

              // Remove user from answered list so input field shows again for incorrect answers
              if (_currentUser?.id != null) {
                _usersWhoAnswered.remove(_currentUser!.id.toString());
              }
            });
            _scrollAnswersToBottom();
          }

          String feedbackMessage = '';
          Color backgroundColor = Colors.orange;

          switch (message) {
            case 'no_active_word':
              feedbackMessage =
                  'No active word to guess. Game hasn\'t started yet.';
              backgroundColor = Colors.blue;
              break;
            case 'drawer_cannot_guess':
              feedbackMessage = 'You are the drawer! You cannot guess.';
              backgroundColor = Colors.purple;
              break;
            case 'not_authenticated':
              feedbackMessage = 'Authentication error. Please reconnect.';
              backgroundColor = Colors.red;
              break;
            case 'not_in_room':
              feedbackMessage = 'You are not in this room.';
              backgroundColor = Colors.red;
              break;
            case 'room_not_found':
              feedbackMessage = 'Room not found.';
              backgroundColor = Colors.red;
              break;
            case 'incorrect':
              feedbackMessage = 'Incorrect guess. Try again!';
              backgroundColor = Colors.orange;
              break;
            default:
              feedbackMessage = 'Guess failed: $message';
              backgroundColor = Colors.red;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(feedbackMessage),
              backgroundColor: backgroundColor,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    });

    _socketService.onSettingsUpdated((data) {
      print(
          '🟢 CLIENT: Received settings_updated event with data: ${data['maxPlayers']}');
      if (mounted) {
        setState(() {
          selectedGameMode = data['gameMode'];
          selectedLanguage = data['language'];
          selectedScript = data['script'];
          selectedCountry = data['country'];
          selectedCategory = data['category'];
          selectedPoints = data['entryPoints'];
          final newVoiceEnabled = data['voiceEnabled'] ?? false;

          // If voice was just enabled, initialize it
          // setState(() {
          //   if (newVoiceEnabled) {
          //     voiceEnabled = newVoiceEnabled;
          //     _initializeVoice();
          //   } else {
          //     voiceEnabled = newVoiceEnabled;
          //     _voiceService.cleanUp();
          //   }
          // });

          isPublic = data['isPublic'] ?? false;
          // Default to 5 if maxPlayers is null or 0 (for UI display)
          maxPlayers = (data['maxPlayers'] != null && data['maxPlayers'] > 0)
              ? data['maxPlayers']
              : 5;
          players = maxPlayers; // Sync players variable with maxPlayers
          
          if (data['status'] != null && _room != null) {
            _room!.status = data['status'];
            _waitingForPlayers =
                data['status'] == 'lobby' || data['status'] == 'waiting';
          }
          if (selectedGameMode != 'team_vs_team' || _waitingForPlayers) {
            _hasShownTeamScoreIntro = false;
          }
          _showTeamScoreboard = false;
          _isLeaderboardVisible = false;
        });
        if (selectedGameMode == 'team_vs_team' &&
            _room?.status == 'playing' &&
            !_waitingForPlayers) {
          _playTeamScoreboardIntro(reset: true);
        } else {
          _resetTeamScoreboardAnimation();
        }
        if (selectedGameMode == 'team_vs_team') {
          _selectTeam('blue'); //default to blue team
        } else {
          selectedGameMode = '1v1';
        }
      }
    });

    _socketService.onGameStart((data) {
      if (mounted) {
        setState(() {
          _waitingForPlayers = false;
          if (_room != null) {
            _room!.status = 'playing';
          }
          _hasShownTeamScoreIntro = false;
          _showTeamScoreboard = false;
          _isLeaderboardVisible = false;
        });
        if (selectedGameMode == 'team_vs_team') {
          _playTeamScoreboardIntro(reset: true);
        } else {
          _resetTeamScoreboardAnimation();
        }
      }
    });

    // Listen for word hints from drawer
    _socketService.onWordHint((data) {
      if (mounted && _currentPhase == 'drawing') {
        setState(() {
          _revealedWord = data['revealedWord'];
          _hintsRemaining = data['hintsRemaining'] ?? _hintsRemaining;
          _showWordHint = true;
        });
      }
    });

    _socketService.onPhaseChange((data) {
      if (mounted) {
        final String? nextPhase = data['phase'] as String?;

        // CRITICAL: Save board size BEFORE any state changes
        final savedSize = _drawerBoardSize != Size.zero
            ? _drawerBoardSize
            : _lastKnownBoardSize;
        final lastPhase = _currentPhase;
        final lastPhaseTimeRemaining = _phaseTimeRemaining;
        setState(() {
          _currentPhase = nextPhase;
          _phaseTimeRemaining = data['duration'] ?? 0;
          _phaseMaxTime = data['duration'] ?? 60;

          if (data['drawer'] is Map<String, dynamic>) {
            _currentDrawerInfo = Map<String, dynamic>.from(
                data['drawer'] as Map<String, dynamic>);
          }

          if (nextPhase == 'drawing') {
            _isIntervalPhase = false;
            _wordHint = data['wordHint'];
            if (_isDrawer) {
              _currentWord = data['word'];
              _currentWordForDashes = null;
            } else {
              _currentWordForDashes = data['wordHint'] ?? data['word'];
            }
            _hintsRemaining = 3;
            _revealedWord = null;
            _showWordHint = false;
            // _chatMessages.clear();
            _currentDrawerMessageKey = null;

            // Clear canvas but PRESERVE size
            _strokes.value = [];
            _currentStroke.clear();
            _undoRedoStack.clear();
            // RESTORE board size immediately!
            _drawerBoardSize = savedSize;
            _lastKnownBoardSize = savedSize;
          } else if (nextPhase == 'reveal') {
            _isIntervalPhase = false;
            _currentWord = data['word'];
            _currentWordForDashes = null;
            _showWordHint = false;
            if (_isDrawer && selectedGameMode == '1v1' && _currentUser != null) {
              final int totalPlayers = _participants.length;
              final int correctGuesses = _usersWhoAnswered.length;
              final int maxPoints = selectedPoints ?? 100;

              if (totalPlayers > 1) {
                // Use ceil to ensure 2.1 or 2.3 becomes 3
                final int earned = ((correctGuesses * 2 * maxPoints) / (totalPlayers-1)).ceil();

                setState(() {
                  _earnedPointsDisplay = earned;
                  final index = _participants.indexWhere((p) => p.user?.id == _currentUser?.id);
                  if (index != -1) {
                    _participants[index].score = (_participants[index].score ?? 0) + earned;
                  }
                });

                // Trigger the floating animation
                _pointsAnimationController.forward(from: 0.0);
              }
            }
            if (_isDrawer) {
              if (lastPhaseTimeRemaining > 2) {
                _announcementManager.startAnnouncementSequence(isTimeUp: false);
              } else {
                _announcementManager.startAnnouncementSequence(isTimeUp: true);
              }
            }
            // DON'T clear canvas during reveal
          } else if (nextPhase == 'interval') {
            setState(() {
              _earnedPointsDisplay = null; // Clear the previous points display
            });
            isAnsweredCorrectly = false;
            _isIntervalPhase = true;
            setState(() {});
            _currentWord = null;
            _wordHint = null;
            _currentWordForDashes = null;
            _answerController.clear();
            _hintsRemaining = 3;
            _revealedWord = null;
            _showWordHint = false;
            // _chatMessages.clear();
            _usersWhoAnswered.clear();
            _currentDrawerMessageKey = null;

            // Clear canvas but PRESERVE size
            _strokes.value = [];
            _currentStroke.clear();
            _undoRedoStack.clear();
            _drawerBoardSize = savedSize;
            _lastKnownBoardSize = savedSize;
          } else if (nextPhase == 'choosing_word') {
            _isIntervalPhase = false;
            _currentWord = null;
            _strokes.value = [];
            _currentStroke.clear();
            _undoRedoStack.clear();
            _drawerBoardSize = savedSize;
            _lastKnownBoardSize = savedSize;
          }
        });
        _showDrawerInfo = false;
        print(
            '📐 Phase changed to $nextPhase. Board size preserved: $_drawerBoardSize');
        if (nextPhase != 'choosing_word') {
          _cancelWordSelectionCountdown();
        }
      }
    });

    _socketService.onDrawerSelected((data) {
      if (mounted) {
        final dynamic drawerData = data['drawer'];
        final Map<String, dynamic>? drawer =
            drawerData is Map<String, dynamic> ? drawerData : null;
        final drawerId = drawer?['id'];
        final bool isDrawer = drawerId == _currentUser?.id;

        final savedDrawerSize = _drawerBoardSize;
        final savedGuesserSize = _guesserBoardSize;

        setState(() {
          _isDrawer = isDrawer;
          _currentDrawerInfo = drawer;
          _currentDrawerMessageKey = null;
          _isLeaderboardVisible = false;

          _strokes.value = [];
          _currentStroke.clear();
          _undoRedoStack.clear();

          _drawerBoardSize = savedDrawerSize;
          _guesserBoardSize = savedGuesserSize;

          // Team mode: Mute drawer, unmute guessers
          // if (selectedGameMode == 'team_vs_team' && voiceEnabled) {
          //   if (_isDrawer) {
          //     _voiceService.toggleMic(muteOption: true); // Mute drawer
          //   } else {
          //     _voiceService.toggleMic(muteOption: false); // Unmute team members
          //   }
          // }

          if (drawer != null) {
            _nextDrawerPreview = Map<String, dynamic>.from(drawer);
          } else {
            _nextDrawerPreview = null;
            _nextDrawerCountdown = 0;
          }
        });

        
        
        

        if (_activeDrawingBoardSize == Size.zero) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              final GlobalKey activeKey =
                  _isDrawer ? _drawerBoardLayoutKey : _guesserBoardLayoutKey;
              final RenderBox? renderBox =
                  activeKey.currentContext?.findRenderObject() as RenderBox?;

              if (renderBox != null && renderBox.hasSize) {
                final capturedSize = renderBox.size;
                setState(() {
                  if (_isDrawer) {
                    _drawerBoardSize = capturedSize;
                  } else {
                    _guesserBoardSize = capturedSize;
                  }
                  _lastKnownBoardSize = capturedSize;
                });
                print(
                    '📐 Board size recaptured after drawer selection: $capturedSize');
              }
            }
          });
        }

        if (drawer != null) {
          final int duration =
              (data['previewDuration'] is int && data['previewDuration'] > 0)
                  ? data['previewDuration'] as int
                  : 5;
          _startNextDrawerCountdown(duration);
        } else {
          _cancelNextDrawerCountdown();
        }
      }
    });
    _socketService.onWordOptions((data) {
      if (mounted && _isDrawer) {
        final List<String> options =
            List<String>.from(data['words'] ?? const <String>[]);
        if (options.isEmpty) return;
        final int duration = (data['duration'] is int && data['duration'] > 0)
            ? data['duration'] as int
            : 10;
        setState(() {
          _wordOptions = options;
        });
        _startWordSelectionCountdown(duration);
        // _showWordSelectionDialog();
      }
    });

    _socketService.onDrawerSkipped((data) {
      if (!mounted) return;
      final skipped = data['drawer'];
      final String skippedName = skipped is Map<String, dynamic>
          ? (skipped['name'] ?? 'Player')
          : 'Player';

      setState(() {
        if (skipped is Map<String, dynamic> &&
            skipped['id'] == _currentUser?.id) {
          _isDrawer = false;
          // if (mounted) {
          //   setState(() {
          //     _voiceService.toggleMic(muteOption: false);
          //   });
          // }
        }
        _wordOptions = null;
        _currentDrawerMessageKey = null;
      });

      _handleWordSelectionTimeout();
      showLostTurnWidget(skippedName);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('$skippedName missed their turn. Selecting next artist...'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    });

    _socketService.onTimeUpdate((data) {
      if (mounted) {
        setState(() {
          _phaseTimeRemaining = data['remainingTime'] ?? 0;
          if (_phaseMaxTime > 0) {
            final double progress = _phaseTimeRemaining / _phaseMaxTime;
            _updateProgressAnimation(progress);
          }
        });
      }
    });

    _socketService.onClearChat((data) {
      if (mounted) {
        setState(() {
          _chatMessages.clear();
        });
      }
    });
    _socketService.onEliminatePlayer((data) {
      /*
    message: `${skipper.user?.name || 'A player'} was eliminated for skipping too many times.`,
        eliminatedParticipant: {
            id: skipper.id,
            userId: skipper.userId,
            roomId: skipper.roomId,
            // Include necessary player data for client UI update
        }
     */
      final message = data["message"];
      final Map<String, dynamic> eliminatedParticipant =  data["eliminatedParticipant"];
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message ?? "Eliminated for inactivity"), backgroundColor: Colors.orange),
        );
      }
      if (eliminatedParticipant["userId"] == _currentDrawerInfo?["id"]) {
        _showAdAndExit();
      }
    });
    _socketService.onGameStarted((data) {
      if (mounted) {
        setState(() {
          _waitingForPlayers = false;
          _isLoading = false;
          if (_room != null) {
            _room!.status = 'playing';
          }
          _hasShownTeamScoreIntro = false;
          _showTeamScoreboard = false;
          _isLeaderboardVisible = false;
        });
        if (selectedGameMode == 'team_vs_team') {
          _playTeamScoreboardIntro(reset: true);
        } else {
          _resetTeamScoreboardAnimation();
        }
      }
    });

    _socketService.onGameEnded((data) {
      if (mounted) {
        setState(() {
          _isGameEnded = true;
        });
        _resetTeamScoreboardAnimation();
        _loadCloseRewardedAd(); // Load ad when game ends
        final rankings = data['rankings'] as List?;
        Future.delayed(const Duration(milliseconds: 7000), () {
          _showGameEndDialog(rankings);
        });
      }
      // if (mounted) {
      //   setState(() {
      //     _voiceService.toggleMic(muteOption: true);
      //   });
      // }
    });

    _socketService.onScoreUpdate((data) {
      if (mounted) {
        setState(() {
          final userId = data['userId'];
          final newScore = data['score'];
          final participantIndex =
              _participants.indexWhere((p) => p.user?.id == userId);
          if (participantIndex != -1) {
            _participants[participantIndex].score = newScore;
          }
        });
      }
    });

    _socketService.onRoundStart((data) {
      if (mounted) {
        setState(() {
          _isDrawer = data['drawer']?['id'] == _currentUser?.id;
          _currentWord = _isDrawer ? data['word'] : null;
          _waitingForPlayers = false;
          // Reset answered users for new round
          _usersWhoAnswered.clear();
          _currentDrawerMessageKey = null;

          // ✅ CLEAR CANVAS on round start
          _strokes.value = [];
          _currentStroke.clear();
          try {
            _undoRedoStack.clear();
          } catch (e) {
            
          }
        });
      }
    });

    _socketService.onCorrectGuess((data) {
      if (_isResuming) return; // Prevent laggy snackbar flood during resume
      if (mounted) {
        final dynamic participant = data['participant'];
        final String teamThatScored = participant['team'] ?? '';
        final int pointsEarned = data['points'] ?? 0;

        // Trigger animation if the current user is on the team that scored
        if (selectedTeam == teamThatScored) {
          setState(() {
            _earnedPointsDisplay = pointsEarned;
            // Optionally mark local state for team-wide celebration
          });
          _pointsAnimationController.forward(from: 0.0);
        }

        final String guessText = data['guess'] ?? '';
        setState(() {
          int? participantId;
          int? participantScore;
          String userName = participant['name'] ?? 'Unknown';

          if (participant is Map<String, dynamic>) {
            if (participant['user'] is Map<String, dynamic>) {
              final Map<String, dynamic> userMap =
                  Map<String, dynamic>.from(participant['user']);
              if (userMap['id'] is int) {
                participantId = userMap['id'] as int;
              }
              if (userMap['name'] is String &&
                  (userMap['name'] as String).trim().isNotEmpty) {
                userName = (userMap['name'] as String).trim();
              }
            }

            if (participantId == null) {
              if (participant['userId'] is int) {
                participantId = participant['userId'] as int;
              } else if (participant['id'] is int) {
                participantId = participant['id'] as int;
              }
            }
            if (participantId.toString() ==
                    _currentParticipant?.id.toString() ||
                participantId.toString() ==
                    _currentParticipant!.user!.id.toString()) {
              isAnsweredCorrectly = true;
            }

            if (participant['score'] is int) {
              participantScore = participant['score'] as int;
            }
            if (participant['name'] is String &&
                (participant['name'] as String).trim().isNotEmpty) {
              userName = (participant['name'] as String).trim();
            }
          }

          final String? participantIdStr = participantId?.toString();

          if (participantId != null) {
            final int index = _participants.indexWhere(
              (p) =>
                  p.userId == participantId ||
                  p.user?.id == participantId ||
                  p.id == participantId,
            );
            if (index != -1) {
              if (participantScore != null) {
                _participants[index].score = participantScore;
              }
              if (userName != 'Unknown') {
                if (_participants[index].user != null) {
                  _participants[index].user!.name = userName;
                } else {
                  _participants[index].user =
                      UserModel(id: participantId, name: userName);
                }
              }
            }
          }

          if (participantIdStr != null) {
            _usersWhoAnswered.add(participantIdStr);
          }

          _answersChatMessages.removeWhere((m) =>
              m['type'] == 'pending' &&
              (participantIdStr == _currentUser?.id?.toString() ||
                  m['userName'] == userName ||
                  m['message'] == guessText));
          
          _answersChatMessages.add({
            'type': 'correct',
            'userName': userName,
            'message': guessText,
            'isCorrect': true,
            'userId': participantIdStr,
            'avatar':
                _currentUser?.profilePicture ?? _currentUser?.avatar ?? '',
            'team': _currentParticipant?.team,
          });
        });

        // Trigger the floating animation near the top score
        _pointsAnimationController.forward(from: 0.0);

        // Show toast notification for drawer
        if (_isDrawer) {
          _showGuessToast(participant['name'] ?? 'Unknown', guessText, true);
        }

        _scrollAnswersToBottom();
      }
    });

    _socketService.onIncorrectGuess((data) {
      if (_isResuming) return; // Prevent laggy snackbar flood during resume
      if (mounted) {
        final guessText = data['guess'] ?? '';
        final user = data['user'];
        final userName = user != null ? user['name'] : 'Unknown';
        final userId = user != null ? user['id']?.toString() : null;

        if (guessText.isNotEmpty) {
          setState(() {
            if (userId == _currentUser?.id?.toString()) {
              _answersChatMessages.removeWhere((m) =>
                  m['type'] == 'pending' &&
                  m['userName'] == (_currentUser?.name ?? 'You') &&
                  m['message'] == guessText);
              if (_currentUser?.id != null) {
                _usersWhoAnswered.remove(_currentUser!.id.toString());
              }
            }

            final existingIndex = _answersChatMessages.indexWhere((m) =>
                m['message'] == guessText &&
                m['userName'] == userName &&
                m['type'] == 'incorrect');

            if (existingIndex == -1) {
              
              _answersChatMessages.add({
                'type': 'incorrect',
                'userName': userName,
                'message': guessText,
                'isCorrect': false,
                'userId': userId,
                'avatar':
                    _currentUser?.profilePicture ?? _currentUser?.avatar ?? '',
                'team': user['team'],
              });
            }
          });

          // Show toast notification for drawer
          if (_isDrawer) {
            _showGuessToast(userName, guessText, false);
          }

          _scrollAnswersToBottom();
        }
      }
    });

    _socketService.onRequestCanvasData((data) async {
      ///  {roomCode: room.code,
      ///  targetSocketId: resumingSocketId }
      
      final canvasData = data as Map<String, dynamic>;
      final roomCode = canvasData['roomCode'];
      final targetSocketId = canvasData['targetSocketId'];
      _socketService.sendCanvasData(
          roomCode,
          targetSocketId,
          _strokes.value.map((e) => e.toJson()).toList(),
          (_phaseTimeRemaining).toDouble());
    });

    _socketService.onCanvasDataReceived((data) async {
      final canvasData = data as Map<String, dynamic>;
      final List<dynamic> historyData = canvasData['history'] as List;
      final List<fdb.Stroke> history = historyData
          .map((e) => fdb.Stroke.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      _room = RoomModel.fromJson(Map<String, dynamic>.from(data['room']));
      _currentPhase = _room?.roundPhase;
      _phaseTimeRemaining = canvasData['remainingTime'];
      if (mounted) {
        _strokes.value = history;
      }
    });
    _socketService.onCanvasClear((data) {
      if (mounted) {
        // Save the current board size BEFORE clearing
        if (_isDrawer) return;
        final savedSize = _drawerBoardSize;

        setState(() {
          _strokes.value = [];
          // Alternative: _drawingPoints = []; // This also works
        });

        // Restore the board size immediately after setState
        _drawerBoardSize = savedSize;

        

        // If size was lost (Size.zero), try to recapture it
        if (_drawerBoardSize == Size.zero) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              final GlobalKey activeKey = _isDrawer
                  ? _drawerBoardLayoutKey // Assuming _isDrawer would lead to expanded board
                  : _guesserBoardLayoutKey;
              final RenderBox? renderBox =
                  activeKey.currentContext?.findRenderObject() as RenderBox?;
              if (renderBox != null && renderBox.hasSize) {
                _drawerBoardSize = renderBox.size;
                print(
                    '📐 Board size recaptured after clear: $_drawerBoardSize');
              }
            }
          });
        }
      }
    });

    _socketService.onRoomClosed((data) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Room closed: ${data['message'] ?? 'No active participants'}'),
            backgroundColor: Colors.orange,
          ),
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.go('/home');
          }
        });
      }
    });

    _socketService.socket?.on('error', (data) {
      
      if (mounted) {
        final message = data['message'] ?? 'Unknown error';
        final details = data['details'] ?? '';

        String errorMessage = '';
        switch (message) {
          case 'only_owner_can_start':
            errorMessage = 'Only the host can start the game';
            break;
          case 'not_enough_players':
            errorMessage = 'Need at least 2 players to start';
            break;
          case 'insufficient_coins':
            errorMessage =
                details.isNotEmpty ? details : 'Insufficient coins to start';
            break;
          case 'both_teams_need_players':
            errorMessage = 'Both teams need at least 2 player';
            break;
          case 'not_team_mode':
            errorMessage = details.isNotEmpty
                ? details
                : 'Team selection is only available in team vs team mode. Please change the game mode first.';
            break;
          case 'game_already_started':
            errorMessage = 'Game has already started';
            break;
          case 'not_authenticated':
            errorMessage = 'Authentication error. Please reconnect.';
            break;
          default:
            errorMessage = 'Error: $message';
        }
        if (mounted) {
          snackbarKey.currentState!.showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_chatScrollController.hasClients) {
        _chatScrollController
            .jumpTo(_chatScrollController.position.maxScrollExtent);
      }
    });
  }

  void _scrollAnswersToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_answersChatScrollController.hasClients) {
        _answersChatScrollController
            .jumpTo(_answersChatScrollController.position.maxScrollExtent);
      }
    });
  }

  void _updateVolumeIcon(double volume) {
    if (!mounted) return;

    // 1. Update the local state (UI slider and icon)
    setState(() {
      _volume = volume.clamp(0.0, 1.0);

      // 2. Map the volume value to the correct icon
      _volumeIcon = _volume == 0.0
          ? Icons.volume_off
          : _volume < 0.3
              ? Icons.volume_down
              : Icons.volume_up;

      // 3. 🎯 ACTION: Set the volume on the game audio player
      // This assumes you have an AudioPlayer instance named _gameAudioPlayer
      try {
        _timeupVideoController?.setVolume(_volume);
        _whosNextVideoController?.setVolume(_volume);
        _welldoneVideoController?.setVolume(_volume);
        _intervalVideoController?.setVolume(_volume);
        _lostTurnVideoController?.setVolume(_volume);
      } catch (e) {
        // Handle the case where the player is not initialized or fails to set volume
        
      }

      // Uncomment and use this block if you are using a dedicated voice service
      // if (voiceEnabled) {
      //  _voiceService.engine!
      //    .adjustPlaybackSignalVolume((volume * 100).toInt());
      // }
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

  void _clearCanvas() {
    final savedSize = _drawerBoardSize;
    _strokes.value = [];
    _currentStroke.clear();
    _undoRedoStack.clear();
    _drawerBoardSize = savedSize;
    _lastKnownBoardSize = savedSize;
    _socketService.clearCanvas(widget.roomId);
  }

  Size _getGuesserBoardSize() {
    final GlobalKey activeKey = _guesserBoardLayoutKey;
    final RenderBox? renderBox =
        activeKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox != null && renderBox.hasSize) {
      // Optionally update the state variable for external use, but only if necessary
      // setState(() { _guesserBoardSize = renderBox.size; });
      return renderBox.size;
    }
    return Size.zero;
  }

  void _sendAnswer() {
    final answer = _answerController.text.trim();
    if (answer.isEmpty || _isDrawer) return;

    // Add to answers chat immediately (will be updated when server confirms)
    setState(() {
      
      _answersChatMessages.add({
        'type': 'pending',
        'userName': _currentUser?.name ?? 'You',
        'message': answer,
        'isCorrect': false,
        'team': selectedTeam,
        'userId': _currentUser?.id?.toString(),
        'avatar': _currentUser?.avatar ?? _currentUser?.profilePicture
      });
      // Mark current user as having answered
      if (_currentUser?.id != null) {
        _usersWhoAnswered.add(_currentUser!.id.toString());
      }
    });
    _scrollAnswersToBottom();

    _socketService.sendGuess(widget.roomId, answer);
    _answerController.clear();
    _answerFocusNode.requestFocus();
  }

  void _sendChatMessage() {
    final message = _chatController.text.trim();
    if (message.isEmpty) return;
    _socketService.sendMessage(widget.roomId, message,
        _currentUser?.avatar ?? _currentUser?.profilePicture ?? '');
    _chatController.clear();
  }

  void _startGame() async {
    // Start the game - backend will deduct coins from all players
    _socketService.startGame(widget.roomId);

    // Wait a moment for backend to process, then refresh user data
    await Future.delayed(const Duration(milliseconds: 1000));
    await _refreshUserData();

    
  }

  void _leaveRoom() async {
    await _roomRepository.leaveRoom(roomId: widget.roomId);
    _socketService.leaveRoom(widget.roomId);
    _socketService.removeAllListeners();
    if (mounted) context.go('/home');
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) {
              setState(() {
                _selectedColor = color;
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void _undo() {
    if (_undoRedoStack.canUndo.value) {
      _undoRedoStack.undo();
      _socketService.clearCanvas(widget.roomId);
      for (final stroke in _strokes.value) {
        _socketService.sendDrawing(widget.roomId, stroke.toJson());
      }
    }
  }

  void _redo() {
    if (_undoRedoStack.canRedo.value) {
      _undoRedoStack.redo();
      _socketService.clearCanvas(widget.roomId);
      for (final stroke in _strokes.value) {
        _socketService.sendDrawing(widget.roomId, stroke.toJson());
      }
    }
  }

  void _showColorPickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2942),
        title:
            const Text('Pick a color', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) {
              setState(() {
                // 1. Get the current opacity before changing the color base
                final double currentOpacity = _selectedColor.opacity;

                // 2. Set the base color (solid version)
                _baseColor = color.withOpacity(1.0);

                // 3. Set the selected color using the new base color and the existing opacity
                _selectedColor = _baseColor.withOpacity(currentOpacity);
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  Widget _showWordSelectionDialog() {
    if (_wordOptions == null || _wordOptions!.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      // height: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Crucial: Shrink vertically
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Your Turn !',
            style: GoogleFonts.comicNeue(
              color: Colors.white,
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          // --- Word Option 1 ---
          _buildWordButton(_wordOptions![0], 0),
          SizedBox(height: 12.h),
          Text(
            'OR',
            style: GoogleFonts.comicNeue(
              color: Colors.white70,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          // --- Word Option 2 ---
          _buildWordButton(_wordOptions![1], 1),
        ],
      ),
    );
  }

  // Helper method to keep _buildWordSelectionDialog clean
  Widget _buildWordButton(String word, int index) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      width: double
          .infinity, // This is fine inside a constrained parent (the Center widget)
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 5.h),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
        onPressed: () {
          _cancelWordSelectionCountdown();
          _socketService.chooseWord(widget.roomId, _wordOptions![index]);

          setState(() {
            _currentWord = _wordOptions?[index];
            _wordOptions = null;
          });
        },
        child: Text(
          word,
          style: TextStyle(
            color: Colors.cyan,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showGameEndDialog(List? rankings) {
    if (rankings == null) return;

    final currentUserRanking = rankings.firstWhere(
      (rank) => rank['userId'] == _currentUser?.id,
      orElse: () => null,
    );

    final coinsWon = currentUserRanking?['coinsAwarded'] ?? 0;

    if (coinsWon > 0) {
      CoinAnimationDialog.show(
        context,
        coinsAwarded: coinsWon,
        onComplete: () {
          final isTeamMode = selectedGameMode == 'team_vs_team';
          List<Team> teams = [];
          if (isTeamMode) {
            int orangeScore = 0;
            int blueScore = 0;
            String? avatarTeamA;
            String? avatarTeamB;
            for (var participant in _participants) {
              if (participant.team == 'orange') {
                orangeScore += participant.score ?? 0;
                if (avatarTeamB != null) avatarTeamB = participant.user?.avatar;
              } else if (participant.team == 'blue') {
                blueScore += participant.score ?? 0;
                if (avatarTeamA != null) avatarTeamA = participant.user?.avatar;
              }
            }
            teams = [
              Team(
                name: "Team A",
                score: blueScore,
                avatar: avatarTeamA ?? AppImages.profile,
              ),
              Team(
                name: "Team B",
                score: orangeScore,
                avatar: avatarTeamB ?? AppImages.profile,
              ),
            ];
          } else {
            _participants.sort((a, b) => b.score!.compareTo(a.score!));

            var topPlayers = _participants.take(3).toList();
            teams = topPlayers.map((player) {
              return Team(
                name: player.user?.name ?? 'Player',
                score: player.score ?? 0,
                avatar: player.user?.avatar ??
                    player.user?.profilePicture ??
                    AppImages.profile,
              );
            }).toList();
          }

          if (teams.isNotEmpty) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.all(16),
                  child: TeamWinnerPopup(
                    teams: teams,
                    isTeamvTeam: isTeamMode,
                    onNext: () {
                      // _toggleLeaderboard(closeRoom: true);
                      Navigator.of(context).pop(); // ✅ Close popup
                      _showCloseAdAndNavigate();   // ✅ Show ad
                    },
                  ),
                );
              },
            );
          }
        },
      );
    } else {
      final isTeamMode = selectedGameMode == 'team_vs_team';
      List<Team> teams = [];
      if (isTeamMode) {
        int orangeScore = 0;
        int blueScore = 0;
        for (var participant in _participants) {
          if (participant.team == 'orange') {
            orangeScore += participant.score ?? 0;
          } else if (participant.team == 'blue') {
            blueScore += participant.score ?? 0;
          }
        }
        teams = [
          Team(
            name: "Alpha",
            score: blueScore,
            avatar: AppImages.profile,
          ),
          Team(
            name: "Beta",
            score: orangeScore,
            avatar: AppImages.profile,
          ),
        ];
      } else {
        _participants.sort((a, b) => b.score!.compareTo(a.score!));
        var topPlayers = _participants.take(3).toList();
        teams = topPlayers.map((player) {
          return Team(
            name: player.user?.name ?? 'Player',
            score: player.score ?? 0,
            avatar: player.user?.avatar ??
                player.user?.profilePicture ??
                AppImages.profile,
          );
        }).toList();
      }

      if (teams.isNotEmpty) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(16),
              child: TeamWinnerPopup(
                teams: teams,
                isTeamvTeam: isTeamMode,
                onNext: () {
                  // _toggleLeaderboard(closeRoom: true);
                  Navigator.of(context).pop(); // ✅ Close popup
                  _showCloseAdAndNavigate();   // ✅ Show ad
                },
              ),
            );
          },
        );
      }
    }
  }

  Future<void> _loadCloseRewardedAd() async {
    if (_isLoadingCloseAd || _closeRewardedAd != null) return;

    setState(() {
      _isLoadingCloseAd = true;
    });

    try {
      await AdService.loadRewardedAd(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _closeRewardedAd = ad;
              _isLoadingCloseAd = false;
            });
            
          }
        },
        onAdFailedToLoad: (error) {
          
          if (mounted) {
            setState(() {
              _isLoadingCloseAd = false;
            });
          }
        },
      );
    } catch (e) {
      
      if (mounted) {
        setState(() {
          _isLoadingCloseAd = false;
        });
      }
    }
  }

  Future<void> _showCloseAdAndNavigate({bool shouldGoHome = false}) async {
    if (_closeRewardedAd == null) {
      if (mounted) {
        shouldGoHome ? context.go('/home') : _toggleLeaderboard(closeRoom: true);
      }
      return;
    }

    try {
      final ad = _closeRewardedAd!;
      _closeRewardedAd = null;

      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (dismissedAd) {
          dismissedAd.dispose();
          if (mounted) {
            shouldGoHome ? context.go('/home') : _toggleLeaderboard(closeRoom: true);
          }
        },
        onAdFailedToShowFullScreenContent: (failedAd, error) {
          
          failedAd.dispose();
          if (mounted) {
            shouldGoHome ? context.go('/home') : _toggleLeaderboard(closeRoom: true);
          }
        },
      );

      
      await ad.show(onUserEarnedReward: (ad, reward) {});
    } catch (e) {
      if (mounted) {
        shouldGoHome ? context.go('/home') : _toggleLeaderboard(closeRoom: true);
      }
    }
  }

  // void _showRankingsDialog(List rankings) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => AlertDialog(
  //       backgroundColor: const Color(0xFF1A2942),
  //       title: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           const Icon(Icons.emoji_events, color: Colors.amber, size: 30),
  //           SizedBox(width: 10.w),
  //           const Text('Game Over!', style: TextStyle(color: Colors.white)),
  //         ],
  //       ),
  //       content: SingleChildScrollView(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             ...rankings.take(3).map((rank) {
  //               final place = rank['place'];
  //               final name = rank['name'] ?? 'Player';
  //               final score = rank['score'] ?? 0;
  //               final coins = rank['coinsAwarded'] ?? 0;

  //               Color medalColor = Colors.grey;
  //               IconData medalIcon = Icons.emoji_events;

  //               if (place == 1) {
  //                 medalColor = Colors.amber;
  //               } else if (place == 2) {
  //                 medalColor = Colors.grey[400]!;
  //               } else if (place == 3) {
  //                 medalColor = Colors.brown;
  //               }

  //               return Container(
  //                 margin: EdgeInsets.only(bottom: 15.h),
  //                 padding: EdgeInsets.all(15.w),
  //                 decoration: BoxDecoration(
  //                   color: place == 1
  //                       ? Colors.amber.withOpacity(0.2)
  //                       : Colors.white.withOpacity(0.1),
  //                   borderRadius: BorderRadius.circular(10.r),
  //                   border: Border.all(color: medalColor, width: 2),
  //                 ),
  //                 child: Row(
  //                   children: [
  //                     Icon(medalIcon, color: medalColor, size: 30),
  //                     SizedBox(width: 10.w),
  //                     Expanded(
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Text(
  //                             name,
  //                             style: const TextStyle(
  //                                 color: Colors.white,
  //                                 fontWeight: FontWeight.bold,
  //                                 fontSize: 16),
  //                           ),
  //                           Text('$score points',
  //                               style: const TextStyle(
  //                                   color: Colors.white70, fontSize: 12)),
  //                         ],
  //                       ),
  //                     ),
  //                     if (coins > 0)
  //                       Container(
  //                         padding: EdgeInsets.symmetric(
  //                             horizontal: 10.w, vertical: 5.h),
  //                         decoration: BoxDecoration(
  //                           color: Colors.amber,
  //                           borderRadius: BorderRadius.circular(15.r),
  //                         ),
  //                         child: Text('+$coins 🪙',
  //                             style: const TextStyle(
  //                                 color: Colors.white,
  //                                 fontWeight: FontWeight.bold)),
  //                       ),
  //                   ],
  //                 ),
  //               );
  //             }),
  //             SizedBox(height: 20.h),
  //             ElevatedButton(
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: Colors.cyan,
  //                 padding:
  //                     EdgeInsets.symmetric(horizontal: 40.w, vertical: 15.h),
  //                 shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(25.r)),
  //               ),
  //               onPressed: () {
  //                 Navigator.pop(context);
  //                 context.go('/home');
  //               },
  //               child: const Text('Back to Home',
  //                   style: TextStyle(
  //                       color: Colors.white,
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.bold)),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _progressAnimationController.dispose();
    _pointsAnimationController.dispose();
    _answerController.dispose();
    _chatController.dispose();
    _chatScrollController.dispose();
    _answersChatScrollController.dispose();
    _answerFocusNode.dispose();
    _chatFocusNode.dispose();
    _sliderTimer?.cancel();
    _nextDrawerTimer?.cancel();
    _wordSelectionTimer?.cancel();
    _teamScoreboardTimer?.cancel();
    _speakingCleanupTimer?.cancel(); // Add this line

    // Properly dispose video controllers
    _timeupVideoController?.pause();
    _timeupVideoController?.dispose();
    _whosNextVideoController?.pause();
    _whosNextVideoController?.dispose();
    _welldoneVideoController?.pause();
    _welldoneVideoController?.dispose();
    _intervalVideoController?.pause();
    _intervalVideoController?.dispose();
    _lostTurnVideoController?.pause();
    _lostTurnVideoController?.dispose();

    _socketService.leaveRoom(widget.roomId);
    _socketService.removeAllListeners();
    // _voiceService.cleanUp();
    _closeRewardedAd?.dispose();
    _strokes.dispose();
    _currentStroke.dispose();
    _showGrid.dispose();
    _backgroundImage.dispose();
    _polygonSides.dispose();
    super.dispose();
  }

  fdb_tool.DrawingTool _getFdbDrawingTool(DrawingTool tool) {
    switch (tool) {
      case DrawingTool.pencil:
      case DrawingTool.colorPicker:
        return fdb_tool.DrawingTool.pencil;
      case DrawingTool.eraser:
        return fdb_tool.DrawingTool.eraser;
      case DrawingTool.circle:
      case DrawingTool.filledCircle:
        return fdb_tool.DrawingTool.circle;
      case DrawingTool.rectangle:
      case DrawingTool.filledRectangle:
        return fdb_tool.DrawingTool.square;
      default:
        return fdb_tool.DrawingTool.pencil;
    }
  }

  bool _isFilled(DrawingTool tool) {
    return tool == DrawingTool.filledCircle ||
        tool == DrawingTool.filledRectangle;
  }

  fdb.StrokeType _getFdbStrokeType(DrawingTool tool) {
    switch (tool) {
      case DrawingTool.eraser:
        return fdb.StrokeType.eraser;
      case DrawingTool.circle:
      case DrawingTool.filledCircle:
        return fdb.StrokeType.circle;
      case DrawingTool.rectangle:
      case DrawingTool.filledRectangle:
        return fdb.StrokeType.square;
      case DrawingTool.pencil:
      case DrawingTool.colorPicker:
        return fdb.StrokeType.normal;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A1628),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                AppImages.bluebackgroundImg,
                fit: BoxFit.cover,
              ),
            ),
            const Center(child: CircularProgressIndicator()),
          ],
        ),
      );
    }

    if (_room?.status == 'lobby' || _waitingForPlayers) {
      return ShowCaseWidget(
        builder: (context) => Builder(builder: (innerContext) {
          return _buildLobbyScreen();
        }),
      );
    }

    return ShowCaseWidget(builder: (context) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        showcasecontext = context;
        final showTutorial = await LocalStorageUtils.showTutorial();
        if ((!_isDrawer) && (!isShowCaseShown) && (showTutorial ?? true)) {
          ShowCaseWidget.of(context).startShowCase([
            showcasekey1,
            showcasekey2,
            showcasekey3,
            showcasekey4,
            showcasekey5,
            showcasekey6
          ]);
          isShowCaseShown = true;
          LocalStorageUtils.setTutorialShown(false);
        }
      });
      return Builder(builder: (innerContext) {
        return Stack( // Use a Stack to layer the loader over the screen
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.1),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOut,
                    )),
                    child: child,
                  ),
                );
              },
              child: _buildGameScreen(),
            ),
            if (_isResuming) 
              Container(
                key: const ValueKey('resuming_overlay'), // Keys help Flutter track changes
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.cyan),
                ),
              ),
          ],
        );
      });
    });
  }

  Widget _buildGameScreen() {
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    // If drawer, show fullscreen drawing board
    if (_isDrawer &&
        !_waitingForPlayers &&
        _room?.status == 'playing' &&
        _currentWord != null) {
      return _buildExpandedDrawingScreen();
    }

    // Original layout for guessers
    final double screenH = MediaQuery.of(context).size.height * 0.48;
    final double boardHeight =
        isKeyboardVisible ? 200.r : screenH.clamp(300.r, 520.r);
    
    return Scaffold(
      key: _gameScreenKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                children: [
                  _buildGameTopBar(),
                  SizedBox(height: 5.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: _buildBoardArea(boardHeight),
                  ),
                  _buildControlsRow(),
                  _buildChatArea(),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
            // _buildSpeakerOverlay(),
            // if (_shouldShowNextDrawerOverlay) _buildNextDrawerOverlay(),
            if (_isLeaderboardVisible &&
                !_shouldShowNextDrawerOverlay )
              _buildLeaderboardOverlay(),
          ],
        ),
      ),
    );
  }

  void _updateProgressAnimation(double targetProgress) {
    final double clampedProgress = targetProgress.clamp(0.0, 1.0);
    _progressAnimation = Tween<double>(
      begin: _progressAnimation.value,
      end: clampedProgress,
    ).animate(
      CurvedAnimation(
        parent: _progressAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _progressAnimationController.forward(from: 0.0);
  }

  Widget _buildExpandedDrawingScreen() {
    final bool isDrawingPhase = !_waitingForPlayers &&
        _room?.status == 'playing' &&
        _currentPhase == 'drawing' &&
        _phaseMaxTime > 0;

    final int remainingSeconds = math.max(
      0,
      math.min(_phaseTimeRemaining, _phaseMaxTime),
    );
    final double progress = isDrawingPhase && _phaseMaxTime > 0
        ? remainingSeconds / _phaseMaxTime
        : 0.0;
    final bool isCritical = isDrawingPhase && remainingSeconds < 20;

    // Update animation smoothly when progress changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateProgressAnimation(progress);
      }
    });

    final String expandedKeyString =
        'expanded_${_currentPhase ?? 'unknown'}_${_isDrawer ? 'drawer' : 'guesser'}';
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        // ⬇️ FIX: Removed the illegal top-level Expanded widget ⬇️
        child: Stack(
          // Stack naturally fills its parent (SafeArea) if not constrained
          children: [
            // This Column handles the primary vertical layout (TopBar + Canvas)
            Column(
              children: [
                _buildGameTopBar(),
                // This inner Expanded is correct because its parent is the Column
                Expanded(
                  child: Container(
                    key: _drawerBoardLayoutKey,
                    margin: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: const Color.fromARGB(255, 38, 37, 37),
                        width: 1,
                      ),
                    ),
                    child: AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return CustomPaint(
                          foregroundPainter: isDrawingPhase &&
                                  _progressAnimation.value > 0
                              ? _PhaseBorderPainter(
                                  progress:
                                      _progressAnimation.value.clamp(0.0, 1.0),
                                  color: isCritical
                                      ? Colors.redAccent
                                      : const Color(0xFF3EE07F),
                                  strokeWidth: 4.w,
                                  borderRadius: 10.r,
                                )
                              : null,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.r),
                            child: Stack(
                              children: [
                                DrawingCanvas(
                                  canvasKey: _canvasKey,
                                  strokesListenable: _strokes,
                                  currentStrokeListenable: _currentStroke,
                                  options: fdb.DrawingCanvasOptions(
                                    // currentTool:
                                    //     _currentTool == DrawingTool.eraser
                                    //         ? fdb_tool.DrawingTool.pencil
                                    //         : _getFdbDrawingTool(_currentTool),
                                    // strokeColor:
                                    //     _currentTool == DrawingTool.eraser
                                    //         ? Colors.black
                                    //         : _selectedColor,
                                    // size: _strokeWidth,
                                    // opacity: _currentTool == DrawingTool.eraser
                                    //     ? 1.0
                                    //     : _selectedColor.opacity,
                                    // backgroundColor: Colors.black,
                                    // showGrid: _showGrid.value,
                                    // fillShape: _isFilled(_currentTool),
                                    // polygonSides: _polygonSides.value,

                                    currentTool: _getFdbDrawingTool(_currentTool),
                                    // 1. COLOR: Force Black (or background color) if Eraser. 
                                    // This ensures "Clean Data" is sent to the server, so other players don't see "Red Eraser" strokes.
                                    strokeColor: _currentTool == DrawingTool.eraser 
                                      ? Colors.black : _selectedColor,
                                    // 2. SIZE: 3x bigger if Eraser
                                    size: _currentTool == DrawingTool.eraser 
                                      ? _strokeWidth * 3.0 : _strokeWidth,
                                    // 3. OPACITY: Force 1.0 (Solid) if Eraser
                                    // This prevents "Transparent Erasing" which looks like gray smudges on other screens.
                                    opacity: _currentTool == DrawingTool.eraser 
                                      ? 1.0 : _selectedColor.opacity,
                                    backgroundColor: Colors.black,
                                    showGrid: _showGrid.value,
                                    fillShape: _isFilled(_currentTool),
                                    polygonSides: _polygonSides.value,
                                  ),

                                  onDrawingStrokeChanged: (stroke) {
                                    // 1. END OF STROKE (User lifted finger)
                                    if (stroke == null) {
                                      // Send the captured stroke, NOT the old history list
                                      if (_lastInProgressStroke != null) {
                                        // Sending the wrapper structure matching our receiver logic
                                        _socketService.socket?.emit('drawing_data', {
                                          'roomId': widget.roomId,
                                          'strokes': _lastInProgressStroke!.toJson(),
                                          'isFinished': true   // Guesser side will now move this to permanent history
                                        });
                                        _lastInProgressStroke = null; // Cleanup
                                      }
                                      return;
                                    }

                                    // 2. ACTIVE DRAWING (User is dragging)
                                    // Simple Throttle: Only send every ~40ms to prevent lag/disconnects
                                    final now = DateTime.now().millisecondsSinceEpoch;
                                    _lastInProgressStroke = stroke; // Capture the stroke

                                    // 1. CHOP LARGE STROKES: If the stroke is getting too heavy, split it.
                                    if (stroke.points.length >= 750) {
                                      // Send this segment as finished
                                      // _sendDrawingUpdate(isFinished: true);
                                      _socketService.socket?.emit('drawing_data', {
                                        'roomId': widget.roomId,
                                        'strokes': stroke.toJson(),
                                        'isFinished': true // Split segment is sent as 'finished'
                                      });
                                      _strokes.value = List<fdb.Stroke>.from(_strokes.value)
                                        ..add(stroke); // Add to local history

                                      // Start a NEW stroke at the last point to continue seamlessly
                                      _currentStroke.startStroke(
                                        stroke.points.last,
                                        color: _currentTool == DrawingTool.eraser
                                          ? Colors.black
                                          : _selectedColor,
                                        size: _currentTool == DrawingTool.eraser
                                          ? _strokeWidth * 3.0
                                          : _strokeWidth,
                                        opacity: _currentTool == DrawingTool.eraser
                                          ? 1.0
                                          : _selectedColor.opacity,
                                        type: _getFdbStrokeType(_currentTool),
                                        filled: _isFilled(_currentTool),
                                      );

                                      // Emit the new stroke immediately so other players see continuous drawing
                                      // instead of waiting for the next 40ms throttle tick.
                                      final newStroke = _currentStroke.value;
                                      if (newStroke != null) {
                                        _socketService.socket?.emit('drawing_data', {
                                          'roomId': widget.roomId,
                                          'strokes': newStroke.toJson(),
                                          'isFinished': false,
                                        });
                                        _lastDrawingEmitTime = now;
                                      }

                                      // CRITICAL FIX: Update the tracking variable to the new empty/started stroke
                                      // so the 'if (stroke == null)' block doesn't resend the old 500 points.
                                      _lastInProgressStroke = null;
                                      return;
                                    }

                                    // 2. REGULAR THROTTLE: Send real-time updates every 40ms
                                    if (now - _lastDrawingEmitTime > 60) {
                                      _lastDrawingEmitTime = now;
                                      // _sendDrawingUpdate(isFinished: false);
                                      _socketService.socket?.emit('drawing_data', {
                                        'roomId': widget.roomId,
                                        'strokes': stroke.toJson(),
                                        'isFinished': false // Guesser updates _currentStroke for live preview
                                      });
                                    }
                                  },
                                  backgroundImageListenable: _backgroundImage,
                                ),
                                // The Word/Hint display is correctly positioned over the Canvas
                                Positioned(
                                  top: 10.h,
                                  left: 0,
                                  right: 0,
                                  child: Center(child: _buildHintSystem()),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            // --- Overlays (Positioned within the main Stack) ---
            // _buildSpeakerOverlay(),

            if (_isLeaderboardVisible &&
                !_shouldShowNextDrawerOverlay )
              _buildLeaderboardOverlay(),

            _buildOptionIcon(),
            _buildDrawingTools(),

            // Show chosen word for drawer at bottom left
            if (_isDrawer && _currentWord != null && _currentPhase == 'drawing')
              Positioned(
                bottom: 80.h,
                left: 16.w,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.draw_outlined,
                        color: Colors.white70,
                        size: 14.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        _currentWord!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
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

// Helper to send drawing update
// void _sendDrawingUpdate({required bool isFinished}) {
//   if (_lastInProgressStroke == null) return;
  
//   _socketService.socket?.emit('drawing_data', {
//     'roomId': widget.roomId,
//     'strokes': _lastInProgressStroke!.toJson(),
//     'isFinished': isFinished
//   });
// }

  void showChatToast(String userName, String message) {
    if (!mounted) return;

    toastification.show(
      context: context,
      title: Text(
        userName,
        style: TextStyle(
          color: Colors.white,
          fontSize: 13.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      description: Text(
        message,
        style: TextStyle(
          color: Colors.white70,
          fontSize: 11.sp,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      type: ToastificationType.info,
      style: ToastificationStyle.fillColored,
      alignment: Alignment.bottomCenter,
      autoCloseDuration: const Duration(seconds: 3),
      showProgressBar: false,
      backgroundColor: Colors.black.withOpacity(0.85),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      borderRadius: BorderRadius.circular(10.r),
      boxShadow: const [
        BoxShadow(
          color: Colors.black38,
          blurRadius: 5,
          offset: Offset(0, 3),
        ),
      ],
    );
  }

  void _showGuessToast(String userName, String guess, bool isCorrect) {
    if (!mounted) return;

    final String message = isCorrect ? '$userName hit!' : '$userName: $guess';

    final overlay = Overlay.of(context);

    // Create an OverlayEntry
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          bottom: 80.h,
          width: MediaQuery.of(context).size.width,
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: 180.w,
                  padding:
                      EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(30, 30, 30, 1),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCorrect ? Icons.check_circle : Icons.close,
                        color: isCorrect ? Colors.green : Colors.red,
                        size: 14.sp,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          message,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    // Insert toast into overlay
    overlay.insert(entry);

    // Remove after 2 seconds with fade-out
    Future.delayed(const Duration(seconds: 2), () {
      entry.remove();
    });
  }

  void _showHintsRemaining(String hints) {
    if (!mounted) return;

    final String message = "Remaining hints: $hints";

    final overlay = Overlay.of(context);

    // Create an OverlayEntry
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          bottom: 80.h,
          width: MediaQuery.of(context).size.width,
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: 180.w,
                  padding:
                      EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(30, 30, 30, 1),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error,
                        color: Colors.grey,
                        size: 14.sp,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          message,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    // Insert toast into overlay
    overlay.insert(entry);

    // Remove after 2 seconds with fade-out
    Future.delayed(const Duration(seconds: 2), () {
      entry.remove();
    });
  }

  Widget _buildIntervalWidget() {
    int orangeScore = 0;
    int blueScore = 0;

    for (var participant in _participants) {
      if (participant.team == 'orange') {
        orangeScore += participant.score ?? 0;
      } else if (participant.team == 'blue') {
        blueScore += participant.score ?? 0;
      }
    }
    const int teamScore = 75; // Example score
    const int targetScore = 100; // Example target
    const String teamLabel = 'B';
    const Color teamColor = Colors.orange;

    Widget buildTeamScorePill({required double maxWidth}) {
      // 1. Calculate the progress ratio (a value between 0.0 and 1.0)
      const double progressRatio =
          targetScore > 0 ? teamScore / targetScore : 0.0;
      // Ensure the width is at least enough to fully contain the badge if score > 0
      final double badgeWidth = 30.w; // Must match the size in teamBadge

      // 2. Calculate the required width for the fill color
      // The total width of the fill should be (progressRatio * maxWidth)
      // We use max(badgeWidth, ...) to ensure the color fill is at least wide enough for the badge.
      final double fillWidth = math.max(badgeWidth, progressRatio * maxWidth);

      return Container(
        // 1. Outer Pill Container (The background/border)
        margin: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
        height: 50.h, // Fixed height for the pill
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(color: Colors.grey, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Distribute children
          children: [
            // 2. The Score Fill Container
            SizedBox(
              // Use the calculated width for the fill
              width: fillWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: teamColor,
                  // Apply rounded corners only on the left side
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(30.r),
                    right: progressRatio == 1.0
                        ? Radius.circular(30.r)
                        : Radius.zero,
                  ),
                ),
                // The Row inside the fill container holds the teamBadge
                child: Row(
                  // Place the badge right at the start (no padding/space here)
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    teamBadge(color: teamColor, label: teamLabel, onTap: () {}),
                    // Add score text or other info here if needed
                  ],
                ),
              ),
            ),

            // 3. Trophy and Spacer (Visible outside the colored fill)
            const Spacer(),
            Image.asset(AppImages.trophy,
                width: 30.w, height: 30.h), // Adjust size if needed
            SizedBox(width: 10.w), // Small padding to keep trophy off the edge
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minWidth: 200.w,
        minHeight: 100.h,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12.h),
          _AnimationVideo(
            controller: _intervalVideoController,
            width: 160.w,
            height: 100.h,
          ),
          SizedBox(height: 12.h),
          Text(
            AppLocalizations.interval.toUpperCase(),
            style: GoogleFonts.fuzzyBubbles(
              color: Colors.white,
              fontSize: 26.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12.h),
          if (!(selectedGameMode == "team_vs_team"))
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: _buildTopThreeLeaders(_participants)),
          if (selectedGameMode == "team_vs_team") SizedBox(height: 12.h),

          if (selectedGameMode == "team_vs_team")
            TeamScoreBar(
                maxScore: _room?.pointsTarget ?? 250,
                barColor: Colors.blue,
                label: 'A',
                labelBgColor: Colors.blue,
                score: blueScore),
          SizedBox(height: 12.h),
          if (selectedGameMode == "team_vs_team")
            TeamScoreBar(
                barColor: Colors.orange,
                label: 'B',
                maxScore: _room?.pointsTarget ?? 250,
                labelBgColor: Colors.orange,
                score: orangeScore),
          // Container(
          //   padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
          //   decoration: BoxDecoration(
          //     color: Colors.white.withOpacity(0.1),
          //     borderRadius: BorderRadius.circular(30.r),
          //     border: Border.all(color: const Color(0xFF25F4EE), width: 1.5),
          //   ),
          //   child: Row(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       Icon(Icons.timer, color: Colors.white, size: 22.sp),
          //       SizedBox(width: 8.w),
          //       Text(
          //         '$countdown',
          //         style: GoogleFonts.lato(
          //           color: Colors.white,
          //           fontSize: 20.sp,
          //           fontWeight: FontWeight.bold,
          //         ),
          //       ),
          //       SizedBox(width: 6.w),
          //       Text(
          //         'seconds',
          //         style: GoogleFonts.lato(
          //           color: Colors.white70,
          //           fontSize: 14.sp,
          //           fontWeight: FontWeight.w500,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildTimeUpWidget() {
    final bool userAnsweredCorrectly =
        _usersWhoAnswered.contains(_currentParticipant!.user!.id.toString());

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minWidth: 200.w,
        minHeight: 100.h,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 24.h),
          _AnimationVideo(
            controller: userAnsweredCorrectly
                ? _welldoneVideoController
                : _timeupVideoController,
            width: 160.w,
            height: 160.h,
          ),
          SizedBox(height: 12.h),
          if (!userAnsweredCorrectly)
            Text(AppLocalizations.timeUp,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                )),
          if (userAnsweredCorrectly)
            Text("You are right!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                )),
          Text("Correct Answer was",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              )),
          _buildLetterDashes(_currentWord ?? "")
        ],
      ),
    );
  }

  Widget _buildSelectingDrawerWidget() {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minWidth: 200.w,
        minHeight: 100.h,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_showDrawerInfo) ...[
              SizedBox(height: 24.h),
              Image.asset(
                _currentDrawerInfo?['avatar'],
                height: 140.h,
                width: 140.w,
              ),
              SizedBox(height: 24.h),
              Text(
                _currentDrawerInfo?['name'],
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.sp,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                AppLocalizations.itsDrawingTime,
                style: TextStyle(
                    color: Colors.cyan,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600),
              ),
            ],
            if (!_showDrawerInfo) ...[
              Text(
                AppLocalizations.whosNext,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24.h),
              _AnimationVideo(
                controller: _whosNextVideoController,
                width: 160.w,
                height: 160.h,
              ),
              // Renders the animated selection
              DrawerSelectionRoller(
                participants: _participants,
                onAnimationComplete: () {
                  if (mounted) {
                    setState(() => _showDrawerInfo = true);
                  }
                },
                selectedDrawerInfo: _currentDrawerInfo!,
                gifPath:
                    AppImages.gif, // Path to your default GIF for the roller
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildLetterDashes(String word) {
    if (word.isEmpty) {
      return const SizedBox.shrink();
    }

    // Base styling (will be scaled down if necessary)
    final double baseBoxWidth = 24.sp; // base container width
    final double baseSpacing = 12.w; // base space between boxes
    final double baseFontSize = 20.sp; // base font size
    const Color letterColor = Colors.white;
    const Color borderColor = Colors.grey;
    const double borderWidth = 1.0;

    final List<String> characters = word.characters.toList();
    final int n = characters.length;

    // Use LayoutBuilder to know how much horizontal space we actually have
    return LayoutBuilder(builder: (context, constraints) {
      // Determine available width: if unconstrained, use screen width as fallback
      final double maxAvailableWidth = (constraints.maxWidth.isFinite)
          ? constraints.maxWidth
          : MediaQuery.of(context).size.width;

      // Calculate required width with base sizes
      final double requiredWidth =
          n * baseBoxWidth + (n - 1) * baseSpacing; // total space needed

      // If required width exceeds available width, compute a scale factor
      double scale = 1.0;
      if (requiredWidth > maxAvailableWidth && requiredWidth > 0) {
        scale = maxAvailableWidth / requiredWidth;
      }

      // Clamp scale so we don't shrink to unreadable sizes
      const double minScale =
          0.45; // tweakable minimum (makes letters still readable)
      scale = scale.clamp(minScale, 1.0);

      // Scaled sizes
      final double boxWidth = baseBoxWidth * scale;
      final double spacing = baseSpacing * scale;
      final double fontSize = baseFontSize * scale;

      // Build letter widgets using scaled sizes
      final letterBoxes = characters.map((char) {
        return Container(
          width: boxWidth,
          alignment: Alignment.center,
          margin: EdgeInsets.only(right: spacing),
          padding: EdgeInsets.only(bottom: 2.h * scale),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: borderColor, width: borderWidth),
            ),
          ),
          child: Text(
            char.toUpperCase(),
            style: TextStyle(
              color: letterColor,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList();

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: letterBoxes,
      );
    });
  }

  Widget _buildLostTurnWidget() {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minWidth: 200.w,
        minHeight: 100.h,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 24.h),
          _AnimationVideo(
            controller: _lostTurnVideoController,
            width: 160.w,
            height: 160.h,
          ),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundImage: const AssetImage(AppImages.profileSelect),
                backgroundColor: Colors.transparent,
              ),
              SizedBox(width: 12.w),
              Text(
                "$missedTheirTurn ${AppLocalizations.missedTheirTurn}",
                style: GoogleFonts.lato(
                  color: Colors.cyan,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Container(
          //   padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
          //   decoration: BoxDecoration(
          //     color: Colors.white.withOpacity(0.1),
          //     borderRadius: BorderRadius.circular(30.r),
          //     border: Border.all(color: const Color(0xFF25F4EE), width: 1.5),
          //   ),
          //   child: Row(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       Icon(Icons.timer, color: Colors.white, size: 22.sp),
          //       SizedBox(width: 8.w),
          //       Text(
          //         '$countdown',
          //         style: GoogleFonts.lato(
          //           color: Colors.white,
          //           fontSize: 20.sp,
          //           fontWeight: FontWeight.bold,
          //         ),
          //       ),
          //       SizedBox(width: 6.w),
          //       Text(
          //         'seconds',
          //         style: GoogleFonts.lato(
          //           color: Colors.white70,
          //           fontSize: 14.sp,
          //           fontWeight: FontWeight.w500,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildNextDrawerOverlay() {
    final String name = (_nextDrawerPreview?['name'] as String?) ?? 'Player';
    final int countdown = _nextDrawerCountdown;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minWidth: 200.w,
        minHeight: 100.h,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'asset/image/next.png',
            width: 160.w,
            height: 160.h,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 24.h),
          Text(
            name,
            style: GoogleFonts.lato(
              color: Colors.white,
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            "It's drawing time, let's rock! 🔥",
            style: GoogleFonts.lato(
              color: const Color(0xFF25F4EE),
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 20.h),
          // Container(
          //   padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
          //   decoration: BoxDecoration(
          //     color: Colors.white.withOpacity(0.1),
          //     borderRadius: BorderRadius.circular(30.r),
          //     border: Border.all(color: const Color(0xFF25F4EE), width: 1.5),
          //   ),
          //   child: Row(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       Icon(Icons.timer, color: Colors.white, size: 22.sp),
          //       SizedBox(width: 8.w),
          //       Text(
          //         '$countdown',
          //         style: GoogleFonts.lato(
          //           color: Colors.white,
          //           fontSize: 20.sp,
          //           fontWeight: FontWeight.bold,
          //         ),
          //       ),
          //       SizedBox(width: 6.w),
          //       Text(
          //         'seconds',
          //         style: GoogleFonts.lato(
          //           color: Colors.white70,
          //           fontSize: 14.sp,
          //           fontWeight: FontWeight.w500,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildPhaseIndicator() {
    String phaseText = '';
    Color phaseColor = Colors.blue;
    IconData phaseIcon = Icons.info;

    switch (_currentPhase) {
      case 'selecting_drawer':
        phaseText = AppLocalizations.selectingDrawer;
        phaseColor = Colors.purple;
        phaseIcon = Icons.person_search;
        break;
      case 'choosing_word':
        phaseText = _isDrawer
            ? AppLocalizations.choosingWord
            : AppLocalizations.drawerIsChoosing;
        phaseColor = Colors.orange;
        phaseIcon = Icons.edit;
        break;
      case 'drawing':
        phaseText = _isDrawer
            ? 'Draw: $_currentWord'
            : (_showWordHint && _revealedWord != null ? _revealedWord! : '');
        phaseColor = Colors.green;
        phaseIcon = _isDrawer ? Icons.brush : Icons.lightbulb;
        break;
      case 'reveal':
        phaseText = 'Word was: $_currentWord';
        phaseColor = Colors.cyan;
        phaseIcon = Icons.visibility;
        break;
      case 'interval':
        phaseText = 'Next round starting...';
        phaseColor = Colors.grey;
        phaseIcon = Icons.timer;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
      decoration: BoxDecoration(
        color: phaseColor.withOpacity(0.2),
        border: Border(bottom: BorderSide(color: phaseColor, width: 2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(phaseIcon, color: phaseColor, size: 24),
          SizedBox(width: 10.w),
          Text(
            phaseText,
            style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 15.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: phaseColor,
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Text(
              '${_phaseTimeRemaining}s',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLobbyScreen() {
    final bool isTablet = MediaQuery.of(context).size.width > 600;
    final isOwner = _currentUser?.id == _room?.ownerId;

    // Filter out current user from participants list

    return BlueBackgroundScaffold(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _leaveRoom,
                          child: const Icon(Icons.arrow_back_ios,
                              color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.h),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        final double controlWidth =
                            (constraints.maxWidth - 10.w) / 2;
                        return Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10.w,
                          runSpacing: 10.w,
                          children: [
                            _buildGradientDropdown(
                              width: controlWidth,
                              hint: 'Word Theme',
                              value: selectedLanguage,
                              items: languages,
                              imageurl: AppImages.mp1,
                              onChanged: isOwner
                                  ? (v) {
                                      setState(() {
                                        selectedLanguage = v;
                                        // Apply word_script logic: If language is English, auto-set script to 'english'
                                        if (_isEnglishLanguage(v)) {
                                          selectedScript = 'english';
                                        } else {
                                          // For non-English languages, default to 'default' if not already set or if switching from English
                                          if (selectedScript == null ||
                                              selectedScript == 'english') {
                                            selectedScript = 'default';
                                          }
                                        }
                                      });
                                      _updateSettings();
                                    }
                                  : null,
                            ),
                            // Hide script dropdown if language is English (word_script must be 'english')
                            if (!_isEnglishLanguage(selectedLanguage))
                              _buildGradientDropdown(
                                width: controlWidth,
                                hint: 'Default',
                                value: selectedScript,
                                items: scripts,
                                imageurl: AppImages.mp2,
                                onChanged: isOwner
                                    ? (v) {
                                        setState(() => selectedScript = v);
                                        _updateSettings();
                                      }
                                    : null,
                              ),
                            // Show placeholder when language is English
                            if (_isEnglishLanguage(selectedLanguage))
                              _buildGradientDropdown(
                                width: controlWidth,
                                hint: 'Word Script',
                                value: 'Default',
                                items: const <String>[
                                  'Word Script: English (auto)'
                                ],
                                imageurl: AppImages.mp2,
                                onChanged: null,
                              ),
                            _buildGradientDropdown(
                              width: controlWidth,
                              hint: 'Country',
                              value: selectedCountry,
                              items: countries,
                              imageurl: AppImages.country,
                              onChanged: isOwner
                                  ? (v) {
                                      setState(() => selectedCountry = v);
                                      _updateSettings();
                                    }
                                  : null,
                            ),
                            _buildGradientDropdown(
                              width: controlWidth,
                              hint: 'Points',
                              value: (selectedPoints ?? 100).toString(),
                              items: pointsOptions
                                  .map((e) => e.toString())
                                  .toList(),
                              imageurl: AppImages.mp3,
                              onChanged: isOwner
                                  ? (v) {
                                      setState(() => selectedPoints =
                                          int.tryParse(v ?? '100'));
                                      _updateSettings();
                                    }
                                  : null,
                            ),
                            _buildGradientDropdown(
                              width: controlWidth,
                              hint: 'Category',
                              value: selectedCategory,
                              items: categories,
                              imageurl: AppImages.mp5,
                              onChanged: isOwner
                                  ? (v) {
                                      setState(() => selectedCategory = v);
                                      _updateSettings();
                                    }
                                  : null,
                            ),
                            _buildGameModeGradientDropdown(
                              width: controlWidth,
                              isOwner: isOwner,
                            ),
                            // _buildCheckboxField(
                            //   width: controlWidth,
                            //   title: 'Voice',
                            //   value: voiceEnabled,
                            //   onChanged: isOwner
                            //       ? (v) {
                            //           (voiceEnabled = v ?? false);
                            //           _updateSettings();
                            //         }
                            //       : null,
                            // ),
                            _buildToggleField(
                              width: controlWidth,
                              title: 'Public',
                              value: isPublic,
                              onChanged: isOwner
                                  ? (v) {
                                      setState(() => isPublic = v);
                                      _updateSettings();
                                    }
                                  : (_) {},
                            ),
                          ],
                        );
                      },
                    ),

                    SizedBox(height: 10.h),

                    // Room code, player count, team color select
                    _buildCreateRoomTopStrip(isOwner),

                    SizedBox(height: 10.h),

                    // Players list panel - Fixed height with scrollable content
                    Container(
                      width: double.infinity,
                      height: 280.h, // Fixed height
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF002547),
                            Color(0xFF002444),
                            Color(0xFF002242),
                            Color(0xFF002548),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(width: 2, color: Colors.blue),
                      ),
                      child: _participants.isEmpty
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 40.h),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      AppImages.waiting,
                                      height: 90.h,
                                      width: 90.w,
                                    ),
                                    SizedBox(height: 10.h),
                                    _buildWaitingText()
                                  ],
                                ),
                              ),
                            )
                          : Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 12.h),
                              child: ListView.builder(
                                itemCount: _participants.length,
                                itemBuilder: (context, index) {
                                  final participant = _participants[index];
                                  final userName =
                                      participant.user?.name ?? 'Guest';

                                  // Determine border color based on game mode and team
                                  Color? borderColor;
                                  if (selectedGameMode == 'team_vs_team') {
                                    // Show team color for team vs team mode
                                    borderColor = participant.team == 'orange'
                                        ? Colors.orange
                                        : participant.team == 'blue'
                                            ? Colors.blue
                                            : null;
                                  }
                                  // No border for 1v1 mode (borderColor stays null)

                                  final userId =
                                      participant.user?.id?.toString() ?? '';
                                  final isSpeaking = voiceEnabled &&
                                      _speakingUserIds.contains(userId);

                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 16.h),
                                    child: Row(
                                      children: [
                                        // Avatar with conditional border and speaking indicator
                                        Stack(
                                          children: [
                                            Container(
                                              width: 50.w,
                                              height: 50.h,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: borderColor != null
                                                    ? Border.all(
                                                        color: borderColor,
                                                        width: 2.w,
                                                      )
                                                    : Border.all(
                                                        color: Colors.blue,
                                                        width: 2.w),
                                                boxShadow: isSpeaking
                                                    ? [
                                                        BoxShadow(
                                                          color: Colors.green
                                                              .withOpacity(0.6),
                                                          blurRadius: 8.r,
                                                          spreadRadius: 2.r,
                                                        ),
                                                      ]
                                                    : null,
                                              ),
                                              child: CircleAvatar(
                                                backgroundColor:
                                                    Colors.transparent,
                                                child: ClipOval(
                                                  clipBehavior: Clip.hardEdge,
                                                  child: participant
                                                              .user?.avatar !=
                                                          null
                                                      ? Image.asset(
                                                          participant
                                                              .user!.avatar!,
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (context, error,
                                                                  stackTrace) {
                                                            return Image.asset(
                                                              AppImages.profile,
                                                              fit: BoxFit.cover,
                                                            );
                                                          },
                                                        )
                                                      : Image.asset(
                                                          AppImages.profile,
                                                          fit: BoxFit.cover,
                                                        ),
                                                ),
                                              ),
                                            ),
                                            // Speaking indicator (mic icon overlay)
                                            if (isSpeaking && voiceEnabled)
                                              Positioned(
                                                bottom: 0,
                                                right: 0,
                                                child: Container(
                                                  width: 18.w,
                                                  height: 18.h,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.green,
                                                    border: Border.all(
                                                      color: Colors.white,
                                                      width: 1.5.w,
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    Icons.mic,
                                                    size: 10.sp,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        SizedBox(width: 12.w),
                                        // Player name
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                userName,
                                                style: GoogleFonts.lato(
                                                  color: Colors.white,
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              // Show "Host" in red if user is the owner
                                              if (participant.user?.id ==
                                                  _room?.ownerId)
                                                Text(
                                                  AppLocalizations.host,
                                                  style: GoogleFonts.lato(
                                                    color: Colors.red,
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.w500,
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
                    ),

                    SizedBox(height: 10.h),

                    // Start / Coins button (UI exact)
                    if (isOwner)
                      GestureDetector(
                        onTap: isOwner
                            ? () {
                                final complete = _isLobbyFormComplete();
                                if (complete) {
                                  _startGame();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Please fill all details')),
                                  );
                                }
                              }
                            : null,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          decoration: BoxDecoration(
                            color: _isLobbyFormComplete()
                                ? const Color.fromARGB(255, 47, 219, 53)
                                : Colors.red,
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _isLobbyFormComplete()
                                  ? Image.asset(AppImages.rocket,
                                      height: 25.h, width: 25.w)
                                  : Image.asset(AppImages.coin,
                                      height: 25.h, width: 25.w),
                              SizedBox(width: 8.w),
                              Text(
                                _isLobbyFormComplete()
                                    ? "Let's go! Room is live"
                                    : '${_calculateEntryCost()}',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            ),
            // Banner Ad - Always at bottom
            if (_isBannerAdLoaded && _bannerAd != null)
              Container(
                width: double.infinity,
                height: 60.h,
                color: Colors.black.withOpacity(0.3),
                child: AdWidget(ad: _bannerAd!),
              )
            else
              Container(
                width: double.infinity,
                height: 60.h,
                color: Colors.grey.withOpacity(0.2),
                child: Center(
                  child: Text(
                    'Loading ads...',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _isLobbyFormComplete() {
    return selectedLanguage != null &&
        selectedScript != null &&
        selectedCountry != null &&
        selectedPoints != null &&
        selectedCategory != null &&
        (selectedGamePlay != null || selectedGameMode != null);
  }

  Widget _buildCreateRoomTopStrip(bool isOwner) {
    final isTeamMode = selectedGameMode == 'team_vs_team';

    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Room code with copy
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: _copyRoomCode,
              child: Container(
                height: 38.h,
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 02.h),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.white, width: 2.w),
                  borderRadius: BorderRadius.circular(25.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(AppImages.copy1, width: 14.w, height: 16.h),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.darkBlue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        height: 40.h,
                        padding: EdgeInsets.symmetric(
                            horizontal: 00.w, vertical: 5.h),
                        child: Center(
                          child: Text(
                            _room?.code ?? 'ad234',
                            style: GoogleFonts.lato(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Image.asset(AppImages.copy, width: 14.w, height: 16.h),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(width: 6.w),

          // Player count +/- 5
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group, size: 18.sp, color: Colors.white),
                SizedBox(width: 6.w),
                Container(
                  height: 38.h,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: Colors.white, width: 2.w),
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: isOwner &&
                                players > _participants.length &&
                                players > 2
                            ? () {
                                setState(() {
                                  players = (players - 1)
                                      .clamp(_participants.length, 15);
                                  maxPlayers = players;
                                });
                                _updateSettings();
                              }
                            : null,
                        child: Container(
                          height: 30.h,
                          // width: 30.w,
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20.h),
                                  bottomLeft: Radius.circular(20.h))),
                          child: Icon(Icons.remove,
                              size: 16.sp,
                              color: (isOwner &&
                                      players > _participants.length &&
                                      players > 2)
                                  ? Colors.white
                                  : Colors.white30),
                        ),
                      ),
                      SizedBox(
                        width: 35.w,
                        height: 35.h,
                        child: Center(
                          child: Text('$players',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16.sp)),
                        ),
                      ),
                      GestureDetector(
                          onTap: isOwner && players < 15
                              ? () {
                                  setState(() {
                                    players = (players + 1).clamp(2, 15);
                                    maxPlayers = players;
                                  });
                                  _updateSettings();
                                }
                              : null,
                          child: Container(
                            height: 30.h,
                            // width: 30.w,
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(20.h),
                                    bottomRight: Radius.circular(20.h))),
                            child: Icon(Icons.add,
                                size: 16.sp, color: Colors.white),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // SizedBox(width: 6.w),

          // Team color arrows (enabled only in team mode)
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: GestureDetector(
                    onTap: isTeamMode
                        ? () => _selectTeam('blue', explicitlyUpdate: true)
                        : null,
                    child: Icon(Icons.arrow_back_ios_new,
                        size: 20.sp,
                        color: isTeamMode ? Colors.white : Colors.white30),
                  ),
                ),
                SizedBox(width: 3.w),
                Container(
                  width: 25.w,
                  height: 25.h,
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 0.9,
                        color: isTeamMode ? Colors.white : Colors.white30),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isTeamMode
                          ? (selectedTeam == 'orange'
                              ? Colors.orange
                              : Colors.blue)
                          : Colors.grey.withOpacity(0.3),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Flexible(
                  child: GestureDetector(
                    onTap: isTeamMode
                        ? () => _selectTeam('orange', explicitlyUpdate: true)
                        : null,
                    child: Icon(Icons.arrow_forward_ios,
                        size: 20.sp,
                        color: isTeamMode ? Colors.white : Colors.white30),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // UI helpers copied to match CreateRoom visuals
  Widget _buildGradientDropdown({
    required double width,
    required String hint,
    required String? value,
    required List<String> items,
    required String imageurl,
    required ValueChanged<String?>? onChanged,
  }) {
    final GlobalKey tapKey = GlobalKey();
    return SizedBox(
      width: width,
      height: 45.h,
      child: Container(
        padding: EdgeInsets.all(1.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.r),
          color: value != null ? Colors.white.withOpacity(0.15) : null,
          border: value == null
              ? Border.all(color: Colors.grey, width: 1.w)
              : Border.all(color: Colors.white, width: 1.w),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: tapKey,
            borderRadius: BorderRadius.circular(23.r),
            onTap: onChanged == null
                ? null
                : () async {
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
                        pos.dy + size.height + gap,
                      ),
                      color: Colors.transparent,
                      constraints: BoxConstraints(
                          minWidth: size.width, maxWidth: size.width),
                      items: [
                        PopupMenuItem<String>(
                          enabled: false,
                          padding: EdgeInsets.zero,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.r),
                              color: Colors.white.withOpacity(0.15),
                            ),
                            padding: EdgeInsets.all(2.w),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(23.r),
                                color: const Color(0xFF0E0E0E),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: items.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final e = entry.value;
                                  return Container(
                                    decoration: index < items.length - 1
                                        ? const BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Color.fromRGBO(
                                                    255, 255, 255, 0.2),
                                                width: 1,
                                              ),
                                            ),
                                          )
                                        : null,
                                    child: InkWell(
                                      onTap: () => Navigator.pop(context, e),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12.w, vertical: 8.h),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            e,
                                            style: GoogleFonts.lato(
                                              color: Colors.white,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w500,
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
                    if (selected != null) {
                      onChanged(selected);
                    }
                  },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(23.r),
                color: const Color(0xFF0E0E0E),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(imageurl, height: 25.h, width: 25.w),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        value ?? hint,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: false,
                        style: GoogleFonts.lato(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: value == null ? Colors.grey : Colors.white,
                        ),
                      ),
                    ),
                    Image.asset(
                      "asset/image/arrow_down.png",
                      height: 16.sp,
                      width: 16.sp,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameModeGradientDropdown({
    required double width,
    required bool isOwner,
  }) {
    final GlobalKey tapKey = GlobalKey();
    final String? displayValue = selectedGameMode == '1v1'
        ? '1v1'
        : selectedGameMode == 'team_vs_team'
            ? 'team_vs_team'
            : null;

    return SizedBox(
      width: width,
      height: 45.h,
      child: Container(
        padding: EdgeInsets.all(1.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.r),
          color: displayValue != null ? Colors.white.withOpacity(0.15) : null,
          border: displayValue == null
              ? Border.all(color: Colors.grey, width: 1.w)
              : Border.all(color: Colors.white, width: 1.w),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: tapKey,
            borderRadius: BorderRadius.circular(23.r),
            onTap: isOwner
                ? () async {
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
                        pos.dy + size.height + gap,
                      ),
                      color: Colors.transparent,
                      constraints: BoxConstraints(
                          minWidth: size.width, maxWidth: size.width),
                      items: [
                        PopupMenuItem<String>(
                          enabled: false,
                          padding: EdgeInsets.zero,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.r),
                              color: Colors.white.withOpacity(0.15),
                            ),
                            padding: EdgeInsets.all(2.w),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(23.r),
                                color: const Color(0xFF0E0E0E),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // 1v1 option
                                  Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Color.fromRGBO(
                                              255, 255, 255, 0.2),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () =>
                                          Navigator.pop(context, '1v1'),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12.w, vertical: 8.h),
                                        child: Center(
                                          child: Text(
                                            AppLocalizations.individual,
                                            style: GoogleFonts.lato(
                                              color: Colors.white,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // team_vs_team option
                                  InkWell(
                                    onTap: () =>
                                        Navigator.pop(context, 'team_vs_team'),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12.w, vertical: 8.h),
                                      child: Center(
                                        child: Text(
                                          AppLocalizations.team,
                                          style: GoogleFonts.lato(
                                            color: Colors.white,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                    if (selected != null) {
                      setState(() {
                        selectedGameMode = selected;
                        selectedGamePlay =
                            (selected == '1v1') ? '1 vs 1' : '2 vs 2';
                      });
                      _updateSettings();
                    }
                  }
                : null,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(23.r),
                color: const Color(0xFF0E0E0E),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(AppImages.mp7, height: 25.h, width: 25.w),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: displayValue == null
                          ? Text(
                              'Game Play',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.lato(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            )
                          : Text(
                              displayValue == '1v1'
                                  ? AppLocalizations.individual
                                  : AppLocalizations.team,
                              style: GoogleFonts.lato(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                    Image.asset(
                      "asset/image/arrow_down.png",
                      height: 16.sp,
                      width: 16.sp,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxField({
    required double width,
    required String title,
    required bool value,
    required ValueChanged<bool?>? onChanged,
  }) {
    return SizedBox(
      width: width,
      height: 45.h,
      child: _gradientShell(
        isActive: value,
        child: InkWell(
          borderRadius: BorderRadius.circular(13.r),
          onTap: onChanged == null ? null : () => onChanged(!value),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.graphic_eq,
                    color: value
                        ? const Color.fromARGB(255, 9, 133, 25)
                        : Colors.grey,
                    size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.lato(
                      color:
                          value ? Colors.white.withOpacity(0.9) : Colors.grey,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Transform.scale(
                  scale: 1.3,
                  child: Checkbox(
                    value: value,
                    onChanged: onChanged,
                    activeColor: const Color.fromARGB(255, 7, 182, 7),
                    checkColor: Colors.black,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleField({
    required double width,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SizedBox(
      width: width,
      height: 45.h,
      child: _gradientShell(
        isActive: value,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_open,
                  color: value
                      ? const Color.fromARGB(255, 220, 228, 223)
                      : Colors.grey,
                  size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.lato(
                    color: value ? Colors.white.withOpacity(0.9) : Colors.grey,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => onChanged(!value),
                child: Image.asset(
                  value ? AppImages.boxtoggleon : AppImages.boxtoggleoff,
                  width: 30.w,
                  height: 35.h,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gradientShell({required Widget child, required bool isActive}) {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.r),
        border: isActive
            ? Border.all(color: Colors.white, width: 1.w)
            : Border.all(color: Colors.grey, width: 1.w),
        color: isActive ? Colors.white.withOpacity(0.15) : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25.r),
        child: BackdropFilter(
          filter: isActive
              ? ImageFilter.blur(sigmaX: 0, sigmaY: 0)
              : ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.r),
              color: const Color(0xFF0E0E0E),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  // Helper method to check if language is English
  bool _isEnglishLanguage(String? language) {
    if (language == null) return false;
    final normalized = language.toLowerCase();
    return normalized == 'english' || normalized == 'en';
  }

  void _updateSettings() {
    if (_currentUser?.id != _room?.ownerId) return;

    // Apply word_script logic: If language is English, script must be 'english'
    String? effectiveScript = selectedScript;
    if (_isEnglishLanguage(selectedLanguage)) {
      effectiveScript = 'default';
      // Also update the state if it's different
      if (selectedScript != 'english') {
        setState(() {
          selectedScript = 'english';
        });
      }
    }

    final settings = {
      'gameMode': selectedGameMode,
      'language': selectedLanguage,
      'script': effectiveScript, // Send word_script as 'script' parameter
      'country': selectedCountry,
      'category': selectedCategory,
      'entryPoints':
          selectedPoints ?? 250, // Entry cost based on selected points
      'targetPoints': selectedPoints, // Points needed to win the game
      'voiceEnabled': voiceEnabled,
      'isPublic': isPublic,
      'maxPlayers': maxPlayers,
    };

    
    _socketService.updateSettings(widget.roomId, settings);
  }

  void _selectTeam(String team, {bool explicitlyUpdate = false}) {
    if (!explicitlyUpdate && selectedTeam != null) return;
    if (selectedGameMode != 'team_vs_team') return;
    if (team == 'A') team = 'blue';
    if (team == 'B') team = 'orange';
    if (team == 'orange') {
      if (selectedTeam == 'orange') {
        team = 'blue';
      }
    } else {
      if (selectedTeam == 'blue') {
        team = 'orange';
      }
    }
    setState(() {
      selectedTeam = team;
      // if (_voiceService.engine != null) {
      //   _voiceService.engine!.leaveChannel();
      //   _voiceService.joinChannel("${widget.roomId}_$selectedTeam");
      // }
    });

    try {
      _socketService.selectTeam(widget.roomId, team);
    } catch (e) {
      // Handle error silently or show a snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to select team. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _copyRoomCode() {
    if (_room?.code != null) {
      Clipboard.setData(ClipboardData(text: _room!.code!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room code copied!')),
      );
    }
  }

  int _calculateEntryCost() {
    // Entry cost based on selected points
    return _room?.entryPoints ?? 250;
  }

// Updated _buildSpeakerOverlay with volume-based glow animation
  Widget _buildSpeakerOverlay() {
    if (_participants.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get all participants with their speaking status
    final allParticipants = _participants.map((p) {
      final uid = p.user?.id == _currentUser?.id ? 0 : (p.userId ?? 0);
      final isSpeaking = _speakingInGameUserIds.contains(uid);
      return {'participant': p, 'isSpeaking': isSpeaking, 'uid': uid};
    }).toList();

    // Separate speakers and non-speakers
    final speakers =
        allParticipants.where((p) => p['isSpeaking'] == true).toList();
    final nonSpeakers =
        allParticipants.where((p) => p['isSpeaking'] == false).toList();

    // Show speakers first, then non-speakers (limit total to prevent overflow)
    const maxVisible = 8; // Maximum avatars to show at once
    final displayList = <Map<String, dynamic>>[];

    // Add all speakers first
    displayList.addAll(speakers);

    // Add non-speakers if there's room
    final remainingSlots = maxVisible - speakers.length;
    if (remainingSlots > 0) {
      displayList.addAll(nonSpeakers.take(remainingSlots));
    }

    if (displayList.isEmpty) return const SizedBox.shrink();

    return Positioned(
      top: 80.h,
      left: 8.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: displayList.map((item) {
          final participant = item['participant'] as RoomParticipant;
          final isSpeaking = item['isSpeaking'] as bool;
          final uid = item['uid'] as int;
          return _buildSpeakerItem(participant, isSpeaking, uid);
        }).toList(),
      ),
    );
  }

  Widget _buildSpeakerItem(
      RoomParticipant participant, bool isSpeaking, int uid) {
    final name = participant.user?.name ?? 'User ${participant.userId}';
    final avatarUrl = participant.user?.avatar;

    // Get current volume for animation (0-255 scale, normalize to 0-1)
    final volume = isSpeaking ? ((_currentVolumes[uid] ?? 0) / 255.0) : 0.0;
    final glowIntensity =
        isSpeaking ? (0.3 + volume * 0.7).clamp(0.3, 1.0) : 0.0;

    return Transform.scale(
      scale: 0.5,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 200),
        tween: Tween(begin: 0.0, end: glowIntensity),
        builder: (context, animValue, child) {
          return Row(
            children: [
              Container(
                width: 50.w,
                height: 50.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: isSpeaking
                      ? [
                          BoxShadow(
                            color: Colors.yellowAccent
                                .withOpacity(animValue * 0.9),
                            blurRadius: 16.r * animValue,
                            spreadRadius: 4.r * animValue,
                          ),
                        ]
                      : null,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSpeaking
                          ? Colors.yellowAccent.withOpacity(animValue)
                          : Colors.white.withOpacity(0.3),
                      width: isSpeaking ? 3.0 : 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child: avatarUrl != null && avatarUrl.isNotEmpty
                        ? Image.asset(
                            avatarUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return _buildDefaultAvatar(name);
                            },
                          )
                        : _buildDefaultAvatar(name),
                  ),
                ),
              ),
              const SizedBox(
                width: 3,
              ),
              Text(
                name,
                style: const TextStyle(color: Colors.white),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildDefaultAvatar(String name) {
    return Container(
      color: Colors.grey[800],
      child: Center(
        child: Text(
          name[0].toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsGrid(bool isOwner) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _buildLobbyDropdown(
              icon: Icons.language,
              hint: 'Language',
              value: selectedLanguage,
              items: languages,
              enabled: isOwner,
              onChanged: (v) {
                setState(() {
                  selectedLanguage = v;
                  // Apply word_script logic: If language is English, auto-set script to 'english'
                  if (_isEnglishLanguage(v)) {
                    selectedScript = 'english';
                  } else {
                    // For non-English languages, default to 'default' if not already set
                    if (selectedScript == null ||
                        selectedScript == 'english' &&
                            !_isEnglishLanguage(selectedLanguage)) {
                      selectedScript = 'default';
                    }
                  }
                });
                _updateSettings();
              },
            )),
            SizedBox(width: 10.w),
            // Hide script dropdown if language is English (word_script must be 'english')
            if (!_isEnglishLanguage(selectedLanguage))
              Expanded(
                  child: _buildLobbyDropdown(
                icon: Icons.text_fields,
                hint: 'Word Script',
                value: selectedScript,
                items: scripts,
                enabled: isOwner,
                onChanged: (v) {
                  setState(() => selectedScript = v);
                  _updateSettings();
                },
              )),
            // Show placeholder when language is English
            if (_isEnglishLanguage(selectedLanguage))
              Expanded(
                child: _buildLobbyDropdown(
                  icon: Icons.text_fields,
                  hint: 'Word Script',
                  value: 'English (auto)',
                  items: const <String>['English (auto)'],
                  enabled: false,
                  onChanged: (_) {},
                ),
              ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
                child: _buildLobbyDropdown(
              icon: Icons.flag,
              hint: 'Country',
              value: selectedCountry,
              items: countries,
              enabled: isOwner,
              onChanged: (v) {
                setState(() => selectedCountry = v);
                _updateSettings();
              },
            )),
            SizedBox(width: 10.w),
            Expanded(
                child: _buildLobbyDropdown(
              icon: Icons.stars,
              hint: 'Points',
              value: selectedPoints?.toString(),
              items: pointsOptions.map((e) => e.toString()).toList(),
              enabled: isOwner,
              onChanged: (v) {
                setState(() => selectedPoints = int.tryParse(v ?? '100'));
                _updateSettings();
              },
            )),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
                child: _buildLobbyDropdown(
              icon: Icons.category,
              hint: 'Category',
              value: selectedCategory,
              items: categories,
              enabled: isOwner,
              onChanged: (v) {
                setState(() => selectedCategory = v);
                _updateSettings();
              },
            )),
            SizedBox(width: 10.w),
            Expanded(child: _buildGameModeDropdown(isOwner)),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
                child: _buildToggle(
              icon: Icons.mic,
              label: 'Voice',
              value: voiceEnabled,
              enabled: isOwner,
              onChanged: (v) {
                setState(() => voiceEnabled = v);
                _updateSettings();
              },
            )),
            SizedBox(width: 10.w),
            Expanded(
                child: _buildToggle(
              icon: Icons.public,
              label: 'Public',
              value: isPublic,
              enabled: isOwner,
              onChanged: (v) {
                setState(() => isPublic = v);
                _updateSettings();
              },
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildLobbyDropdown({
    required IconData icon,
    required String hint,
    required String? value,
    required List<String> items,
    required bool enabled,
    required Function(String?) onChanged,
  }) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F).withOpacity(0.6),
        borderRadius: BorderRadius.circular(25.r),
        border: Border.all(
            color: const Color(0xFF4A90E2).withOpacity(0.4), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                hint: Text(hint,
                    style: TextStyle(color: Colors.white54, fontSize: 13.sp)),
                dropdownColor: const Color(0xFF1A2942),
                style: TextStyle(color: Colors.white, fontSize: 13.sp),
                icon: Icon(Icons.arrow_drop_down,
                    color: const Color(0xFF4A90E2), size: 20.sp),
                items: items
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        enabled: enabled,
                        child: Text(
                          item,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: enabled ? onChanged : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameModeDropdown(bool isOwner) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F).withOpacity(0.6),
        borderRadius: BorderRadius.circular(25.r),
        border: Border.all(
            color: const Color(0xFF4A90E2).withOpacity(0.4), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(Icons.gamepad, color: Colors.white70, size: 18.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedGameMode,
                dropdownColor: const Color(0xFF1A2942),
                style: TextStyle(color: Colors.white, fontSize: 13.sp),
                icon: Icon(Icons.arrow_drop_down,
                    color: const Color(0xFF4A90E2), size: 20.sp),
                items: [
                  DropdownMenuItem(
                      value: '1v1',
                      child: Center(
                        child: Image.asset(
                          AppImages.onevsone,
                          width: 60.w,
                          height: 12.h,
                          fit: BoxFit.contain,
                        ),
                      )),
                  DropdownMenuItem(
                      value: 'team_vs_team',
                      child: Center(
                        child: Image.asset(
                          AppImages.teamvsteam,
                          width: 60.w,
                          height: 12.h,
                          fit: BoxFit.contain,
                        ),
                      )),
                ],
                selectedItemBuilder: (BuildContext context) {
                  return [
                    // Selected item for 1v1
                    Center(
                      child: Image.asset(
                        AppImages.onevsone,
                        width: 50.w,
                        height: 12.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                    // Selected item for team_vs_team
                    Center(
                      child: Image.asset(
                        AppImages.teamvsteam,
                        width: 50.w,
                        height: 12.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ];
                },
                onChanged: isOwner
                    ? (v) async {
                        setState(() => selectedGameMode = v);
                        _updateSettings();
                        
                        if (selectedGameMode == 'team_vs_team') {
                          await Future.delayed(const Duration(milliseconds: 100));
                          selectedTeam = 'blue';
                          _selectTeam('blue', explicitlyUpdate: true);
                        }
                      }
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle({
    required IconData icon,
    required String label,
    required bool value,
    required bool enabled,
    required Function(bool) onChanged,
  }) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F).withOpacity(0.6),
        borderRadius: BorderRadius.circular(25.r),
        border: Border.all(
            color: const Color(0xFF4A90E2).withOpacity(0.4), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(label,
                style: TextStyle(color: Colors.white, fontSize: 13.sp)),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: enabled ? onChanged : null,
              activeThumbColor: Colors.white,
              activeTrackColor: const Color(0xFF4CAF50),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCodeSection() {
    final isOwner = _currentUser?.id == _room?.ownerId;
    final isTeamMode = selectedGameMode == 'team_vs_team';

    return Column(
      children: [
        // Top border line
        Container(
          height: 1.h,
          color: Colors.white.withOpacity(0.2),
        ),
        SizedBox(height: 12.h),
        // Room code + player count + color selector in one row
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Room code
            Flexible(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.white, width: 2.w),
                  borderRadius: BorderRadius.circular(25.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(AppImages.copy1, width: 18.w, height: 22.h),
                    SizedBox(width: 2.w),
                    GestureDetector(
                      onTap: _copyRoomCode,
                      child: Text(
                        _room?.code ?? 'ad234',
                        style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 14.sp,
                            backgroundColor:
                                const Color.fromARGB(255, 91, 174, 212),
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Image.asset(AppImages.copy, width: 18.w, height: 22.h),
                  ],
                ),
              ),
            ),
            SizedBox(width: 5.w),
            // Player count
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person, size: 20.sp, color: Colors.white),
                SizedBox(width: 4.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: Colors.white, width: 2.w),
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: isOwner &&
                                maxPlayers > _participants.length &&
                                maxPlayers > 2
                            ? () {
                                setState(() => maxPlayers -= 1);
                                _updateSettings();
                              }
                            : null,
                        child: Padding(
                          padding: EdgeInsets.all(1.w),
                          child: Icon(Icons.remove,
                              size: 14.sp,
                              color: (isOwner &&
                                      maxPlayers > _participants.length &&
                                      maxPlayers > 2)
                                  ? Colors.white
                                  : Colors.white30),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 1.w, vertical: 1.h),
                        child: Text(
                          "$maxPlayers",
                          style:
                              TextStyle(color: Colors.white, fontSize: 14.sp),
                        ),
                      ),
                      GestureDetector(
                        onTap: isOwner && maxPlayers < 15
                            ? () {
                                setState(() => maxPlayers += 1);
                                _updateSettings();
                              }
                            : null,
                        child: Padding(
                          padding: EdgeInsets.all(2.w),
                          child: Icon(Icons.add,
                              size: 20.sp,
                              color: (isOwner && maxPlayers < 15)
                                  ? Colors.white
                                  : Colors.white30),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(width: 5.w),
            // Color selector (only visible in team mode)
            if (isTeamMode)
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => _selectTeam('blue', explicitlyUpdate: true),
                      child: Icon(Icons.arrow_left,
                          size: 25.sp, color: Colors.white),
                    ),
                    SizedBox(width: 4.w),
                    Container(
                      width: 30.w,
                      height: 30.h,
                      decoration: BoxDecoration(
                        border: Border.all(width: 0.9, color: Colors.white),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Container(
                        decoration: BoxDecoration(
                          color: selectedTeam == null
                              ? Colors.grey
                              : selectedTeam == 'orange'
                                  ? Colors.orange
                                  : Colors.blue,
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    GestureDetector(
                      onTap: () =>
                          _selectTeam('orange', explicitlyUpdate: true),
                      child: Icon(Icons.arrow_right,
                          size: 25.sp, color: Colors.white),
                    ),
                  ],
                ),
              )
            else
              // Disabled color selector for 1v1 mode
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_left, size: 25.sp, color: Colors.white30),
                    SizedBox(width: 4.w),
                    Container(
                      width: 30.w,
                      height: 30.h,
                      decoration: BoxDecoration(
                        border: Border.all(width: 0.9, color: Colors.white30),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.arrow_right, size: 25.sp, color: Colors.white30),
                  ],
                ),
              ),
          ],
        ),
        SizedBox(height: 12.h),
      ],
    );
  }

  void _showThicknessOpacityPopup(TapDownDetails details) async {
    if (!_isDrawer) return;

    final Offset position = details.globalPosition;
    const Color containerBackground =
        Color(0xFF2E3132); // The inner black background of the pop-up

    // Local state for the popup (initial values from global state)
    double localStrokeWidth = _strokeWidth;
    double localOpacity = _selectedColor.opacity;

    // Custom Shapes for SliderThemeData
    final SliderComponentShape largeSolid = EndIconShape(
      radius: 8.0,
      color:
          _baseColor.withOpacity(1.0), // Use solid base color for the thick end
    );

    // FIX: REVERTED to EndIconShape for the left cap of the opacity slider (smallFilled).
    // The RoundSliderWithBorderThumb was causing the TypeError.
    // FIX: This shape must use all required parameters.
    final SliderComponentShape smallFilled = RoundSliderWithBorderThumb(
        thumbRadius: 5.0,
        borderWidth: 2.0,
        outerColor: Colors.white,
        internalBorderColor: Colors.black,
        internalBorderWidth: 0.2,
        innerColor: _baseColor,
        innerCircleRadius: 3);

    // This one is already updated:
    const SliderComponentShape largeHollowRing = RoundSliderWithBorderThumb(
        thumbRadius: 5.0,
        borderWidth: 2.0,
        outerColor: Colors.white,
        innerCircleRadius: 1.2,
        internalBorderColor:
            Colors.black, // Added internalBorderColor here for completeness
        innerColor: Colors.white,
        internalBorderWidth: 4); // Corrected to 1.0 (double)

    // FIX: This shape was missing the parameter.
    const SliderComponentShape smallHollowRing = RoundSliderWithBorderThumb(
      thumbRadius: 5.0,
      borderWidth: 2.0,
      outerColor: Colors.white,
      innerCircleRadius: 3,
      internalBorderColor:
          Colors.black, // Added internalBorderColor here for completeness
      internalBorderWidth: 1.0, // <--- ADDED MISSING PARAMETER
      innerColor: Colors.white,
    );

    // FIX: This shape was missing the parameter.
    const SliderComponentShape centralThumb = RoundSliderWithBorderThumb(
      thumbRadius: 5.0,
      internalBorderColor: Colors.white,
      innerCircleRadius: 1.5,
      innerColor: Colors.black,
      outerColor: Colors.white,
      borderWidth: 2.0,
      internalBorderWidth: 0.5,
    );
    final double verticalOffset = 110.0.h; // Define vertical offset
    final double horizontalOffset = 50.0.w; // Define horizontal offset

    // Show the menu/popup
    await showMenu(
      context: context,
      color: Colors.transparent,
      position: RelativeRect.fromRect(
        (position - Offset(horizontalOffset, verticalOffset)) &
            const Size(1, 1),
        Offset.zero & MediaQuery.of(context).size, // The bounding box (screen)
      ),
      items: [
        PopupMenuItem(
          enabled: false,
          padding: EdgeInsets.zero,
          child: StatefulBuilder(
            builder: (context, dialogSetState) {
              return Container(
                width: 100.w, // Fixed width for the popup
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. Thickness Slider
                    Container(
                      color: containerBackground,
                      margin: const EdgeInsets.all(5),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 4.0,
                            activeTrackColor: Colors.white,
                            inactiveTrackColor: Colors.white,
                            thumbShape: centralThumb,
                            trackShape: CustomTrackWithEndCaps(
                              leftCap: smallHollowRing,
                              rightCap: largeSolid, // Use the solid color shape
                            ),
                            thumbColor: containerBackground,
                            overlayShape: SliderComponentShape.noOverlay,
                            valueIndicatorShape: SliderComponentShape.noThumb,
                          ),
                          child: Slider(
                            value: localStrokeWidth,
                            min: 1.0,
                            max: 10.0,
                            divisions: 9,
                            onChanged: (double value) {
                              dialogSetState(() {
                                localStrokeWidth = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    // 2. Opacity/Alpha Slider
                    Container(
                      color: containerBackground,
                      margin: const EdgeInsets.all(5),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 4.0,
                            activeTrackColor: Colors.white,
                            inactiveTrackColor: Colors.white,
                            thumbShape: centralThumb,
                            trackShape: CustomTrackWithEndCaps(
                              leftCap:
                                  smallFilled, // Now correctly using EndIconShape
                              rightCap:
                                  largeHollowRing, // Use the hollow ring shape
                            ),
                            thumbColor: containerBackground,
                            overlayShape: SliderComponentShape.noOverlay,
                            valueIndicatorShape: SliderComponentShape.noThumb,
                          ),
                          child: Slider(
                            value: localOpacity,
                            min: 0.1,
                            max: 1.0,
                            divisions: 9,
                            onChanged: (double value) {
                              dialogSetState(() {
                                localOpacity = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ).then((result) {
      if (mounted && result != 'dismiss') {
        // Apply the selected thickness and opacity to the main state
        setState(() {
          _strokeWidth = localStrokeWidth;
          // Use the base color and the locally selected opacity
          _selectedColor = _baseColor.withOpacity(localOpacity);
        });
      }
    });
  }

  Widget _buildTeamSelection() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _selectTeam('orange', explicitlyUpdate: true),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 15.h),
              decoration: BoxDecoration(
                color: selectedTeam == 'orange'
                    ? Colors.orange.withOpacity(0.3)
                    : const Color(0xFF1A2942),
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(
                  color: selectedTeam == 'orange'
                      ? Colors.orange
                      : Colors.cyan.withOpacity(0.3),
                  width: selectedTeam == 'orange' ? 3 : 1,
                ),
              ),
              child: const Center(
                child: Text(
                  'Team Orange',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: GestureDetector(
            onTap: () => _selectTeam('blue', explicitlyUpdate: true),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 15.h),
              decoration: BoxDecoration(
                color: selectedTeam == 'blue'
                    ? Colors.blue.withOpacity(0.3)
                    : const Color(0xFF1A2942),
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(
                  color: selectedTeam == 'blue'
                      ? Colors.blue
                      : Colors.cyan.withOpacity(0.3),
                  width: selectedTeam == 'blue' ? 3 : 1,
                ),
              ),
              child: const Center(
                child: Text(
                  'Team Blue',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantsSection(bool isTeamMode) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F).withOpacity(0.4),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
            color: const Color(0xFF4A90E2).withOpacity(0.4), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Player avatars row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // First player (filled) with glow effect
              if (_participants.isNotEmpty)
                Container(
                  width: isTablet ? 60.w : 50.w,
                  height: isTablet ? 60.h : 50.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4A90E2).withOpacity(0.6),
                        blurRadius: 12.r,
                        spreadRadius: 2.r,
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border:
                          Border.all(color: const Color(0xFF4A90E2), width: 2),
                    ),
                    child: Icon(Icons.person,
                        color: const Color(0xFF1E3A5F),
                        size: isTablet ? 32.sp : 28.sp),
                  ),
                )
              else
                Container(
                  width: isTablet ? 60.w : 50.w,
                  height: isTablet ? 60.h : 50.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white30,
                        width: 2,
                        style: BorderStyle.solid),
                  ),
                ),

              SizedBox(width: isTablet ? 16.w : 12.w),

              // Second player placeholder (dashed circle)
              Container(
                width: isTablet ? 60.w : 50.w,
                height: isTablet ? 60.h : 50.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white30,
                      width: 2,
                      style: BorderStyle.solid),
                ),
              ),

              SizedBox(width: isTablet ? 16.w : 12.w),

              // Third player placeholder (dashed circle)
              Container(
                width: isTablet ? 60.w : 50.w,
                height: isTablet ? 60.h : 50.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white30,
                      width: 2,
                      style: BorderStyle.solid),
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // Waiting text with animated dots
          _buildWaitingText(),
        ],
      ),
    );
  }

  Widget _buildWaitingText() {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return StreamBuilder<int>(
      stream:
          Stream.periodic(const Duration(milliseconds: 500), (count) => count),
      builder: (context, snapshot) {
        int dotCount = (snapshot.data ?? 0) % 4;
        String dots = '.' * dotCount;

        return Text(
          'Waiting for players $dots',
          style: TextStyle(
            color: Colors.white,
            fontSize: isTablet ? 18.sp : 16.sp,
            fontWeight: FontWeight.w500,
          ),
        );
      },
    );
  }

  Widget _SpeakingIndicatorOverlay({
    required Widget child,
    required bool isSpeaking,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: isSpeaking
            ? Border.all(color: Colors.greenAccent, width: 2.w)
            : null,
        boxShadow: isSpeaking
            ? [
                BoxShadow(
                  color: Colors.greenAccent.withOpacity(0.5),
                  blurRadius: 8.r,
                  spreadRadius: 2.r,
                )
              ]
            : null,
      ),
      child: child,
    );
  }

  Widget _buildStartButton(bool isOwner, bool canStart) {
    final entryCost = _calculateEntryCost();
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Container(
      width: double.infinity,
      height: isTablet ? 70.h : 56.h,
      decoration: BoxDecoration(
        gradient: canStart && isOwner
            ? const LinearGradient(
                colors: [Color(0xFFE53935), Color(0xFFD32F2F)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : null,
        color: canStart && isOwner ? null : Colors.grey.shade700,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: canStart && isOwner
            ? [
                BoxShadow(
                  color: const Color(0xFFE53935).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canStart && isOwner ? _startGame : null,
          borderRadius: BorderRadius.circular(28.r),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AppImages.coin,
                  width: isTablet ? 35.w : 28.w,
                  height: isTablet ? 35.h : 28.h,
                ),
                SizedBox(width: 8.w),
                Text(
                  '$entryCost',
                  style: TextStyle(
                    fontSize: isTablet ? 26.sp : 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool get _isTeamGamePlaying =>
      !_waitingForPlayers &&
      (_room?.status == 'playing') &&
      selectedGameMode == 'team_vs_team';

  void _resetTeamScoreboardAnimation({bool withSetState = true}) {
    _teamScoreboardTimer?.cancel();
    _hasShownTeamScoreIntro = false;
    _isLeaderboardVisible = false;
    _currentDrawerMessageKey = null;
    if (withSetState && mounted) {
      setState(() {
        _showTeamScoreboard = false;
        _isLeaderboardVisible = false;
        _currentDrawerMessageKey = null;
      });
    } else {
      _showTeamScoreboard = false;
    }
  }

  void _playTeamScoreboardIntro({bool reset = false}) {
    if (reset) {
      _hasShownTeamScoreIntro = false;
    }

    if (!_isTeamGamePlaying) {
      _resetTeamScoreboardAnimation(withSetState: mounted);
      return;
    }

    if (_hasShownTeamScoreIntro) {
      if (!_showTeamScoreboard && mounted) {
        setState(() {
          _showTeamScoreboard = true;
        });
      }
      return;
    }

    _teamScoreboardTimer?.cancel();
    _hasShownTeamScoreIntro = true;

    if (mounted) {
      setState(() {
        _showTeamScoreboard = false;
      });
    } else {
      _showTeamScoreboard = false;
    }

    _teamScoreboardTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      if (_isTeamGamePlaying) {
        setState(() {
          _showTeamScoreboard = true;
        });
      }
    });
  }

  Future<void> _resetGameState() async {
    if (!mounted) return;

    setState(() {
      // Reset game state
      _isGameEnded = false;
      _isDrawer = false;
      _currentWord = null;
      _currentWordForDashes = null;
      _waitingForPlayers = true;

      // Clear drawing data
      _strokes.value = [];
      _currentStroke.clear();
      _undoRedoStack.clear();

      // Clear chat messages
      _chatMessages.clear();
      _answersChatMessages.clear();

      // Reset drawer info
      _currentDrawerInfo = null;
      _nextDrawerPreview = null;
      _currentDrawerMessageKey = null;

      // Reset word selection
      _isWordSelectionDialogVisible = false;
      _isWordSelectionLostTurn = false;
      _wordOptions = null;

      // Reset team scoreboard
      _showTeamScoreboard = false;
      _hasShownTeamScoreIntro = false;
      _isLeaderboardVisible = false;

      // Reset all participants' scores
      for (var participant in _participants) {
        participant.score = 0;
      }

      // Reset timers
      _nextDrawerTimer?.cancel();
      _nextDrawerTimer = null;
      _nextDrawerCountdown = 0;

      _wordSelectionTimer?.cancel();
      _wordSelectionTimer = null;
      _wordSelectionTimeLeft = 0;

      _teamScoreboardTimer?.cancel();
      _teamScoreboardTimer = null;
    });

    // Refresh user data to get updated coin balance
    await _refreshUserData();

    
  }

  Future<void> _refreshUserData() async {
    try {
      final result = await _userRepository.getMe();
      result.fold(
        (failure) {
          
        },
        (user) {
          if (mounted) {
            setState(() {
              _currentUser = user;
            });
            
          }
        },
      );
    } catch (e) {
      
    }
  }

  void _toggleLeaderboard({bool? closeRoom}) {
    if (closeRoom ?? false) {
      setState(() {
        _room?.status = 'lobby';
      });
      // Reset all game data when returning to lobby
      _resetGameState();
    }
    if (_participants.isEmpty) {
      return;
    }
  
    final bool canShow = !_waitingForPlayers && (_room?.status == 'playing');

    if (!canShow) {
      if (_isLeaderboardVisible && mounted) {
        setState(() {
          _isLeaderboardVisible = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLeaderboardVisible = !_isLeaderboardVisible;
      });
    }
    print('Toggling leaderboard visibility. Current state: $_isLeaderboardVisible');
  }

  _DrawerMessageOption? _findDrawerMessageOption(String? key) {
    if (key == null) return null;
    for (final _DrawerMessageOption option in _drawerMessageOptions) {
      if (option.key == key) {
        return option;
      }
    }
    return null;
  }

  void _applyDrawerMessage(String key) {
    final _DrawerMessageOption? option = _findDrawerMessageOption(key);
    if (option == null || !mounted) return;
    setState(() {
      _currentDrawerMessageKey = key;
    });
  }

  Future<void> _showDrawerMessagePicker() async {
    final List<Widget> optionTiles = _drawerMessageOptions
        .map(
          (option) => InkWell(
            borderRadius: BorderRadius.circular(14.r),
            onTap: () {
              Navigator.of(context).pop(option);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
              child: Row(
                children: [
                  Container(
                    width: 28.w,
                    height: 28.h,
                    decoration: BoxDecoration(
                      color: option.accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: Image.asset(
                        option.iconPath,
                        width: 20.w,
                        height: 20.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    option.label,
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .toList();

    final _DrawerMessageOption? selected =
        await showDialog<_DrawerMessageOption>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF101830),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Send Message',
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 16.h),
                ...optionTiles,
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      _handleDrawerMessageSelection(selected);
    }
  }

  void _handleDrawerMessageSelection(_DrawerMessageOption option) {
    if (!mounted) return;
    setState(() {
      _currentDrawerMessageKey = option.key;
    });
    _socketService.sendMessage(
        widget.roomId,
        '$_drawerMessagePrefix${option.key}',
        _currentUser?.avatar ?? _currentUser?.profilePicture ?? '');
  }

  Widget _buildVsBadge({
    double? size,
    Color backgroundColor = Colors.black,
    Color textColor = Colors.white,
  }) {
    final double resolvedSize = size ?? 30.w;
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.2),
      ),
      alignment: Alignment.center,
      child: Text(
        'Vs',
        style: GoogleFonts.lato(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 20.sp,
        ),
      ),
    );
  }

  Widget _buildTeamIntroHeader() {
    return FittedBox(
      key: const ValueKey('team-intro'),
      fit: BoxFit.scaleDown,
      child: SizedBox(
        height: 44.h,
        child: Image.asset(
          AppImages.teamvsteamone,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  void _showTeamPlayers(String teamKey, String teamDisplayLabel) {
    
    final teamPlayers = _participants.where((participant) {
      
      return participant.team == teamKey;
    }).toList();
    teamPlayers.sort((a, b) => (b.score ?? 0).compareTo(a.score ?? 0));
    
    final teamPlayersList = teamPlayers
        .map((participant) => TeamPlayer(
              rank: teamPlayers.indexOf(participant) + 1,
              name: participant.user?.name ?? 'Player',
              avatarPath: participant.user?.avatar ?? AppImages.profile,
              flagEmoji: '🇮🇳',
            ))
        .toList();
    

    if (teamPlayersList.isEmpty) {
      return;
    }

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => TeamDisplayPopup(
        teamName: teamDisplayLabel,
        players: teamPlayersList,
      ),
    );
  }

Widget _buildTeamScoreboardView() {
  int blueScore = 0;
  int orangeScore = 0;

  for (final participant in _participants) {
    if (participant.team == 'blue') {
      blueScore += participant.score ?? 0;
    } else if (participant.team == 'orange') {
      orangeScore += participant.score ?? 0;
    }
  }

  Text buildScoreText(int score) => Text(
        '$score',
        style: GoogleFonts.lato(
          color: Colors.white,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
        ),
      );

  final isTablet = MediaQuery.of(context).size.width > 600;

  return FittedBox(
    fit: BoxFit.scaleDown,
    child: Stack(
      clipBehavior: Clip.none, // Correctly placed to allow points to float up
      alignment: Alignment.center,
      children: [
        // 1. The Main Scoreboard Container
        Container(
          key: ValueKey('team-scoreboard-$blueScore-$orangeScore'),
          decoration: BoxDecoration(
            color: const Color(0xFF0C0C0C),
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(color: Colors.white, width: 1.4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 12.r,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              teamBadge(
                label: 'A',
                color: const Color(0xFF02A9F7),
                onTap: () => _showTeamPlayers('blue', 'Team A'),
                isTablet: isTablet,
              ),
              SizedBox(width: 14.w),
              buildScoreText(blueScore),
              SizedBox(width: 18.w),
              Transform.scale(
                scale: 1.5,
                child: _buildVsBadge(
                  size: 30.h,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                ),
              ),
              SizedBox(width: 18.w),
              buildScoreText(orangeScore),
              SizedBox(width: 14.w),
              teamBadge(
                label: 'B',
                color: const Color(0xFFF59E0B),
                onTap: () => _showTeamPlayers('orange', 'Team B'),
                isTablet: isTablet,
              ),
            ],
          ),
        ),

        // 2. The Floating Points (Direct children of the Stack)
        if (selectedTeam == 'blue' && _earnedPointsDisplay != null)
          _buildFloatingTeamPoints(left: 30.w),

        if (selectedTeam == 'orange' && _earnedPointsDisplay != null)
          _buildFloatingTeamPoints(right: 30.w),
      ],
    ),
  );
}

  Widget _buildFloatingTeamPoints({double? left, double? right}) {
    return Positioned(
      left: left,
      right: right,
      top: -20.h,
      child: AnimatedBuilder(
        animation: _pointsAnimationController,
        builder: (context, child) {
          return Opacity(
            opacity: _pointsOpacityAnimation.value,
            child: Transform.translate(
              offset: Offset(0, _pointsOffsetAnimation.value),
              child: Text(
                '+$_earnedPointsDisplay',
                style: GoogleFonts.lato(
                  color: Colors.greenAccent,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOneVsOneIntro() {
    return FittedBox(
      key: const ValueKey('one-vs-one-intro'),
      fit: BoxFit.scaleDown,
      child: SizedBox(
        height: 44.h,
        child: Image.asset(
          AppImages.onevsone,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildOneVsOneScoreboardView() {
    RoomParticipant? currentParticipant;
    if (_currentUser?.id != null) {
      try {
        currentParticipant = _participants.firstWhere(
          (participant) => participant.user?.id == _currentUser!.id,
        );
      } catch (_) {
        currentParticipant =
            _participants.isNotEmpty ? _participants.first : null;
      }
    } else if (_participants.isNotEmpty) {
      currentParticipant = _participants.first;
    }

    if (currentParticipant == null) {
      return const SizedBox.shrink();
    }

    final String userName = currentParticipant.user?.name ?? 'Player';
    final int score = currentParticipant.score ?? 0;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            key: ValueKey(
                'one-vs-one-${currentParticipant.user?.id ?? 'none'}-$score'),
            margin: EdgeInsets.only(left: 22.w),
            padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 8.h),
            constraints: BoxConstraints(maxWidth: 180.w),
            decoration: BoxDecoration(
              color: const Color(0xFF13131F),
              borderRadius: BorderRadius.circular(24.r),
              border:
                  Border.all(color: Colors.white.withOpacity(0.25), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.45),
                  blurRadius: 10.r,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              userName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 38.w,
              height: 38.h,
              decoration: BoxDecoration(
                color: const Color(0xFF1F1F2A),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.45),
                    blurRadius: 8.r,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                '$score',
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          // Floating Animation (Visible for both Drawer and Guesser)
          if (_earnedPointsDisplay != null && _earnedPointsDisplay! > 0)
            Positioned(
              left: 5.w, // Positioned near the score bubble
              top: 0,
              child: AnimatedBuilder(
                animation: _pointsAnimationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _pointsOffsetAnimation.value),
                    child: Opacity(
                      opacity: _pointsOpacityAnimation.value,
                      child: Text(
                        '+$_earnedPointsDisplay',
                        style: GoogleFonts.lato(
                          color: Colors.greenAccent,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1))],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptionIcon() {
    const double iconHeight = 30;
    const double iconWidth = 30;

    // Base position for the icon
    double baseRight = 16.w;
    double baseBottom = 90.h;

    // Position the menu above the icon.
    // bottom: baseBottom + iconHeight + (small gap, e.g., 5.h)
    // right: baseRight (or adjusted for center alignment if needed)
    final double menuBottom = baseBottom + iconHeight + 5.h;
    final double menuRight = baseRight;

    final List<Widget> optionTiles = [
      InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: () {
          setState(
            () {
              _showOptionMenu = false;
              _handleDrawerMessageSelection(_drawerMessageOptions[0]);
            },
          );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: iconHeight,
                width: iconWidth,
                child: Image.asset(
                  AppImages.correct,
                ),
              ),
              Text(
                'Correct',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                ),
              )
            ],
          ),
        ),
      ),
      InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: () {
          setState(
            () {
              _showOptionMenu = false;
              _handleDrawerMessageSelection(_drawerMessageOptions[1]);
            },
          );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: iconHeight,
                width: iconWidth,
                child: Image.asset(
                  AppImages.wrong,
                ),
              ),
              Text(
                'Wrong',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                ),
              )
            ],
          ),
        ),
      ),
      InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: () {
          setState(
            () {
              _showOptionMenu = false;
              _handleDrawerMessageSelection(_drawerMessageOptions[2]);
            },
          );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: iconHeight,
                width: iconWidth,
                child: Image.asset(
                  AppImages.breakWord,
                ),
              ),
              Text(
                'Break Word',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                ),
              )
            ],
          ),
        ),
      ),
      InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: () {
          setState(
            () {
              _showOptionMenu = false;
              _handleDrawerMessageSelection(_drawerMessageOptions[3]);
            },
          );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: iconHeight,
                width: iconWidth,
                child: Image.asset(
                  AppImages.alternateWord,
                ),
              ),
              Text(
                'Alternate Word',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                ),
              )
            ],
          ),
        ),
      ),
    ];

    return Stack(
      children: [
        // 1. The Menu Container (Positioned Above the Icon)
        if (_showOptionMenu)
          Positioned(
            right: menuRight,
            bottom: menuBottom,
            child: Container(
              // height: menuHeight,
              // width: menuWidth,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    begin: AlignmentGeometry.topCenter,
                    end: AlignmentGeometry.bottomCenter,
                    colors: [
                      Color.fromARGB(255, 19, 23, 55),
                      Color.fromARGB(255, 26, 28, 69)
                    ]),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding:
                        EdgeInsets.symmetric(horizontal: 50.w, vertical: 10.h),
                    child: Text(
                      "Send Message",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  ...optionTiles
                ],
              ),
            ),
          ),

        // 2. The Icon (Positioned at the Base)
        Positioned(
          right: baseRight,
          bottom: baseBottom,
          child: GestureDetector(
            onTap: () {
              // Toggle the visibility of the menu
              setState(() {
                _showOptionMenu = !_showOptionMenu;
              });
            },
            child: SizedBox(
              height: iconHeight,
              width: iconWidth,
              child: Image.asset(AppImages.optionIcon),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardOverlay() {
    final List<RoomParticipant> sortedParticipants =
        List<RoomParticipant>.from(_participants)
          ..sort((a, b) => (b.score ?? 0).compareTo(a.score ?? 0));

    if (sortedParticipants.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<RoomParticipant> topThree = sortedParticipants.length >= 3
        ? sortedParticipants.sublist(0, 3)
        : sortedParticipants;
    final List<RoomParticipant> remaining = sortedParticipants.length > 3
        ? sortedParticipants.sublist(3)
        : <RoomParticipant>[];
    

    final Size size = MediaQuery.of(context).size;
    final double panelWidth = math.min(size.width * 0.88, 360.w);
    final double panelHeight = math.min(size.height * 0.78, 560.h);
    final int? currentUserId = _currentUser?.id;

    return Positioned.fill(
      child: GestureDetector(
        onTap: _toggleLeaderboard,
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: Colors.black.withOpacity(0.75),
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: panelWidth,
                height: panelHeight,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF101026), Color(0xFF080817)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: const Color(0xFF6F3CFF).withOpacity(0.45),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.55),
                      blurRadius: 18.r,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(8.w, 32.h, 8.w, 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Transform.scale(
                            scale: 3.5,
                            child: Image.asset(
                              AppImages.leaderboardBanner,
                              height: 46.h,
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          _buildTopThreeLeaders(topThree),
                          SizedBox(height: 20.h),
                          Expanded(
                              child: Container(
                                  decoration: BoxDecoration(
                                    // color: Colors.white.withOpacity(0.04),
                                    borderRadius: BorderRadius.circular(18.r),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.05),
                                    ),
                                  ),
                                  child: remaining.isEmpty
                                      ? Center(
                                          child: Text(
                                            AppLocalizations.leaderboardUpdates,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.lato(
                                              color: Colors.white70,
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        )
                                      : ListView.separated(
                                          padding: EdgeInsets.zero,
                                          itemCount: remaining.length,
                                          itemBuilder: (context, index) {
                                            final RoomParticipant participant =
                                                remaining[index];
                                            final int rank = index + 4;
                                            final bool isCurrentUser =
                                                participant.user?.id ==
                                                    currentUserId;

                                            return buildLeaderboardRow(
                                              participant,
                                              rank,
                                              isCurrentUser,
                                            );
                                          },
                                          separatorBuilder: (context, index) {
                                            return const Divider(
                                              color: Colors.white24,
                                              thickness: 1,
                                            );
                                          },
                                        ))
                              //  ListView.builder(
                              //     padding: EdgeInsets.symmetric(
                              //         vertical: 12.h, horizontal: 4.w),
                              //     itemCount: remaining.length,
                              //     itemBuilder: (context, index) {
                              //       final RoomParticipant participant =
                              //           remaining[index];
                              //       final int rank = index + 4;
                              //       final bool isCurrentUser =
                              //           participant.user?.id ==
                              //               currentUserId;
                              //       return _buildLeaderboardRow(
                              //         participant,
                              //         rank,
                              //         isCurrentUser,
                              //       );
                              //     },
                              //   ),
                              ),
                        ],
                      ),
                    ),
                    if (_isGameEnded)
                      Positioned(
                        top: 12.h,
                        right: 12.w,
                        child: GestureDetector(
                          onTap: () {
                            _showCloseAdAndNavigate();
                          },
                          child: Container(
                            width: 32.w,
                            height: 32.h,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.18),
                              ),
                            ),
                            child: Icon(
                              Icons.close,
                              size: 18.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopThreeLeaders(List<RoomParticipant> players) {
    if (players.isEmpty) {
      return SizedBox(
        height: 120.h,
        child: Center(
          child: Text(
            AppLocalizations.noPlayersYet,
            style: GoogleFonts.lato(
              color: Colors.white70,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
    players.sort((a, b) => (b.score ?? 0).compareTo(a.score ?? 0));

    RoomParticipant? first = players.isNotEmpty ? players[0] : null;
    RoomParticipant? second = players.length > 1 ? players[1] : null;
    RoomParticipant? third = players.length > 2 ? players[2] : null;

    return SizedBox(
      // height: 150.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: second != null
                ? _buildTopLeaderCard(second, 2)
                : const SizedBox.shrink(),
          ),
          SizedBox(width: 8.w),
          Expanded(
            flex: 2,
            child: first != null
                ? _buildTopLeaderCard(first, 1)
                : const SizedBox.shrink(),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: third != null
                ? _buildTopLeaderCard(third, 3)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopLeaderCard(RoomParticipant participant, int rank) {
    final String name = participant.user?.name?.trim().isNotEmpty == true
        ? participant.user!.name!
        : 'Player';
    final String? avatar = participant.user?.avatar;
    final int score = participant.score ?? 0;

    final bool isFirst = rank == 1;
    final double avatarSize = isFirst ? 76.w : 64.w;
    final double containerWidth = isFirst ? 96.w : 86.w;

    final Color accentColor = rank == 1
        ? const Color(0xFFFFD54F)
        : rank == 2
            ? const Color.fromRGBO(155, 155, 155, 1)
            : const Color.fromRGBO(188, 110, 69, 1);

    return SizedBox(
      width: containerWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withOpacity(0.85),
                      accentColor.withOpacity(0.45),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.45),
                      blurRadius: 14.r,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ),
              _buildLeaderboardAvatar(avatar, avatarSize - 8.w),
              Positioned(
                top: -8.h,
                right: 10.w,
                child: Image.asset(rank == 1
                    ? AppImages.medal1
                    : rank == 2
                        ? AppImages.medal2
                        : AppImages.medal3),
              ),
            ],
          ),
          SizedBox(height: isFirst ? 14.h : 12.h),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              color: Colors.white,
              fontSize: isFirst ? 14.sp : 13.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AppImages.coin,
                width: 14.w,
                height: 14.h,
              ),
              SizedBox(width: 4.w),
              Text(
                '$score',
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildLeaderboardRow(
    RoomParticipant? participant,
    int rank,
    bool isCurrentUser,
  ) {
    final String? name = (participant?.user?.name?.trim().isNotEmpty == true)
        ? participant?.user!.name!
        : "Player";

    final int score = participant?.score ?? 0;

    final String? avatar = participant?.user?.avatar;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? const Color(0xFF0A1628).withOpacity(0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        border: isCurrentUser
            ? Border.all(
                color: const Color(0xFF0A1628).withOpacity(0.4),
                width: 1,
              )
            : null,
      ),
      child: Row(
        children: [
          // Rank Box
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: const Color(0xFF132238),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: GoogleFonts.lato(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SizedBox(width: 16.w),

          // Avatar with border
          if (avatar != null)
            Container(
              padding: EdgeInsets.all(2.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: CircleAvatar(
                radius: 18.r,
                backgroundImage: AssetImage(avatar),
              ),
            ),

          SizedBox(width: 16.w),

          // Name + Flag
          Expanded(
            child: Row(
              children: [
                Text(
                  name ?? "",
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Image.asset(
                  AppImages.flag,
                  width: 24.w,
                  height: 16.h,
                ),
              ],
            ),
          ),

          // Score
          Row(
            children: [
              Image.asset(
                AppImages.coin,
                width: 14.w,
                height: 14.h,
              ),
              SizedBox(width: 4.w),
              Image.asset(
                AppImages.star,
                width: 24.w,
                height: 16.h,
              ),
              const SizedBox(width: 8),
              Text(
                '$score',
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    return Container(
      width: 30.w,
      height: 30.h,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      alignment: Alignment.center,
      child: Text(
        '$rank',
        style: GoogleFonts.lato(
          color: Colors.white,
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildLeaderboardAvatar(String? avatarUrl, double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,

        color: Colors.black,
        // border: Border.all(color: Colors.white, width: size * 0.08),
      ),
      child: ClipOval(
        child: avatarUrl != null && avatarUrl.isNotEmpty
            ? Image.asset(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Image.asset(
                    AppImages.profile,
                    fit: BoxFit.cover,
                  );
                },
              )
            : Image.asset(
                AppImages.profile,
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  Widget _buildGameTopBar() {
    final roomId = _room?.code ?? '—';
    final isTeamMode = selectedGameMode == 'team_vs_team';
    final bool isPlaying = !_waitingForPlayers && (_room?.status == 'playing');

    final Widget centerContent;
    if (isTeamMode) {
      centerContent = isPlaying && _showTeamScoreboard
          ? _buildTeamScoreboardView()
          : _buildTeamIntroHeader();
    } else {
      centerContent =
          isPlaying ? _buildOneVsOneScoreboardView() : _buildOneVsOneIntro();
    }

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
            // Wrap the Room ID Pill (representing the current user) with the Speaking Indicator
            _SpeakingIndicatorOverlay(
              isSpeaking: voiceEnabled &&
                  _speakingInGameUserIds.contains(_currentUser?.id),
              child: Showcase(
                  descriptionAlignment: Alignment.centerLeft,
                  tooltipActions: [
                    TooltipActionButton(
                      name: 'skip',
                      backgroundColor: Colors.white,
                      textStyle: const TextStyle(color: Colors.grey),
                      type: TooltipDefaultActionType.skip,
                      onTap: () => ShowcaseView.get().dismiss(),
                    ),
                    TooltipActionButton(
                      name: 'Next',
                      tailIcon: const ActionButtonIcon(
                        icon: Icon(Icons.arrow_forward_ios, size: 12),
                      ),
                      type: TooltipDefaultActionType.next,
                      backgroundColor: Colors.white,
                      textStyle: const TextStyle(color: Colors.black),
                      onTap: () => ShowcaseView.get().next(),
                    ),
                  ],
                  overlayColor: const Color.fromRGBO(116, 116, 116, 0.63),
                  showArrow: false,
                  toolTipMargin: 21,
                  tooltipPadding: const EdgeInsets.all(12),
                  description: "Click to View room name and teams",
                  key: showcasekey2,
                  child: _copyableRoomIdPill(roomId)),
            ),
            SizedBox(width: 5.w),
            Expanded(
              child: Center(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: (isPlaying && _participants.isNotEmpty)
                      ? _toggleLeaderboard
                      : null,
                  child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        final Animation<double> curved = CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        );
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(scale: curved, child: child),
                        );
                      },
                      child: Showcase(
                        descriptionAlignment: Alignment.centerLeft,
                        tooltipActions: [
                          TooltipActionButton(
                            name: 'skip',
                            backgroundColor: Colors.white,
                            textStyle: const TextStyle(color: Colors.grey),
                            type: TooltipDefaultActionType.skip,
                            onTap: () => ShowcaseView.get().dismiss(),
                          ),
                          TooltipActionButton(
                            name: 'Next',
                            tailIcon: const ActionButtonIcon(
                              icon: Icon(Icons.arrow_forward_ios, size: 12),
                            ),
                            type: TooltipDefaultActionType.next,
                            backgroundColor: Colors.white,
                            textStyle: const TextStyle(color: Colors.black),
                            onTap: () => ShowcaseView.get().next(),
                          ),
                        ],

                        overlayColor: const Color.fromRGBO(116, 116, 116, 0.63),
                        showArrow: false,
                        toolTipMargin: 21,
                        tooltipPadding: const EdgeInsets.all(12),
                        key: showcasekey1,
                        description: "Click to View top players and scores",

                        /// 👇 ADD width + height here
                        child: Center(child: centerContent),
                      )),
                ),
              ),
            ),
            SizedBox(width: 5.w),
            GestureDetector(
              onTap: () {
                 _toggleLeaderboard();
                 return;
                List<Team> teams = [];
                if (isTeamMode) {
                  int orangeScore = 0;
                  int blueScore = 0;
                  String? avatarTeamA;
                  String? avatarTeamB;
                  for (var participant in _participants) {
                    if (participant.team == 'orange') {
                      orangeScore += participant.score ?? 0;
                      if (avatarTeamB != null) {
                        avatarTeamB = participant.user?.avatar ??
                            participant.user?.profilePicture;
                      }
                    } else if (participant.team == 'blue') {
                      blueScore += participant.score ?? 0;
                      if (avatarTeamA != null) {
                        avatarTeamA = participant.user?.avatar ??
                            participant.user?.profilePicture;
                      }
                    }
                  }
                  teams = [
                    Team(
                      name: "Team A",
                      score: blueScore,
                      avatar: avatarTeamA ?? AppImages.profile,
                    ),
                    Team(
                      name: "Team B",
                      score: orangeScore,
                      avatar: avatarTeamB ?? AppImages.profile,
                    ),
                  ];
                } else {
                  _participants.sort((a, b) => b.score!.compareTo(a.score!));
                  var topPlayers = _participants.take(3).toList();
                  teams = topPlayers.map((player) {
                    return Team(
                      name: player.user?.name ?? 'Player',
                      score: player.score ?? 0,
                      avatar: player.user?.avatar ??
                          player.user?.profilePicture ??
                          AppImages.profile,
                    );
                  }).toList();
                }

                if (teams.isNotEmpty) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return Dialog(
                        backgroundColor: Colors.transparent,
                        insetPadding: const EdgeInsets.all(16),
                        child: TeamWinnerPopup(
                          teams: teams,
                          isTeamvTeam: isTeamMode,
                          onNext: () {
                            _toggleLeaderboard();
                          },
                        ),
                      );
                    },
                  );
                }
              },
              child: Showcase(
                targetBorderRadius: BorderRadius.circular(20),
                tooltipBackgroundColor: Colors.white,
                descriptionAlignment: Alignment.centerLeft,
                tooltipActions: [
                  TooltipActionButton(
                    name: 'skip',
                    backgroundColor: Colors.white,
                    textStyle: const TextStyle(color: Colors.grey),
                    type: TooltipDefaultActionType.skip,
                    onTap: () => ShowcaseView.get().dismiss(),
                  ),
                  TooltipActionButton(
                    name: 'Next',
                    tailIcon: const ActionButtonIcon(
                      icon: Icon(Icons.arrow_forward_ios, size: 12),
                    ),
                    type: TooltipDefaultActionType.next,
                    backgroundColor: Colors.white,
                    textStyle: const TextStyle(color: Colors.black),
                    onTap: () => ShowcaseView.get().next(),
                  ),
                ],
                overlayColor: const Color.fromRGBO(116, 116, 116, 0.63),
                showArrow: false,
                toolTipMargin: 21,
                tooltipPadding: const EdgeInsets.all(12),
                description: "Click to see the room status",
                key: showcasekey3,
                child: _pill(
                    (isPublic)
                        ? AppLocalizations.public
                        : AppLocalizations.private,
                    color: (isPublic)
                        ? Colors.green
                        : const Color.fromARGB(255, 190, 30, 19),
                    textColor: Colors.white,
                    width: 70.w,
                    leading: Image.asset(
                      AppImages.circleprivate,
                      height: 18.h,
                      width: 18.w,
                    )),
              ),
            ),
            SizedBox(width: 5.w),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ExitPopUp(
                      imagePath: AppImages.inactive,
                      onExit: () {
                        _leaveRoom();
                      },
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

  // Inside _GameRoomScreenState...

  void _showPencilToolsPopup(TapDownDetails details) async {
    if (!_isDrawer) return;

    final Offset position = details.globalPosition;

    // Define a map of DrawingTool to an icon asset path (for UI consistency)
    const Map<DrawingTool, String> toolIcons = {
      DrawingTool.eraser: AppImages.eraser,
      DrawingTool.circle: AppImages.circle,
      DrawingTool.filledCircle: AppImages.circleFilled,
      DrawingTool.rectangle: AppImages.rectangle,
      DrawingTool.filledRectangle: AppImages.rectangleFilled,
      DrawingTool.pencil: AppImages.drawingPencil,
    };

    // Build the menu content, passing a specific String or Enum value for popping
    final List<Widget> menuItems = [
      // --- Row 1: Outline Shapes & Eraser/Actions ---
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Eraser (Tool)
          _buildToolButton(
              child: Image.asset(toolIcons[DrawingTool.eraser]!,
                  width: 20.w, height: 20.h),
              isSelected: _currentTool == DrawingTool.eraser,
              onTap: () => Navigator.of(context).pop(DrawingTool.eraser)),
          // Circle (Outline) (Tool)
          _buildToolButton(
              child: Image.asset(toolIcons[DrawingTool.circle]!,
                  width: 20.w, height: 20.h),
              isSelected: _currentTool == DrawingTool.circle,
              onTap: () => Navigator.of(context).pop(DrawingTool.circle)),
          // Rectangle (Outline) (Tool)
          _buildToolButton(
              child: Image.asset(toolIcons[DrawingTool.rectangle]!,
                  width: 20.w, height: 20.h),
              isSelected: _currentTool == DrawingTool.rectangle,
              onTap: () => Navigator.of(context).pop(DrawingTool.rectangle)),
          // Color Picker (Action)
          _buildToolButton(
              child:
                  Image.asset(AppImages.colorPicker, width: 20.w, height: 20.h),
              onTap: () => Navigator.of(context).pop('color_picker')),
          // Undo (Action)
          _buildToolButton(
              child: Image.asset(AppImages.undo, width: 20.w, height: 20.h),
              onTap: () => Navigator.of(context).pop('undo')),
        ],
      ),
      const SizedBox(height: 4),
      // --- Row 2: Filled Shapes & Pencil/Redo/Clear ---
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pencil (Tool)
          _buildToolButton(
              child: Image.asset(toolIcons[DrawingTool.pencil]!,
                  width: 20.w, height: 20.h),
              isSelected: _currentTool == DrawingTool.pencil,
              onTap: () => Navigator.of(context).pop(DrawingTool.pencil)),
          // Filled Circle (Tool)
          _buildToolButton(
              child: Image.asset(toolIcons[DrawingTool.filledCircle]!,
                  width: 20.w, height: 20.h),
              isSelected: _currentTool == DrawingTool.filledCircle,
              onTap: () => Navigator.of(context).pop(DrawingTool.filledCircle)),
          // Filled Rectangle (Tool)
          _buildToolButton(
              child: Image.asset(toolIcons[DrawingTool.filledRectangle]!,
                  width: 20.w, height: 20.h),
              isSelected: _currentTool == DrawingTool.filledRectangle,
              onTap: () =>
                  Navigator.of(context).pop(DrawingTool.filledRectangle)),
          // Clear Canvas (Bucket Fill Action)
          _buildToolButton(
              child:
                  Image.asset(AppImages.bucketFill, width: 20.w, height: 20.h),
              onTap: () => Navigator.of(context).pop('clear_canvas')),
          // Redo (Action)
          _buildToolButton(
              child: Image.asset(AppImages.redo, width: 20.w, height: 20.h),
              onTap: () => Navigator.of(context).pop('redo')),
        ],
      ),
    ];

    final double verticalOffset = 90.0.h; // Define vertical offset
    final double horizontalOffset = 50.0.w; // Define horizontal offset

    final dynamic result = await showMenu<dynamic>(
      context: context,
      color: Colors.transparent,
      position: RelativeRect.fromRect(
        (position -
                Offset(
                  horizontalOffset,
                  verticalOffset,
                )) &
            const Size(1, 1),
        Offset.zero & MediaQuery.of(context).size,
      ),
      items: [
        PopupMenuItem(
          enabled: false,
          padding: EdgeInsets.zero,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(29, 34, 34, 1),
              borderRadius: BorderRadius.circular(8.r),
              boxShadow: const [
                BoxShadow(color: Colors.black54, blurRadius: 4)
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: menuItems,
            ),
          ),
        ),
      ],
    );

    // Apply results after the menu is closed
    if (result != null) {
      if (result is DrawingTool) {
        // Tool selection
        setState(() {
          _currentTool = result;
        });
      } else if (result is String) {
        // Action dispatch
        switch (result) {
          case 'undo':
            _undo();
            break;
          case 'redo':
            _redo();
            break;
          case 'color_picker':
            // The color picker needs to be shown *after* this menu closes
            _showColorPickerDialog();
            break;
          case 'clear_canvas':
            _clearCanvas();
            break;
        }
      }
    }
  }

  void _useHint() {
    if (_hintsRemaining <= 0 ||
        _currentWord == null ||
        _currentPhase != 'drawing' ||
        !_isDrawer) {
      return;
    }
    String? newRevealedWord;
    int newHintsRemaining = _hintsRemaining - 1;
    _showHintsRemaining(newHintsRemaining.toString());

    if (_revealedWord == null) {
      // First hint: Show dashes based on word length
      final wordLength = _currentWord!.length;
      newRevealedWord = '_' * wordLength;
    } else if (_hintsRemaining == 2) {
      // Second hint: Reveal first letter
      final wordLength = _currentWord!.length;
      if (wordLength > 0) {
        newRevealedWord = _currentWord![0] + '_' * (wordLength - 1);
      } else {
        newRevealedWord = _revealedWord;
      }
    } else if (_hintsRemaining == 1) {
      // Third hint: Reveal the next unrevealed letter
      final chars = _revealedWord!.split('');
      final wordChars = _currentWord!.split('');
      int revealIndex = -1;
      for (int i = 0; i < wordChars.length; i++) {
        if (chars[i] == '_') {
          revealIndex = i;
          break;
        }
      }

      if (revealIndex != -1) {
        chars[revealIndex] = wordChars[revealIndex];
        newRevealedWord = chars.join();
      } else {
        newRevealedWord = _revealedWord;
      }
    } else {
      newRevealedWord = _revealedWord;
    }

    // Update local state
    setState(() {
      _hintsRemaining = newHintsRemaining;
      _showWordHint = true;
      _revealedWord = newRevealedWord;
    });

    // Broadcast hint to all users
    if (newRevealedWord != null) {
      _socketService.sendHint(
          widget.roomId, newRevealedWord, newHintsRemaining);
    }
  }

  Widget _buildHintSystem() {
    // Only show during drawing phase
    if (_currentPhase != 'drawing') {
      return const SizedBox.shrink();
    }

    // Get word length for dashes (use current word if drawer, wordHint if guesser)
    String? wordToUse =
        _isDrawer ? _currentWord : (_currentWordForDashes ?? _wordHint);
    if (wordToUse == null) {
      return const SizedBox.shrink();
    }

    // Word hint display (dashes or revealed letters) - centered at top middle
    if (_showWordHint && _revealedWord != null) {
      final characters = _revealedWord!.characters.toList();
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: characters.map((char) {
          final displayChar = char == '_' ? '_' : char.toUpperCase();
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 6.w),
            child: Text(
              displayChar,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.w,
              ),
            ),
          );
        }).toList(),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildHintButton() {
    final bool isActive = _hintsRemaining > 0 &&
        _currentWord != null &&
        _currentPhase == 'drawing';

    return GestureDetector(
      onTap: isActive ? _useHint : null,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF1E88E5) : Colors.grey.shade600,
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: const Color(0xFF1E88E5).withOpacity(0.5),
                        blurRadius: 8.r,
                        spreadRadius: 0.5.r,
                      )
                    ]
                  : null,
            ),
            child: Icon(
              Icons.lightbulb,
              color: Colors.white,
              size: 22.sp,
            ),
          ),
          Positioned(
            top: -4.h,
            right: -4.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                color:
                    isActive ? const Color(0xFFFF7043) : Colors.grey.shade500,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '$_hintsRemaining',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _copyableRoomIdPill(String roomId) {
    return GestureDetector(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: roomId));
        setState(() => _copied = true);
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) setState(() => _copied = false);
        });
      },
      child: _pill(_copied ? 'Copied!' : roomId,
          color: const Color(0xFF1B1C2A),
          textColor: Colors.white,
          width: 100.w,
          spacing: 25.w,
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
    double? width,
    double? spacing,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            leading,
            SizedBox(width: spacing ?? 2.w),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamsImage() {
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

  Widget _buildTeamScores() {
    // Calculate team scores
    int orangeScore = 0;
    int blueScore = 0;

    for (var participant in _participants) {
      if (participant.team == 'orange') {
        orangeScore += participant.score ?? 0;
      } else if (participant.team == 'blue') {
        blueScore += participant.score ?? 0;
      }
    }

    return Row(
      children: [
        // Team A (Blue/Cyan)
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.cyan,
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Text(
            'A',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          '$blueScore',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 12.w),

        // VS
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Text(
            'VS',
            style: TextStyle(
              color: Colors.black,
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        SizedBox(width: 12.w),
        Text(
          '$orangeScore',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 8.w),

        // Team B (Orange)
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Text(
            'B',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopPlayer() {
    // Find player with highest score
    if (_participants.isEmpty) {
      return const SizedBox.shrink();
    }

    var topPlayer =
        _participants.reduce((a, b) => (a.score ?? 0) > (b.score ?? 0) ? a : b);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.amber, width: 2),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12.r,
            backgroundColor: Colors.amber,
            child: Text(
              (topPlayer.user?.name ?? 'G')[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            '${topPlayer.score ?? 0}',
            style: TextStyle(
              color: Colors.amber,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildModalOverlays() {
    debugPrint("CURRENT PHASE : $_currentPhase");
    // 1. HIGHEST PRIORITY: Word Selection Dialog (Blocks all others)
    if (_isWordSelectionDialogVisible) {
      return [_showWordSelectionDialog()];
    }

    // 2. SECOND PRIORITY: Lost Turn Message (Should block scoreboards/previews)
    if (_isWordSelectionLostTurn) {
      // Assuming _buildLostTurnWidget exists in your class
      return [
        _buildLostTurnWidget(),
      ];
    }

    if (_currentWord != null && _currentPhase == 'reveal') {
      return [
        _buildTimeUpWidget(),
      ];
    }
    if (_currentPhase == 'selecting_drawer') {
      return [
        _buildSelectingDrawerWidget(),
      ];
    }
    // 3. THIRD PRIORITY: Interval/Scoreboard Phase
    final bool isScoreboardPhase = (_isTeamGamePlaying &&
            (_currentDrawerInfo?['team'] != _currentParticipant?.team)) ||
        (_currentPhase == 'interval');

    if (isScoreboardPhase ||
        (_currentPhase == "selecting_drawer" && !_isDrawer)) {
      // Assuming interval widget exists and handles team score/interval screens
      return [
        _buildIntervalWidget(),
      ];
    }

    // 4. LOWEST PRIORITY: Next Drawer Preview
    if (_shouldShowNextDrawerOverlay) {
      return [
        _buildNextDrawerOverlay(),
      ];
    }

    // Fallback: If the outer condition was true but none of the inner conditions are met.
    return [_buildIntervalWidget()];
  }

  Widget _buildBoardArea(double height) {
    final players = _participants;

    final bool isDrawingPhase = !_waitingForPlayers &&
        _room?.status == 'playing' &&
        _currentPhase == 'drawing' &&
        _phaseMaxTime > 0;

    final int remainingSeconds = math.max(
      0,
      math.min(_phaseTimeRemaining, _phaseMaxTime),
    );

    final double progress = (_currentPhase == 'drawing' ||
                _currentPhase == 'interval' ||
                _currentPhase == 'choosing_word') &&
            _phaseMaxTime > 0
        ? remainingSeconds / _phaseMaxTime
        : 0.0;
    
    final bool isCritical = isDrawingPhase && remainingSeconds < 20;

    // NEW CODE BLOCK (REPLACEMENT)
    Color indicatorColor;

    // 1. Determine the base color based on the current phase
    if (_currentPhase == 'drawing') {
      // Drawing phase uses green, turning red if critical
      indicatorColor = isCritical ? Colors.redAccent : const Color(0xFF3EE07F);
    } else if (_currentPhase == 'choosing_word') {
      // Choosing word phase uses yellow
      indicatorColor = Colors.yellow;
    } else if (_currentPhase == 'interval') {
      // Interval phase uses a default color (e.g., blue or light gray)
      indicatorColor =
          const Color.fromRGBO(46, 9, 255, 1); // Re-use your initial blue color
    } else {
      // For all other phases (e.g., 'selecting_drawer', 'waiting'), hide the bar.
      indicatorColor = Colors.transparent;
    }

    // 2. Ensure progress is not zero/negative if we want to show it
    if (progress <= 0) {
      indicatorColor = Colors.transparent;
    }

    // Update animation smoothly when progress changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateProgressAnimation(progress);
      }
    });

    final Widget boardContent = ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: (_isWordSelectionDialogVisible ||
                  _shouldShowNextDrawerOverlay ||
                  _isWordSelectionLostTurn ||
                  (_isTeamGamePlaying &&
                          (_currentDrawerInfo?['team'] !=
                              _currentParticipant?.team) ||
                      (_currentPhase == 'interval')) ||
                  (_currentWord != null) ||
                  (_currentPhase == 'selecting_drawer') ||
                  (_currentPhase == 'choosing_word')) &&
              (_currentPhase != 'drawing')
          ? Stack(
              children: [
                Column(children: _buildModalOverlays()),
                if (_showSlider)
                  Positioned(
                    top: height - 50.h,
                    left: 15.w,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
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
            )
          : Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: const Color(0xFF111111),
                    child: _waitingForPlayers || _room?.status != 'playing'
                        ? _waitingForPlayersView(players)
                        : _buildDrawingBoard(),
                  ),
                ),
                if (_showSlider)
                  Positioned(
                    top: height - 50.h,
                    left: 15.w,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
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
                if (_isDrawer &&
                    !_waitingForPlayers &&
                    _room?.status == 'playing')
                  Positioned(
                    top: 10.h,
                    left: 10.w,
                    child: _buildDrawingTools(),
                  ),
                if (!_waitingForPlayers &&
                    _room?.status == 'playing' &&
                    _currentPhase == 'drawing')
                  Positioned(
                    top: 10.h,
                    left: 0,
                    right: 0,
                    child: Center(child: _buildHintSystem()),
                  ),
                if (_isDrawer &&
                    !_waitingForPlayers &&
                    _room?.status == 'playing' &&
                    _currentPhase == 'drawing')
                  Positioned(
                    bottom: 16.h,
                    right: 16.w,
                    child: _buildHintButton(),
                  ),
              ],
            ),
    );

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(10.r),
        border: universalBorder,
      ),
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          
          
          return CustomPaint(
            foregroundPainter: _progressAnimation.value > 0 &&
                    indicatorColor != Colors.transparent
                ? _PhaseBorderPainter(
                    progress: _progressAnimation.value.clamp(0.0, 1.0),
                    color: indicatorColor,
                    strokeWidth: 4.w,
                    borderRadius: 10.r,
                  )
                : null,
            child: child,
          );
        },
        child: boardContent,
      ),
    );
  }

  Widget _waitingForPlayersView(List<RoomParticipant> players) {
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

  // Modify _buildDrawingBoard() to use LayoutBuilder to capture size immediately

  Widget _buildDrawingBoard() {
    // FIX: Use the correct layout key based on role
    return Container(
      key: _isDrawer ? _drawerBoardLayoutKey : _guesserBoardLayoutKey,
      child: IgnorePointer(
        ignoring: true,
        child: DrawingCanvas(
          canvasKey:
              GlobalKey(), // Use a different key or same if needed, but guesser doesn't need to repaint boundary for export usually
          strokesListenable: _strokes,
          currentStrokeListenable: _currentStroke,
          options: fdb.DrawingCanvasOptions(
            currentTool: fdb_tool.DrawingTool.pencil, // Default for display
            strokeColor: Colors.black,
            size: 1.0,
            backgroundColor: Colors.black,
            showGrid: _showGrid.value,
          ),
          onDrawingStrokeChanged: null,
          backgroundImageListenable: _backgroundImage,
        ),
      ),
    );
  }

  Widget _buildToolButton({
    required Widget child,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(4),
        width: 15.h,
        height: 15.h,
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.greenAccent.withOpacity(0.25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(2),
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget _buildDrawingTools() {
    // Determine if the full game board is in focus (full screen mode for drawer)
    final bool isDrawingPhase = !_waitingForPlayers &&
        _room?.status == 'playing' &&
        _currentPhase == 'drawing';
    final bool isFullScreenDrawer = _isDrawer && isDrawingPhase;
    final bool isActive = _hintsRemaining > 0 &&
        _currentWord != null &&
        _currentPhase == 'drawing';

    // The actual pop-up content widget
    final Widget pencilToolsPopup = Container(
      height: 50.h,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(29, 34, 34, 1),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 4)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: [eraser circle rectangle undo]
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildToolButton(
                  child: Image.asset(AppImages.eraser),
                  onTap: () {
                    /* Eraser Logic */
                    setState(() => _showPencilTools = false);
                  }),
              _buildToolButton(
                  child: Image.asset(AppImages.circle),
                  onTap: () {
                    /* Circle Logic */
                    setState(() => _showPencilTools = false);
                  }),
              _buildToolButton(
                  child: Image.asset(AppImages.rectangle),
                  onTap: () {
                    /* Rectangle Logic */
                    setState(() => _showPencilTools = false);
                  }),
              _buildToolButton(
                  child: Image.asset(AppImages.bucketFill),
                  onTap: () {
                    /* Undo Logic */
                    setState(() => _showPencilTools = false);
                  }),
              _buildToolButton(
                  child: Image.asset(AppImages.redo),
                  onTap: () {
                    /* Undo Logic */
                    setState(() => _showPencilTools = false);
                  }),
            ],
          ),
          // Row 2: [ pencil circle_filled rectangle_filled color_picker redo]
          SizedBox(
            width: 100.w,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildToolButton(
                    isSelected: true, // Example: Pencil is selected
                    child: Image.asset(AppImages.drawingPencil),
                    onTap: () {
                      /* Pencil Logic */
                      setState(() => _showPencilTools = false);
                    }),
                _buildToolButton(
                    child: Image.asset(AppImages.circleFilled),
                    onTap: () {
                      /* Filled Circle Logic */
                      setState(() => _showPencilTools = false);
                    }),
                _buildToolButton(
                    child: Image.asset(AppImages.rectangleFilled),
                    onTap: () {
                      /* Filled Rectangle Logic */
                      setState(() => _showPencilTools = false);
                    }),
                _buildToolButton(
                    child: Image.asset(AppImages.colorPicker),
                    onTap: () {
                      /* Color Picker Logic */
                      setState(() => _showPencilTools = false);
                    }),
                _buildToolButton(
                    child: Image.asset(AppImages.redo),
                    onTap: () {
                      /* Redo Logic */
                      setState(() => _showPencilTools = false);
                    }),
              ],
            ),
          ),
        ],
      ),
    );

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
        child: Stack(
          children: [
            Row(
              children: [
                // Pencil Icon (Now toggles the pop-up)
                GestureDetector(
                  onTapDown: (details) => _showPencilToolsPopup(details),
                  child: Container(
                    key: _pencilKey, // Attach here
                    height: 40,
                    width: 40,
                    margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _isDrawer ? Colors.white : Colors.grey,
                        width: 2,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(3)),
                    ),
                    child: Center(
                        child: Image.asset(AppImages.pencilDraw, scale: 2)),
                  ),
                ),
                GestureDetector(
                  // Use onTapDown for immediate feedback like showMenu expects
                  onTapDown: (details) => _showThicknessOpacityPopup(details),
                  child: Container(
                    // Keep original styling
                    height: 40,
                    width: 40,
                    margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: _isDrawer ? Colors.white : Colors.grey,
                          width: 2),
                      borderRadius: const BorderRadius.all(Radius.circular(3)),
                    ),
                    child:
                        Center(child: Image.asset(AppImages.increaseDecrease)),
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => SizedBox(
                        height: 10.h,
                        width: 20.w,
                        child: Dialog(
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7537E0), Color(0xFF286FD3)],
                              ),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              height: MediaQuery.of(context).size.height * 0.5,
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    AppLocalizations.skipTurn,
                                    style: GoogleFonts.lato(
                                        color: Colors.white,
                                        fontSize: 22.sp,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.none),
                                  ),
                                  SizedBox(height: 20.h),
                                  Text(
                                    AppLocalizations.areYouSureSkip,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.lato(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w400,
                                        decoration: TextDecoration.none),
                                  ),
                                  SizedBox(height: 30.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          setState(() {
                                            _currentWord = null;
                                            _isDrawer = !_isDrawer;
                                          });
                                          _socketService
                                              .skipTurn(widget.roomId);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFD0C9C9),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          minimumSize: const Size(120, 45),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              AppLocalizations.yesSad,
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 15.w),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFFFFFFF),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          minimumSize: const Size(120, 45),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              AppLocalizations.noCool,
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: _isDrawer ? Colors.white : Colors.grey,
                          width: 2),
                      borderRadius: const BorderRadius.all(Radius.circular(3)),
                    ),
                    child: Center(child: Image.asset(AppImages.skipChance)),
                  ),
                ),

                Badge(
                  offset: const Offset(0, 2),
                  backgroundColor: Colors.black,
                  label: Text("$_hintsRemaining"),
                  child: GestureDetector(
                    onTap: isActive ? _useHint : null,
                    child: Container(
                      height: 40,
                      width: 40,
                      alignment: Alignment.topRight,
                      margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: _isDrawer ? Colors.white : Colors.grey,
                            width: 2),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(3)),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.lightbulb_sharp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                // Color Palette (Expanded)
                Expanded(
                  child: Container(
                    height: 40,
                    margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: _isDrawer ? Colors.white : Colors.grey,
                          width: 2),
                      borderRadius: const BorderRadius.all(Radius.circular(3)),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              ..._colorPalette
                                  .sublist(
                                      0, (_colorPalette.length / 2).toInt())
                                  .map(
                                    (color) => GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedColor = color;
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: color,
                                          borderRadius:
                                              BorderRadius.circular(2),
                                          border: _selectedColor == color
                                              ? Border.all(
                                                  color: Colors.white, width: 1)
                                              : null,
                                        ),
                                        margin: const EdgeInsets.fromLTRB(1, 1, 1, 1),
                                        height: 15,
                                        width: 15,
                                      ),
                                    ),
                                  )
                                  ,
                            ],
                          ),
                          Row(
                            children: [
                              ..._colorPalette
                                  .sublist((_colorPalette.length / 2).toInt())
                                  .map(
                                    (color) => GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedColor = color;
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: _selectedColor == color
                                              ? Border.all(
                                                  color: Colors.white, width: 1)
                                              : null,
                                          color: color,
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                        margin: const EdgeInsets.fromLTRB(1, 1, 1, 1),
                                        height: 15,
                                        width: 15,
                                      ),
                                    ),
                                  )
                                  ,
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  // OverlayEntry _buildComplimentWidget() {
  //   int teamCounts = 0;
  //   List<String> teamMembers = [];
  //   if (_currentDrawerInfo!['team'] != null) {
  //     final team = _currentDrawerInfo!['team'];
  //     teamMembers.addAll(_participants
  //         .where((e) => e.team == team)
  //         .map((e) => e.id.toString())
  //         .toList());

  //     _usersWhoAnswered.map((e) {
  //       if (teamMembers.contains(e)) {
  //         teamCounts++;
  //       }
  //     });
  //   }

  //   return OverlayEntry(
  //     builder: (context) {
  //       return Positioned.fill(
  //         child: Container(
  //             padding: const EdgeInsets.all(2),
  //             decoration: BoxDecoration(
  //               gradient: const LinearGradient(
  //                 colors: [Color(0xFF7537E0), Color(0xFF286FD3)],
  //               ),
  //               borderRadius: BorderRadius.circular(22),
  //             ),
  //             child: Container(
  //                 width: MediaQuery.of(context).size.width * 0.9,
  //                 height: MediaQuery.of(context).size.height * 0.5,
  //                 decoration: BoxDecoration(
  //                   color: Colors.black87,
  //                   borderRadius: BorderRadius.circular(20),
  //                 ),
  //                 child: Column(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       // Image and initial spacing
  //                       Image.asset(AppImages.gif),
  //                       SizedBox(height: 14.h),

  //                       // Conditional Messages (Only ONE of these blocks will render)
  //                       if (_usersWhoAnswered.length > _participants.length / 3)
  //                         Text("😢 Oops! Time’s Up!"),
  //                       if (_usersWhoAnswered.length > _participants.length / 2)
  //                         Text("👏 Good Job!"),
  //                       if (_usersWhoAnswered.length >
  //                           _participants.length / 1.5)
  //                         Text("🎉 Well Done!!!"),

  //                       // Spacing and final status (rendered unconditionally)
  //                       SizedBox(height: 14.h),

  //                       // Corrected String Interpolation
  //                       if (_currentDrawerInfo?['team'] != null)
  //                         Text(
  //                           '${teamCounts}/${_participants.length} teammates guessed !',
  //                           style: TextStyle(
  //                               fontSize: 14.sp,
  //                               color: Colors.white70), // Example style
  //                         ),
  //                       if (_currentDrawerInfo?['team'] == null)
  //                         Text(
  //                           '${_usersWhoAnswered.length}/${_participants.length} participants guessed !',
  //                           style: TextStyle(
  //                               fontSize: 14.sp,
  //                               color: Colors.white70), // Example style
  //                         ),
  //                     ]))),
  //       );
  //     },
  //   );
  // }
  OverlayEntry _buildComplimentWidget() {
    
    Widget buildGuessCompliment() {
      final guessed = _usersWhoAnswered.length;
      final total = _participants.length - 1;

      if (total < 1) {
        return const SizedBox
            .shrink(); // Avoid division by zero or nonsensical math
      }

      if (guessed > total / 1.5) {
        // Check 66.6% threshold first
        return _buildPerfectRound();
      } else if (guessed > total / 2) {
        // Check 50% threshold next
        return _buildCloseCall();
      } else if (guessed > total / 3) {
        // Check 33.3% threshold next
        return _buildToughRound();
      } else {
        // Final default case
        return _buildToughRound();
      }
    }

    return OverlayEntry(builder: (context) {
      // 1. Positioned.fill creates the full-screen container for background dimming/alignment
      return Positioned.fill(
        child: Material(
          // This material is for the dark background dimming effect
          color: Colors.black54, // Semi-transparent black background
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7537E0), Color(0xFF286FD3)],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.5,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: buildGuessCompliment(),
              ),
            ),
          ),
        ),
      );
    });
  }

  OverlayEntry _buildDrawerScoreWidget() {
    Color textColor = Colors.green;
    Widget buildGuessCompliment() {
      final guessed = _usersWhoAnswered.length;

      final total = _participants.length - 1;
      Color color = Colors.green;
      if (total < 1) {
        return const SizedBox
            .shrink(); // Avoid division by zero or nonsensical math
      }

      if (guessed > (total * 0.75)) {
        // Check 66.6% threshold first
        return const Text("🎉 Well Done!!!",
            style: TextStyle(color: Colors.white, fontSize: 20));
      } else if (guessed > (total * 0.5)) {
        color = const Color.fromRGBO(142, 152, 255, 1);
        // Check 50% threshold next
        return const Text("👏 Good Job!",
            style: TextStyle(color: Colors.white, fontSize: 20));
      } else if (guessed == 0) {
        color = Colors.red;
        textColor = Colors.red;
        // Check 33.3% threshold next
        return const Text("😢 Oops! Time’s Up!",
            style: TextStyle(color: Colors.white, fontSize: 20));
      } else {
        // Final default case
        return const Text("👌 Nice Try!",
            style: TextStyle(color: Colors.white, fontSize: 20));
      }
    }

    
    return OverlayEntry(
      builder: (context) {
        return Positioned.fill(
          child: Material(
            // Use Material for background dimming
            color: Colors.black54, // Semi-transparent black
            child: Center(
              child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7537E0), Color(0xFF286FD3)],
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.5,
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _AnimationVideo(
                              controller: _welldoneVideoController,
                              width: 160.w,
                              height: 160.h,
                            ),
                            SizedBox(height: 14.h),

                            buildGuessCompliment(),

                            SizedBox(height: 14.h),

                            // Corrected String Interpolation
                            RichText(
                              textAlign: TextAlign
                                  .center, // Optional: ensures centering within the container
                              text: TextSpan(
                                // 1. Define the base style (for the muted, static text: '/' and 'teammates guessed !')
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.white70,
                                ),
                                children: <TextSpan>[
                                  // 2. Guessed Count (Highlighted)
                                  TextSpan(
                                    text:
                                        "${_usersWhoAnswered.length.toString()}/${_participants.length - 1} ",
                                    style: TextStyle(
                                      color: textColor, // Highlight Color
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp,
                                    ),
                                  ),

                                  // 5. Static text (Base style)
                                  const TextSpan(
                                    text: ' teammates guessed !',
                                  ),
                                ],
                              ),
                            )
                          ]))),
            ),
          ),
        );
      },
    );
  }

  OverlayEntry _buildDrawerTimeUpWidget() {
    
    return OverlayEntry(
      builder: (context) {
        return Positioned.fill(
          child: Material(
            // Use Material for background dimming
            color: Colors.black54, // Semi-transparent black
            child: Center(
              child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7537E0), Color(0xFF286FD3)],
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.5,
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _AnimationVideo(
                              controller: _timeupVideoController,
                              width: 160.w,
                              height: 160.h,
                            ),
                            SizedBox(height: 14.h),
                            Text(
                              AppLocalizations.oops,
                              style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            SizedBox(height: 14.h),
                            Text(
                              AppLocalizations.almostHadIt,
                              style: TextStyle(
                                  fontSize: 18.sp, color: Colors.white),
                            )
                          ]))),
            ),
          ),
        );
      },
    );
  }

  Widget _buildToughRound() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("💭", style: TextStyle(fontSize: 24.sp)),
        SizedBox(height: 10.h),
        Text(
          AppLocalizations.toughRound,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 22.sp),
        ),
        SizedBox(height: 10.h),
        Text(
          AppLocalizations.noOneCrackedIt,
          style: const TextStyle(color: Colors.white),
        ),
        Text(
          AppLocalizations.letsTryNext,
          style: const TextStyle(color: Colors.white),
        )
      ],
    );
  }

  Widget _buildCloseCall() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("✨", style: TextStyle(fontSize: 24.sp)),
        SizedBox(height: 10.h),
        Text(
          AppLocalizations.closeCall,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 22.sp),
        ),
        SizedBox(height: 10.h),
        Text(
          AppLocalizations.fewSharpEyes,
          style: const TextStyle(color: Colors.white),
        ),
        Text(
          AppLocalizations.almostThereTeam,
          style: const TextStyle(color: Colors.white),
        )
      ],
    );
  }

  Widget _buildPerfectRound() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("🎨", style: TextStyle(fontSize: 24.sp)),
        SizedBox(height: 10.h),
        Text(
          AppLocalizations.keepItUp,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 22.sp),
        ),
        Text(
          AppLocalizations.artistOfTheTeam,
          style: TextStyle(color: Colors.white, fontSize: 22.sp),
        ),
        SizedBox(height: 10.h),
        const Text(
          "Almost there, team!",
          style: TextStyle(color: Colors.white),
        )
      ],
    );
  }

  Widget _buildControlsRow() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.w, 6.h, 10.w, 6.h),
      child: Row(
        children: [
          Showcase(
            descriptionAlignment: Alignment.centerLeft,
            tooltipActions: [
              TooltipActionButton(
                name: 'skip',
                backgroundColor: Colors.white,
                textStyle: const TextStyle(color: Colors.grey),
                type: TooltipDefaultActionType.skip,
                onTap: () => ShowcaseView.get().dismiss(),
              ),
              TooltipActionButton(
                name: 'Next',
                tailIcon: const ActionButtonIcon(
                  icon: Icon(Icons.arrow_forward_ios, size: 12),
                ),
                type: TooltipDefaultActionType.next,
                backgroundColor: Colors.white,
                textStyle: const TextStyle(color: Colors.black),
                onTap: () => ShowcaseView.get().next(),
              ),
            ],
            overlayColor: const Color.fromRGBO(116, 116, 116, 0.63),
            showArrow: false,
            toolTipMargin: 21,
            tooltipPadding: const EdgeInsets.all(12),
            description:
                "Click to View users and scores according to team wise  ",
            key: showcasekey6,
            child: Container(
              height: 50.h,
              width: 120.w,
              padding: EdgeInsets.symmetric(horizontal: 1.w),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(8.r),
                border: universalBorder,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // _buildIconBox(
                  //   child: Image.asset(
                  //     !_voiceService.mute ? AppImages.micon : AppImages.micoff,
                  //     width: 25.w,
                  //     height: 25.w,
                  //   ),
                  //   onTap: () async {
                  //     // Only allow mic toggle if voice is enabled for the room
                  //     if (!voiceEnabled) {
                  //       ScaffoldMessenger.of(context).showSnackBar(
                  //         const SnackBar(
                  //           content: Text(
                  //             'Voice chat is not enabled in this room',
                  //           ),
                  //           backgroundColor: Colors.orange,
                  //         ),
                  //       );
                  //       return;
                  //     }

                  //     // Toggle mic through voice service (handles permissions)
                  //     final success = await _voiceService.toggleMic();
                  //     if (mounted) {
                  //       setState(() {});
                  //     }
                  //   },
                  // ),
                  _buildIconBox(
                    child: Icon(_volumeIcon, size: 25.w, color: Colors.white70),
                    onTap: _toggleSlider,
                  ),
                  _buildIconBox(
                    child: Icon(Icons.info_outline,
                        size: 25.w, color: Colors.yellow),
                    onTap: () {
                      if (showcasecontext != null) {
                        ShowCaseWidget.of(showcasecontext!).startShowCase([
                          showcasekey1,
                          showcasekey2,
                          showcasekey3,
                          showcasekey4,
                          showcasekey5,
                          showcasekey6,
                        ]);
                      }
                    },
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
                          participants: _participants, roomId: _room!.id!),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // )),
          SizedBox(width: 8.w),
          Expanded(
            child: _buildDrawerMessageSelector(),
          ),
        ],
      ),
    );
  }

  Widget _buildIconBox({required Widget child, required VoidCallback onTap}) {
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

  Widget _buildDrawerMessageSelector() {
    final _DrawerMessageOption? selectedOption =
        _findDrawerMessageOption(_currentDrawerMessageKey);

    final bool canSelectMessage =
        _isDrawer && !_waitingForPlayers && (_room?.status == 'playing');

    final Color borderColor =
        selectedOption?.accentColor.withOpacity(0.6) ?? const Color(0xFF0B0B0B);
    final Color backgroundColor =
        canSelectMessage ? const Color(0xFF141414) : const Color(0xFF0F0F0F);

    return GestureDetector(
      onTap: canSelectMessage
          ? _showDrawerMessagePicker
          : () {
              if (!_isDrawer) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Only the drawer can send these messages.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
      child: Container(
        height: 50.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10.r),
          border: universalBorder,
        ),
        child: Row(
          children: [
            Text(
              'Message :',
              style: GoogleFonts.lato(
                color: Colors.white60,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 10.w),
            if (selectedOption != null)
              Container(
                width: 22.w,
                height: 22.h,
                decoration: BoxDecoration(
                  color: selectedOption.accentColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(6.r),
                  border: universalBorder,
                ),
                child: Center(
                  child: Image.asset(
                    selectedOption.iconPath,
                    width: 16.w,
                    height: 16.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            if (selectedOption != null) SizedBox(width: 8.w),
            Expanded(
              child: Text(
                selectedOption?.label ?? 'Select',
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lato(
                  color: selectedOption?.accentColor ?? Colors.white38,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (canSelectMessage)
              Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white60,
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatArea() {
    // Check if current user has answered
    final currentUserId = _currentUser?.id?.toString();
    final hasCurrentUserAnswered =
        currentUserId != null && _usersWhoAnswered.contains(currentUserId);

    // Check if current user is on the same team as the drawer
    final bool isOurTeamDrawing = _currentDrawerInfo?['team'] == selectedTeam;

    // Determine if the user is currently a spectator
    final bool isSpectator = selectedGameMode == 'team_vs_team' && 
                              _currentPhase == 'drawing' && 
                              !isOurTeamDrawing;

    // Corrected Team Label Logic (Blue = A, Orange = B)
    final String activeTeamLabel = _currentDrawerInfo?['team'] == 'blue' ? 'A' : 'B';

    final shouldShowAnswerInput = (!_isDrawer &&
            !hasCurrentUserAnswered &&
            _isAnswersChatExpanded &&
            _currentPhase == 'drawing' &&
            (selectedGameMode == '1v1' || isOurTeamDrawing));

    // If expanded, return full width chat (same height)
    if (_isAnswersChatExpanded || _isGeneralChatExpanded) {
      return Expanded(
        child: Container(
          width: double.infinity,
          color: Colors.black,
          child: _isAnswersChatExpanded
              ? _buildExpandedAnswersChat(shouldShowAnswerInput)
              : _buildExpandedGeneralChat(),
        ),
      );
    }

    // Collapsed state
    return Expanded(
      child: Container(
        padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 12.h),
        color: const Color(0xFF000000),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Answers Chat (Left)
            _isAnswersChatExpanded
                ? Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: 8.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF121212),
                        border: universalBorder,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        children: [
                          // Header with close icon
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 8.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                      color: const Color(0xFF202020),
                                      borderRadius: BorderRadius.circular(20.r),
                                      border: universalBorder),
                                  child: Text(
                                    'Answers chat',
                                    style: GoogleFonts.inter(
                                      color: Colors.white70,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isAnswersChatExpanded = false;
                                    });
                                  },
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.blue,
                                    size: 20.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(color: Colors.black26, height: 1),
                          // Messages list
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(8.w),
                              child: _answersChatMessages.isEmpty
                                  ? Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(16.w),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CircleAvatar(
                                              radius: 20.r,
                                              backgroundColor: Colors.grey[800],
                                              child: Icon(
                                                Icons.person,
                                                color: Colors.white70,
                                                size: 20.sp,
                                              ),
                                            ),
                                            SizedBox(height: 12.h),
                                            Text(
                                              'Type your answers here. If you\'re correct, it will be marked in green',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 8.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      controller: _answersChatScrollController,
                                      itemCount: _answersChatMessages.length,
                                      itemBuilder: (context, i) {
                                        final m = _answersChatMessages[i];
                                        
                                        final isCorrect =
                                            m['isCorrect'] == true;
                                        final isPending =
                                            m['type'] == 'pending';
                                        final userName =
                                            m['userName'] ?? 'User';
                                        final message = m['message'] ?? '';
                                        final avatar = m['avatar'];
                                        final team = m['team'];

                                        return Container(
                                          margin: EdgeInsets.only(bottom: 12.h),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Avatar
                                              Container(
                                                padding: EdgeInsets.all(2.r),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: team == 'orange'
                                                        ? Colors.orange
                                                        : team == 'blue'
                                                            ? Colors.blue
                                                            : Colors.transparent,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: CircleAvatar(
                                                  radius: 16.r,
                                                  backgroundColor: Colors.black,
                                                  child: avatar != null
                                                      ? Image.asset(avatar)
                                                      : Text(
                                                          userName[0]
                                                              .toUpperCase(),
                                                          style: TextStyle(
                                                            fontSize: 12.sp,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                ),
                                              ),
                                              SizedBox(width: 8.w),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      userName,
                                                      style: TextStyle(
                                                        color: team == 'orange'
                                                            ? Colors.orange
                                                            : team == 'blue'
                                                                ? Colors.blue
                                                                : Colors.white,
                                                        fontSize: 12.sp,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4.h),
                                                    Text(
                                                      isCorrect
                                                          ? "correct"
                                                          : message,
                                                      style: TextStyle(
                                                        color: isCorrect
                                                            ? Colors.greenAccent
                                                            : Colors.white70,
                                                        fontSize: 12.sp,
                                                      ),
                                                    ),
                                                    if (isCorrect)
                                                      const Icon(
                                                          Icons.check_circle,
                                                          color: Colors
                                                              .greenAccent,
                                                          size: 1)
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ),
                          // Input field (only if not drawer and hasn't answered)
                          if (shouldShowAnswerInput)
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                      color: Colors.black26, width: 1),
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
                                      controller: _answerController,
                                      focusNode: _answerFocusNode,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Type your answers here...',
                                        hintStyle: TextStyle(
                                          color: Colors.white38,
                                          fontSize: 10.sp,
                                        ),
                                        filled: true,
                                        fillColor: Colors.transparent,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                          borderSide: const BorderSide(
                                            color: Colors.blue,
                                            width: 1,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                          borderSide: const BorderSide(
                                            color: Colors.blue,
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                          borderSide: const BorderSide(
                                            color: Colors.blue,
                                            width: 1.5,
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 10.h,
                                        ),
                                      ),
                                      textInputAction: TextInputAction.send,
                                      onSubmitted: (text) {
                                        if (text.trim().isNotEmpty) {
                                          _sendAnswer();
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  )
                : Showcase(
                    descriptionAlignment: Alignment.centerLeft,
                    tooltipActions: [
                      TooltipActionButton(
                        name: 'skip',
                        backgroundColor: Colors.white,
                        textStyle: const TextStyle(color: Colors.grey),
                        type: TooltipDefaultActionType.skip,
                        onTap: () => ShowcaseView.get().dismiss(),
                      ),
                      TooltipActionButton(
                        name: 'Next',
                        tailIcon: const ActionButtonIcon(
                          icon: Icon(Icons.arrow_forward_ios, size: 12),
                        ),
                        type: TooltipDefaultActionType.next,
                        backgroundColor: Colors.white,
                        textStyle: const TextStyle(color: Colors.black),
                        onTap: () => ShowcaseView.get().next(),
                      ),
                    ],
                    overlayColor: const Color.fromRGBO(116, 116, 116, 0.63),
                    showArrow: false,
                    toolTipMargin: 21,
                    tooltipPadding: const EdgeInsets.all(12),
                    description:
                        "Click to View users and scores according to team wise  ",
                    key: showcasekey4,
                    child: GestureDetector(
                      onTap: isSpectator 
                        ? null 
                        : () {
                          setState(() {
                            _isAnswersChatExpanded = true;
                            _isGeneralChatExpanded = false;
                          });
                      },
                      child: Container(
                        width: 120.w,
                        margin: EdgeInsets.only(right: 8.w),
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: const Color(0xFF121212),
                          // border: universalBorder,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(left: 8.w),
                          child: isSpectator 
                            ? Column( // STRICT: Show this label ONLY for spectators
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.lock_outline, color: Colors.white24, size: 18.sp),
                                  SizedBox(height: 4.h),
                                  Text(
                                    "Team $activeTeamLabel's Turn",
                                    style: GoogleFonts.lato(
                                      color: Colors.white38,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text("(Spectating)", style: GoogleFonts.lato(color: Colors.white24, fontSize: 8.sp)),
                                ],
                              )
                            : Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 5.h),
                                Container(
                                  // height: 30.h,
                                  // width: 100.w,
                                  decoration: BoxDecoration(
                                      color: const Color(0xFF202020),
                                      borderRadius: BorderRadius.circular(20.r),
                                      border: universalBorder),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6.w, vertical: 3.h),
                                  child: Center(
                                    child: Text(
                                      'Answers chat',
                                      style: GoogleFonts.inter(
                                        color: Colors.white70,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                // SizedBox(height: 8.h),
                                // Show recent messages in collapsed view
                                Expanded(
                                  child: _answersChatMessages.isEmpty
                                      ? Padding(
                                          padding: EdgeInsets.all(16.w),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                CircleAvatar(
                                                  radius: 16.r,
                                                  backgroundColor:
                                                      Colors.grey[800],
                                                  child: Icon(
                                                    Icons.person,
                                                    color: Colors.white70,
                                                    size: 20.sp,
                                                  ),
                                                ),
                                                SizedBox(height: 8.h),
                                                Text(
                                                  'Type your answers here. If you\'re correct, it will be marked in green',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 8.sp,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          padding: EdgeInsets.all(8.w),
                                          itemCount: _answersChatMessages.length,
                                          itemBuilder: (context, i) {
                                            final m = _answersChatMessages[i];

                                            final isCorrect =
                                                m['isCorrect'] == true;
                                            final isPending =
                                                m['type'] == 'pending';
                                            final userName =
                                                m['userName'] ?? 'User';
                                            final message = m['message'] ?? '';
                                            final avatar = m['avatar'];
                                            final team = m['team'];

                                            return Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 12.h),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Avatar
                                                  Container(
                                                    clipBehavior: Clip.hardEdge,
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: BoxBorder.all(
                                                            color: team != null
                                                                ? team == 'blue'
                                                                    ? Colors.blue
                                                                    : Colors
                                                                        .orange
                                                                : Colors.blue,
                                                            width: 1)),
                                                    child: CircleAvatar(
                                                        radius: 16.r,
                                                        backgroundColor:
                                                            Colors.black,
                                                        child: avatar != null
                                                            ? Image.asset(avatar)
                                                            : Text(
                                                                userName[0]
                                                                    .toUpperCase(),
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        8.sp,
                                                                    color: Colors
                                                                        .white))),
                                                  ),
                                                  SizedBox(width: 8.w),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          userName,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12.sp,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        SizedBox(height: 4.h),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              isCorrect
                                                                  ? "correct"
                                                                  : message,
                                                              style: TextStyle(
                                                                color: isCorrect
                                                                    ? Colors
                                                                        .greenAccent
                                                                    : Colors
                                                                        .white70,
                                                                fontSize: 8.sp,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 4.w,
                                                            ),
                                                            if (isCorrect)
                                                              const Icon(
                                                                  Icons
                                                                      .check_circle,
                                                                  size: 12,
                                                                  color: Colors
                                                                      .greenAccent)
                                                          ],
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
                              ],
                          ),
                        ),
                      ),
                    )),
            _isGeneralChatExpanded
                ? Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF000000),
                        border: universalBorder,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        children: [
                          // Header with close icon
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 8.h,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'General Chat',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isGeneralChatExpanded = false;
                                    });
                                  },
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.blue,
                                    size: 20.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(color: Colors.black26, height: 1),
                          // Messages list
                          Expanded(
                            child: _chatMessages.isEmpty
                                ? Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.w),
                                      child: Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            CircleAvatar(
                                              radius: 20.r,
                                              backgroundColor: Colors.grey[800],
                                              child: Icon(
                                                Icons.person,
                                                color: Colors.white70,
                                                size: 24.sp,
                                              ),
                                            ),
                                            SizedBox(height: 12.h),
                                            Text(
                                              'Welcome! This is your general \nchat area. Type below to start!',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    controller: _chatScrollController,
                                    padding: EdgeInsets.all(10.w),
                                    itemCount: _chatMessages.length,
                                    itemBuilder: (context, idx) {
                                      final m = _chatMessages[idx];
                                      final isSystem = m['type'] == 'system';
                                      final userName = m['userName'] ?? 'User';
                                      final avatar = m['avatar'];
                                      final team = m['team'];
                                      final message = m['message'];
                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 6.h,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(2.r),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: team == 'orange'
                                                      ? Colors.orange
                                                      : team == 'blue'
                                                          ? Colors.blue
                                                          : Colors.transparent,
                                                  width: 2,
                                                ),
                                              ),
                                              child: CircleAvatar(
                                                radius: 16.r,
                                                backgroundColor: Colors.black,
                                                child: avatar != null
                                                    ? Image.asset(avatar)
                                                    : Text(
                                                        userName[0]
                                                            .toUpperCase(),
                                                        style: TextStyle(
                                                            fontSize: 12.sp,
                                                            color:
                                                                Colors.white),
                                                      ),
                                              ),
                                            ),
                                            SizedBox(width: 8.w),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    userName,
                                                    style: TextStyle(
                                                      color: team == 'orange'
                                                          ? Colors.orange
                                                          : team == 'blue'
                                                              ? Colors.blue
                                                              : Colors.white,
                                                      fontSize: 12.sp,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2.h),
                                                  Text(
                                                    message,
                                                    style: TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 12.sp,
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
                          // Input field
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
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: TextField(
                                    controller: _chatController,
                                    focusNode: _chatFocusNode,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Type anything...',
                                      hintStyle: TextStyle(
                                        color: Colors.white38,
                                        fontSize: 14.sp,
                                      ),
                                      filled: true,
                                      fillColor: Colors.transparent,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                        borderSide: const BorderSide(
                                          color: Colors.blue,
                                          width: 1,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                        borderSide: const BorderSide(
                                          color: Colors.blue,
                                          width: 1,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                        borderSide: const BorderSide(
                                          color: Colors.blue,
                                          width: 1.5,
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                        vertical: 10.h,
                                      ),
                                    ),
                                    textInputAction: TextInputAction.send,
                                    onSubmitted: (text) {
                                      _sendChatMessage();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Showcase(
                    descriptionAlignment: Alignment.centerLeft,
                    tooltipActions: [
                      TooltipActionButton(
                        name: 'skip',
                        backgroundColor: Colors.white,
                        textStyle: const TextStyle(color: Colors.grey),
                        type: TooltipDefaultActionType.skip,
                        onTap: () => ShowcaseView.get().dismiss(),
                      ),
                      TooltipActionButton(
                        name: 'Next',
                        tailIcon: const ActionButtonIcon(
                          icon: Icon(Icons.arrow_forward_ios, size: 12),
                        ),
                        type: TooltipDefaultActionType.next,
                        backgroundColor: Colors.white,
                        textStyle: const TextStyle(color: Colors.black),
                        onTap: () => ShowcaseView.get().next(),
                      ),
                    ],
                    overlayColor: const Color.fromRGBO(116, 116, 116, 0.63),
                    showArrow: false,
                    toolTipMargin: 21,
                    tooltipPadding: const EdgeInsets.all(12),
                    description:
                        "Click to View users and scores according to team wise  ",
                    key: showcasekey5,
                    child: Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isGeneralChatExpanded = true;
                            _isAnswersChatExpanded = false;
                          });
                        },
                        child: Container(
                          alignment: Alignment
                              .bottomCenter, // Aligns the content (the Column) to the bottom
                          decoration: BoxDecoration(
                            color: const Color(0xFF000000),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: _chatMessages.isEmpty
                              ? Padding(
                                  padding: EdgeInsets.all(16.w),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment
                                        .end, // Pushes the Row to the bottom
                                    crossAxisAlignment: CrossAxisAlignment
                                        .stretch, // Allows Row to center its contents if needed
                                    children: [
                                      Row(
                                        // Use Row to place Avatar and Text horizontally
                                        mainAxisSize: MainAxisSize
                                            .min, // Essential to prevent Row from expanding unnecessarily
                                        mainAxisAlignment: MainAxisAlignment
                                            .center, // Centers the content of the Row
                                        crossAxisAlignment: CrossAxisAlignment
                                            .center, // Vertically centers icon and text
                                        children: [
                                          CircleAvatar(
                                            radius: 20.r,
                                            backgroundColor: Colors.grey[800],
                                            child: Icon(
                                              Icons.person,
                                              color: Colors.white70,
                                              size: 24.sp,
                                            ),
                                          ),
                                          SizedBox(
                                              width: 8
                                                  .w), // Added space between icon and text
                                          Flexible(
                                            // Use Flexible to manage the width of the Text widget
                                            child: Text(
                                              'Welcome! This is your general chat area. Type below to start!',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12.sp,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  reverse: true, // Scrolls to bottom
                                  shrinkWrap: true,
                                  padding: EdgeInsets.all(8.w),
                                  itemCount: _chatMessages.length,
                                  itemBuilder: (context, idx) {
                                    // Access messages in reverse order
                                    final m = _chatMessages[
                                        _chatMessages.length - 1 - idx];
                                    final userName = m['userName'] ?? 'User';
                                    final isSystem = m['type'] == 'system';
                                    final avatar = m['avatar'];
                                    final team = m['team'];
                                    return Container(
                                      margin: EdgeInsets.only(bottom: 6.h),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            clipBehavior: Clip.hardEdge,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: BoxBorder.all(
                                                    color: team != null
                                                        ? team == 'blue'
                                                            ? Colors.blue
                                                            : Colors.orange
                                                        : Colors.blue,
                                                    width: 1)),
                                            child: CircleAvatar(
                                                radius: 16.r,
                                                backgroundColor: Colors.black,
                                                child: avatar != null
                                                    ? Image.asset(
                                                        avatar,
                                                      )
                                                    : Text(
                                                        userName[0]
                                                            .toUpperCase(),
                                                        style: TextStyle(
                                                            fontSize: 8.sp,
                                                            color:
                                                                Colors.white))),
                                          ),
                                          SizedBox(width: 6.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  userName,
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 10.sp,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                SizedBox(height: 2.h),
                                                Text(
                                                  m['message'] ?? '',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 10.sp,
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
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpectatorLockedView(String teamLabel) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline, color: Colors.white24, size: 18.sp),
        SizedBox(height: 4.h),
        Text(
          "Team $teamLabel's Turn",
          style: GoogleFonts.lato(
            color: Colors.white38,
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "(Spectating)",
          style: GoogleFonts.lato(
            color: Colors.white24,
            fontSize: 8.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedAnswersChat(bool shouldShowAnswerInput) {
    return Container(
        // width: double.infinity,
        color: const Color(0xFF121212),
        child: Stack(
          children: [
            Column(
              children: [
                // Header with close icon
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF202020),
                          borderRadius: BorderRadius.circular(20.r),
                          border: universalBorder,
                        ),
                        child: Text(
                          'Answers chat',
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isAnswersChatExpanded = false;
                          });
                        },
                        child: Icon(
                          Icons.close,
                          color: Colors.blue,
                          size: 24.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.black26, height: 1),
                // Messages list
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    child: ListView.builder(
                      controller: _answersChatScrollController,
                      itemCount: _answersChatMessages.length,
                      itemBuilder: (context, i) {
                        final m = _answersChatMessages[i];
                        
                        final isCorrect = m['isCorrect'] == true;
                        final isPending = m['type'] == 'pending';
                        final userName = m['userName'] ?? 'User';
                        final message = m['message'] ?? '';
                        final avatar = m['avatar'];
                        final team = m['team'];

                        return Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar
                              Container(
                                padding: EdgeInsets.all(2.r),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: team == 'orange'
                                        ? Colors.orange
                                        : team == 'blue'
                                            ? Colors.blue
                                            : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 16.r,
                                  backgroundColor: Colors.black,
                                  child: avatar != null
                                      ? Image.asset(avatar)
                                      : Text(
                                          userName[0].toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userName,
                                      style: TextStyle(
                                        color: team == 'orange'
                                            ? Colors.orange
                                            : team == 'blue'
                                                ? Colors.blue
                                                : Colors.white,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      isCorrect ? "correct" : message,
                                      style: TextStyle(
                                        color: isCorrect
                                            ? Colors.greenAccent
                                            : Colors.white70,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                    if (isCorrect)
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.greenAccent,
                                        size: 1,
                                      )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Input field (only if not drawer and hasn't answered)
              ],
            ),

            if (shouldShowAnswerInput)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.black26, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 30.h, // <<< SET HEIGHT HERE
                          padding: EdgeInsets.all(1.6.w),
                          decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color.fromRGBO(94, 212, 255, 1),
                                    Color.fromRGBO(255, 255, 255, 1)
                                  ]),
                              borderRadius: BorderRadius.circular(8.r)),
                          child: TextField(
                            controller: _answerController,
                            focusNode: _answerFocusNode,
                            minLines: 1,
                            // Change maxLines to 1 to enforce single-line behavior that matches the fixed height
                            // maxLines: 3,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                            ),
                            cursorColor: Colors.white.withOpacity(0.8),
                            decoration: InputDecoration(
                              hintText: 'Type anything...',
                              hintStyle: TextStyle(
                                color: Colors.white38,
                                fontSize: 12.sp,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: const Color.fromRGBO(0, 0, 0, 1),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 5.w,
                                vertical: 8
                                    .h, // <<< Adjusted vertical padding to fit 41.h total height
                              ),
                            ),
                            textInputAction: TextInputAction.send,
                            onSubmitted: (text) {
                              _sendAnswer();
                            },
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _sendAnswer();
                        },
                        child: Padding(
                          padding: EdgeInsets.only(left: 8.0.w),
                          child: Image.asset(
                            AppImages.sendButton,
                            scale: 0.9,
                            // height: 30.h,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            // if ((_currentDrawerInfo?['team'] == _currentParticipant?.team))
            if ((isAnsweredCorrectly))
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  alignment: Alignment.center,
                  height: 35.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromRGBO(5, 255, 84, 1),
                        Color.fromRGBO(5, 255, 84, 1)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10.0.h),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: 5.h, bottom: 5.h),
                    child: Stack(
                      children: [
                        Text("Correct answer 🥳",
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.bold,
                              foreground: Paint()
                                ..style = PaintingStyle
                                    .stroke // Tells Flutter to draw an outline
                                ..strokeWidth = 2.0 // Thickness of the outline
                                ..color = Colors.black,
                            )),
                        Text("Correct answer 🥳",
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            )),
                      ],
                    ),
                  ),
                ),
              )
          ],
        ));
  }

  Widget _buildExpandedGeneralChat() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF000000),
      child: Column(
        children: [
          // Header with close icon
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'General Chat',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isGeneralChatExpanded = false;
                    });
                  },
                  child: Icon(
                    Icons.close,
                    color: Colors.blue,
                    size: 24.sp,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.black26, height: 1),
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _chatScrollController,
              padding: EdgeInsets.all(16.w),
              itemCount: _chatMessages.length,
              itemBuilder: (context, idx) {
                final m = _chatMessages[idx];
                final isSystem = m['type'] == 'system';
                final userName = m['userName'] ?? 'User';
                final avatar = m['avatar'];
                final team = m['team'];

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: BoxBorder.all(
                                color: team != null
                                    ? team == 'blue'
                                        ? Colors.blue
                                        : Colors.orange
                                    : Colors.blue,
                                width: 1)),
                        child: CircleAvatar(
                            radius: 16.r,
                            backgroundColor: Colors.black,
                            child: avatar != null
                                ? Image.asset(avatar)
                                : Text(userName[0].toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 8.sp, color: Colors.white))),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              m['message'] ?? '',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
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
          // Input field
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: const BoxDecoration(
              color: Color(0xFF000000),
              border: Border(
                top: BorderSide(color: Colors.black26, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 30.h, // <<< SET HEIGHT HERE
                    padding: EdgeInsets.all(1.6.w),
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color.fromRGBO(94, 212, 255, 1),
                              Color.fromRGBO(255, 255, 255, 1)
                            ]),
                        borderRadius: BorderRadius.circular(8.r)),
                    child: TextField(
                      controller: _chatController,
                      focusNode: _chatFocusNode,
                      minLines: 1,
                      // Change maxLines to 1 to enforce single-line behavior that matches the fixed height
                      maxLines: 1,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                      cursorColor: Colors.white.withOpacity(0.8),
                      decoration: InputDecoration(
                        hintText: 'Type anything...',
                        hintStyle: TextStyle(
                          color: Colors.white38,
                          fontSize: 12.sp,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color.fromRGBO(0, 0, 0, 1),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 5.w,
                          vertical: 8
                              .h, // <<< Adjusted vertical padding to fit 41.h total height
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (text) {
                        _sendChatMessage();
                      },
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    _sendChatMessage();
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: 8.0.w),
                    child: Image.asset(AppImages.sendButton, scale: 0.9),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper widget for playing animation videos
class _AnimationVideo extends StatefulWidget {
  final VideoPlayerController? controller;
  final double width;
  final double height;

  const _AnimationVideo({
    required this.controller,
    required this.width,
    required this.height,
  });

  @override
  State<_AnimationVideo> createState() => _AnimationVideoState();
}

class _AnimationVideoState extends State<_AnimationVideo> {
  @override
  void initState() {
    super.initState();
    // Start playing the video if controller is ready
    _startVideo();
  }

  void _startVideo() {
    if (widget.controller != null && widget.controller!.value.isInitialized) {
      widget.controller!.seekTo(Duration.zero);
      widget.controller!.play();
      
    } else {
      
    }
  }

  void _stopVideo() {
    if (widget.controller != null && widget.controller!.value.isInitialized) {
      widget.controller!.pause();
      widget.controller!.seekTo(Duration.zero);
      
    }
  }

  @override
  void didUpdateWidget(_AnimationVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If controller changed, stop old and start new
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller != null &&
          oldWidget.controller!.value.isInitialized) {
        oldWidget.controller!.pause();
        oldWidget.controller!.seekTo(Duration.zero);
      }
      _startVideo();
    }
  }

  @override
  void dispose() {
    // Stop and reset the video when widget is disposed
    _stopVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller == null || !widget.controller!.value.isInitialized) {
      
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: widget.controller!.value.size.width,
          height: widget.controller!.value.size.height,
          child: VideoPlayer(widget.controller!),
        ),
      ),
    );
  }
}

class TeamScoreBar extends StatelessWidget {
  final Color barColor;
  final String label;
  final Color labelBgColor;
  final Color trophyColor;
  final double width;
  final double height;
  final int maxScore;
  final int score;

  const TeamScoreBar({
    super.key,
    required this.barColor,
    required this.label,
    required this.maxScore,
    required this.labelBgColor,
    required this.score,
    this.trophyColor = Colors.yellow,
    this.width = 220,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    num safeMax = (maxScore <= 0 ? 1 : maxScore);
    num safeScore = (score < 0 ? 0 : score);

    double inverseWidth = width * (1 - (safeScore / safeMax));
    double finalWidth = inverseWidth.clamp(10, width);

    print((width /
            ((width - 20) /
                ((width - 20) * (score <= 0 ? 1 : score / maxScore)))) -
        40);
    
    print(
        ((width - 20) / ((width - 20) * (score <= 0 ? 1 : score / maxScore))));
    final isTablet = MediaQuery.of(context).size.width > 600;
    return Container(
      width: width,
      height: height,
      // padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(color: Colors.grey.shade700, width: 1),
      ),
      child: Row(
        children: [
          // LEFT COLOR BAR
          Expanded(
            child: Container(
              height: isTablet ? height : null,
              width: score.w,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(height / 2),
              ),
              child: Row(
                children: [
                  const Spacer(),

                  // CIRCLE LABEL
                  teamBadge(
                      label: label,
                      color: labelBgColor,
                      onTap: () {},
                      isTablet: isTablet)
                ],
              ),
            ),
          ),
          SizedBox(
              width: score == 0
                  ? (width /
                          ((width - 20) /
                              ((width - 20) *
                                  (score <= 0 ? 1 : score / maxScore)))) -
                      80
                  : (maxScore - score).clamp(0, width - 20).toDouble()),

          // TROPHY ICON
          Icon(
            Icons.emoji_events,
            color: trophyColor,
            size: height * 0.55,
          ),

          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

Widget teamBadge({
  required String label,
  required Color color,
  required VoidCallback onTap,
  bool isTablet = false,
}) {
  debugPrint("ISTABLET: $isTablet");
  final Widget circle = Container(
    width: isTablet ? 25.w : 32.w,
    height: isTablet ? 32.h : 35.h,
    // padding:EdgeInsets.all(5.h),
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 1.5),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.45),
          blurRadius: 6.r,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    alignment: Alignment.center,
    child: Text(
      label,
      style: GoogleFonts.lato(
        color: Colors.white,
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  return GestureDetector(onTap: onTap, child: circle);
}
