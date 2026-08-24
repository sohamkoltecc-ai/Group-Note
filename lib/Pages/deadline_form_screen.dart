import 'package:flutter/material.dart';
import '../Services/deadline_service.dart';

class DeadlineFormScreen extends StatefulWidget {
  const DeadlineFormScreen({
    super.key,
    required this.deadlineService,
    this.deadline,
    this.initialDate,
  });

  final DeadlineService deadlineService;
  final Deadline? deadline;
  final DateTime? initialDate;

  @override
  State<DeadlineFormScreen> createState() => _DeadlineFormScreenState();
}

class _DeadlineFormScreenState extends State<DeadlineFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime _date;
  late TimeOfDay _time;
  late DeadlinePriority _priority;
  late ReminderOption _reminder;

  @override
  void initState() {
    super.initState();
    final existing = widget.deadline;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _descriptionController = TextEditingController(
      text: existing?.description ?? '',
    );
    _date = existing?.dueDate ?? widget.initialDate ?? DateTime.now();
    _time = existing == null
        ? TimeOfDay.now()
        : TimeOfDay(
            hour: existing.dueTime.hour,
            minute: existing.dueTime.minute,
          );
    _priority = existing?.priority ?? DeadlinePriority.medium;
    _reminder = existing?.reminder ?? ReminderOption.none;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF8FAFC),
    appBar: AppBar(
      title: Text(
        widget.deadline == null ? 'Create Deadline' : 'Edit Deadline',
      ),
      backgroundColor: const Color(0xFF2563EB),
      foregroundColor: Colors.white,
    ),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _field(_titleController, 'Title', required: true),
          const SizedBox(height: 14),
          _field(_descriptionController, 'Description', maxLines: 3),
          const SizedBox(height: 18),
          _selectionTile(
            Icons.calendar_today_rounded,
            'Date',
            _dateLabel(),
            _pickDate,
          ),
          _selectionTile(
            Icons.access_time_rounded,
            'Time',
            _time.format(context),
            _pickTime,
          ),
          const SizedBox(height: 18),
          _dropdown<DeadlinePriority>(
            'Priority',
            _priority,
            DeadlinePriority.values,
            (value) => value.label,
            (value) => setState(() => _priority = value),
          ),
          const SizedBox(height: 14),
          _dropdown<ReminderOption>(
            'Reminder',
            _reminder,
            ReminderOption.values,
            (value) => value.label,
            (value) => setState(() => _reminder = value),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _save,
              icon: const Icon(Icons.save_rounded),
              label: Text(
                widget.deadline == null ? 'Create Deadline' : 'Save Changes',
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    int maxLines = 1,
  }) => TextFormField(
    controller: controller,
    maxLines: maxLines,
    decoration: InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
    ),
    validator: required
        ? (value) =>
              value == null || value.trim().isEmpty ? 'Title is required' : null
        : null,
  );

  Widget _selectionTile(
    IconData icon,
    String label,
    String value,
    VoidCallback onTap,
  ) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
    tileColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    leading: Icon(icon, color: const Color(0xFF2563EB)),
    title: Text(label),
    subtitle: Text(value),
    trailing: const Icon(Icons.chevron_right_rounded),
    onTap: onTap,
  );

  Widget _dropdown<T>(
    String label,
    T current,
    List<T> values,
    String Function(T) name,
    ValueChanged<T> onChanged,
  ) => DropdownButtonFormField<T>(
    initialValue: current,
    isExpanded: true,
    decoration: InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
    ),
    items: values
        .map(
          (value) => DropdownMenuItem(value: value, child: Text(name(value))),
        )
        .toList(),
    onChanged: (value) {
      if (value != null) onChanged(value);
    },
  );

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _date = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(context: context, initialTime: _time);
    if (time != null) setState(() => _time = time);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final service = widget.deadlineService;
    final existing = widget.deadline;
    final deadline = existing == null
        ? service.addDeadline(
            title: _titleController.text,
            description: _descriptionController.text,
            dueDate: _date,
            dueTime: DeadlineTime(hour: _time.hour, minute: _time.minute),
            priority: _priority,
            reminder: _reminder,
          )
        : existing.copyWith(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            dueDate: _date,
            dueTime: DeadlineTime(hour: _time.hour, minute: _time.minute),
            priority: _priority,
            reminder: _reminder,
          );
    if (existing != null) service.updateDeadline(deadline);
    if (mounted) Navigator.pop(context, deadline);
  }

  String _dateLabel() => '${_date.day}/${_date.month}/${_date.year}';
}
