import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/app_theme.dart';

/// A scannable QR code card rendered from a code string (student id/barcode).
/// Used in the profile (B5).
class QrCodeCard extends StatelessWidget {
  const QrCodeCard({
    super.key,
    required this.code,
    this.size = 220,
  });

  final String code;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: tokens.borderStructural),
          ),
          child: QrImageView(
            data: code,
            version: QrVersions.auto,
            size: size,
            gapless: true,
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          code,
          textDirection: TextDirection.ltr,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
        ),
      ],
    );
  }
}