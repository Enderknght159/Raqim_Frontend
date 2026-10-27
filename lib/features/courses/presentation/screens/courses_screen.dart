import 'package:flutter/material.dart';

/// Courses home (cards). Placeholder until the feature is built.
class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الدورات')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_outlined, size: 56),
            SizedBox(height: 12),
            Text('الدورات — قريباً'),
          ],
        ),
      ),
    );
  }
}
