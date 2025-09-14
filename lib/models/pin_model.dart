import 'package:hive/hive.dart';

part 'pin_model.g.dart';

@HiveType(typeId: 1)
class PinModel extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String description;
  
  @HiveField(3)
  double latitude;
  
  @HiveField(4)
  double longitude;
  
  @HiveField(5)
  String category;
  
  @HiveField(6)
  List<String> imageUrls;
  
  @HiveField(7)
  List<String> videoUrls;
  
  @HiveField(8)
  String createdBy;
  
  @HiveField(9)
  DateTime createdAt;
  
  @HiveField(10)
  DateTime? updatedAt;
  
  @HiveField(11)
  bool isSponsored;
  
  @HiveField(12)
  SponsorInfo? sponsorInfo;
  
  @HiveField(13)
  int checkInCount;
  
  @HiveField(14)
  double rating;
  
  @HiveField(15)
  List<String> tags;

  PinModel({
    required this.id,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.category,
    this.imageUrls = const [],
    this.videoUrls = const [],
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.isSponsored = false,
    this.sponsorInfo,
    this.checkInCount = 0,
    this.rating = 0.0,
    this.tags = const [],
  });

  factory PinModel.fromJson(Map<String, dynamic> json) {
    return PinModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      category: json['category'],
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      videoUrls: List<String>.from(json['videoUrls'] ?? []),
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      isSponsored: json['isSponsored'] ?? false,
      sponsorInfo: json['sponsorInfo'] != null 
          ? SponsorInfo.fromJson(json['sponsorInfo']) 
          : null,
      checkInCount: json['checkInCount'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
      'imageUrls': imageUrls,
      'videoUrls': videoUrls,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isSponsored': isSponsored,
      'sponsorInfo': sponsorInfo?.toJson(),
      'checkInCount': checkInCount,
      'rating': rating,
      'tags': tags,
    };
  }
}

@HiveType(typeId: 2)
class SponsorInfo extends HiveObject {
  @HiveField(0)
  String companyName;
  
  @HiveField(1)
  String companyLogo;
  
  @HiveField(2)
  String perkTitle;
  
  @HiveField(3)
  String perkDescription;
  
  @HiveField(4)
  String? perkCode;
  
  @HiveField(5)
  DateTime? perkExpiry;
  
  @HiveField(6)
  String? contactInfo;

  SponsorInfo({
    required this.companyName,
    required this.companyLogo,
    required this.perkTitle,
    required this.perkDescription,
    this.perkCode,
    this.perkExpiry,
    this.contactInfo,
  });

  factory SponsorInfo.fromJson(Map<String, dynamic> json) {
    return SponsorInfo(
      companyName: json['companyName'],
      companyLogo: json['companyLogo'],
      perkTitle: json['perkTitle'],
      perkDescription: json['perkDescription'],
      perkCode: json['perkCode'],
      perkExpiry: json['perkExpiry'] != null 
          ? DateTime.parse(json['perkExpiry']) 
          : null,
      contactInfo: json['contactInfo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'companyLogo': companyLogo,
      'perkTitle': perkTitle,
      'perkDescription': perkDescription,
      'perkCode': perkCode,
      'perkExpiry': perkExpiry?.toIso8601String(),
      'contactInfo': contactInfo,
    };
  }
}
