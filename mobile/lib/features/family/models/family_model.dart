import 'package:cloud_firestore/cloud_firestore.dart';

/// Family model matching `/families/{familyId}` in ARCHITECTURE.md.
///
/// Note: `hashedPassword` is server-only and excluded from client model.
class Family {
  const Family({
    this.id,
    required this.name,
    this.familyCode,
    required this.adminIds,
    required this.memberIds,
    this.petIds = const [],
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String name;
  final String? familyCode;
  final List<String> adminIds;
  final List<String> memberIds;
  final List<String> petIds;
  final String createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Whether [userId] has admin privileges.
  bool isAdmin(String userId) => adminIds.contains(userId);

  /// Total member count.
  int get memberCount => memberIds.length;

  /// Total pet count.
  int get petCount => petIds.length;

  // ── Firestore serialization ───────────────────────────────────

  factory Family.fromMap(Map<String, dynamic> map, {String? id}) {
    return Family(
      id: id,
      name: map['name'] as String? ?? '',
      familyCode: map['familyCode'] as String?,
      adminIds: List<String>.from(map['adminIds'] ?? []),
      memberIds: List<String>.from(map['memberIds'] ?? []),
      petIds: List<String>.from(map['petIds'] ?? []),
      createdBy: map['createdBy'] as String? ?? '',
      createdAt: _timestampToDateTime(map['createdAt']),
      updatedAt: _timestampToDateTime(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'familyCode': familyCode,
      'adminIds': adminIds,
      'memberIds': memberIds,
      'petIds': petIds,
      'createdBy': createdBy,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Family copyWith({
    String? id,
    String? name,
    String? familyCode,
    List<String>? adminIds,
    List<String>? memberIds,
    List<String>? petIds,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Family(
      id: id ?? this.id,
      name: name ?? this.name,
      familyCode: familyCode ?? this.familyCode,
      adminIds: adminIds ?? this.adminIds,
      memberIds: memberIds ?? this.memberIds,
      petIds: petIds ?? this.petIds,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime? _timestampToDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  @override
  String toString() => 'Family(id: $id, name: $name, members: $memberCount)';
}
