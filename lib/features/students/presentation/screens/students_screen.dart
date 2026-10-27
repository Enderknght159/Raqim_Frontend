import 'package:flutter/material.dart';

/// Students roster/search. Placeholder until the feature is built.
class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الطلاب')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.groups_outlined, size: 56),
            SizedBox(height: 12),
            Text('الطلاب — قريباً'),
          ],
        ),
      ),
    );
  }
}
