import 'package:cloud_firestore/cloud_firestore.dart';

/// Vaccination model matching `/pets/{petId}/vaccinations/{vaccinationId}`.
class Vaccination {
  const Vaccination({
    this.id,
    required this.name,
    required this.dateAdministered,
    this.nextDueDate,
    this.veterinarian,
    this.clinic,
    this.batchNumber,
    this.documentUrl,
    this.reminderSent = false,
    required this.createdBy,
    this.createdAt,
  });

  final String? id;
  final String name;
  final DateTime dateAdministered;
  final DateTime? nextDueDate;
  final String? veterinarian;
  final String? clinic;
  final String? batchNumber;
  final String? documentUrl;
  final bool reminderSent;
  final String createdBy;
  final DateTime? createdAt;

  /// Whether the next due date has passed.
  bool get isOverdue =>
      nextDueDate != null && nextDueDate!.isBefore(DateTime.now());

  /// Whether the next due date is within 30 days.
  bool get isDueSoon =>
      nextDueDate != null &&
      !isOverdue &&
      nextDueDate!.isBefore(DateTime.now().add(const Duration(days: 30)));

  factory Vaccination.fromMap(Map<String, dynamic> map, {String? id}) {
    return Vaccination(
      id: id,
      name: map['name'] as String? ?? '',
      dateAdministered: _ts(map['dateAdministered']) ?? DateTime.now(),
      nextDueDate: _ts(map['nextDueDate']),
      veterinarian: map['veterinarian'] as String?,
      clinic: map['clinic'] as String?,
      batchNumber: map['batchNumber'] as String?,
      documentUrl: map['documentUrl'] as String?,
      reminderSent: map['reminderSent'] as bool? ?? false,
      createdBy: map['createdBy'] as String? ?? '',
      createdAt: _ts(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dateAdministered': Timestamp.fromDate(dateAdministered),
      'nextDueDate': nextDueDate != null
          ? Timestamp.fromDate(nextDueDate!)
          : null,
      'veterinarian': veterinarian,
      'clinic': clinic,
      'batchNumber': batchNumber,
      'documentUrl': documentUrl,
      'reminderSent': reminderSent,
      'createdBy': createdBy,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  Vaccination copyWith({
    String? id,
    String? name,
    DateTime? dateAdministered,
    DateTime? nextDueDate,
    String? veterinarian,
    String? clinic,
    String? batchNumber,
    String? documentUrl,
    bool? reminderSent,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return Vaccination(
      id: id ?? this.id,
      name: name ?? this.name,
      dateAdministered: dateAdministered ?? this.dateAdministered,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      veterinarian: veterinarian ?? this.veterinarian,
      clinic: clinic ?? this.clinic,
      batchNumber: batchNumber ?? this.batchNumber,
      documentUrl: documentUrl ?? this.documentUrl,
      reminderSent: reminderSent ?? this.reminderSent,
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
