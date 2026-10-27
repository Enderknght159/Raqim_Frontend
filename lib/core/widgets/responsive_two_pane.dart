import 'package:flutter/material.dart';

/// Stacks [main] and [side] on narrow windows, and places them side by side
/// once the available width reaches [breakpoint].
///
/// The two panes are independent: each side is responsible for its own
/// scrolling. A side without [sideFlex] gets a fixed [sideWidth].
class ResponsiveTwoPane extends StatelessWidget {
  const ResponsiveTwoPane({
    super.key,
    required this.main,
    required this.side,
    this.breakpoint = 1024,
    this.gap = 16,
    this.mainFlex = 3,
    this.sideFlex,
    this.sideWidth = 360,
    this.minHeightForTwoPane = 500,
  });

  final Widget main;
  final Widget side;
  final double breakpoint;
  final double gap;
  final int mainFlex;
  final int? sideFlex;
  final double sideWidth;
  final double minHeightForTwoPane;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final canSplit =
            constraints.maxWidth >= breakpoint &&
            constraints.maxHeight >= minHeightForTwoPane;
        if (!canSplit) {
          return Column(
            children: [
              main,
              SizedBox(height: gap),
              side,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: mainFlex, child: main),
            SizedBox(width: gap),
            if (sideFlex != null)
              Expanded(flex: sideFlex!, child: side)
            else
              SizedBox(width: sideWidth, child: side),
          ],
        );
      },
    );
  }
}
