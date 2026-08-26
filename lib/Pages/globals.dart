import 'package:flutter/material.dart';

// --- SHARED DATA MODELS ---
class SearchItem {
  final String title;
  final String category;
  final String subtitle;
  final IconData icon;
  final Color accentColor;

  SearchItem({
    required this.title,
    required this.category,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });
}

class TaskItem {
  final String id;
  final String title;
  final String course;
  final String dueDate;
  bool isCompleted;

  TaskItem({
    required this.id,
    required this.title,
    required this.course,
    required this.dueDate,
    this.isCompleted = false,
  });
}

// --- GLOBAL MOCK DATA ---
final List<SearchItem> globalSearchDatabase = [
  SearchItem(
    title: 'Data Structures - Stacks PDF',
    category: 'PDF',
    subtitle: 'Unit 3 • 24 Annotations',
    icon: Icons.picture_as_pdf_rounded,
    accentColor: Colors.redAccent,
  ),
  SearchItem(
    title: 'DBMS Internal Exam Group',
    category: 'Group',
    subtitle: '138 Members • Active Discussion',
    icon: Icons.forum_rounded,
    accentColor: const Color(0xFF2563EB),
  ),
  SearchItem(
    title: 'Complete DBMS Assignment 3',
    category: 'Task',
    subtitle: 'Due Tomorrow • 6:00 PM',
    icon: Icons.assignment_turned_in_rounded,
    accentColor: Colors.amber.shade700,
  ),
  SearchItem(
    title: 'IoT Sensor Data Lecture Notes',
    category: 'Note',
    subtitle: 'Updated by Soham • 5 Pages',
    icon: Icons.edit_note_rounded,
    accentColor: Colors.green,
  ),
  SearchItem(
    title: 'DTM Study Circle',
    category: 'Group',
    subtitle: '4 Members • Private Group',
    icon: Icons.groups_rounded,
    accentColor: Colors.indigo,
  ),
  SearchItem(
    title: 'Prepare DS Unit 3 Questions',
    category: 'Task',
    subtitle: 'Due Aug 28 • 9:00 PM',
    icon: Icons.check_circle_rounded,
    accentColor: Colors.teal,
  ),
];

final List<TaskItem> globalTaskList = [
  TaskItem(
    id: '1',
    title: 'Complete DBMS Assignment 3',
    course: 'Database Systems',
    dueDate: 'Tomorrow, 6:00 PM',
  ),
  TaskItem(
    id: '2',
    title: 'Prepare DS Unit 3 Questions',
    course: 'Data Structures',
    dueDate: 'Aug 28, 9:00 PM',
  ),
  TaskItem(
    id: '3',
    title: 'Revise IoT Sensor Architecture',
    course: 'IoT Systems',
    dueDate: 'Aug 30, 11:59 PM',
  ),
  TaskItem(
    id: '4',
    title: 'Group Note Mini-Project Submission',
    course: 'Software Engineering',
    dueDate: 'Sep 02, 5:00 PM',
  ),
];
