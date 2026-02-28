import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ── Event Type ──────────────────────────────────────────────────

enum EventType {
  feeding('Feeding', Icons.restaurant_rounded),
  medication('Medication', Icons.medication_rounded),
  walk('Walk', Icons.directions_walk_rounded),
  grooming('Grooming', Icons.content_cut_rounded),
  vetAppointment('Vet Appointment', Icons.local_hospital_rounded),
  reminder('Reminder', Icons.notifications_rounded),
  custom('Custom', Icons.event_rounded);

  const EventType(this.displayName, this.icon);
  final String displayName;
  final IconData icon;

  /// Firestore string → enum.
  static EventType fromString(String value) => switch (value) {
    'feeding' => EventType.feeding,
    'medication' => EventType.medication,
    'walk' => EventType.walk,
    'grooming' => EventType.grooming,
    'vet_appointment' => EventType.vetAppointment,
    'reminder' => EventType.reminder,
    _ => EventType.custom,
  };

  String toFirestore() => switch (this) {
    EventType.feeding => 'feeding',
    EventType.medication => 'medication',
    EventType.walk => 'walk',
    EventType.grooming => 'grooming',
    EventType.vetAppointment => 'vet_appointment',
    EventType.reminder => 'reminder',
    EventType.custom => 'custom',
  };
}

// ── Event Schedule (for cyclic events) ──────────────────────────

class EventSchedule {
  const EventSchedule({
    required this.times,
    this.daysOfWeek,
    this.intervalDays,
    required this.startDate,
    this.endDate,
  });

  final List<String> times;
  final List<int>? daysOfWeek;
  final int? intervalDays;
  final DateTime startDate;
  final DateTime? endDate;

  factory EventSchedule.fromMap(Map<String, dynamic> map) {
    return EventSchedule(
      times: List<String>.from(map['times'] ?? []),
      daysOfWeek: map['daysOfWeek'] != null
          ? List<int>.from(map['daysOfWeek'])
          : null,
      intervalDays: map['intervalDays'] as int?,
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: map['endDate'] != null
          ? (map['endDate'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'times': times,
    if (daysOfWeek != null) 'daysOfWeek': daysOfWeek,
    if (intervalDays != null) 'intervalDays': intervalDays,
    'startDate': Timestamp.fromDate(startDate),
    if (endDate != null) 'endDate': Timestamp.fromDate(endDate!),
  };

  EventSchedule copyWith({
    List<String>? times,
    List<int>? daysOfWeek,
    int? intervalDays,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return EventSchedule(
      times: times ?? this.times,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      intervalDays: intervalDays ?? this.intervalDays,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  /// Human-readable schedule summary.
  String get displaySummary {
    final timeStr = times.join(', ');
    if (daysOfWeek != null && daysOfWeek!.isNotEmpty) {
      const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final days = daysOfWeek!.map((d) => dayNames[d - 1]).join(', ');
      return '$days at $timeStr';
    }
    if (intervalDays != null) {
      if (intervalDays == 1) return 'Daily at $timeStr';
      return 'Every $intervalDays days at $timeStr';
    }
    return 'Daily at $timeStr';
  }
}

// ── Event Model ─────────────────────────────────────────────────

class Event {
  const Event({
    required this.id,
    required this.title,
    this.description,
    required this.petId,
    required this.familyId,
    required this.type,
    required this.isCyclic,
    this.schedule,
    this.oneTimeDate,
    this.assignedTo,
    required this.createdBy,
    required this.isActive,
    this.reminderMinutesBefore = 5,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String? description;
  final String petId;
  final String familyId;
  final EventType type;
  final bool isCyclic;
  final EventSchedule? schedule;
  final DateTime? oneTimeDate;
  final String? assignedTo;
  final String createdBy;
  final bool isActive;
  final int reminderMinutesBefore;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isOneTime => !isCyclic;

  factory Event.fromMap(Map<String, dynamic> map, String id) {
    return Event(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      petId: map['petId'] as String? ?? '',
      familyId: map['familyId'] as String? ?? '',
      type: EventType.fromString(map['type'] as String? ?? 'custom'),
      isCyclic: map['isCyclic'] as bool? ?? false,
      schedule: map['schedule'] != null
          ? EventSchedule.fromMap(Map<String, dynamic>.from(map['schedule']))
          : null,
      oneTimeDate: map['oneTimeDate'] != null
          ? (map['oneTimeDate'] as Timestamp).toDate()
          : null,
      assignedTo: map['assignedTo'] as String?,
      createdBy: map['createdBy'] as String? ?? '',
      isActive: map['isActive'] as bool? ?? true,
      reminderMinutesBefore: map['reminderMinutesBefore'] as int? ?? 5,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'petId': petId,
    'familyId': familyId,
    'type': type.toFirestore(),
    'isCyclic': isCyclic,
    if (schedule != null) 'schedule': schedule!.toMap(),
    if (oneTimeDate != null) 'oneTimeDate': Timestamp.fromDate(oneTimeDate!),
    'assignedTo': assignedTo,
    'createdBy': createdBy,
    'isActive': isActive,
    'reminderMinutesBefore': reminderMinutesBefore,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  Event copyWith({
    String? title,
    String? description,
    String? petId,
    String? familyId,
    EventType? type,
    bool? isCyclic,
    EventSchedule? schedule,
    DateTime? oneTimeDate,
    String? assignedTo,
    bool? isActive,
    int? reminderMinutesBefore,
  }) {
    return Event(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      petId: petId ?? this.petId,
      familyId: familyId ?? this.familyId,
      type: type ?? this.type,
      isCyclic: isCyclic ?? this.isCyclic,
      schedule: schedule ?? this.schedule,
      oneTimeDate: oneTimeDate ?? this.oneTimeDate,
      assignedTo: assignedTo ?? this.assignedTo,
      createdBy: createdBy,
      isActive: isActive ?? this.isActive,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
