import 'package:flutter/material.dart';
import '../Services/deadline_service.dart';
import '../Widget/deadline_card.dart';
import 'deadline_form_screen.dart';

enum DeadlineFilter { all, upcoming, today, overdue, completed }

class DeadlinesScreen extends StatefulWidget {
  const DeadlinesScreen({super.key, required this.deadlineService});

  final DeadlineService deadlineService;
  @override
  State<DeadlinesScreen> createState() => _DeadlinesScreenState();
}

class _DeadlinesScreenState extends State<DeadlinesScreen> {
  late final DeadlineService _service;
  DeadlineFilter _filter = DeadlineFilter.all;
  DeadlinePriority? _priority;

  @override
  void initState() {
    super.initState();
    _service = widget.deadlineService;
    _service.addListener(_refresh);
  }

  @override
  void dispose() {
    _service.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var deadlines = switch (_filter) {
      DeadlineFilter.all => _service.deadlines,
      DeadlineFilter.upcoming => _service.upcoming(),
      DeadlineFilter.today => _service.today(),
      DeadlineFilter.overdue => _service.overdue(),
      DeadlineFilter.completed => _service.completed(),
    };
    if (_priority != null) {
      deadlines = deadlines
          .where((item) => item.priority == _priority)
          .toList();
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Deadline'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: deadlines.isEmpty
                  ? _emptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: deadlines.length,
                      itemBuilder: (context, index) => DeadlineCard(
                        deadline: deadlines[index],
                        onTap: () => _openForm(deadline: deadlines[index]),
                        onToggleComplete: () => _toggle(deadlines[index]),
                        onDelete: () => _delete(deadlines[index]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() => Container(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            const SizedBox(width: 4),
            const Text(
              'Deadlines',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: DeadlineFilter.values
                .map(
                  (filter) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_filterLabel(filter)),
                      selected: _filter == filter,
                      selectedColor: Colors.white,
                      backgroundColor: Colors.white.withValues(alpha: .16),
                      labelStyle: TextStyle(
                        color: _filter == filter
                            ? const Color(0xFF1E3A8A)
                            : Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) => setState(() => _filter = filter),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonHideUnderline(
          child: DropdownButton<DeadlinePriority?>(
            value: _priority,
            hint: const Text(
              'All priorities',
              style: TextStyle(color: Colors.white),
            ),
            dropdownColor: Colors.white,
            iconEnabledColor: Colors.white,
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All priorities'),
              ),
              ...DeadlinePriority.values.map(
                (priority) => DropdownMenuItem(
                  value: priority,
                  child: Text(priority.label),
                ),
              ),
            ],
            onChanged: (value) => setState(() => _priority = value),
          ),
        ),
      ],
    ),
  );

  Widget _emptyState() => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.event_available_outlined,
          size: 50,
          color: Color(0xFF94A3B8),
        ),
        SizedBox(height: 12),
        Text('No deadlines found', style: TextStyle(color: Color(0xFF64748B))),
      ],
    ),
  );
  String _filterLabel(DeadlineFilter filter) => switch (filter) {
    DeadlineFilter.all => 'All',
    DeadlineFilter.upcoming => 'Upcoming',
    DeadlineFilter.today => 'Today',
    DeadlineFilter.overdue => 'Overdue',
    DeadlineFilter.completed => 'Completed',
  };
  Future<void> _openForm({Deadline? deadline}) async => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) =>
          DeadlineFormScreen(deadlineService: _service, deadline: deadline),
    ),
  );
  void _toggle(Deadline deadline) {
    deadline.completed
        ? _service.markIncomplete(deadline.id)
        : _service.markComplete(deadline.id);
  }

  void _delete(Deadline deadline) {
    _service.deleteDeadline(deadline.id);
  }
}
