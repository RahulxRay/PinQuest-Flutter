import 'package:hive/hive.dart';

part 'badge_model.g.dart';

@HiveType(typeId: 5)
class BadgeModel extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String description;
  
  @HiveField(3)
  String iconPath;
  
  @HiveField(4)
  BadgeCategory category;
  
  @HiveField(5)
  int requiredPoints;
  
  @HiveField(6)
  String? requiredAction;
  
  @HiveField(7)
  int? requiredCount;
  
  @HiveField(8)
  BadgeRarity rarity;

  BadgeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.category,
    this.requiredPoints = 0,
    this.requiredAction,
    this.requiredCount,
    this.rarity = BadgeRarity.common,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      iconPath: json['iconPath'],
      category: BadgeCategory.values.firstWhere(
        (e) => e.toString() == 'BadgeCategory.${json['category']}',
        orElse: () => BadgeCategory.general,
      ),
      requiredPoints: json['requiredPoints'] ?? 0,
      requiredAction: json['requiredAction'],
      requiredCount: json['requiredCount'],
      rarity: BadgeRarity.values.firstWhere(
        (e) => e.toString() == 'BadgeRarity.${json['rarity']}',
        orElse: () => BadgeRarity.common,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconPath': iconPath,
      'category': category.toString().split('.').last,
      'requiredPoints': requiredPoints,
      'requiredAction': requiredAction,
      'requiredCount': requiredCount,
      'rarity': rarity.toString().split('.').last,
    };
  }
}

@HiveType(typeId: 6)
enum BadgeCategory {
  @HiveField(0)
  general,
  
  @HiveField(1)
  explorer,
  
  @HiveField(2)
  creator,
  
  @HiveField(3)
  social,
  
  @HiveField(4)
  achievement;
}

@HiveType(typeId: 7)
enum BadgeRarity {
  @HiveField(0)
  common,
  
  @HiveField(1)
  uncommon,
  
  @HiveField(2)
  rare,
  
  @HiveField(3)
  epic,
  
  @HiveField(4)
  legendary;
}
