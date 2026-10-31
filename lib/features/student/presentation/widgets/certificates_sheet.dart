import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/status_badge.dart';
import 'package:raqim/core/widgets/adaptive_sheet.dart';

/// One immutable certificate entry for the shared full-list sheet.
typedef CertificateEntry = ({
  int startJuz,
  int endJuz,
  int mark,
  bool byHeart,
  DateTime date,
});

/// Full Quran-certificates sheet — shared by the student Quran tab (B2) and
/// the admin student profile (E7).
void showCertificatesSheet(BuildContext context, List<CertificateEntry> certs) {
  final tokens = Theme.of(context).extension<AppTokens>()!;
  showAppSheet<void>(
    context: context,
    maxWidth: 720,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (context, controller) => ListView.builder(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        itemCount: certs.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Text(
                    'شهادات القرآن',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  StatusBadge(
                    label: '${certs.length} شهادة',
                    color: tokens.reward,
                  ),
                ],
              ),
            );
          }
          final c = certs[i - 1];
          return ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.school_outlined, color: tokens.reward),
            title: Text(
              'الجزء ${c.startJuz} – ${c.endJuz}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              'الدرجة: ${c.mark} · ${c.date.day}/${c.date.month}/${c.date.year}',
            ),
            trailing: StatusBadge(
              label: c.byHeart ? 'عن ظهر قلب' : 'عن حاضر',
              color: c.byHeart ? tokens.brand : tokens.textMuted,
            ),
          );
        },
      ),
    ),
  );
}
