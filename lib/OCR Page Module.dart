import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'Services/ocr_service.dart';

class OCRPage extends StatefulWidget {
  const OCRPage({super.key});

  @override
  State<OCRPage> createState() => _OCRPageState();
}

class _OCRPageState extends State<OCRPage> {
  final ImagePicker picker = ImagePicker();
  final OCRService ocrService = OCRService();

  String extractedText = "";
  bool loading = false;

  Future<void> selectImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() {
      loading = true;
    });

    final text = await ocrService.extractText(File(image.path));

    setState(() {
      extractedText = text;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("OCR Notes")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: selectImage,
              icon: const Icon(Icons.image),
              label: const Text("Select Image"),
            ),

            const SizedBox(height: 20),

            if (loading) const CircularProgressIndicator(),

            if (!loading)
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: extractedText),
                  maxLines: null,
                  expands: true,
                  decoration: const InputDecoration(
                    hintText: "Extracted text will appear here...",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
