import 'package:flutter/material.dart';

/// Placeholder for not-yet-implemented feature screens.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.construction, size: 56),
            SizedBox(height: 12),
            Text('قريباً'),
          ],
        ),
      ),
    );
  }
}