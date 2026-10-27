import 'package:flutter/material.dart';

import 'responsive_scope.dart';

/// Adaptive replacement for [showModalBottomSheet].
///
/// - Compact portrait: the familiar bottom sheet.
/// - Rail/expanded, or a short landscape window: a dialog centred on screen.
///
/// The caller keeps building its content exactly as before; only the host
/// changes. This keeps every existing sheet functional on wide windows without
/// duplicating content.
Future<T?> showAppSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  double maxWidth = 560,
  bool isScrollControlled = true,
  bool showDragHandle = true,
  bool useSafeArea = true,
  bool forceDialog = false,
}) {
  final data = ResponsiveScope.of(context);
  final useDialog = forceDialog || !data.isCompact || data.dense;

  if (!useDialog) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      showDragHandle: showDragHandle,
      useSafeArea: useSafeArea,
      builder: builder,
    );
  }

  final size = MediaQuery.sizeOf(context);
  return showDialog<T>(
    context: context,
    builder: (dialogContext) => Dialog(
      insetPadding: const EdgeInsets.all(24),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: size.height * 0.9,
        ),
        child: builder(dialogContext),
      ),
    ),
  );
}
