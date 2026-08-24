import 'package:flutter/material.dart';
import '../Services/deadline_service.dart';
import '../Widget/calendar_day_cell.dart';
import '../Widget/deadline_card.dart';
import 'deadline_form_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key, required this.deadlineService});

  final DeadlineService deadlineService;
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final DeadlineService _service;
  late DateTime _visibleMonth;
  late DateTime _selectedDate;
  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _service = widget.deadlineService;
    _selectedDate = _dateOnly(DateTime.now());
    _visibleMonth = DateTime(_selectedDate.year, _selectedDate.month);
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
    final selectedDeadlines = _service.forDate(_selectedDate);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addDeadline,
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
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _calendarCard(),
                  const SizedBox(height: 22),
                  Text(
                    'Deadlines on ${_dateLabel(_selectedDate)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (selectedDeadlines.isEmpty)
                    _emptySelectedDate()
                  else
                    ...selectedDeadlines.map(
                      (item) => DeadlineCard(
                        deadline: item,
                        onTap: () => _editDeadline(item),
                        onToggleComplete: () => _toggle(item),
                        onDelete: () => _delete(item),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    child: Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        const SizedBox(width: 4),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Calendar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Plan deadlines and reminders',
                style: TextStyle(color: Color(0xFFBFDBFE), fontSize: 13),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: _goToday,
          child: const Text(
            'Today',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );

  Widget _calendarCard() {
    final first = DateTime(_visibleMonth.year, _visibleMonth.month);
    final daysInMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month + 1,
      0,
    ).day;
    final leadingEmptyCells = first.weekday - 1;
    final totalCells = leadingEmptyCells + daysInMonth;
    final rowCells = totalCells + ((7 - totalCells % 7) % 7);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => setState(
                  () => _visibleMonth = DateTime(
                    _visibleMonth.year,
                    _visibleMonth.month - 1,
                  ),
                ),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Text(
                '${_months[_visibleMonth.month - 1]} ${_visibleMonth.year}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              IconButton(
                onPressed: () => setState(
                  () => _visibleMonth = DateTime(
                    _visibleMonth.year,
                    _visibleMonth.month + 1,
                  ),
                ),
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.05,
            children: [
              ..._weekdays.map(
                (day) => Center(
                  child: Text(
                    day,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.9,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rowCells,
            itemBuilder: (context, index) {
              if (index < leadingEmptyCells || index >= totalCells) {
                return const SizedBox.shrink();
              }
              final date = DateTime(
                _visibleMonth.year,
                _visibleMonth.month,
                index - leadingEmptyCells + 1,
              );
              return CalendarDayCell(
                date: date,
                isSelected: _sameDate(date, _selectedDate),
                isToday: _sameDate(date, DateTime.now()),
                hasDeadline: _service.hasDeadlineOn(date),
                onTap: () => setState(() => _selectedDate = date),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _emptySelectedDate() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Row(
      children: [
        const Icon(Icons.event_busy_outlined, color: Color(0xFF94A3B8)),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'No deadlines for this date.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ),
        TextButton(onPressed: _addDeadline, child: const Text('Add')),
      ],
    ),
  );

  void _goToday() => setState(() {
    _selectedDate = _dateOnly(DateTime.now());
    _visibleMonth = DateTime(_selectedDate.year, _selectedDate.month);
  });
  Future<void> _addDeadline() async => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => DeadlineFormScreen(
        deadlineService: _service,
        initialDate: _selectedDate,
      ),
    ),
  );
  Future<void> _editDeadline(Deadline deadline) async => Navigator.push(
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

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
  static bool _sameDate(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
  String _dateLabel(DateTime value) =>
      '${_months[value.month - 1]} ${value.day}, ${value.year}';
}
