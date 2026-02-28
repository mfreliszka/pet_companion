import 'package:cloud_firestore/cloud_firestore.dart';

/// Tracks a single completion of an event.
class EventCompletion {
  const EventCompletion({
    required this.id,
    required this.scheduledAt,
    required this.completedAt,
    required this.completedBy,
    required this.completedByName,
    this.notes,
    this.medicationAdded,
  });

  final String id;
  final DateTime scheduledAt;
  final DateTime completedAt;
  final String completedBy;
  final String completedByName;
  final String? notes;
  final bool? medicationAdded;

  factory EventCompletion.fromMap(Map<String, dynamic> map, String id) {
    return EventCompletion(
      id: id,
      scheduledAt:
          (map['scheduledAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt:
          (map['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedBy: map['completedBy'] as String? ?? '',
      completedByName: map['completedByName'] as String? ?? '',
      notes: map['notes'] as String?,
      medicationAdded: map['medicationAdded'] as bool?,
    );
  }

  Map<String, dynamic> toMap() => {
    'scheduledAt': Timestamp.fromDate(scheduledAt),
    'completedAt': Timestamp.fromDate(completedAt),
    'completedBy': completedBy,
    'completedByName': completedByName,
    if (notes != null) 'notes': notes,
    if (medicationAdded != null) 'medicationAdded': medicationAdded,
  };
}
