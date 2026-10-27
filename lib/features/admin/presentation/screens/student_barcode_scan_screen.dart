import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';

/// Full-screen barcode scan that pops with the raw scanned value (used by
/// [StudentPickerField] and other student lookups). Falls back to manual
/// typing when the camera is unavailable.
class StudentBarcodeScanScreen extends StatefulWidget {
  const StudentBarcodeScanScreen({super.key});

  @override
  State<StudentBarcodeScanScreen> createState() =>
      _StudentBarcodeScanScreenState();
}

class _StudentBarcodeScanScreenState extends State<StudentBarcodeScanScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  final _manual = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    _manual.dispose();
    super.dispose();
  }

  void _submit(String code) {
    final value = code.trim();
    if (value.isEmpty || _busy || !mounted) return;
    _busy = true;
    HapticFeedback.lightImpact();
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Scaffold(
      appBar: AppBar(title: const Text('مسح باركود الطالب')),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                final barcode = capture.barcodes.firstOrNull;
                final value = barcode?.rawValue;
                if (value != null) _submit(value);
              },
              errorBuilder: (context, error) => _manualArea(tokens),
            ),
          ),
          Container(
            width: double.infinity,
            color: tokens.surfaceSubtle,
            padding: const EdgeInsets.all(16),
            child: _manualArea(tokens, compact: true),
          ),
        ],
      ),
    );
  }

  Widget _manualArea(AppTokens tokens, {bool compact = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!compact)
          Text(
            'الكاميرا غير متاحة — أدخل الباركود يدويًا',
            style: TextStyle(color: tokens.textMuted),
          ),
        TextField(
          controller: _manual,
          autofocus: compact,
          textDirection: TextDirection.ltr,
          decoration: const InputDecoration(
            labelText: 'الباركود',
            hintText: 'frq-532',
            prefixIcon: Icon(Icons.qr_code),
          ),
          onSubmitted: _submit,
        ),
        const SizedBox(height: 10),
        AppButton(
          label: 'استخدام الباركود',
          icon: Icons.check,
          onPressed: () => _submit(_manual.text),
        ),
      ],
    );
  }
}
