import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:raqim/core/network/api_exception.dart';
import 'package:raqim/core/theme/app_theme.dart';
import 'package:raqim/core/widgets/async_view.dart';
import 'package:raqim/shared/no_access_screen.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  home: child,
);

void main() {
  testWidgets('no-access view speaks Arabic and offers reload + back', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        Scaffold(
          body: NoAccessView(
            onRetry: () {},
            onBack: () {},
            backLabel: 'العودة للرئيسية',
          ),
        ),
      ),
    );

    expect(find.text('لا تملك الصلاحية لعمل هذا الإجراء'), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsOneWidget);
    expect(find.text('العودة للرئيسية'), findsOneWidget);
  });

  testWidgets('a forbidden AsyncView keeps a Scaffold and shows the no-access '
      'state instead of a raw 403', (tester) async {
    final future = Future<int>.delayed(
      const Duration(milliseconds: 10),
      () => throw const ApiException(
        code: 'E16',
        messageAr: 'لا تملك صلاحية',
        statusCode: 403,
      ),
    );
    await tester.pumpWidget(
      _wrap(
        AsyncView<int>(
          future: future,
          errorTitle: 'تعذر التحميل',
          onRetry: () {},
          frame: (context, child) => Scaffold(
            appBar: AppBar(title: const Text('اختبار')),
            body: child,
          ),
          builder: (context, value) => Text('$value'),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pumpAndSettle();

    expect(find.text('اختبار'), findsOneWidget);
    expect(find.text('لا تملك الصلاحية لعمل هذا الإجراء'), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsOneWidget);
    expect(find.text('لا تملك صلاحية'), findsNothing);
  });
}
