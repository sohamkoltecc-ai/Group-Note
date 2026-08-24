/// Data types for the deadlines module. This file deliberately has no Flutter
/// dependency so the same model can be used by a local or Firestore repository.
enum DeadlinePriority { low, medium, high, critical }

enum ReminderOption {
  none,
  atDeadline,
  fiveMinutesBefore,
  fifteenMinutesBefore,
  thirtyMinutesBefore,
  oneHourBefore,
  oneDayBefore,
}

class DeadlineTime {
  const DeadlineTime({required this.hour, required this.minute})
    : assert(hour >= 0 && hour < 24),
      assert(minute >= 0 && minute < 60);

  final int hour;
  final int minute;

  Map<String, dynamic> toMap() => {'hour': hour, 'minute': minute};

  factory DeadlineTime.fromMap(Map<String, dynamic> map) => DeadlineTime(
    hour: (map['hour'] as num).toInt(),
    minute: (map['minute'] as num).toInt(),
  );
}

class Deadline {
  const Deadline({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.dueTime,
    required this.priority,
    required this.completed,
    required this.reminder,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final DeadlineTime dueTime;
  final DeadlinePriority priority;
  final bool completed;
  final ReminderOption reminder;
  final DateTime createdAt;
  final DateTime updatedAt;

  DateTime get dueDateTime => DateTime(
    dueDate.year,
    dueDate.month,
    dueDate.day,
    dueTime.hour,
    dueTime.minute,
  );

  bool get isOverdue => !completed && dueDateTime.isBefore(DateTime.now());

  Deadline copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    DeadlineTime? dueTime,
    DeadlinePriority? priority,
    bool? completed,
    ReminderOption? reminder,
    DateTime? updatedAt,
  }) => Deadline(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    dueDate: dueDate ?? this.dueDate,
    dueTime: dueTime ?? this.dueTime,
    priority: priority ?? this.priority,
    completed: completed ?? this.completed,
    reminder: reminder ?? this.reminder,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'dueDate': dueDate.toIso8601String(),
    'dueTime': dueTime.toMap(),
    'priority': priority.name,
    'completed': completed,
    'reminder': reminder.name,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Deadline.fromMap(Map<String, dynamic> map) => Deadline(
    id: map['id'] as String,
    title: map['title'] as String,
    description: map['description'] as String,
    dueDate: DateTime.parse(map['dueDate'] as String),
    dueTime: DeadlineTime.fromMap(
      Map<String, dynamic>.from(map['dueTime'] as Map),
    ),
    priority: DeadlinePriority.values.byName(map['priority'] as String),
    completed: map['completed'] as bool,
    reminder: ReminderOption.values.byName(map['reminder'] as String),
    createdAt: DateTime.parse(map['createdAt'] as String),
    updatedAt: DateTime.parse(map['updatedAt'] as String),
  );
}
