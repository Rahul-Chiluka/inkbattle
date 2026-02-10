import 'dart:convert';
import 'dart:developer';
import 'user_model.dart';

RoomModel roomModelFromJson(String str) => RoomModel.fromJson(json.decode(str));

String roomModelToJson(RoomModel data) => json.encode(data.toJson());

class RoomModel {
  int? id;
  String? code;
  String? name;
  String? roomType;
  String? language;
  String? script;
  String? country;
  int? pointsTarget;
  dynamic category; // Can be String? or List<String>? for backward compatibility
  String? gamePlay;
  String? gameMode;
  int? entryPoints;
  bool? voiceEnabled;
  bool? isPublic;
  int? maxPlayers;
  String? status;
  int? ownerId;
  int? themeId;

  // --- NEW GAME STATE FIELDS ---
  int? currentDrawerId; // BIGINT.UNSIGNED (int in Dart)
  int? currentRound; // INTEGER
  DateTime? roundStartTime; // DATETIME
  String? roundPhase; // STRING
  DateTime? roundPhaseEndTime; // DATETIME
  int? roundRemainingTime; // INTEGER
  // -----------------------------

  int? participantCount;
  bool? isFull;
  List<RoomParticipant>? participants;

  UserModel? owner;
  DateTime? createdAt;
  DateTime? updatedAt;

  RoomModel({
    this.id,
    this.code,
    this.name,
    this.roomType,
    this.language,
    this.script,
    this.country,
    this.pointsTarget,
    this.category,
    this.gamePlay,
    this.gameMode,
    this.entryPoints,
    this.voiceEnabled,
    this.isPublic,
    this.maxPlayers,
    this.status,
    this.ownerId,
    this.themeId,
    // NEW FIELDS
    this.currentDrawerId,
    this.currentRound,
    this.roundStartTime,
    this.roundPhase,
    this.roundPhaseEndTime,
    this.roundRemainingTime,
    // END NEW FIELDS
    this.participantCount,
    this.isFull,
    this.participants,
    this.owner,
    this.createdAt,
    this.updatedAt,
  });

  static List<RoomParticipant>? _parseRoomParticipants(dynamic raw) {
    if (raw == null || raw is! List) return null;
    try {
      return List<RoomParticipant>.from(
        (raw as List<dynamic>).map((x) {
          final m = x is Map<String, dynamic> ? x : Map<String, dynamic>.from(x as Map);
          return RoomParticipant.fromJson(m);
        }),
      );
    } catch (_) {
      return null;
    }
  }

  factory RoomModel.fromJson(Map<String, dynamic> json) => RoomModel(
    id: json["id"],
    code: json["code"],
    name: json["name"],
    roomType: json["roomType"],
    language: json["language"],
    script: json["script"],
    country: json["country"],
    pointsTarget: json["targetPoints"],
    category: json["category"],
    gamePlay: json["gamePlay"],
    gameMode: json["gameMode"],
    entryPoints: json["entryPoints"],
    voiceEnabled: json["voiceEnabled"],
    isPublic: json["isPublic"],
    maxPlayers: json["maxPlayers"],
    status: json["status"],
    ownerId: json["ownerId"],
    themeId: json["themeId"],

    // --- NEW GAME STATE JSON PARSING ---
    currentDrawerId: json["currentDrawerId"],
    currentRound: json["currentRound"],
    roundStartTime: json["roundStartTime"] == null
        ? null
        : DateTime.parse(json["roundStartTime"]),
    roundPhase: json["roundPhase"],
    roundPhaseEndTime: json["roundPhaseEndTime"] == null
        ? null
        : DateTime.parse(json["roundPhaseEndTime"]),
    roundRemainingTime: json["roundRemainingTime"],

    // ------------------------------------
    participantCount: json["participantCount"],
    isFull: json["isFull"],
    participants: _parseRoomParticipants(json["RoomParticipants"]),
    owner: json["owner"] == null ? null : UserModel.fromJson(json["owner"]),
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "code": code,
    "name": name,
    "roomType": roomType,
    "language": language,
    "script": script,
    "country": country,
    "pointsTarget": pointsTarget,
    "category": category,
    "gamePlay": gamePlay,
    "gameMode": gameMode,
    "entryPoints": entryPoints,
    "voiceEnabled": voiceEnabled,
    "isPublic": isPublic,
    "maxPlayers": maxPlayers,
    "status": status,
    "ownerId": ownerId,
    "themeId": themeId,

    // --- NEW GAME STATE JSON OUTPUT ---
    "currentDrawerId": currentDrawerId,
    "currentRound": currentRound,
    "roundStartTime": roundStartTime?.toIso8601String(),
    "roundPhase": roundPhase,
    "roundPhaseEndTime": roundPhaseEndTime?.toIso8601String(),
    "roundRemainingTime": roundRemainingTime,

    // ----------------------------------
    "participantCount": participantCount,
    "isFull": isFull,
    "RoomParticipants": participants?.map((x) => x.toJson()).toList(),
    "owner": owner?.toJson(),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

class RoomParticipant {
  int? id;
  int? roomId;
  int? userId;
  String? team;
  int? score;
  bool? isDrawer;
  bool? isActive;
  bool? ready; // true when user has tapped Ready in lobby
  UserModel? user;

  RoomParticipant({
    this.id,
    this.roomId,
    this.userId,
    this.team,
    this.score,
    this.isDrawer,
    this.isActive,
    this.ready,
    this.user,
  });

  factory RoomParticipant.fromJson(Map<String, dynamic> json) {
    // Handle both formats: nested User object from API and flattened data from socket
    UserModel? user;
    if (json["User"] != null) {
      // From API - nested User object (capital U)
      try {
        user = UserModel.fromJson(json["User"] is Map<String, dynamic>
            ? json["User"] as Map<String, dynamic>
            : Map<String, dynamic>.from(json["User"] as Map));
      } catch (_) {
        user = null;
      }
    } else if (json["user"] != null) {
      // From API - Sequelize uses lowercase "user" when serializing include
      try {
        user = UserModel.fromJson(json["user"] is Map<String, dynamic>
            ? json["user"] as Map<String, dynamic>
            : Map<String, dynamic>.from(json["user"] as Map));
      } catch (_) {
        user = null;
      }
    } else if (json["name"] != null) {
      // From socket - flattened data
      user = UserModel(
        id: json["id"],
        name: json["name"],
        avatar: json["avatar"],
        coins: json["coins"],
      );
    }

    return RoomParticipant(
      id: json["id"],
      roomId: json["roomId"],
      userId: json["userId"] ?? json["id"], // Socket uses 'id' for userId
      team: json["team"],
      score: json["score"] ?? 0,
      isDrawer: json["isDrawer"] ?? false,
      isActive: json["isActive"] ?? true,
      ready: json["ready"] == true,
      user: user,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "roomId": roomId,
    "userId": userId,
    "team": team,
    "score": score,
    "isDrawer": isDrawer,
    "isActive": isActive,
    "ready": ready,
    "User": user?.toJson(),
  };
}

class RoomResponse {
  bool? success;
  RoomModel? room;
  RoomParticipant? participant;
  bool? matched;
  bool? created;

  RoomResponse({
    this.success,
    this.room,
    this.participant,
    this.matched,
    this.created,
  });

  factory RoomResponse.fromJson(Map<String, dynamic> json) => RoomResponse(
    success: json["success"],
    room: json["room"] == null ? null : RoomModel.fromJson(json["room"]),
    participant: json["participant"] == null
        ? null
        : RoomParticipant.fromJson(json["participant"]),
    matched: json["matched"],
    created: json["created"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "room": room?.toJson(),
    "participant": participant?.toJson(),
    "matched": matched,
    "created": created,
  };
}

class RoomListResponse {
  bool? success;
  List<RoomModel>? rooms;

  RoomListResponse({this.success, this.rooms});
  // developer.log('RoomListResponse: ${rooms?.length ?? 0} rooms. $rooms', name: 'RoomListResponse');
  factory RoomListResponse.fromJson(Map<String, dynamic> json) {
    final roomsRaw = json["rooms"];
    List<RoomModel>? rooms;
    if (roomsRaw != null && roomsRaw is List) {
      try {
        rooms = List<RoomModel>.from(
          (roomsRaw as List<dynamic>).map((x) {
            if (x is Map<String, dynamic>) {
              return RoomModel.fromJson(x);
            }
            return RoomModel.fromJson(Map<String, dynamic>.from(x as Map));
          }),
        );
      } catch (e) {
        rooms = [];
      }
    }
    return RoomListResponse(success: json["success"], rooms: rooms);
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "rooms": rooms?.map((x) => x.toJson()).toList(),
  };
}
