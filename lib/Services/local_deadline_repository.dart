import '../Backend/deadline.dart';
import 'deadline_repository.dart';

class LocalDeadlineRepository implements DeadlineRepository {
  LocalDeadlineRepository([Iterable<Deadline> initialDeadlines = const []])
    : _deadlines = List<Deadline>.from(initialDeadlines);

  final List<Deadline> _deadlines;

  @override
  List<Deadline> getDeadlines() => List<Deadline>.unmodifiable(_deadlines);

  @override
  Deadline? getDeadlineById(String id) {
    for (final deadline in _deadlines) {
      if (deadline.id == id) return deadline;
    }
    return null;
  }

  @override
  Deadline addDeadline(Deadline deadline) {
    if (getDeadlineById(deadline.id) != null) {
      throw StateError('A deadline with this id already exists.');
    }
    _deadlines.add(deadline);
    return deadline;
  }

  @override
  Deadline updateDeadline(Deadline deadline) {
    final index = _deadlines.indexWhere((item) => item.id == deadline.id);
    if (index == -1) throw StateError('Deadline not found.');
    _deadlines[index] = deadline;
    return deadline;
  }

  @override
  void deleteDeadline(String id) =>
      _deadlines.removeWhere((deadline) => deadline.id == id);
}
