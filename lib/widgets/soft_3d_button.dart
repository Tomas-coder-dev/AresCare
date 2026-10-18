import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class Soft3DButton extends StatefulWidget {
  const Soft3DButton({required this.label, required this.onPressed, super.key});

  final String label;
  final VoidCallback? onPressed;

  @override
  State<Soft3DButton> createState() => _Soft3DButtonState();
}

class _Soft3DButtonState extends State<Soft3DButton> {
  static const _depth = 4.0;
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onPressed == null || _pressed == value) {
      return;
    }
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return GestureDetector(
      onTapDown: enabled ? (_) => _setPressed(true) : null,
      onTapUp: enabled ? (_) => _setPressed(false) : null,
      onTapCancel: () => _setPressed(false),
      onTap: enabled
          ? () {
              HapticFeedback.lightImpact();
              widget.onPressed!();
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        width: double.infinity,
        transform: Matrix4.translationValues(0, _pressed ? _depth : 0, 0),
        padding: const EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? AppColors.accent : AppColors.pending,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: enabled ? AppColors.accentShadow : AppColors.pending,
              offset: Offset(0, _pressed ? 0 : _depth),
              blurRadius: 0,
            ),
            if (!_pressed)
              BoxShadow(
                color: AppColors.primaryText.withValues(alpha: 0.06),
                offset: const Offset(0, 8),
                blurRadius: 16,
              ),
          ],
        ),
        child: Text(
          widget.label,
          style: AppTypography.nunito(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryText,
          ),
        ),
      ),
    );
  }
}
