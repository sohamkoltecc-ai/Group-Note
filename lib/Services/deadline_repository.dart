import '../Backend/deadline.dart';

abstract class DeadlineRepository {
  List<Deadline> getDeadlines();
  Deadline? getDeadlineById(String id);
  Deadline addDeadline(Deadline deadline);
  Deadline updateDeadline(Deadline deadline);
  void deleteDeadline(String id);
}
