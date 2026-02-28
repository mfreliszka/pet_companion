import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ── Time-of-Day Slot ────────────────────────────────────────────

enum TimeOfDaySlot {
  morning('Morning', Icons.wb_sunny_rounded),
  afternoon('Afternoon', Icons.wb_cloudy_rounded),
  evening('Evening', Icons.nightlight_rounded),
  custom('Custom', Icons.schedule_rounded);

  const TimeOfDaySlot(this.displayName, this.icon);
  final String displayName;
  final IconData icon;

  static TimeOfDaySlot fromString(String value) => switch (value) {
    'morning' => TimeOfDaySlot.morning,
    'afternoon' => TimeOfDaySlot.afternoon,
    'evening' => TimeOfDaySlot.evening,
    _ => TimeOfDaySlot.custom,
  };

  String toFirestore() => name;
}

// ── Routine Task ────────────────────────────────────────────────

class RoutineTask {
  const RoutineTask({
    required this.id,
    required this.title,
    this.assignedTo,
    required this.order,
  });

  final String id;
  final String title;
  final String? assignedTo;
  final int order;

  factory RoutineTask.fromMap(Map<String, dynamic> map) {
    return RoutineTask(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      assignedTo: map['assignedTo'] as String?,
      order: map['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'assignedTo': assignedTo,
    'order': order,
  };

  RoutineTask copyWith({String? title, String? assignedTo, int? order}) {
    return RoutineTask(
      id: id,
      title: title ?? this.title,
      assignedTo: assignedTo ?? this.assignedTo,
      order: order ?? this.order,
    );
  }
}

// ── Routine Template ────────────────────────────────────────────

class RoutineTemplate {
  const RoutineTemplate({
    required this.id,
    required this.familyId,
    this.petId,
    required this.name,
    required this.timeOfDay,
    required this.tasks,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String familyId;
  final String? petId;
  final String name;
  final TimeOfDaySlot timeOfDay;
  final List<RoutineTask> tasks;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory RoutineTemplate.fromMap(Map<String, dynamic> map, String id) {
    return RoutineTemplate(
      id: id,
      familyId: map['familyId'] as String? ?? '',
      petId: map['petId'] as String?,
      name: map['name'] as String? ?? '',
      timeOfDay: TimeOfDaySlot.fromString(
        map['timeOfDay'] as String? ?? 'morning',
      ),
      tasks:
          (map['tasks'] as List<dynamic>?)
              ?.map((t) => RoutineTask.fromMap(Map<String, dynamic>.from(t)))
              .toList() ??
          [],
      isActive: map['isActive'] as bool? ?? true,
      createdBy: map['createdBy'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'familyId': familyId,
    'petId': petId,
    'name': name,
    'timeOfDay': timeOfDay.toFirestore(),
    'tasks': tasks.map((t) => t.toMap()).toList(),
    'isActive': isActive,
    'createdBy': createdBy,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  RoutineTemplate copyWith({
    String? name,
    TimeOfDaySlot? timeOfDay,
    List<RoutineTask>? tasks,
    bool? isActive,
    String? petId,
  }) {
    return RoutineTemplate(
      id: id,
      familyId: familyId,
      petId: petId ?? this.petId,
      name: name ?? this.name,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      tasks: tasks ?? this.tasks,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

// ── Daily Log (completion tracking) ─────────────────────────────

class CompletedTaskInfo {
  const CompletedTaskInfo({
    required this.completedBy,
    required this.completedAt,
  });

  final String completedBy;
  final DateTime completedAt;

  factory CompletedTaskInfo.fromMap(Map<String, dynamic> map) {
    return CompletedTaskInfo(
      completedBy: map['completedBy'] as String? ?? '',
      completedAt:
          (map['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'completedBy': completedBy,
    'completedAt': Timestamp.fromDate(completedAt),
  };
}

class DailyLog {
  const DailyLog({required this.date, required this.completedTasks});

  final String date;
  final Map<String, CompletedTaskInfo> completedTasks;

  factory DailyLog.fromMap(Map<String, dynamic> map, String date) {
    final tasks = <String, CompletedTaskInfo>{};
    final completedMap = map['completedTasks'] as Map<String, dynamic>?;
    if (completedMap != null) {
      for (final entry in completedMap.entries) {
        tasks[entry.key] = CompletedTaskInfo.fromMap(
          Map<String, dynamic>.from(entry.value),
        );
      }
    }
    return DailyLog(date: date, completedTasks: tasks);
  }

  Map<String, dynamic> toMap() => {
    'completedTasks': completedTasks.map((k, v) => MapEntry(k, v.toMap())),
  };

  bool isTaskCompleted(String taskId) => completedTasks.containsKey(taskId);
}
