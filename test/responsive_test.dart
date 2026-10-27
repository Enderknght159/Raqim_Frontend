import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raqim/core/config/app_breakpoints.dart';
import 'package:raqim/core/widgets/adaptive_data_table.dart';
import 'package:raqim/core/widgets/adaptive_sheet.dart';
import 'package:raqim/core/widgets/responsive_scope.dart';
import 'package:raqim/core/widgets/responsive_shell.dart';

void main() {
  group('AppBreakpoints', () {
    test('three width states', () {
      expect(AppBreakpoints.tierOf(390), AppLayoutTier.compact);
      expect(AppBreakpoints.tierOf(599), AppLayoutTier.compact);
      expect(AppBreakpoints.tierOf(600), AppLayoutTier.rail);
      expect(AppBreakpoints.tierOf(1023), AppLayoutTier.rail);
      expect(AppBreakpoints.tierOf(1024), AppLayoutTier.expanded);
    });

    test('phone landscape is dense, tablet portrait is not', () {
      expect(AppBreakpoints.denseFor(const Size(844, 390)), isTrue);
      expect(AppBreakpoints.denseFor(const Size(768, 1024)), isFalse);
    });

    test('tables need width + a tablet-like shortest side', () {
      expect(AppBreakpoints.showTablesFor(const Size(844, 390)), isFalse);
      expect(AppBreakpoints.showTablesFor(const Size(690, 1000)), isFalse);
      expect(AppBreakpoints.showTablesFor(const Size(744, 1133)), isTrue);
      expect(AppBreakpoints.showTablesFor(const Size(1440, 900)), isTrue);
    });

    test('extended rail starts at 1200', () {
      expect(
        AppBreakpoints.extendedRailFor(
          const Size(1024, 768),
          AppLayoutTier.expanded,
        ),
        isFalse,
      );
      expect(
        AppBreakpoints.extendedRailFor(
          const Size(1200, 800),
          AppLayoutTier.expanded,
        ),
        isTrue,
      );
    });
  });

  testWidgets('ResponsiveShell switches bottom bar <-> rail', (tester) async {
    Future<void> pumpAt(Size size) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveScope(
            data: ResponsiveData.fromSize(size),
            child: ResponsiveShell(
              destinations: const [
                ResponsiveDestination(
                  icon: Icons.home,
                  label: 'الرئيسية',
                  path: '/',
                ),
                ResponsiveDestination(
                  icon: Icons.person,
                  label: 'الملف',
                  path: '/profile',
                ),
              ],
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              body: const Text('body'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    await pumpAt(const Size(390, 844));
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);

    await pumpAt(const Size(844, 390));
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(tester.takeException(), isNull);

    await pumpAt(const Size(1280, 800));
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
      isTrue,
    );
  });

  testWidgets('ResponsiveShell keeps five rail items usable in dense mode', (
    tester,
  ) async {
    const size = Size(844, 390);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: ResponsiveScope(
          data: ResponsiveData.fromSize(size),
          child: ResponsiveShell(
            destinations: const [
              ResponsiveDestination(
                icon: Icons.home,
                label: 'الرئيسية',
                path: '/',
              ),
              ResponsiveDestination(
                icon: Icons.menu_book,
                label: 'القرآن',
                path: '/quran',
              ),
              ResponsiveDestination(
                icon: Icons.emoji_events,
                label: 'التحصيل',
                path: '/a',
              ),
              ResponsiveDestination(
                icon: Icons.groups,
                label: 'حلقاتي',
                path: '/teams',
              ),
              ResponsiveDestination(
                icon: Icons.person,
                label: 'الملف',
                path: '/profile',
              ),
            ],
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            body: const Text('body'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ResponsiveShell hosts a detail Scaffold on the rail', (
    tester,
  ) async {
    const size = Size(844, 390);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: ResponsiveScope(
          data: ResponsiveData.fromSize(size),
          child: ResponsiveShell(
            destinations: const [
              ResponsiveDestination(
                icon: Icons.home,
                label: 'الرئيسية',
                path: '/',
              ),
            ],
            selectedIndex: null,
            onDestinationSelected: (_) {},
            body: Scaffold(
              appBar: AppBar(title: const Text('detail')),
              body: const Text('detail-body'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.text('detail'), findsOneWidget);
    expect(find.text('detail-body'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('showAppSheet uses a sheet on compact and a dialog on wide', (
    tester,
  ) async {
    Future<void> pumpAt(Size size) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => showAppSheet<void>(
                    context: context,
                    builder: (_) => const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('sheet-content'),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    await pumpAt(const Size(390, 844));
    expect(find.text('sheet-content'), findsOneWidget);
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await pumpAt(const Size(844, 390));
    expect(find.text('sheet-content'), findsOneWidget);
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await pumpAt(const Size(1024, 768));
    expect(find.text('sheet-content'), findsOneWidget);
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets('AdaptiveDataTable chooses a table only on tablet/web', (
    tester,
  ) async {
    Widget wrap(Size size) => MaterialApp(
      home: ResponsiveScope(
        data: ResponsiveData.fromSize(size),
        child: Scaffold(
          body: AdaptiveDataTable(
            table: const Text('table'),
            cards: const Text('cards'),
          ),
        ),
      ),
    );

    await tester.pumpWidget(wrap(const Size(844, 390)));
    expect(find.text('cards'), findsOneWidget);
    expect(find.text('table'), findsNothing);

    await tester.pumpWidget(wrap(const Size(744, 1133)));
    expect(find.text('table'), findsOneWidget);
    expect(find.text('cards'), findsNothing);
  });
}
