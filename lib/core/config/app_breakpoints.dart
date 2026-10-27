import 'package:flutter/widgets.dart';

/// The three navigation/layout states approved for Raqim.
///
/// The decision is **width-first** (never device type or orientation):
/// - [compact]  : phones in portrait / narrow windows.
/// - [rail]     : phone landscape + tablet portrait.
/// - [expanded] : tablet landscape / web.
enum AppLayoutTier { compact, rail, expanded }

/// Central responsive rules. Keep every breakpoint here so screens never
/// hard-code magic numbers.
class AppBreakpoints {
  AppBreakpoints._();

  /// Below this width the app uses the bottom navigation.
  static const double railMin = 600;

  /// At/above this width the app uses the expanded shell (rail/sidebar).
  static const double expandedMin = 1024;

  /// Dense data tables need enough horizontal room…
  static const double tablesMinWidth = 720;

  /// …and a tablet-like window (a phone in landscape is always shorter).
  static const double tabletShortestSide = 600;

  /// Phone landscape / very short windows: compress vertical chrome.
  static const double denseHeight = 500;

  /// Reading/tools content is centred; dense tables may use the full width.
  static const double maxContentWidth = 1200;

  /// Forms and settings pages.
  static const double formWidth = 640;

  /// Notifications / audit-like reading lists.
  static const double readingWidth = 800;

  /// Wide sidebar starts here; below it the rail stays compact.
  static const double sidebarMin = 1200;

  static AppLayoutTier tierOf(double width) {
    if (width < railMin) return AppLayoutTier.compact;
    if (width < expandedMin) return AppLayoutTier.rail;
    return AppLayoutTier.expanded;
  }

  static AppLayoutTier tierOfSize(Size size) => tierOf(size.width);

  static bool denseFor(Size size) => size.height < denseHeight;

  static bool showTablesFor(Size size) =>
      size.width >= tablesMinWidth && size.shortestSide >= tabletShortestSide;

  static bool extendedRailFor(Size size, AppLayoutTier tier) =>
      tier == AppLayoutTier.expanded && size.width >= sidebarMin;
}
