import 'package:cloud_firestore/cloud_firestore.dart';

/// Pet species options matching ARCHITECTURE.md schema.
enum PetSpecies {
  dog,
  cat,
  bird,
  rabbit,
  fish,
  reptile,
  other;

  String get displayName => switch (this) {
    PetSpecies.dog => 'Dog',
    PetSpecies.cat => 'Cat',
    PetSpecies.bird => 'Bird',
    PetSpecies.rabbit => 'Rabbit',
    PetSpecies.fish => 'Fish',
    PetSpecies.reptile => 'Reptile',
    PetSpecies.other => 'Other',
  };

  static PetSpecies fromString(String value) {
    return PetSpecies.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PetSpecies.other,
    );
  }
}

/// Pet gender options.
enum PetGender {
  male,
  female,
  unknown;

  String get displayName => switch (this) {
    PetGender.male => 'Male',
    PetGender.female => 'Female',
    PetGender.unknown => 'Unknown',
  };

  static PetGender fromString(String value) {
    return PetGender.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PetGender.unknown,
    );
  }
}

/// Pet model matching `/pets/{petId}` in ARCHITECTURE.md.
class Pet {
  const Pet({
    this.id,
    required this.name,
    required this.species,
    this.breed,
    required this.gender,
    this.dateOfBirth,
    this.photoUrl,
    this.photoThumbnailUrl,
    this.microchipId,
    this.microchipRegistry,
    this.microchipContactInfo,
    this.currentWeight,
    required this.familyId,
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String name;
  final PetSpecies species;
  final String? breed;
  final PetGender gender;
  final DateTime? dateOfBirth;
  final String? photoUrl;
  final String? photoThumbnailUrl;
  final String? microchipId;
  final String? microchipRegistry;
  final String? microchipContactInfo;
  final double? currentWeight;
  final String familyId;
  final String createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // ── Firestore serialization ───────────────────────────────────

  factory Pet.fromMap(Map<String, dynamic> map, {String? id}) {
    return Pet(
      id: id,
      name: map['name'] as String? ?? '',
      species: PetSpecies.fromString(map['species'] as String? ?? 'other'),
      breed: map['breed'] as String?,
      gender: PetGender.fromString(map['gender'] as String? ?? 'unknown'),
      dateOfBirth: _timestampToDateTime(map['dateOfBirth']),
      photoUrl: map['photoUrl'] as String?,
      photoThumbnailUrl: map['photoThumbnailUrl'] as String?,
      microchipId: map['microchipId'] as String?,
      microchipRegistry: map['microchipRegistry'] as String?,
      microchipContactInfo: map['microchipContactInfo'] as String?,
      currentWeight: (map['currentWeight'] as num?)?.toDouble(),
      familyId: map['familyId'] as String? ?? '',
      createdBy: map['createdBy'] as String? ?? '',
      createdAt: _timestampToDateTime(map['createdAt']),
      updatedAt: _timestampToDateTime(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'species': species.name,
      'breed': breed,
      'gender': gender.name,
      'dateOfBirth': dateOfBirth != null
          ? Timestamp.fromDate(dateOfBirth!)
          : null,
      'photoUrl': photoUrl,
      'photoThumbnailUrl': photoThumbnailUrl,
      'microchipId': microchipId,
      'microchipRegistry': microchipRegistry,
      'microchipContactInfo': microchipContactInfo,
      'currentWeight': currentWeight,
      'familyId': familyId,
      'createdBy': createdBy,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // ── copyWith ──────────────────────────────────────────────────

  Pet copyWith({
    String? id,
    String? name,
    PetSpecies? species,
    String? breed,
    PetGender? gender,
    DateTime? dateOfBirth,
    String? photoUrl,
    String? photoThumbnailUrl,
    String? microchipId,
    String? microchipRegistry,
    String? microchipContactInfo,
    double? currentWeight,
    String? familyId,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      photoUrl: photoUrl ?? this.photoUrl,
      photoThumbnailUrl: photoThumbnailUrl ?? this.photoThumbnailUrl,
      microchipId: microchipId ?? this.microchipId,
      microchipRegistry: microchipRegistry ?? this.microchipRegistry,
      microchipContactInfo: microchipContactInfo ?? this.microchipContactInfo,
      currentWeight: currentWeight ?? this.currentWeight,
      familyId: familyId ?? this.familyId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────

  static DateTime? _timestampToDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  @override
  String toString() => 'Pet(id: $id, name: $name, species: $species)';
}
