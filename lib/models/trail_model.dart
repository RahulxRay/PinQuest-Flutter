import 'package:hive/hive.dart';

part 'trail_model.g.dart';

@HiveType(typeId: 3)
class TrailModel extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String description;
  
  @HiveField(3)
  List<String> pinIds;
  
  @HiveField(4)
  String createdBy;
  
  @HiveField(5)
  DateTime createdAt;
  
  @HiveField(6)
  String? imageUrl;
  
  @HiveField(7)
  TrailDifficulty difficulty;
  
  @HiveField(8)
  int estimatedDuration; // in minutes
  
  @HiveField(9)
  double distance; // in kilometers
  
  @HiveField(10)
  List<String> tags;
  
  @HiveField(11)
  bool isPublic;
  
  @HiveField(12)
  int completionCount;
  
  @HiveField(13)
  double rating;

  TrailModel({
    required this.id,
    required this.title,
    required this.description,
    required this.pinIds,
    required this.createdBy,
    required this.createdAt,
    this.imageUrl,
    this.difficulty = TrailDifficulty.easy,
    this.estimatedDuration = 60,
    this.distance = 0.0,
    this.tags = const [],
    this.isPublic = true,
    this.completionCount = 0,
    this.rating = 0.0,
  });

  factory TrailModel.fromJson(Map<String, dynamic> json) {
    return TrailModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      pinIds: List<String>.from(json['pinIds']),
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      imageUrl: json['imageUrl'],
      difficulty: TrailDifficulty.values.firstWhere(
        (e) => e.toString() == 'TrailDifficulty.${json['difficulty']}',
        orElse: () => TrailDifficulty.easy,
      ),
      estimatedDuration: json['estimatedDuration'] ?? 60,
      distance: (json['distance'] ?? 0.0).toDouble(),
      tags: List<String>.from(json['tags'] ?? []),
      isPublic: json['isPublic'] ?? true,
      completionCount: json['completionCount'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'pinIds': pinIds,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'imageUrl': imageUrl,
      'difficulty': difficulty.toString().split('.').last,
      'estimatedDuration': estimatedDuration,
      'distance': distance,
      'tags': tags,
      'isPublic': isPublic,
      'completionCount': completionCount,
      'rating': rating,
    };
  }

  // Calculate completion percentage for a user
  double getCompletionPercentage(List<String> userCompletedPins) {
    if (pinIds.isEmpty) return 0.0;
    
    int completedCount = 0;
    for (String pinId in pinIds) {
      if (userCompletedPins.contains(pinId)) {
        completedCount++;
      }
    }
    
    return completedCount / pinIds.length;
  }

  bool isCompleted(List<String> userCompletedPins) {
    return getCompletionPercentage(userCompletedPins) >= 1.0;
  }
}

@HiveType(typeId: 4)
enum TrailDifficulty {
  @HiveField(0)
  easy,
  
  @HiveField(1)
  medium,
  
  @HiveField(2)
  hard,
  
  @HiveField(3)
  expert;

  String get displayName {
    switch (this) {
      case TrailDifficulty.easy:
        return 'Easy';
      case TrailDifficulty.medium:
        return 'Medium';
      case TrailDifficulty.hard:
        return 'Hard';
      case TrailDifficulty.expert:
        return 'Expert';
    }
  }

  String get description {
    switch (this) {
      case TrailDifficulty.easy:
        return 'Perfect for beginners';
      case TrailDifficulty.medium:
        return 'Moderate challenge';
      case TrailDifficulty.hard:
        return 'For experienced explorers';
      case TrailDifficulty.expert:
        return 'Ultimate challenge';
    }
  }
}
