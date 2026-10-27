import 'package:flutter/widgets.dart';

import '../config/app_breakpoints.dart';

/// Immutable snapshot of the current window responsive state.
@immutable
class ResponsiveData {
  const ResponsiveData({
    required this.size,
    required this.tier,
    required this.dense,
    required this.showTables,
    required this.extendedRail,
  });

  factory ResponsiveData.fromSize(Size size) {
    final tier = AppBreakpoints.tierOfSize(size);
    return ResponsiveData(
      size: size,
      tier: tier,
      dense: AppBreakpoints.denseFor(size),
      showTables: AppBreakpoints.showTablesFor(size),
      extendedRail: AppBreakpoints.extendedRailFor(size, tier),
    );
  }

  final Size size;
  final AppLayoutTier tier;
  final bool dense;
  final bool showTables;
  final bool extendedRail;

  bool get isCompact => tier == AppLayoutTier.compact;
  bool get isRail => tier == AppLayoutTier.rail;
  bool get isExpanded => tier == AppLayoutTier.expanded;

  @override
  bool operator ==(Object other) =>
      other is ResponsiveData &&
      other.size == size &&
      other.tier == tier &&
      other.dense == dense &&
      other.showTables == showTables &&
      other.extendedRail == extendedRail;

  @override
  int get hashCode => Object.hash(size, tier, dense, showTables, extendedRail);
}

/// Inherited responsive state.
///
/// Screens normally read it via [ResponsiveScope.of]. When no scope exists
/// (unit tests, public pages) it falls back to `MediaQuery.sizeOf`, so a
/// widget never crashes just because it is rendered outside a shell.
class ResponsiveScope extends InheritedWidget {
  const ResponsiveScope({super.key, required this.data, required super.child});

  final ResponsiveData data;

  static ResponsiveData of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ResponsiveScope>();
    if (scope != null) return scope.data;
    return ResponsiveData.fromSize(MediaQuery.sizeOf(context));
  }

  @override
  bool updateShouldNotify(ResponsiveScope oldWidget) => oldWidget.data != data;
}
