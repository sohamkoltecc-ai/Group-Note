import 'deadline_service.dart';

/// Stores the reminder integration boundary. Device notifications are not
/// delivered in this phase because no notification package is configured.
class ReminderService {
  ReminderService._();

  static final ReminderService instance = ReminderService._();
  final Set<String> _configuredReminderIds = <String>{};

  Future<void> scheduleReminder(Deadline deadline) async {
    if (!deadline.completed && deadline.reminder != ReminderOption.none) {
      _configuredReminderIds.add(deadline.id);
    }
  }

  Future<void> cancelReminder(String deadlineId) async {
    _configuredReminderIds.remove(deadlineId);
  }

  Future<void> updateReminder(Deadline deadline) async {
    await cancelReminder(deadline.id);
    await scheduleReminder(deadline);
  }

  bool isConfigured(String deadlineId) =>
      _configuredReminderIds.contains(deadlineId);
}
