import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// A right-edge quick-jump rail for long session lists (contacts-app style).
///
/// Drag (or tap) anywhere on the rail to jump; a large floating bubble shows
/// the session number under the finger.
class SessionIndexSlider extends StatefulWidget {
  const SessionIndexSlider({
    super.key,
    required this.labels,
    required this.onSelected,
    this.width = 104,
  });

  /// Labels in display order (e.g. session numbers, newest first).
  final List<String> labels;
  final ValueChanged<int> onSelected;

  /// Total overlay width including the bubble area.
  final double width;

  @override
  State<SessionIndexSlider> createState() => _SessionIndexSliderState();
}

class _SessionIndexSliderState extends State<SessionIndexSlider> {
  int? _active;
  double _fraction = 0;

  int? _indexFor(double dy, double height) {
    if (widget.labels.isEmpty || height <= 0) return null;
    final fraction = (dy / height).clamp(0.0, 0.9999);
    return (fraction * widget.labels.length).floor();
  }

  void _update(double dy, double height) {
    final index = _indexFor(dy, height);
    if (index == null) return;
    final fraction = widget.labels.length == 1
        ? 0.5
        : (index + 0.5) / widget.labels.length;
    if (index != _active) widget.onSelected(index);
    if (index != _active || (fraction - _fraction).abs() > 0.001) {
      setState(() {
        _active = index;
        _fraction = fraction;
      });
    }
  }

  void _clear() {
    if (_active == null) return;
    setState(() => _active = null);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final labels = widget.labels;
    if (labels.isEmpty) return const SizedBox.shrink();
    final bubble = _active == null ? null : labels[_active!];
    return SizedBox(
      width: widget.width,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 12,
                bottom: 12,
                right: 0,
                child: SizedBox(
                  width: 30,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (d) => _update(d.localPosition.dy, height - 24),
                    onVerticalDragStart: (d) =>
                        _update(d.localPosition.dy, height - 24),
                    onVerticalDragUpdate: (d) =>
                        _update(d.localPosition.dy, height - 24),
                    onVerticalDragEnd: (_) => _clear(),
                    onTapUp: (_) => Future<void>.delayed(
                      const Duration(milliseconds: 350),
                      () {
                        if (mounted) _clear();
                      },
                    ),
                    onTapCancel: _clear,
                    child: Container(
                      decoration: BoxDecoration(
                        color: tokens.surfaceCard.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: tokens.borderStructural),
                      ),
                      child: LayoutBuilder(
                        builder: (context, rail) {
                          final usable = (rail.maxHeight - 8).clamp(
                            0.0,
                            1000.0,
                          );
                          final itemHeight = labels.isEmpty
                              ? 0.0
                              : usable / labels.length;
                          // On very short viewports (landscape phones) numbers
                          // would overflow the rail; fall back to dots.
                          if (itemHeight < 6) {
                            final dots = (usable / 6).floor().clamp(3, 18);
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                for (var i = 0; i < dots; i++)
                                  Container(
                                    width: 3,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: tokens.brandText.withValues(
                                        alpha: 0.6,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            );
                          }
                          final fontSize = itemHeight < 9
                              ? itemHeight * 0.75
                              : 8.5;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              for (final label in labels)
                                Text(
                                  label,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    height: 1,
                                    fontWeight: FontWeight.w800,
                                    color: tokens.brandText,
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              if (bubble != null && height > 70)
                Positioned(
                  top: ((height - 58) * _fraction).clamp(0.0, height - 58),
                  left: 0,
                  child: IgnorePointer(
                    child: Container(
                      width: 58,
                      height: 58,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: tokens.brand,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x22000000),
                            blurRadius: 14,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        bubble,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
