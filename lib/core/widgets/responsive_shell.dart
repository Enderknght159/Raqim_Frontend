import 'package:flutter/material.dart';

import '../config/app_breakpoints.dart';
import '../theme/app_theme.dart';
import 'responsive_scope.dart';

/// One navigation destination for [ResponsiveShell].
@immutable
class ResponsiveDestination {
  const ResponsiveDestination({
    required this.icon,
    required this.label,
    required this.path,
    this.selectedIcon,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final String path;
}

/// Shared shell: bottom navigation on compact windows, a RTL-aware
/// [NavigationRail] on landscape/tablet/web, and a centred content column
/// capped at [AppBreakpoints.maxContentWidth].
///
/// The rail is the **first child of the row**, so it lands on the right in
/// RTL automatically (never hard-code left/right).
class ResponsiveShell extends StatelessWidget {
  const ResponsiveShell({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.banner,
    this.showNavigation = true,
    this.contentMaxWidth = AppBreakpoints.maxContentWidth,
    this.centerContent = true,
    this.resizeToAvoidBottomInset = true,
  });

  final List<ResponsiveDestination> destinations;
  final int? selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? banner;
  final bool showNavigation;
  final double contentMaxWidth;
  final bool centerContent;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final data = ResponsiveScope.of(context);
    final tokens = Theme.of(context).extension<AppTokens>() ?? AppTokens.light;

    Widget content = body;
    if (banner != null) {
      content = Column(
        children: [
          banner!,
          Expanded(child: content),
        ],
      );
    }

    if (centerContent) {
      content = Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentMaxWidth),
          child: content,
        ),
      );
    }

    final isRail = !data.isCompact;
    final dense = data.dense;

    final scaffold = Scaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: isRail
          ? Row(
              children: [
                _rail(context, data, tokens),
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: tokens.borderStructural,
                ),
                Expanded(child: content),
              ],
            )
          : content,
      bottomNavigationBar: !isRail && showNavigation
          ? _bottomBar(context, tokens)
          : null,
    );

    // Dense landscape also trims screen-level AppBars.
    if (dense) {
      return Theme(
        data: Theme.of(context).copyWith(
          appBarTheme: Theme.of(
            context,
          ).appBarTheme.copyWith(toolbarHeight: 48),
        ),
        child: scaffold,
      );
    }
    return scaffold;
  }

  Widget _bottomBar(BuildContext context, AppTokens tokens) {
    return NavigationBar(
      selectedIndex: selectedIndex ?? 0,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: tokens.surfacePage,
      destinations: [
        for (final d in destinations)
          NavigationDestination(
            icon: Icon(d.icon),
            selectedIcon: Icon(d.selectedIcon ?? d.icon),
            label: d.label,
          ),
      ],
    );
  }

  Widget _rail(BuildContext context, ResponsiveData data, AppTokens tokens) {
    final extended = data.extendedRail;
    final labelType = extended
        ? null
        : data.dense
        ? NavigationRailLabelType.none
        : NavigationRailLabelType.all;

    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      extended: extended,
      minWidth: data.dense ? 64 : 80,
      minExtendedWidth: 220,
      labelType: labelType,
      scrollable: true,
      groupAlignment: -1,
      backgroundColor: tokens.surfacePage,
      useIndicator: true,
      indicatorColor: tokens.brandTint,
      selectedIconTheme: IconThemeData(color: tokens.brandText, size: 24),
      unselectedIconTheme: IconThemeData(color: tokens.textMuted, size: 22),
      selectedLabelTextStyle: TextStyle(
        color: tokens.brandText,
        fontWeight: FontWeight.w800,
        fontSize: 13,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: tokens.textMuted,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
      destinations: [
        for (final d in destinations)
          NavigationRailDestination(
            icon: Icon(d.icon),
            selectedIcon: Icon(d.selectedIcon ?? d.icon),
            label: Text(d.label),
            padding: EdgeInsets.symmetric(vertical: data.dense ? 2 : 4),
          ),
      ],
    );
  }
}
