import 'package:flutter/material.dart';
import '../Services/deadline_service.dart';

class DeadlineCard extends StatelessWidget {
  const DeadlineCard({
    super.key,
    required this.deadline,
    required this.onTap,
    required this.onToggleComplete,
    required this.onDelete,
  });

  final Deadline deadline;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = _priorityColor(deadline.priority);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: deadline.completed ? const Color(0xFFF8FAFC) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: deadline.completed,
                activeColor: const Color(0xFF2563EB),
                onChanged: (_) => onToggleComplete(),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deadline.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: deadline.completed
                            ? TextDecoration.lineThrough
                            : null,
                        color: deadline.completed
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF0F172A),
                      ),
                    ),
                    if (deadline.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        deadline.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _chip(
                          Icons.calendar_today_rounded,
                          '${deadline.dueDate.day}/${deadline.dueDate.month}/${deadline.dueDate.year}',
                          const Color(0xFF2563EB),
                        ),
                        _chip(
                          Icons.access_time_rounded,
                          deadline.dueTime.format(context),
                          const Color(0xFF64748B),
                        ),
                        _chip(
                          Icons.flag_rounded,
                          deadline.isOverdue
                              ? 'Overdue'
                              : deadline.priority.label,
                          deadline.isOverdue ? const Color(0xFFDC2626) : color,
                        ),
                        if (deadline.reminder != ReminderOption.none)
                          _chip(
                            Icons.notifications_active_outlined,
                            deadline.reminder.label,
                            const Color(0xFF7C3AED),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    onDelete();
                  } else {
                    onTap();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  Color _priorityColor(DeadlinePriority priority) => switch (priority) {
    DeadlinePriority.low => const Color(0xFF059669),
    DeadlinePriority.medium => const Color(0xFFD97706),
    DeadlinePriority.high => const Color(0xFFEA580C),
    DeadlinePriority.critical => const Color(0xFFDC2626),
  };
}
