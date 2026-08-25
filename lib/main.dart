import 'package:flutter/material.dart';
import 'package:groupnote/Pages/home_Page.dart';
import 'package:groupnote/Pages/Home_Page.dart';
import 'package:groupnote/Services/deadline_service.dart';
import 'package:groupnote/Services/deadline_service_factory.dart';

void main() {
  runApp(MyApp(deadlineService: createLocalDeadlineService()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.deadlineService});

  final DeadlineService deadlineService;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: NavigationHub(deadlineService: deadlineService),
    );
  }
}
