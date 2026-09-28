import 'package:flutter/material.dart';

class GoogleLogo extends StatelessWidget {
  final double size;

  const GoogleLogo({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;

    // Blue Path
    final pBlue = Path()
      ..moveTo(scale * 23.745, scale * 12.27)
      ..cubicTo(scale * 23.745, scale * 11.57, scale * 23.685, scale * 10.87, scale * 23.555, scale * 10.2)
      ..lineTo(scale * 12.0, scale * 10.2)
      ..lineTo(scale * 12.0, scale * 14.71)
      ..lineTo(scale * 18.6, scale * 14.71)
      ..cubicTo(scale * 18.31, scale * 16.23, scale * 17.46, scale * 17.53, scale * 16.2, scale * 18.39)
      ..lineTo(scale * 16.2, scale * 21.44)
      ..lineTo(scale * 20.08, scale * 21.44)
      ..cubicTo(scale * 22.35, scale * 19.35, scale * 23.745, scale * 16.27, scale * 23.745, scale * 12.27)
      ..close();
    canvas.drawPath(pBlue, Paint()..color = const Color(0xFF4285F4));

    // Green Path
    final pGreen = Path()
      ..moveTo(scale * 12.0, scale * 24.0)
      ..cubicTo(scale * 15.24, scale * 24.0, scale * 17.95, scale * 22.92, scale * 19.93, scale * 21.09)
      ..lineTo(scale * 16.05, scale * 18.04)
      ..cubicTo(scale * 14.97, scale * 18.76, scale * 13.6, scale * 19.2, scale * 12.0, scale * 19.2)
      ..cubicTo(scale * 8.88, scale * 19.2, scale * 6.23, scale * 17.1, scale * 5.28, scale * 14.27)
      ..lineTo(scale * 1.25, scale * 14.27)
      ..lineTo(scale * 1.25, scale * 17.42)
      ..cubicTo(scale * 3.26, scale * 21.36, scale * 7.33, scale * 24.0, scale * 12.0, scale * 24.0)
      ..close();
    canvas.drawPath(pGreen, Paint()..color = const Color(0xFF34A853));

    // Yellow Path
    final pYellow = Path()
      ..moveTo(scale * 5.28, scale * 14.27)
      ..cubicTo(scale * 5.03, scale * 13.55, scale * 4.9, scale * 12.78, scale * 4.9, scale * 12.0)
      ..cubicTo(scale * 4.9, scale * 11.22, scale * 5.04, scale * 10.45, scale * 5.28, scale * 9.73)
      ..lineTo(scale * 5.28, scale * 6.58)
      ..lineTo(scale * 1.25, scale * 6.58)
      ..cubicTo(scale * 0.45, scale * 8.18, scale * 0.0, scale * 9.99, scale * 0.0, scale * 12.0)
      ..cubicTo(scale * 0.0, scale * 14.01, scale * 0.45, scale * 15.82, scale * 1.25, scale * 17.42)
      ..lineTo(scale * 5.28, scale * 14.27)
      ..close();
    canvas.drawPath(pYellow, Paint()..color = const Color(0xFFFBBC05));

    // Red Path
    final pRed = Path()
      ..moveTo(scale * 12.0, scale * 4.75)
      ..cubicTo(scale * 13.77, scale * 4.75, scale * 15.35, scale * 5.36, scale * 16.6, scale * 6.55)
      ..lineTo(scale * 20.02, scale * 3.13)
      ..cubicTo(scale * 17.95, scale * 1.19, scale * 15.24, scale * 0.0, scale * 12.0, scale * 0.0)
      ..cubicTo(scale * 7.33, scale * 0.0, scale * 3.26, scale * 2.64, scale * 1.25, scale * 6.58)
      ..lineTo(scale * 5.28, scale * 9.73)
      ..cubicTo(scale * 6.23, scale * 6.9, scale * 8.88, scale * 4.75, scale * 12.0, scale * 4.75)
      ..close();
    canvas.drawPath(pRed, Paint()..color = const Color(0xFFEA4335));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
