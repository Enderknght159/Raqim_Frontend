import 'package:flutter/material.dart';

/// Scan / manual attendance screen (kiosk-style). Placeholder until built.
class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الحضور')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code_scanner, size: 56),
            SizedBox(height: 12),
            Text('الحضور — قريباً'),
          ],
        ),
      ),
    );
  }
}
