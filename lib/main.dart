import 'package:flutter/material.dart';

import 'Pages/Ai screen.dart';
import 'Pages/Drawing Notes Modulle.dart';
import 'Pages/OCR Page Module.dart';

void main() {
  runApp(const NoteApp());
}

class NoteApp extends StatelessWidget {
  const NoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Note App',

      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),

      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Note App'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [
            FeatureCard(
              icon: Icons.document_scanner,
              title: 'OCR',
              subtitle: 'Scan notes',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OCRPage()),
              ),
            ),
            FeatureCard(
              icon: Icons.smart_toy,
              title: 'AI Assistant',
              subtitle: 'Ask AI',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AIStudyAssistant()),
              ),
            ),
            FeatureCard(
              icon: Icons.brush,
              title: 'Drawing',
              subtitle: 'Draw a note',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DrawingNotePage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  const FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 42),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle),
            ],
          ),
        ),
      ),
    );
  }
}
