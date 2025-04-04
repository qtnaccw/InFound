import 'package:cloud_firestore/cloud_firestore.dart';

class BadgeModel {
  final String badgeId;
  final String badgeTitle;
  final String badgeDescription;
  final String badgeIconUrl;
  final String badgeCondition;
  final String tier;
  final List<String> badgeOwners;
  final DateTime updatedAt;
  final DateTime createdAt;

  BadgeModel(
      {required this.badgeId,
      required this.badgeTitle,
      required this.badgeDescription,
      required this.badgeIconUrl,
      required this.badgeCondition,
      required this.tier,
      required this.badgeOwners,
      required this.updatedAt,
      required this.createdAt});

  toJson() {
    return {
      'badgeId': badgeId,
      'badgeTitle': badgeTitle,
      'badgeDescription': badgeDescription,
      'badgeIconUrl': badgeIconUrl,
      'badgeCondition': badgeCondition,
      'tier': tier,
      'badgeOwners': badgeOwners,
      'createdAt': createdAt,
      'updatedAt': updatedAt
    };
  }

  static empty() {
    return BadgeModel(
        badgeId: '',
        badgeTitle: '',
        badgeDescription: '',
        badgeIconUrl: '',
        badgeCondition: '',
        tier: '',
        badgeOwners: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now());
  }

  factory BadgeModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return BadgeModel(
          badgeId: data.containsKey('badgeId') ? data['badgeId'] ?? '' : '',
          badgeTitle: data.containsKey('badgeTitle') ? data['badgeTitle'] ?? '' : '',
          badgeDescription: data.containsKey('badgeDescription') ? data['badgeDescription'] ?? '' : '',
          badgeIconUrl: data.containsKey('badgeIconUrl') ? data['badgeIconUrl'] ?? '' : '',
          badgeCondition: data.containsKey('badgeCondition') ? data['badgeCondition'] ?? '' : '',
          tier: data.containsKey('tier') ? data['tier'] ?? '' : '',
          badgeOwners: data.containsKey('badgeOwners') ? List<String>.from(data['badgeOwners']) : [],
          createdAt: data.containsKey('createdAt') ? data["createdAt"].toDate() : DateTime.now(),
          updatedAt: data.containsKey('updatedAt') ? data["updatedAt"].toDate() : DateTime.now());
    } else {
      return BadgeModel.empty();
    }
  }

  BadgeModel copyWith({
    String? badgeId,
    String? badgeTitle,
    String? badgeDescription,
    String? badgeIconUrl,
    String? badgeCondition,
    String? tier,
    List<String>? badgeOwners,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BadgeModel(
      badgeId: badgeId ?? this.badgeId,
      badgeTitle: badgeTitle ?? this.badgeTitle,
      badgeDescription: badgeDescription ?? this.badgeDescription,
      badgeIconUrl: badgeIconUrl ?? this.badgeIconUrl,
      badgeCondition: badgeCondition ?? this.badgeCondition,
      tier: tier ?? this.tier,
      badgeOwners: badgeOwners ?? this.badgeOwners,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
