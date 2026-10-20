import 'package:flutter/material.dart';

/// Subtle one-shot entrance animation (fade + scale-up).
///
/// Follows `motion-and-interaction.md`: entries use `easeOutCubic` and short
/// durations. When the OS requests reduced motion, the child is shown
/// immediately (no animation).
class AnimatedEntrance extends StatefulWidget {
  const AnimatedEntrance({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.delay = Duration.zero,
    this.fromScale = 0.94,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;
  final double fromScale;

  @override
  State<AnimatedEntrance> createState() => _AnimatedEntranceState();
}

class _AnimatedEntranceState extends State<AnimatedEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;
  bool _disableAnimations = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(curve);
    _scale = Tween<double>(
      begin: widget.fromScale,
      end: 1,
    ).animate(curve);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disable = MediaQuery.disableAnimationsOf(context);
    if (disable != _disableAnimations) {
      _disableAnimations = disable;
      if (disable) {
        _controller.stop();
        _controller.value = 1;
      } else {
        _play();
      }
    } else if (!_started) {
      _play();
    }
  }

  bool _started = false;

  @override
  void didUpdateWidget(covariant AnimatedEntrance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.delay != widget.delay ||
        oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
      _play();
    }
  }

  void _play() {
    if (_started) return;
    _started = true;
    if (_disableAnimations) {
      _controller.value = 1;
      return;
    }
    _controller.value = 0;
    if (widget.delay == Duration.zero) {
      _controller.forward();
      return;
    }
    Future<void>.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_disableAnimations) return widget.child;
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}