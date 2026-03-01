import 'package:cloud_firestore/cloud_firestore.dart';

/// Invitation model for top-level `/invitations/{invitationId}`.
class Invitation {
  const Invitation({
    this.id,
    required this.familyId,
    required this.familyName,
    required this.invitedEmail,
    required this.invitedBy,
    required this.status,
    this.createdAt,
    this.expiresAt,
  });

  final String? id;
  final String familyId;
  final String familyName;
  final String invitedEmail;
  final String invitedBy;
  final InvitationStatus status;
  final DateTime? createdAt;
  final DateTime? expiresAt;

  factory Invitation.fromMap(Map<String, dynamic> map, {String? id}) {
    return Invitation(
      id: id,
      familyId: map['familyId'] as String? ?? '',
      familyName: map['familyName'] as String? ?? '',
      invitedEmail: map['invitedEmail'] as String? ?? '',
      invitedBy: map['invitedBy'] as String? ?? '',
      status: InvitationStatus.fromString(
        map['status'] as String? ?? 'pending',
      ),
      createdAt: _timestampToDateTime(map['createdAt']),
      expiresAt: _timestampToDateTime(map['expiresAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'familyId': familyId,
      'familyName': familyName,
      'invitedEmail': invitedEmail,
      'invitedBy': invitedBy,
      'status': status.name,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
    };
  }

  static DateTime? _timestampToDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}

enum InvitationStatus {
  pending,
  accepted,
  declined;

  static InvitationStatus fromString(String value) {
    return InvitationStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => InvitationStatus.pending,
    );
  }
}
