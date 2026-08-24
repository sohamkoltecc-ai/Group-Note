import '../Backend/deadline.dart';

abstract class ReminderScheduler {
  void schedule(Deadline deadline);
  void cancel(String deadlineId);
}

/// Temporary no-op delivery implementation. Replace it with a device or FCM
/// scheduler later without changing deadline UI or business logic.
class LocalReminderScheduler implements ReminderScheduler {
  final Set<String> _configuredReminderIds = <String>{};

  @override
  void schedule(Deadline deadline) {
    if (!deadline.completed && deadline.reminder != ReminderOption.none) {
      _configuredReminderIds.add(deadline.id);
    }
  }

  @override
  void cancel(String deadlineId) {
    _configuredReminderIds.remove(deadlineId);
  }

  bool isConfigured(String deadlineId) =>
      _configuredReminderIds.contains(deadlineId);
}

class ReminderService {
  ReminderService(this._scheduler);

  final ReminderScheduler _scheduler;

  void scheduleReminder(Deadline deadline) => _scheduler.schedule(deadline);
  void cancelReminder(String deadlineId) => _scheduler.cancel(deadlineId);

  void updateReminder(Deadline deadline) {
    cancelReminder(deadline.id);
    scheduleReminder(deadline);
  }
}
