import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.gradient,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: gradient == null
          ? null
          : ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
            ),
      child: child,
    );

    if (gradient == null || isLoading) return button;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: button,
    );
  }
}
