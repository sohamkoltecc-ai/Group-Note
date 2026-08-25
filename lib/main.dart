import 'package:flutter/material.dart';
import 'package:groupnote/Pages/Navigation_hub.dart';
import 'package:groupnote/Services/deadline_service.dart';
import 'package:groupnote/Services/deadline_service_factory.dart';

void main() {
  runApp(MyApp(deadlineService: createLocalDeadlineService()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.deadlineService});

  final DeadlineService deadlineService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Group Note',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF1E40AF),
        primaryColor: const Color(0xFF2563EB),
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
          surface: const Color(0xFFF8FAFC),
        ),
      ),
      home: NavigationHub(deadlineService: deadlineService),
    );
  }
}