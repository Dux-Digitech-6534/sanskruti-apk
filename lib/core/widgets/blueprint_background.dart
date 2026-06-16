import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

class BlueprintBackground extends StatelessWidget {
  const BlueprintBackground({
    required this.child,
    this.blueTop = false,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  final Widget child;
  final bool blueTop;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: blueTop
              ? const [
                  AppColors.primaryDark,
                  AppColors.primary,
                  AppColors.background,
                  Color(0xFFFFF8EA),
                ]
              : const [AppColors.background, Color(0xFFFFF8EA)],
          stops: blueTop ? const [0, .36, .58, 1] : null,
        ),
      ),
      child: CustomPaint(
        painter: _BlueprintPainter(
          color: blueTop
              ? Colors.white.withValues(alpha: .08)
              : AppColors.primary.withValues(alpha: .045),
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class _BlueprintPainter extends CustomPainter {
  const _BlueprintPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final baseY = size.height * .94;
    for (var i = 0; i < 5; i++) {
      final x = size.width * (.58 + i * .085);
      final h = size.height * (.055 + i * .012);
      final rect = Rect.fromLTWH(x, baseY - h, size.width * .075, h);
      canvas.drawRect(rect, paint);
      canvas.drawLine(
        Offset(x, baseY - h * .66),
        Offset(x + rect.width, baseY - h * .66),
        paint,
      );
      canvas.drawLine(
        Offset(x, baseY - h * .33),
        Offset(x + rect.width, baseY - h * .33),
        paint,
      );
      canvas.drawLine(
        Offset(x + rect.width * .5, baseY),
        Offset(x + rect.width * .5, baseY - h),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BlueprintPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
