import 'package:cloud_firestore/cloud_firestore.dart';

/// Weight entry model matching `/pets/{petId}/weightHistory/{entryId}`.
class WeightEntry {
  const WeightEntry({
    this.id,
    required this.weightKg,
    required this.unit,
    required this.date,
    required this.createdBy,
    this.createdAt,
  });

  final String? id;
  final double weightKg;
  final String unit; // "kg" or "lbs"
  final DateTime date;
  final String createdBy;
  final DateTime? createdAt;

  /// Formatted weight with unit for display.
  String get displayWeight {
    final value = unit == 'lbs' ? weightKg * 2.20462 : weightKg;
    return '${value.toStringAsFixed(1)} $unit';
  }

  factory WeightEntry.fromMap(Map<String, dynamic> map, {String? id}) {
    return WeightEntry(
      id: id,
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit'] as String? ?? 'kg',
      date: _timestampToDateTime(map['date']) ?? DateTime.now(),
      createdBy: map['createdBy'] as String? ?? '',
      createdAt: _timestampToDateTime(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'weightKg': weightKg,
      'unit': unit,
      'date': Timestamp.fromDate(date),
      'createdBy': createdBy,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  WeightEntry copyWith({
    String? id,
    double? weightKg,
    String? unit,
    DateTime? date,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return WeightEntry(
      id: id ?? this.id,
      weightKg: weightKg ?? this.weightKg,
      unit: unit ?? this.unit,
      date: date ?? this.date,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static DateTime? _timestampToDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
