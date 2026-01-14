import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:developer';
import 'dart:async'; // Import for Completer
import 'package:inkbattle_frontend/config/environment.dart';



class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;

  bool get isConnected => _isConnected;
  IO.Socket? get socket => _socket;

  void connect(String token) {
    if (_socket != null && _isConnected) {
      _socket?.disconnect();
    }
    print("Sending token: $token");
    _socket = IO.io(
      Environment.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({'token': token})
          .setExtraHeaders({'X-App-Secret': Environment.appSecret})
          .enableForceNew()
          .build(),
    );

    _socket?.onConnect((_) {
      _isConnected = true;
      log('Socket connected: ${_socket?.id}');
    });

    _socket?.onDisconnect((_) {
      _isConnected = false;
      log('Socket disconnected');
    });

    _socket?.onError((error) {
      log('Socket error: $error');
    });

    _socket?.onConnectError((error) {
      log('Socket connection error: $error');
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
    log('Socket disconnected and disposed');
  }

  // New request method for emitting events with acknowledgment
  Future<dynamic> request(String event, [dynamic data]) {
    final completer = Completer<dynamic>();
    if (_socket == null || !_isConnected) {
      completer.completeError('Socket not connected for event: $event');
      return completer.future;
    }

    _socket?.emitWithAck(
      event,
      data,
      ack: (response) {
        if (response is Map && response.containsKey('error')) {
          completer.completeError(response['error']);
        } else {
          completer.complete(response);
        }
      },
    );
    return completer.future;
  }

  // Room events
  void joinRoom(String roomId) {
    _socket?.emit('join_room', {'roomId': roomId});
    log('Joining room: $roomId');
  }

  void leaveRoom(String roomId) {
    _socket?.emit('leave_room', {'roomId': roomId});
    log('Leaving room: $roomId');
    _socket?.disconnect();
  }

  // Drawing events
  void sendDrawing(String roomId, Map<String, dynamic> drawData) {
    _socket?.emit('drawing_data', {'roomId': roomId, 'strokes': drawData});
  }

  void clearCanvas(String roomId, [int? canvasVersion]) {
    _socket?.emit('clear_canvas', {
      'roomId': roomId,
      'canvasVersion': canvasVersion,
    });
  }

  // Chat events
  void sendMessage(String roomId, String message, String avatar) {
    _socket?.emit('chat_message',
        {'roomId': roomId, 'content': message, 'avatar': avatar});
  }

  void sendGuess(String roomId, String guess) {
    _socket?.emit('submit_guess', {'roomId': roomId, 'guess': guess});
  }

  void sendHint(String roomId, String revealedWord, int hintsRemaining) {
    _socket?.emit('word_hint', {
      'roomId': roomId,
      'revealedWord': revealedWord,
      'hintsRemaining': hintsRemaining,
    });
  }

  // Game events
  void startGame(String roomId) {
    _socket?.emit('start_game', {'roomId': roomId});
  }

  void nextRound(String roomId) {
    _socket?.emit('next_round', {'roomId': roomId});
  }

  void continueWaiting(String roomId) {
    _socket?.emit('continue_waiting', {'roomId': roomId});
  }

  // Listeners
  void onRoomJoined(Function(dynamic) callback) {
    _socket?.on('room_joined', callback);
  }

  void onRoomParticipants(Function(dynamic) callback) {
    _socket?.on('room_participants', callback);
  }

  void onUserBannedFromGame(Function(dynamic) callback) {
    _socket?.on('user_banned_from_room', callback);
  }

  void onUserKickedFromGame(Function(dynamic) callback) {
    _socket?.on('user_banned', callback);
  }

  void onRequestCanvasData(Function(dynamic) callback) {
    ///  {roomCode: room.code,
    ///  targetSocketId: resumingSocketId }
    ///
    _socket?.on('request_canvas_data', callback);
  }

  void onCanvasDataReceived(Function(dynamic) callback) {
    /// {
    /// roomCode: roomCode,
    ///history: history,
    ///}
    _socket?.on('canvas_resume', callback);
  }

  void onPlayerJoined(Function(dynamic) callback) {
    _socket?.on('player_joined', callback);
  }

  void onPlayerLeft(Function(dynamic) callback) {
    _socket?.on('player_left', callback);
  }
  void onEliminatePlayer(Function(dynamic) callback){
    _socket?.on('eliminate_player',callback);
  }

  void onDraw(Function(dynamic) callback) {
    _socket?.on('drawing_data', callback);
  }

  void onDrawingData(Function(dynamic) callback) {
    _socket?.on('drawing_data', callback);
  }

  // ✅ PHASE 2: Acknowledgment listener for drawing data
  void onDrawingAck(Function(dynamic) callback) {
    _socket?.on('drawing_ack', callback);
  }

  void onClearCanvas(Function(dynamic) callback) {
    _socket?.on('clear_canvas', callback);
  }

  void onCanvasClear(Function(dynamic) callback) {
    _socket?.on('canvas_cleared', callback);
  }

  void onChatMessage(Function(dynamic) callback) {
    _socket?.on('chat_message', callback);
  }

  void onCorrectGuess(Function(dynamic) callback) {
    _socket?.on('correct_guess', callback);
  }

  void onGuessResult(Function(dynamic) callback) {
    _socket?.on('guess_result', callback);
  }

  void onIncorrectGuess(Function(dynamic) callback) {
    _socket?.on('incorrect_guess', callback);
  }

  void onWordHint(Function(dynamic) callback) {
    _socket?.on('word_hint', callback);
  }

  void onGameStart(Function(dynamic) callback) {
    _socket?.on('game_started', callback);
  }

  void onRoundStart(Function(dynamic) callback) {
    _socket?.on('round_started', callback);
  }

  void onRoundEnd(Function(dynamic) callback) {
    _socket?.on('round_end', callback);
  }

  void onGameEnd(Function(dynamic) callback) {
    _socket?.on('game_end', callback);
  }

  void onScoreUpdate(Function(dynamic) callback) {
    _socket?.on('score_update', callback);
  }

  void onSkipTurn(Function(dynamic) callback) {
    _socket?.on('skip_turn', callback);
  }
  void onPlayerRemoved(Function(dynamic) callback){
    _socket?.on('player_removed',callback);
  }

  void onLobbyTimeExceeded(Function(dynamic) callback) {
    /*{
      "roomCode": "ABCD12",
      "message": "It looks like everyone left! Do you want to continue waiting or exit?",
      "duration": 120
    } */
    _socket?.on('lobby_time_exceeded', callback);
  }

  void onRoomClosed(Function(dynamic) callback) {
    _socket?.on('room_closed', callback);
  }

  // New events for refactored game
  void onSettingsUpdated(Function(dynamic) callback) {
    _socket?.on('settings_updated', callback);
  }

  void onPhaseChange(Function(dynamic) callback) {
    _socket?.on('phase_change', callback);
  }

  void onDrawerSelected(Function(dynamic) callback) {
    _socket?.on('drawer_selected', callback);
  }

  void onWordOptions(Function(dynamic) callback) {
    _socket?.on('word_options', callback);
  }

  void onDrawerSkipped(Function(dynamic) callback) {
    _socket?.on('drawer_skipped', callback);
  }

  void onTimeUpdate(Function(dynamic) callback) {
    _socket?.on('time_update', callback);
  }

  void onClearChat(Function(dynamic) callback) {
    _socket?.on('clear_chat', callback);
  }

  void onGameStarted(Function(dynamic) callback) {
    _socket?.on('game_started', callback);
  }

  void onGameEnded(Function(dynamic) callback) {
    _socket?.on('game_ended', callback);
  }

  // Emit new events
  void updateSettings(String roomId, Map<String, dynamic> settings) {
    _socket?.emit('update_settings', {'roomId': roomId, 'settings': settings});
  }

  void sendCanvasData(String roomCode, String targetSocketId,
      List<Map<String, dynamic>> history, double remainingTime) {
    _socket?.emit('send_canvas_data', {
      'roomCode': roomCode,
      'targetSocketId': targetSocketId,
      'history': history,
      'remainingTime': remainingTime
    });
  }

  void skipTurn(String roomid) {
    _socket!.emit('skip_turn', {"roomId": roomid});
  }

  void selectTeam(String roomId, String team) {
    print("selecting Team");
    _socket?.emit('select_team', {'roomId': roomId, 'team': team});
  }

  void chooseWord(String roomId, String word) {
    _socket?.emit('choose_word', {'roomId': roomId, 'word': word});
  }

  // Remove listeners
  void removeAllListeners() {
    _socket?.off('room_joined');
    _socket?.off('room_participants');
    _socket?.off('player_joined');
    _socket?.off('player_left');
    _socket?.off('drawing_data');
    _socket?.off('clear_canvas');
    _socket?.off('canvas_cleared');
    _socket?.off('chat_message');
    _socket?.off('correct_guess');
    _socket?.off('guess_result');
    _socket?.off('game_started');
    _socket?.off('round_started');
    _socket?.off('round_end');
    _socket?.off('game_end');
    _socket?.off('score_update');
    _socket?.off('room_closed');
    _socket?.off('settings_updated');
    _socket?.off('phase_change');
    _socket?.off('drawer_selected');
    _socket?.off('word_options');
    _socket?.off('drawer_skipped');
    _socket?.off('time_update');
    _socket?.off('clear_chat');
    _socket?.off('game_ended');
  }
}
