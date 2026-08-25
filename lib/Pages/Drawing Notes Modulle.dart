import 'package:flutter/material.dart';

class DrawingPoint {
  final Offset offset;
  final Paint paint;

  DrawingPoint({required this.offset, required this.paint});
}

class DrawingNotePage extends StatefulWidget {
  const DrawingNotePage({super.key});

  @override
  State<DrawingNotePage> createState() => _DrawingNotePageState();
}

class _DrawingNotePageState extends State<DrawingNotePage> {
  final List<DrawingPoint?> points = [];

  Color selectedColor = Colors.black;
  double strokeWidth = 5;

  void addPoint(Offset point) {
    final paint = Paint()
      ..color = selectedColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    setState(() {
      points.add(DrawingPoint(offset: point, paint: paint));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Drawing Note"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              setState(() {
                points.clear();
              });
            },
          ),
        ],
      ),
      body: GestureDetector(
        onPanStart: (details) {
          addPoint(details.localPosition);
        },
        onPanUpdate: (details) {
          addPoint(details.localPosition);
        },
        onPanEnd: (_) {
          setState(() {
            points.add(null);
          });
        },
        child: CustomPaint(
          painter: DrawingPainter(points),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint?> points;

  DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];

      if (current != null && next != null) {
        canvas.drawLine(current.offset, next.offset, current.paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    return true;
  }
}
