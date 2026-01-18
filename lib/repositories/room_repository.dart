import 'package:dartz/dartz.dart';
import 'package:inkbattle_frontend/constants/api_end_points.dart';
import 'package:inkbattle_frontend/models/room_model.dart';
import 'package:inkbattle_frontend/utils/api/api_exceptions.dart';
import 'package:inkbattle_frontend/utils/api/api_manager.dart';
import 'package:inkbattle_frontend/utils/api/failure.dart';

class RoomRepository {
  final ApiManager _apiManager = ApiManager();

  // Create room (simplified - only name required, settings in lobby)
  Future<Either<Failure, RoomResponse>> createRoom({
    required String name,
  }) async {
    try {
      var payload = {
        "name": name,
      };

      var jsonResponse = await _apiManager.post(
        ApiEndPoints.createRoom,
        payload,
        isTokenMandatory: true,
      );

      var roomResponse = RoomResponse.fromJson(jsonResponse);
      return right(roomResponse);
    } on AppException catch (e) {
      return left(ApiFailure(message: e.message));
    } catch (e) {
      return left(ApiFailure(message: e.toString()));
    }
  }

  // Update lobby settings (owner only)
  Future<Either<Failure, RoomResponse>> updateLobbySettings({
    required String roomId,
    String? gameMode,
    String? language,
    String? script,
    String? country,
    List<String>? categories,
    int? entryPoints,
    int? targetPoints,
    bool? voiceEnabled,
    bool? isPublic,
    int? maxPlayers,
  }) async {
    try {
      var payload = {
        "gameMode": gameMode,
        "language": language,
        "script": script,
        "country": country,
        "category": categories ?? [],
        "entryPoints": entryPoints,
        "targetPoints": targetPoints,
        "voiceEnabled": voiceEnabled,
        "isPublic": isPublic,
        "maxPlayers": maxPlayers,
      };

      var jsonResponse = await _apiManager.post(
        '${ApiEndPoints.rooms}/$roomId/update-settings',
        payload,
        isTokenMandatory: true,
      );

      var roomResponse = RoomResponse.fromJson(jsonResponse);
      return right(roomResponse);
    } on AppException catch (e) {
      return left(ApiFailure(message: e.message));
    } catch (e) {
      return left(ApiFailure(message: e.toString()));
    }
  }

  // Select team (for team_vs_team mode)
  Future<Either<Failure, bool>> selectTeam({
    required String roomId,
    required String team, // 'orange' or 'blue'
  }) async {
    try {
      var payload = {
        "team": team,
      };

      await _apiManager.post(
        '${ApiEndPoints.rooms}/$roomId/select-team',
        payload,
        isTokenMandatory: true,
      );

      return right(true);
    } on AppException catch (e) {
      return left(ApiFailure(message: e.message));
    } catch (e) {
      return left(ApiFailure(message: e.toString()));
    }
  }

  // Join room by code
  Future<Either<Failure, RoomResponse>> joinRoomByCode({
    required String roomCode,
    String? team,
  }) async {
    try {
      var payload = {
        "code": roomCode,
      };

      // Add team if provided (for team_vs_team mode)
      if (team != null && (team == 'orange' || team == 'blue')) {
        payload["team"] = team;
      }

      var jsonResponse = await _apiManager.post(
        ApiEndPoints.joinRoom,
        payload,
        isTokenMandatory: true,
      );

      var roomResponse = RoomResponse.fromJson(jsonResponse);
      return right(roomResponse);
    } on AppException catch (e) {
      return left(ApiFailure(message: e.message));
    } catch (e) {
      return left(ApiFailure(message: e.toString()));
    }
  }

  // Join room by ID
  Future<Either<Failure, RoomResponse>> joinRoomById({
    required int roomId,
  }) async {
    try {
      var payload = {
        "roomId": roomId,
      };

      var jsonResponse = await _apiManager.post(
        ApiEndPoints.joinRoomById,
        payload,
        isTokenMandatory: true,
      );

      var roomResponse = RoomResponse.fromJson(jsonResponse);
      return right(roomResponse);
    } on AppException catch (e) {
      return left(ApiFailure(message: e.message));
    } catch (e) {
      return left(ApiFailure(message: e.toString()));
    }
  }

  // Get room by code (for checking entry cost before joining)
  Future<Either<Failure, RoomModel>> getRoomByCode({
    required String roomCode,
  }) async {
    try {
      var jsonResponse = await _apiManager.get(
        '${ApiEndPoints.rooms}/code/$roomCode',
        isTokenMandatory: true,
      );

      var roomModel = RoomModel.fromJson(jsonResponse['room']);
      return right(roomModel);
    } on AppException catch (e) {
      return left(ApiFailure(message: e.message));
    } catch (e) {
      return left(ApiFailure(message: e.toString()));
    }
  }

  // Get room details
  Future<Either<Failure, RoomModel>> getRoomDetails({
    required String roomId,
  }) async {
    try {
      var jsonResponse = await _apiManager.get(
        ApiEndPoints.getRoomDetails(roomId),
        isTokenMandatory: true,
      );

      var roomModel = RoomModel.fromJson(jsonResponse['room']);
      return right(roomModel);
    } on AppException catch (e) {
      return left(ApiFailure(message: e.message));
    } catch (e) {
      return left(ApiFailure(message: e.toString()));
    }
  }

  // Leave room
  Future<Either<Failure, bool>> leaveRoom({
    required String roomId,
  }) async {
    try {
      await _apiManager.post(
        ApiEndPoints.leaveRoom(roomId),
        {},
        isTokenMandatory: true,
      );

      return right(true);
    } on AppException catch (e) {
      return left(ApiFailure(message: e.message));
    } catch (e) {
      return left(ApiFailure(message: e.toString()));
    }
  }

  // Play random match
  Future<Either<Failure, RoomResponse>> playRandom({
    String? gameMode,
    String? language,
    String? country,
    List<String>? categories,
    int? entryPoints,
    int? targetPoints,
    bool? voiceEnabled,
  }) async {
    try { 
      var payload = {
        "language": language ?? "english",
        "country": country,
        "category": categories ?? [],
        "targetPoints": targetPoints ?? 100,
        "voiceEnabled": voiceEnabled ?? true,
      };

      var jsonResponse = await _apiManager.post(
        ApiEndPoints.playRandom,
        payload,
        isTokenMandatory: true,
      );

      var roomResponse = RoomResponse.fromJson(jsonResponse);
      return right(roomResponse);
    } on AppException catch (e) {
      return left(ApiFailure(message: e.message));
    } catch (e) {
      return left(ApiFailure(message: e.toString()));
    }
  }

  // Create public room
  Future<Either<Failure, RoomResponse>> createPublicRoom({
    required String name,
    String? gameMode,
    String? language,
    String? country,
    List<String>? categories, // Can be String? or List<String>? for multi-select
    int? entryPoints,
    int? targetPoints,
    int? maxPlayers,
  }) async {
    try {
      var payload = {
        "name": name,
        "gameMode": gameMode ?? "1v1",
        "language": language ?? "english",
        "country": country,
        "category": categories ?? [],
        "entryPoints": entryPoints ?? 250,
        "targetPoints": targetPoints ?? 100,
        "maxPlayers": maxPlayers ?? 2,
        "isPublic": true,
      };

      var jsonResponse = await _apiManager.post(
        ApiEndPoints.createPublicRoom,
        payload,
        isTokenMandatory: true,
      );

      var roomResponse = RoomResponse.fromJson(jsonResponse);
      return right(roomResponse);
    } on AppException catch (e) {
      return left(ApiFailure(message: e.message));
    } catch (e) {
      return left(ApiFailure(message: e.toString()));
    }
  }

  // Create team room
  Future<Either<Failure, RoomResponse>> createTeamRoom({
    required String name,
    String? language,
    String? country,
    List<String>? categories,
    int? entryPoints,
    int? targetPoints,
    int? maxPlayers,
  }) async {
    try {
      var payload = {
        "name": name,
        "gameMode": "team_vs_team",
        "language": language ?? "english",
        "country": country,
        "category": categories ?? [],
        "entryPoints": entryPoints ?? 250,
        "targetPoints": targetPoints ?? 100,
        "maxPlayers": maxPlayers ?? 4,
        "isPublic": false,
      };

      var jsonResponse = await _apiManager.post(
        ApiEndPoints.createTeamRoom,
        payload,
        isTokenMandatory: true,
      );

      var roomResponse = RoomResponse.fromJson(jsonResponse);
      return right(roomResponse);
    } on AppException catch (e) {
      return left(ApiFailure(message: e.message));
    } catch (e) {
      return left(ApiFailure(message: e.toString()));
    }
  }

  // List public rooms
  Future<Either<Failure, RoomListResponse>> listRooms({
    String? gameMode,
    String? language,
    String? script,
    String? country,
    List<String>? categories,
    bool? voiceEnabled,
    int? targetPoints,
    int? page,
    int? limit,
  }) async {
    try {
      var queryParams = <String, dynamic>{};
      if (gameMode != null) queryParams['gameMode'] = gameMode;
      if (language != null) queryParams['language'] = language;
      if (country != null) queryParams['country'] = country;
      if (categories != null && categories.isNotEmpty) queryParams['category'] = categories;
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (script != null) queryParams['script'] = script;
      if (voiceEnabled != null) queryParams['voiceEnabled'] = voiceEnabled;
      if (targetPoints != null) queryParams['pointsTarget'] = targetPoints;

      String url = ApiEndPoints.listRooms;
      if (queryParams.isNotEmpty) {
        final queryParts = <String>[];
        queryParams.forEach((key, value) {
          if (value is List) {
            // Handle arrays by sending multiple query parameters or comma-separated
            // For category array, send as comma-separated string
            queryParts.add('$key=${Uri.encodeComponent(value.join(','))}');
          } else {
            queryParts.add('$key=${Uri.encodeComponent(value.toString())}');
          }
        });
        url = '$url?${queryParts.join('&')}';
      }

      var jsonResponse = await _apiManager.get(
        url,
        isTokenMandatory: true,
      );

      var roomListResponse = RoomListResponse.fromJson(jsonResponse);
      return right(roomListResponse);
    } on AppException catch (e) {
      return left(ApiFailure(message: e.message));
    } catch (e) {
      return left(ApiFailure(message: e.toString()));
    }
  }
}
