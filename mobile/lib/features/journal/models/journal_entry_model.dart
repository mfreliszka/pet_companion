import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ── Journal Entry Types ─────────────────────────────────────────

/// All journal entry types matching ARCHITECTURE.md schema.
enum JournalEntryType {
  mood,
  symptom,
  appetite,
  energy,
  weight,
  behavior,
  note,
  medication,
  careRecord,
  walk,
  grooming;

  String get displayName => switch (this) {
    JournalEntryType.mood => 'Mood',
    JournalEntryType.symptom => 'Symptom',
    JournalEntryType.appetite => 'Appetite',
    JournalEntryType.energy => 'Energy',
    JournalEntryType.weight => 'Weight',
    JournalEntryType.behavior => 'Behavior',
    JournalEntryType.note => 'Note',
    JournalEntryType.medication => 'Medication',
    JournalEntryType.careRecord => 'Care Record',
    JournalEntryType.walk => 'Walk',
    JournalEntryType.grooming => 'Grooming',
  };

  /// Firestore string value (snake_case for care_record).
  String get firestoreValue => switch (this) {
    JournalEntryType.careRecord => 'care_record',
    _ => name,
  };

  IconData get icon => switch (this) {
    JournalEntryType.mood => Icons.mood_rounded,
    JournalEntryType.symptom => Icons.healing_rounded,
    JournalEntryType.appetite => Icons.restaurant_rounded,
    JournalEntryType.energy => Icons.bolt_rounded,
    JournalEntryType.weight => Icons.monitor_weight_rounded,
    JournalEntryType.behavior => Icons.pets_rounded,
    JournalEntryType.note => Icons.note_rounded,
    JournalEntryType.medication => Icons.medication_rounded,
    JournalEntryType.careRecord => Icons.local_hospital_rounded,
    JournalEntryType.walk => Icons.directions_walk_rounded,
    JournalEntryType.grooming => Icons.content_cut_rounded,
  };

  Color get color => switch (this) {
    JournalEntryType.mood => const Color(0xFFFFC107),
    JournalEntryType.symptom => const Color(0xFFEF5350),
    JournalEntryType.appetite => const Color(0xFFFF9800),
    JournalEntryType.energy => const Color(0xFF42A5F5),
    JournalEntryType.weight => const Color(0xFF66BB6A),
    JournalEntryType.behavior => const Color(0xFFAB47BC),
    JournalEntryType.note => const Color(0xFF78909C),
    JournalEntryType.medication => const Color(0xFFEC407A),
    JournalEntryType.careRecord => const Color(0xFF26A69A),
    JournalEntryType.walk => const Color(0xFF8D6E63),
    JournalEntryType.grooming => const Color(0xFF7E57C2),
  };

  static JournalEntryType fromString(String value) {
    // Handle snake_case from Firestore.
    if (value == 'care_record') return JournalEntryType.careRecord;
    return JournalEntryType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => JournalEntryType.note,
    );
  }
}

// ── Type-specific data enums ────────────────────────────────────

enum MoodLevel {
  happy,
  sad,
  anxious,
  energetic,
  calm;

  String get displayName => switch (this) {
    MoodLevel.happy => 'Happy',
    MoodLevel.sad => 'Sad',
    MoodLevel.anxious => 'Anxious',
    MoodLevel.energetic => 'Energetic',
    MoodLevel.calm => 'Calm',
  };

  String get emoji => switch (this) {
    MoodLevel.happy => '😊',
    MoodLevel.sad => '😢',
    MoodLevel.anxious => '😰',
    MoodLevel.energetic => '🤩',
    MoodLevel.calm => '😌',
  };

  static MoodLevel fromString(String value) {
    return MoodLevel.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MoodLevel.calm,
    );
  }
}

enum SymptomSeverity {
  mild,
  moderate,
  severe;

  String get displayName => switch (this) {
    SymptomSeverity.mild => 'Mild',
    SymptomSeverity.moderate => 'Moderate',
    SymptomSeverity.severe => 'Severe',
  };

  Color get color => switch (this) {
    SymptomSeverity.mild => const Color(0xFFFFC107),
    SymptomSeverity.moderate => const Color(0xFFFF9800),
    SymptomSeverity.severe => const Color(0xFFEF5350),
  };

  static SymptomSeverity fromString(String value) {
    return SymptomSeverity.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SymptomSeverity.mild,
    );
  }
}

enum AppetiteLevel {
  ateWell,
  ateSome,
  didntEat;

  String get displayName => switch (this) {
    AppetiteLevel.ateWell => 'Ate Well',
    AppetiteLevel.ateSome => 'Ate Some',
    AppetiteLevel.didntEat => "Didn't Eat",
  };

  String get firestoreValue => switch (this) {
    AppetiteLevel.ateWell => 'ate_well',
    AppetiteLevel.ateSome => 'ate_some',
    AppetiteLevel.didntEat => 'didnt_eat',
  };

  IconData get icon => switch (this) {
    AppetiteLevel.ateWell => Icons.sentiment_very_satisfied_rounded,
    AppetiteLevel.ateSome => Icons.sentiment_neutral_rounded,
    AppetiteLevel.didntEat => Icons.sentiment_very_dissatisfied_rounded,
  };

  static AppetiteLevel fromString(String value) {
    return AppetiteLevel.values.firstWhere(
      (e) => e.firestoreValue == value || e.name == value,
      orElse: () => AppetiteLevel.ateSome,
    );
  }
}

enum EnergyLevel {
  low,
  normal,
  high;

  String get displayName => switch (this) {
    EnergyLevel.low => 'Low',
    EnergyLevel.normal => 'Normal',
    EnergyLevel.high => 'High',
  };

  IconData get icon => switch (this) {
    EnergyLevel.low => Icons.battery_1_bar_rounded,
    EnergyLevel.normal => Icons.battery_4_bar_rounded,
    EnergyLevel.high => Icons.battery_full_rounded,
  };

  static EnergyLevel fromString(String value) {
    return EnergyLevel.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EnergyLevel.normal,
    );
  }
}

enum BehaviorIncident {
  barking,
  jumping,
  accidents,
  aggression,
  anxiety,
  other;

  String get displayName => switch (this) {
    BehaviorIncident.barking => 'Barking',
    BehaviorIncident.jumping => 'Jumping',
    BehaviorIncident.accidents => 'Accidents',
    BehaviorIncident.aggression => 'Aggression',
    BehaviorIncident.anxiety => 'Anxiety',
    BehaviorIncident.other => 'Other',
  };

  static BehaviorIncident fromString(String value) {
    return BehaviorIncident.values.firstWhere(
      (e) => e.name == value,
      orElse: () => BehaviorIncident.other,
    );
  }
}

enum GroomingType {
  bath,
  nails,
  brushing,
  haircut,
  other;

  String get displayName => switch (this) {
    GroomingType.bath => 'Bath',
    GroomingType.nails => 'Nails',
    GroomingType.brushing => 'Brushing',
    GroomingType.haircut => 'Haircut',
    GroomingType.other => 'Other',
  };

  static GroomingType fromString(String value) {
    return GroomingType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => GroomingType.other,
    );
  }
}

// ── Symptom options ─────────────────────────────────────────────

/// Known symptom types for multi-select.
class SymptomOptions {
  static const List<String> all = [
    'vomiting',
    'diarrhea',
    'lethargy',
    'coughing',
    'sneezing',
    'limping',
    'other',
  ];

  static String displayName(String symptom) => switch (symptom) {
    'vomiting' => 'Vomiting',
    'diarrhea' => 'Diarrhea',
    'lethargy' => 'Lethargy',
    'coughing' => 'Coughing',
    'sneezing' => 'Sneezing',
    'limping' => 'Limping',
    'other' => 'Other',
    _ => symptom,
  };
}

// ── Journal Entry Model ─────────────────────────────────────────

/// Journal entry model matching `/pets/{petId}/journalEntries/{entryId}`
/// in ARCHITECTURE.md.
class JournalEntry {
  const JournalEntry({
    this.id,
    this.petId,
    required this.type,
    required this.timestamp,
    required this.createdBy,
    required this.createdByName,
    this.notes,
    this.photoUrls = const [],
    this.data = const {},
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String? petId;
  final JournalEntryType type;
  final DateTime timestamp;
  final String createdBy;
  final String createdByName;
  final String? notes;
  final List<String> photoUrls;
  final Map<String, dynamic> data;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // ── Firestore serialization ───────────────────────────────────

  factory JournalEntry.fromMap(Map<String, dynamic> map, {String? id}) {
    return JournalEntry(
      id: id,
      type: JournalEntryType.fromString(map['type'] as String? ?? 'note'),
      timestamp: _timestampToDateTime(map['timestamp']) ?? DateTime.now(),
      createdBy: map['createdBy'] as String? ?? '',
      createdByName: map['createdByName'] as String? ?? '',
      notes: map['notes'] as String?,
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      createdAt: _timestampToDateTime(map['createdAt']),
      updatedAt: _timestampToDateTime(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.firestoreValue,
      'timestamp': Timestamp.fromDate(timestamp),
      'createdBy': createdBy,
      'createdByName': createdByName,
      'notes': notes,
      'photoUrls': photoUrls,
      'data': data,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // ── copyWith ──────────────────────────────────────────────────

  JournalEntry copyWith({
    String? id,
    String? petId,
    JournalEntryType? type,
    DateTime? timestamp,
    String? createdBy,
    String? createdByName,
    String? notes,
    List<String>? photoUrls,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      notes: notes ?? this.notes,
      photoUrls: photoUrls ?? this.photoUrls,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ── Data accessors ────────────────────────────────────────────

  /// Short summary text for display in timeline cards.
  String get summary {
    return switch (type) {
      JournalEntryType.mood =>
        '${MoodLevel.fromString(data['mood'] ?? '').emoji} ${MoodLevel.fromString(data['mood'] ?? '').displayName} (${data['scale']}/5)',
      JournalEntryType.symptom =>
        '${SymptomSeverity.fromString(data['severity'] ?? '').displayName}: ${(data['symptoms'] as List?)?.join(', ') ?? ''}',
      JournalEntryType.appetite => AppetiteLevel.fromString(
        data['level'] ?? '',
      ).displayName,
      JournalEntryType.energy => EnergyLevel.fromString(
        data['level'] ?? '',
      ).displayName,
      JournalEntryType.weight => '${data['weightKg']} ${data['unit'] ?? 'kg'}',
      JournalEntryType.behavior => BehaviorIncident.fromString(
        data['incident'] ?? '',
      ).displayName,
      JournalEntryType.note => notes ?? '',
      JournalEntryType.medication =>
        '${data['medicationName'] ?? ''} ${data['administered'] == true ? '✓' : '✗'}',
      JournalEntryType.careRecord =>
        data['diagnosis'] as String? ??
            data['treatment'] as String? ??
            'Care visit',
      JournalEntryType.walk =>
        '${data['durationMinutes'] ?? '?'} min${data['distanceKm'] != null ? ', ${data['distanceKm']} km' : ''}',
      JournalEntryType.grooming => GroomingType.fromString(
        data['grooming_type'] ?? '',
      ).displayName,
    };
  }

  // ── Helpers ───────────────────────────────────────────────────

  static DateTime? _timestampToDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  @override
  String toString() =>
      'JournalEntry(id: $id, type: ${type.displayName}, timestamp: $timestamp)';
}
