import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/models/student_models.dart';
import '../../domain/quran_units.dart';
import 'rating_stars.dart';

/// Full tasmi' (memorization) log sheet — shared by the student Quran tab (B2)
/// and the admin student profile (E7).
void showTasmiLogSheet(BuildContext context, List<Memorization> mems) {
  final tokens = Theme.of(context).extension<AppTokens>()!;
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (context, controller) => ListView.builder(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        // Lazy list: scales to thousands of records without jank.
        itemCount: mems.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text('سجل التسميع',
                      style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  StatusBadge(
                      label: '${mems.length} تسجيلة', color: tokens.brand),
                ],
              ),
            );
          }
          final m = mems[i - 1];
          return ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.menu_book,
                color: RatingStars.colorFor(m.rating, tokens)),
            title: Text(
                'صفحة ${m.page} — ${quranDisplaySurah(m.page, m.partIndex, m.surah)}'),
            subtitle: Text(
                'المسمِّع: ${m.reciterName} · ${m.date.day}/${m.date.month}/${m.date.year}'),
            trailing: RatingStars(rating: m.rating),
          );
        },
      ),
    ),
  );
}
