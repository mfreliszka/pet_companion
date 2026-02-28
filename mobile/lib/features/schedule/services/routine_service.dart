import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/routine_template_model.dart';

/// Service for managing routine templates in top-level `/routineTemplates`.
class RoutineService {
  RoutineService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _templatesRef =>
      _firestore.collection('routineTemplates');

  // ── CRUD ────────────────────────────────────────────────────

  Future<String> addTemplate(RoutineTemplate template) async {
    final doc = await _templatesRef.add(template.toMap());
    return doc.id;
  }

  Future<void> updateTemplate(RoutineTemplate template) async {
    await _templatesRef.doc(template.id).update(template.toMap());
  }

  Future<void> deleteTemplate(String templateId) async {
    await _templatesRef.doc(templateId).delete();
  }

  // ── Streams ─────────────────────────────────────────────────

  /// Stream all active routine templates for a family.
  Stream<List<RoutineTemplate>> streamFamilyRoutines(String familyId) {
    return _templatesRef
        .where('familyId', isEqualTo: familyId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => RoutineTemplate.fromMap(d.data(), d.id))
              .toList(),
        );
  }

  // ── Single Fetch ─────────────────────────────────────────────

  /// Fetch a single routine template by ID.
  Future<RoutineTemplate?> getTemplate(String templateId) async {
    final doc = await _templatesRef.doc(templateId).get();
    if (!doc.exists) return null;
    return RoutineTemplate.fromMap(doc.data()!, doc.id);
  }

  // ── Daily Log Operations ────────────────────────────────────

  /// Mark a task as complete for a given day.
  Future<void> markTaskComplete(
    String templateId,
    String dateString,
    String taskId,
    String userId,
  ) async {
    await _templatesRef
        .doc(templateId)
        .collection('dailyLogs')
        .doc(dateString)
        .set({
          'completedTasks': {
            taskId: CompletedTaskInfo(
              completedBy: userId,
              completedAt: DateTime.now(),
            ).toMap(),
          },
        }, SetOptions(merge: true));
  }

  /// Unmark a task for a given day.
  Future<void> unmarkTaskComplete(
    String templateId,
    String dateString,
    String taskId,
  ) async {
    await _templatesRef
        .doc(templateId)
        .collection('dailyLogs')
        .doc(dateString)
        .update({'completedTasks.$taskId': FieldValue.delete()});
  }

  /// Stream the daily log for a given template + date.
  Stream<DailyLog> streamDailyLog(String templateId, String dateString) {
    return _templatesRef
        .doc(templateId)
        .collection('dailyLogs')
        .doc(dateString)
        .snapshots()
        .map((snap) {
          if (!snap.exists) {
            return DailyLog(date: dateString, completedTasks: {});
          }
          return DailyLog.fromMap(snap.data()!, dateString);
        });
  }
}
