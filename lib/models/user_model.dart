import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String email;
  
  @HiveField(2)
  String displayName;
  
  @HiveField(3)
  String? photoUrl;
  
  @HiveField(4)
  int totalPoints;
  
  @HiveField(5)
  List<String> badges;
  
  @HiveField(6)
  List<String> completedPins;
  
  @HiveField(7)
  List<String> completedTrails;
  
  @HiveField(8)
  DateTime createdAt;
  
  @HiveField(9)
  DateTime? lastActiveAt;
  
  @HiveField(10)
  bool isSponsored;
  
  @HiveField(11)
  String? sponsorCompany;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.totalPoints = 0,
    this.badges = const [],
    this.completedPins = const [],
    this.completedTrails = const [],
    required this.createdAt,
    this.lastActiveAt,
    this.isSponsored = false,
    this.sponsorCompany,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      totalPoints: json['totalPoints'] ?? 0,
      badges: List<String>.from(json['badges'] ?? []),
      completedPins: List<String>.from(json['completedPins'] ?? []),
      completedTrails: List<String>.from(json['completedTrails'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      lastActiveAt: json['lastActiveAt'] != null 
          ? DateTime.parse(json['lastActiveAt']) 
          : null,
      isSponsored: json['isSponsored'] ?? false,
      sponsorCompany: json['sponsorCompany'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'totalPoints': totalPoints,
      'badges': badges,
      'completedPins': completedPins,
      'completedTrails': completedTrails,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'isSponsored': isSponsored,
      'sponsorCompany': sponsorCompany,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    int? totalPoints,
    List<String>? badges,
    List<String>? completedPins,
    List<String>? completedTrails,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    bool? isSponsored,
    String? sponsorCompany,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      totalPoints: totalPoints ?? this.totalPoints,
      badges: badges ?? this.badges,
      completedPins: completedPins ?? this.completedPins,
      completedTrails: completedTrails ?? this.completedTrails,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      isSponsored: isSponsored ?? this.isSponsored,
      sponsorCompany: sponsorCompany ?? this.sponsorCompany,
    );
  }
}
