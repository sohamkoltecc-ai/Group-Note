import 'package:flutter/material.dart';
import 'globals.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({Key? key}) : super(key: key);

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController courseController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void dispose() {
    titleController.dispose();
    courseController.dispose();
    super.dispose();
  }

  // ================= ADD NEW TASK =================

  void _showAddTaskDialog() {
    titleController.clear();
    courseController.clear();
    selectedDate = null;
    selectedTime = null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Add New Task',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // TASK TITLE
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Task Title',
                        hintText: 'Enter task name',
                        prefixIcon: const Icon(Icons.task_alt),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // COURSE
                    TextField(
                      controller: courseController,
                      decoration: InputDecoration(
                        labelText: 'Course / Subject',
                        hintText: 'Enter course name',
                        prefixIcon: const Icon(Icons.school_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // DATE
                    InkWell(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2035),
                        );

                        if (pickedDate != null) {
                          setDialogState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                selectedDate == null
                                    ? 'Select due date'
                                    : '${selectedDate!.day.toString().padLeft(2, '0')}/'
                                      '${selectedDate!.month.toString().padLeft(2, '0')}/'
                                      '${selectedDate!.year}',
                                style: TextStyle(
                                  color: selectedDate == null
                                      ? const Color(0xFF64748B)
                                      : const Color(0xFF0F172A),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // TIME
                    InkWell(
                      onTap: () async {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );

                        if (pickedTime != null) {
                          setDialogState(() {
                            selectedTime = pickedTime;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              selectedTime == null
                                  ? 'Select due time'
                                  : selectedTime!.format(context),
                              style: TextStyle(
                                color: selectedTime == null
                                    ? const Color(0xFF64748B)
                                    : const Color(0xFF0F172A),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // BUTTONS
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    final title = titleController.text.trim();
                    final course = courseController.text.trim();

                    if (title.isEmpty ||
                        course.isEmpty ||
                        selectedDate == null ||
                        selectedTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please fill all task details',
                          ),
                        ),
                      );
                      return;
                    }

                    final dueDate =
                        '${selectedDate!.day.toString().padLeft(2, '0')}/'
                        '${selectedDate!.month.toString().padLeft(2, '0')}/'
                        '${selectedDate!.year} • '
                        '${selectedTime!.format(context)}';

                    setState(() {
                      globalTaskList.add(
                        TaskItem(
                          id: DateTime.now()
                              .millisecondsSinceEpoch
                              .toString(),
                          title: title,
                          course: course,
                          dueDate: dueDate,
                          isCompleted: false,
                        ),
                      );
                    });

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Task added successfully!'),
                      ),
                    );
                  },
                  child: const Text('Add Task'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ================= TASK PAGE =================

  @override
  Widget build(BuildContext context) {
    final pendingTasks =
        globalTaskList.where((task) => !task.isCompleted).length;

    return Column(
      children: [

        // HEADER
        _buildPageHeader(
          'Planner & Tasks',
          '$pendingTasks Pending Tasks',
        ),

        // TASK AREA
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [

                // MY TASKS TITLE
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 22, 20, 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'My Tasks',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),

                // TASK LIST
                Expanded(
                  child: globalTaskList.isEmpty
                      ? const Center(
                          child: Text(
                            'No tasks yet',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 15,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            20,
                            5,
                            20,
                            10,
                          ),
                          itemCount: globalTaskList.length,
                          itemBuilder: (context, index) {
                            final task = globalTaskList[index];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: CheckboxListTile(
                                activeColor: const Color(0xFF2563EB),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(16),
                                ),
                                value: task.isCompleted,
                                onChanged: (value) {
                                  setState(() {
                                    task.isCompleted =
                                        value ?? false;
                                  });
                                },

                                title: Text(
                                  task.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: task.isCompleted
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF0F172A),
                                    decoration: task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),

                                subtitle: Padding(
                                  padding:
                                      const EdgeInsets.only(top: 5),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.school_outlined,
                                        size: 14,
                                        color: Color(0xFF64748B),
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          task.course,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color:
                                                Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      const Icon(
                                        Icons.access_time,
                                        size: 14,
                                        color: Color(0xFF64748B),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        task.dueDate,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color:
                                              Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // ADD NEW TASK BUTTON
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    5,
                    20,
                    15,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: _showAddTaskDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Add New Task',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ================= HEADER =================

  Widget _buildPageHeader(
    String title,
    String subtitle,
  ) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF2563EB),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        20,
        16,
        20,
        24,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF93C5FD),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}