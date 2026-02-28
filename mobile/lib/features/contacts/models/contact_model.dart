import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ── Contact Type ─────────────────────────────────────────────────

enum ContactType {
  veterinarian('Veterinarian', Icons.local_hospital_rounded),
  groomer('Groomer', Icons.content_cut_rounded),
  petSitter('Pet Sitter', Icons.person_rounded),
  emergency('Emergency', Icons.emergency_rounded),
  pharmacy('Pharmacy', Icons.local_pharmacy_rounded),
  trainer('Trainer', Icons.fitness_center_rounded),
  other('Other', Icons.contacts_rounded);

  const ContactType(this.displayName, this.icon);
  final String displayName;
  final IconData icon;

  static ContactType fromString(String value) => switch (value) {
    'veterinarian' => ContactType.veterinarian,
    'groomer' => ContactType.groomer,
    'petSitter' => ContactType.petSitter,
    'emergency' => ContactType.emergency,
    'pharmacy' => ContactType.pharmacy,
    'trainer' => ContactType.trainer,
    _ => ContactType.other,
  };

  String toFirestore() => name;
}

// ── PetContact Model ────────────────────────────────────────────

class PetContact {
  const PetContact({
    required this.id,
    required this.familyId,
    required this.name,
    required this.type,
    this.phone,
    this.email,
    this.address,
    this.notes,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String familyId;
  final String name;
  final ContactType type;
  final String? phone;
  final String? email;
  final String? address;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory PetContact.fromMap(Map<String, dynamic> map, String id) {
    return PetContact(
      id: id,
      familyId: map['familyId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      type: ContactType.fromString(map['type'] as String? ?? ''),
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      address: map['address'] as String?,
      notes: map['notes'] as String?,
      createdBy: map['createdBy'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'familyId': familyId,
    'name': name,
    'type': type.toFirestore(),
    'phone': phone,
    'email': email,
    'address': address,
    'notes': notes,
    'createdBy': createdBy,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  PetContact copyWith({
    String? name,
    ContactType? type,
    String? phone,
    String? email,
    String? address,
    String? notes,
  }) {
    return PetContact(
      id: id,
      familyId: familyId,
      name: name ?? this.name,
      type: type ?? this.type,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
