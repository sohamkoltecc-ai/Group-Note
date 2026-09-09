import 'package:flutter/material.dart';

import '../Services/Flutter service.dart';

class AIStudyAssistant extends StatefulWidget {
  const AIStudyAssistant({super.key});

  @override
  State<AIStudyAssistant> createState() => _AIStudyAssistantState();
}

class _AIStudyAssistantState extends State<AIStudyAssistant> {
  final TextEditingController controller = TextEditingController();

  String answer = "";
  bool loading = false;

  Future<void> askQuestion() async {
    if (controller.text.trim().isEmpty) return;

    setState(() {
      loading = true;
    });

    try {
      final ai = AIService("YOUR_BACKEND_URL");

      final result = await ai.askAI(controller.text.trim());

      if (!mounted) return;
      setState(() {
        answer = result;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        answer = "Something went wrong.";
      });
    }

    if (!mounted) return;
    setState(() {
      loading = false;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Study Assistant")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Ask your study question...",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: loading ? null : askQuestion,
              child: const Text("Ask AI"),
            ),

            const SizedBox(height: 20),

            if (loading) const CircularProgressIndicator(),

            Expanded(child: SingleChildScrollView(child: Text(answer))),
          ],
        ),
      ),
    );
  }
}
