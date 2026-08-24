import 'package:flutter/material.dart';

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

extension DeadlinePriorityLabel on DeadlinePriority {
  String get label => switch (this) {
    DeadlinePriority.low => 'Low',
    DeadlinePriority.medium => 'Medium',
    DeadlinePriority.high => 'High',
    DeadlinePriority.critical => 'Critical',
  };
}

extension ReminderOptionLabel on ReminderOption {
  String get label => switch (this) {
    ReminderOption.none => 'None',
    ReminderOption.atDeadline => 'At deadline time',
    ReminderOption.fiveMinutesBefore => '5 minutes before',
    ReminderOption.fifteenMinutesBefore => '15 minutes before',
    ReminderOption.thirtyMinutesBefore => '30 minutes before',
    ReminderOption.oneHourBefore => '1 hour before',
    ReminderOption.oneDayBefore => '1 day before',
  };
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
  final TimeOfDay dueTime;
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
    TimeOfDay? dueTime,
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
}

class DeadlineService extends ChangeNotifier {
  DeadlineService._() {
    final now = DateTime.now();
    _deadlines.addAll([
      Deadline(
        id: 'sample-today',
        title: 'Review project requirements',
        description: 'Confirm the Group Note module integration details.',
        dueDate: DateTime(now.year, now.month, now.day),
        dueTime: const TimeOfDay(hour: 18, minute: 0),
        priority: DeadlinePriority.high,
        completed: false,
        reminder: ReminderOption.oneHourBefore,
        createdAt: now,
        updatedAt: now,
      ),
      Deadline(
        id: 'sample-upcoming',
        title: 'Prepare calendar demo',
        description: 'Show monthly navigation and deadline indicators.',
        dueDate: DateTime(now.year, now.month, now.day + 2),
        dueTime: const TimeOfDay(hour: 12, minute: 0),
        priority: DeadlinePriority.medium,
        completed: false,
        reminder: ReminderOption.fifteenMinutesBefore,
        createdAt: now,
        updatedAt: now,
      ),
    ]);
  }

  static final DeadlineService instance = DeadlineService._();
  final List<Deadline> _deadlines = [];

  List<Deadline> get deadlines => _sorted(_deadlines);

  Deadline addDeadline({
    required String title,
    required String description,
    required DateTime dueDate,
    required TimeOfDay dueTime,
    required DeadlinePriority priority,
    required ReminderOption reminder,
  }) {
    final now = DateTime.now();
    final deadline = Deadline(
      id: now.microsecondsSinceEpoch.toString(),
      title: title.trim(),
      description: description.trim(),
      dueDate: _dateOnly(dueDate),
      dueTime: dueTime,
      priority: priority,
      completed: false,
      reminder: reminder,
      createdAt: now,
      updatedAt: now,
    );
    _deadlines.add(deadline);
    notifyListeners();
    return deadline;
  }

  void updateDeadline(Deadline deadline) {
    final index = _deadlines.indexWhere((item) => item.id == deadline.id);
    if (index == -1) return;
    _deadlines[index] = deadline.copyWith(updatedAt: DateTime.now());
    notifyListeners();
  }

  void deleteDeadline(String id) {
    _deadlines.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void markComplete(String id) => _setCompletion(id, true);
  void markIncomplete(String id) => _setCompletion(id, false);

  void _setCompletion(String id, bool completed) {
    final index = _deadlines.indexWhere((item) => item.id == id);
    if (index == -1) return;
    _deadlines[index] = _deadlines[index].copyWith(
      completed: completed,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  List<Deadline> forDate(DateTime date) =>
      _sorted(_deadlines.where((item) => _sameDate(item.dueDate, date)));

  List<Deadline> upcoming() => _sorted(
    _deadlines.where(
      (item) => !item.completed && !item.dueDateTime.isBefore(DateTime.now()),
    ),
  );

  List<Deadline> today() => forDate(DateTime.now());

  List<Deadline> overdue() =>
      _sorted(_deadlines.where((item) => item.isOverdue));

  List<Deadline> completed() =>
      _sorted(_deadlines.where((item) => item.completed));

  List<Deadline> byPriority(DeadlinePriority priority) =>
      _sorted(_deadlines.where((item) => item.priority == priority));

  bool hasDeadlineOn(DateTime date) =>
      _deadlines.any((item) => _sameDate(item.dueDate, date));

  static List<Deadline> _sorted(Iterable<Deadline> items) {
    final result = List<Deadline>.from(items);
    result.sort((a, b) => a.dueDateTime.compareTo(b.dueDateTime));
    return result;
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static bool _sameDate(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}
