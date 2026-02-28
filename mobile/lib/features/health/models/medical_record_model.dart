import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ── Medical Record Type Enum ────────────────────────────────────

enum MedicalRecordType {
  vetVisit,
  testResult,
  prescription,
  imaging,
  other;

  String get displayName => switch (this) {
    MedicalRecordType.vetVisit => 'Vet Visit',
    MedicalRecordType.testResult => 'Test Result',
    MedicalRecordType.prescription => 'Prescription',
    MedicalRecordType.imaging => 'Imaging',
    MedicalRecordType.other => 'Other',
  };

  String get firestoreValue => switch (this) {
    MedicalRecordType.vetVisit => 'vet_visit',
    MedicalRecordType.testResult => 'test_result',
    _ => name,
  };

  IconData get icon => switch (this) {
    MedicalRecordType.vetVisit => Icons.local_hospital_rounded,
    MedicalRecordType.testResult => Icons.science_rounded,
    MedicalRecordType.prescription => Icons.description_rounded,
    MedicalRecordType.imaging => Icons.image_rounded,
    MedicalRecordType.other => Icons.folder_rounded,
  };

  static MedicalRecordType fromString(String value) {
    if (value == 'vet_visit') return MedicalRecordType.vetVisit;
    if (value == 'test_result') return MedicalRecordType.testResult;
    return MedicalRecordType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MedicalRecordType.other,
    );
  }
}

// ── Medical Record Model ────────────────────────────────────────

/// Medical record matching `/pets/{petId}/medicalRecords/{recordId}`.
class MedicalRecord {
  const MedicalRecord({
    this.id,
    required this.title,
    required this.type,
    required this.date,
    this.veterinarian,
    this.clinic,
    this.diagnosis,
    this.treatment,
    this.cost,
    this.nextFollowUp,
    this.documentUrls = const [],
    this.tags = const [],
    this.notes,
    required this.createdBy,
    this.createdAt,
  });

  final String? id;
  final String title;
  final MedicalRecordType type;
  final DateTime date;
  final String? veterinarian;
  final String? clinic;
  final String? diagnosis;
  final String? treatment;
  final double? cost;
  final DateTime? nextFollowUp;
  final List<String> documentUrls;
  final List<String> tags;
  final String? notes;
  final String createdBy;
  final DateTime? createdAt;

  factory MedicalRecord.fromMap(Map<String, dynamic> map, {String? id}) {
    return MedicalRecord(
      id: id,
      title: map['title'] as String? ?? '',
      type: MedicalRecordType.fromString(map['type'] as String? ?? 'other'),
      date: _ts(map['date']) ?? DateTime.now(),
      veterinarian: map['veterinarian'] as String?,
      clinic: map['clinic'] as String?,
      diagnosis: map['diagnosis'] as String?,
      treatment: map['treatment'] as String?,
      cost: (map['cost'] as num?)?.toDouble(),
      nextFollowUp: _ts(map['nextFollowUp']),
      documentUrls: List<String>.from(map['documentUrls'] ?? []),
      tags: List<String>.from(map['tags'] ?? []),
      notes: map['notes'] as String?,
      createdBy: map['createdBy'] as String? ?? '',
      createdAt: _ts(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'type': type.firestoreValue,
      'date': Timestamp.fromDate(date),
      'veterinarian': veterinarian,
      'clinic': clinic,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'cost': cost,
      'nextFollowUp': nextFollowUp != null
          ? Timestamp.fromDate(nextFollowUp!)
          : null,
      'documentUrls': documentUrls,
      'tags': tags,
      'notes': notes,
      'createdBy': createdBy,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  MedicalRecord copyWith({
    String? id,
    String? title,
    MedicalRecordType? type,
    DateTime? date,
    String? veterinarian,
    String? clinic,
    String? diagnosis,
    String? treatment,
    double? cost,
    DateTime? nextFollowUp,
    List<String>? documentUrls,
    List<String>? tags,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return MedicalRecord(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      date: date ?? this.date,
      veterinarian: veterinarian ?? this.veterinarian,
      clinic: clinic ?? this.clinic,
      diagnosis: diagnosis ?? this.diagnosis,
      treatment: treatment ?? this.treatment,
      cost: cost ?? this.cost,
      nextFollowUp: nextFollowUp ?? this.nextFollowUp,
      documentUrls: documentUrls ?? this.documentUrls,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static DateTime? _ts(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    return null;
  }
}
