import 'deadline_service.dart';
import 'local_deadline_repository.dart';
import 'reminder_service.dart';

/// Creates the current local deadline module. Replace the repository here at
/// application startup when a Firestore implementation is available.
DeadlineService createLocalDeadlineService() {
  final now = DateTime.now();
  return DeadlineService(
    LocalDeadlineRepository([
      Deadline(
        id: 'sample-today',
        title: 'Review project requirements',
        description: 'Confirm the Group Note module integration details.',
        dueDate: DateTime(now.year, now.month, now.day),
        dueTime: const DeadlineTime(hour: 18, minute: 0),
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
        dueTime: const DeadlineTime(hour: 12, minute: 0),
        priority: DeadlinePriority.medium,
        completed: false,
        reminder: ReminderOption.fifteenMinutesBefore,
        createdAt: now,
        updatedAt: now,
      ),
    ]),
    reminderService: ReminderService(LocalReminderScheduler()),
  );
}
