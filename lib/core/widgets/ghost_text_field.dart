import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

/// A text field whose default value is a «ghost»: shown in muted style until
/// the user starts editing, at which point it disappears so they can type
/// their value without clearing it first. If left empty on unfocus, the
/// ghost returns (and [text] reads '' again — fall back to the ghost).
class GhostTextField extends StatefulWidget {
  const GhostTextField({
    super.key,
    required this.ghost,
    required this.label,
    this.keyboardType,
    this.inputFormatters,
    this.textDirection,
    this.controller,
    this.align = TextAlign.start,
  });

  /// Placeholder-like default that disappears on first edit.
  final String ghost;

  final String label;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextDirection? textDirection;
  final TextAlign align;

  /// Optional external controller (kept in sync while touched).
  final TextEditingController? controller;

  @override
  State<GhostTextField> createState() => _GhostTextFieldState();
}

class _GhostTextFieldState extends State<GhostTextField> {
  final FocusNode _focus = FocusNode();
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  bool _touched = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (_focus.hasFocus && !_touched) {
        setState(() => _touched = true);
        _controller.clear();
      } else if (!_focus.hasFocus && _controller.text.trim().isEmpty) {
        setState(() => _touched = false);
      }
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return TextField(
      controller: _controller,
      focusNode: _focus,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      textDirection: widget.textDirection,
      textAlign: widget.align,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: _touched ? null : widget.ghost,
        hintStyle: TextStyle(color: tokens.textMuted.withValues(alpha: 0.7)),
      ),
    );
  }
}
