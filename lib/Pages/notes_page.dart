import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  // ---------------------------------------------------------
  // NOTEBOOKS
  // ---------------------------------------------------------

  final List<Map<String, dynamic>> notebooks = [
    {
      'title': 'Data Structures',
      'pages': 12,
      'type': 'Notebook',
      'icon': Icons.menu_book_rounded,
      'color': const Color(0xFF2563EB),
      'description': 'Important Data Structures notes',
      'content': '',
    },
    {
      'title': 'DBMS Unit 2',
      'pages': 8,
      'type': 'Notebook',
      'icon': Icons.storage_rounded,
      'color': const Color(0xFF7C3AED),
      'description': 'Database Systems notes',
      'content': '',
    },
    {
      'title': 'IoT Architecture',
      'pages': 5,
      'type': 'Notebook',
      'icon': Icons.sensors_rounded,
      'color': const Color(0xFF059669),
      'description': 'IoT Architecture notes',
      'content': '',
    },
  ];

  // ---------------------------------------------------------
  // PDF NOTES
  // ---------------------------------------------------------

  final List<Map<String, dynamic>> pdfNotes = [];

  // ---------------------------------------------------------
  // ADD PDF
  // ---------------------------------------------------------

  Future<void> _addPdf() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result == null) {
        return;
      }

      final file = result.files.single;

      if (file.bytes == null) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to read this PDF file'),
          ),
        );
        return;
      }

      final Uint8List pdfBytes = file.bytes!;

      setState(() {
        pdfNotes.insert(0, {
          'title': file.name,
          'bytes': pdfBytes,
        });
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${file.name} added successfully'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not add PDF: $e'),
        ),
      );
    }
  }

  // ---------------------------------------------------------
  // VIEW PDF
  // ---------------------------------------------------------

  void _viewPdf(Map<String, dynamic> pdf) {
    final Uint8List bytes = pdf['bytes'] as Uint8List;
    final String title = pdf['title'] as String;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerPage(
          title: title,
          bytes: bytes,
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // DELETE PDF
  // ---------------------------------------------------------

  void _deletePdf(int index) {
    final String title = pdfNotes[index]['title'] as String;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Delete PDF?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "$title"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  pdfNotes.removeAt(index);
                });

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PDF deleted successfully'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------
  // CREATE NEW NOTEBOOK
  // ---------------------------------------------------------

  void _showNewNotebookDialog() {
    final TextEditingController nameController =
        TextEditingController();

    final TextEditingController descriptionController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Create New Notebook',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 21,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Notebook Name',
                  hintText: 'e.g. Data Structures',
                  prefixIcon:
                      const Icon(Icons.menu_book_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: descriptionController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText:
                      'Write a few words about this notebook',
                  prefixIcon:
                      const Icon(Icons.description_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
          actionsPadding:
              const EdgeInsets.fromLTRB(16, 0, 16, 14),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final description =
                    descriptionController.text.trim();

                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Please enter a notebook name'),
                    ),
                  );
                  return;
                }

                final newNotebook = {
                  'title': name,
                  'pages': 0,
                  'type': 'Notebook',
                  'icon': Icons.menu_book_rounded,
                  'color': const Color(0xFF2563EB),
                  'description': description.isEmpty
                      ? 'My personal notes'
                      : description,
                  'content': '',
                };

                setState(() {
                  notebooks.add(newNotebook);
                });

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$name notebook created'),
                  ),
                );

                _openNotebook(newNotebook);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Create Notebook',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------
  // OPEN NOTEBOOK
  // ---------------------------------------------------------

  void _openNotebook(Map<String, dynamic> notebook) {
    final TextEditingController contentController =
        TextEditingController(
      text: notebook['content'] as String,
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return SizedBox(
                height:
                    MediaQuery.of(context).size.height * 0.75,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF1E3A8A),
                            Color(0xFF2563EB),
                          ],
                        ),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color:
                                  Colors.white.withOpacity(0.15),
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.menu_book_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notebook['title'] as String,
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  notebook['description']
                                      as String,
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFFBFDBFE),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                            },
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(18, 18, 18, 10),
                      child: Row(
                        children: [
                          const Text(
                            'Page 1',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${contentController.text.length} characters',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                        ),
                        child: TextField(
                          controller: contentController,
                          maxLines: null,
                          expands: true,
                          textAlignVertical:
                              TextAlignVertical.top,
                          onChanged: (value) {
                            setDialogState(() {});
                          },
                          decoration: InputDecoration(
                            hintText:
                                'Start writing your notes here...\n\nYou can write definitions, important points, examples, formulas, or anything you want to remember.',
                            hintStyle: const TextStyle(
                              color: Color(0xFF94A3B8),
                              height: 1.5,
                            ),
                            filled: true,
                            fillColor:
                                const Color(0xFFF8FAFC),
                            contentPadding:
                                const EdgeInsets.all(16),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(dialogContext);
                              },
                              style: OutlinedButton.styleFrom(
                                minimumSize:
                                    const Size(0, 50),
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text('Close'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  notebook['content'] =
                                      contentController.text;

                                  notebook['pages'] =
                                      contentController.text
                                              .trim()
                                              .isEmpty
                                          ? 0
                                          : 1;
                                });

                                Navigator.pop(dialogContext);

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Notes saved successfully',
                                    ),
                                  ),
                                );
                              },
                              icon:
                                  const Icon(Icons.save_rounded),
                              label:
                                  const Text('Save Notes'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF1E3A8A),
                                foregroundColor: Colors.white,
                                minimumSize:
                                    const Size(0, 50),
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // HEADER
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1E3A8A),
                Color(0xFF2563EB),
              ],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(
            20,
            18,
            20,
            24,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Notebooks & PDFs',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${notebooks.length + pdfNotes.length} files stored',
                style: const TextStyle(
                  color: Color(0xFFBFDBFE),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        // MAIN CONTENT
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 20),
              children: [
                // NOTEBOOK SECTION
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Row(
                    children: [
                      const Text(
                        'My Notebooks',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${notebooks.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 260,
                  child: GridView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    scrollDirection: Axis.horizontal,
                    itemCount: notebooks.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.05,
                    ),
                    itemBuilder: (context, index) {
                      return _buildNotebookCard(
                        notebooks[index],
                      );
                    },
                  ),
                ),

                // NEW NOTEBOOK
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _showNewNotebookDialog,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text(
                        'New Notebook',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                ),

                // PDF SECTION
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(20, 5, 20, 10),
                  child: Row(
                    children: [
                      const Text(
                        'PDF Notes',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${pdfNotes.length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ),

                // ADD PDF BUTTON
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _addPdf,
                      icon: const Icon(
                        Icons.picture_as_pdf_rounded,
                      ),
                      label: const Text(
                        'Add PDF Notes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            const Color(0xFF1E3A8A),
                        side: const BorderSide(
                          color: Color(0xFF1E3A8A),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // PDF LIST
                if (pdfNotes.isEmpty)
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.picture_as_pdf_outlined,
                          size: 42,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'No PDF notes yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Add your study PDFs here to view them anytime.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...List.generate(
                    pdfNotes.length,
                    (index) => _buildPdfCard(
                      pdfNotes[index],
                      index,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------
  // NOTEBOOK CARD
  // ---------------------------------------------------------

  Widget _buildNotebookCard(
    Map<String, dynamic> notebook,
  ) {
    final Color color =
        notebook['color'] as Color;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _openNotebook(notebook),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: Icon(
                notebook['icon'] as IconData,
                color: color,
                size: 26,
              ),
            ),
            const Spacer(),
            Text(
              notebook['title'] as String,
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${notebook['pages']} Pages',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 3),
            const Row(
              children: [
                Icon(
                  Icons.menu_book_outlined,
                  size: 14,
                  color: Color(0xFF94A3B8),
                ),
                SizedBox(width: 4),
                Text(
                  'Notebook',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // PDF CARD
  // ---------------------------------------------------------

  Widget _buildPdfCard(
    Map<String, dynamic> pdf,
    int index,
  ) {
    return Container(
      margin:
          const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE11D48)
                  .withOpacity(0.10),
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.picture_as_pdf_rounded,
              color: Color(0xFFE11D48),
              size: 27,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              pdf['title'] as String,
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ),

          IconButton(
            tooltip: 'View PDF',
            onPressed: () => _viewPdf(pdf),
            icon: const Icon(
              Icons.visibility_rounded,
              color: Color(0xFF2563EB),
            ),
          ),

          IconButton(
            tooltip: 'Delete PDF',
            onPressed: () => _deletePdf(index),
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFE11D48),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// PDF VIEWER PAGE
// ---------------------------------------------------------

class PdfViewerPage extends StatelessWidget {
  final String title;
  final Uint8List bytes;

  const PdfViewerPage({
    Key? key,
    required this.title,
    required this.bytes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor:
            const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: SfPdfViewer.memory(bytes),
    );
  }
}