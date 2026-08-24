import 'package:flutter/foundation.dart';

import '../Backend/deadline.dart';
import 'deadline_repository.dart';
import 'reminder_service.dart';

export '../Backend/deadline.dart';

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

class DeadlineService extends ChangeNotifier {
  DeadlineService(this._repository, {required this.reminderService});

  final DeadlineRepository _repository;
  final ReminderService reminderService;

  List<Deadline> get deadlines => _sorted(_repository.getDeadlines());

  Deadline addDeadline({
    required String title,
    required String description,
    required DateTime dueDate,
    required DeadlineTime dueTime,
    required DeadlinePriority priority,
    required ReminderOption reminder,
  }) {
    final now = DateTime.now();
    final deadline = _repository.addDeadline(
      Deadline(
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
      ),
    );
    reminderService.updateReminder(deadline);
    notifyListeners();
    return deadline;
  }

  void updateDeadline(Deadline deadline) {
    final updated = _repository.updateDeadline(
      deadline.copyWith(updatedAt: DateTime.now()),
    );
    reminderService.updateReminder(updated);
    notifyListeners();
  }

  void deleteDeadline(String id) {
    _repository.deleteDeadline(id);
    reminderService.cancelReminder(id);
    notifyListeners();
  }

  void markComplete(String id) => _setCompletion(id, true);
  void markIncomplete(String id) => _setCompletion(id, false);

  void _setCompletion(String id, bool completed) {
    final deadline = _repository.getDeadlineById(id);
    if (deadline == null) return;
    updateDeadline(deadline.copyWith(completed: completed));
  }

  List<Deadline> forDate(DateTime date) =>
      _sorted(deadlines.where((item) => _sameDate(item.dueDate, date)));

  List<Deadline> upcoming() => _sorted(
    deadlines.where(
      (item) => !item.completed && !item.dueDateTime.isBefore(DateTime.now()),
    ),
  );

  List<Deadline> today() => forDate(DateTime.now());

  List<Deadline> overdue() =>
      _sorted(deadlines.where((item) => item.isOverdue));

  List<Deadline> completed() =>
      _sorted(deadlines.where((item) => item.completed));

  List<Deadline> byPriority(DeadlinePriority priority) =>
      _sorted(deadlines.where((item) => item.priority == priority));

  bool hasDeadlineOn(DateTime date) =>
      deadlines.any((item) => _sameDate(item.dueDate, date));

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
