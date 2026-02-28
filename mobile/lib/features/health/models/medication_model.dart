import 'package:cloud_firestore/cloud_firestore.dart';

// ── Frequency Enum ──────────────────────────────────────────────

enum MedicationFrequency {
  daily,
  twiceDaily,
  weekly,
  asNeeded;

  String get displayName => switch (this) {
    MedicationFrequency.daily => 'Daily',
    MedicationFrequency.twiceDaily => 'Twice Daily',
    MedicationFrequency.weekly => 'Weekly',
    MedicationFrequency.asNeeded => 'As Needed',
  };

  String get firestoreValue => switch (this) {
    MedicationFrequency.twiceDaily => 'twice_daily',
    MedicationFrequency.asNeeded => 'as_needed',
    _ => name,
  };

  static MedicationFrequency fromString(String value) {
    if (value == 'twice_daily') return MedicationFrequency.twiceDaily;
    if (value == 'as_needed') return MedicationFrequency.asNeeded;
    return MedicationFrequency.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MedicationFrequency.daily,
    );
  }
}

// ── Medication Model ────────────────────────────────────────────

/// Medication model matching `/pets/{petId}/medications/{medicationId}`.
class Medication {
  const Medication({
    this.id,
    required this.name,
    this.dosage,
    required this.frequency,
    this.scheduledTimes = const [],
    required this.startDate,
    this.endDate,
    this.isActive = true,
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String name;
  final String? dosage;
  final MedicationFrequency frequency;
  final List<String> scheduledTimes;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final String createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Medication.fromMap(Map<String, dynamic> map, {String? id}) {
    return Medication(
      id: id,
      name: map['name'] as String? ?? '',
      dosage: map['dosage'] as String?,
      frequency: MedicationFrequency.fromString(
        map['frequency'] as String? ?? 'daily',
      ),
      scheduledTimes: List<String>.from(map['scheduledTimes'] ?? []),
      startDate: _timestampToDateTime(map['startDate']) ?? DateTime.now(),
      endDate: _timestampToDateTime(map['endDate']),
      isActive: map['isActive'] as bool? ?? true,
      createdBy: map['createdBy'] as String? ?? '',
      createdAt: _timestampToDateTime(map['createdAt']),
      updatedAt: _timestampToDateTime(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency.firestoreValue,
      'scheduledTimes': scheduledTimes,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'isActive': isActive,
      'createdBy': createdBy,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Medication copyWith({
    String? id,
    String? name,
    String? dosage,
    MedicationFrequency? frequency,
    List<String>? scheduledTimes,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      scheduledTimes: scheduledTimes ?? this.scheduledTimes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
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
}
