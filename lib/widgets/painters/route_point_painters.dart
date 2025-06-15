import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:seekaclimb/models/cml_point.dart';
import 'package:seekaclimb/models/cml_route_point.dart';

// CustomPainter de base pour les route points

abstract class CwlBaseRoutePointPainter extends CustomPainter {
  final List<CmlRoutePoint> routePoints;
  final Color color;
  final double animationValue;
  final double lineWidth;

  CwlBaseRoutePointPainter({
    required this.routePoints,
    required this.color,
    required this.animationValue,
    required this.lineWidth,
  });

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  Paint getBasePaint() => Paint()
    ..color = color
    ..strokeWidth = lineWidth
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
}

// Painter qui anime uniquement le dernier segment de route
class CwlLastSegmentRoutePointPainter extends CwlBaseRoutePointPainter {
  CwlLastSegmentRoutePointPainter({
    required super.routePoints,
    required super.color,
    required super.animationValue,
    required super.lineWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (routePoints.length < 2) return;
    final paint = getBasePaint();

    // Dessine tous les segments précédents sans animation
    if (routePoints.length > 2) {
      final Path mainPath = Path();
      final firstPoint = routePoints[0];
      mainPath.moveTo(firstPoint.point.x, firstPoint.point.y);

      for (int i = 0; i < routePoints.length - 2; i++) {
        _addCurvedSegment(mainPath, i);
      }
      canvas.drawPath(mainPath, paint);
    }

    // Anime le dernier segment
    if (routePoints.length >= 2) {
      final Path lastSegmentPath = Path();
      final int lastIndex = routePoints.length - 2;
      final startPoint = routePoints[lastIndex];

      lastSegmentPath.moveTo(startPoint.point.x, startPoint.point.y);
      _addCurvedSegment(lastSegmentPath, lastIndex);

      final ui.PathMetric pathMetric = lastSegmentPath.computeMetrics().first;
      final double progress = Curves.easeOutQuad.transform(animationValue);
      final Path extractPath = pathMetric.extractPath(
        0,
        pathMetric.length * progress,
      );
      canvas.drawPath(extractPath, paint);
    }
  }

  void _addCurvedSegment(Path path, int i) {
    final CmlPoint p0 = i > 0 ? routePoints[i - 1].point : routePoints[i].point;
    final CmlPoint p1 = routePoints[i].point;
    final CmlPoint p2 = routePoints[i + 1].point;
    final CmlPoint p3 = i + 2 < routePoints.length
        ? routePoints[i + 2].point
        : p2;

    const double t = 0.2;
    final controlPoint1 = Offset(
      p1.x + (p2.x - p0.x) * t,
      p1.y + (p2.y - p0.y) * t,
    );
    final controlPoint2 = Offset(
      p2.x - (p3.x - p1.x) * t,
      p2.y - (p3.y - p1.y) * t,
    );

    path.cubicTo(
      controlPoint1.dx,
      controlPoint1.dy,
      controlPoint2.dx,
      controlPoint2.dy,
      p2.x,
      p2.y,
    );
  }
}

// Painter qui anime le chemin complet des route points
class CwlFullRoutePointPainter extends CwlBaseRoutePointPainter {
  CwlFullRoutePointPainter({
    required super.routePoints,
    required super.color,
    required super.animationValue,
    required super.lineWidth,
  });

  void _drawInitialCircle(Canvas canvas) {
    if (routePoints.isEmpty) return;

    final double circleProgress = (animationValue < 0.2)
        ? (animationValue / 0.2)
        : 1.0;
    final Paint circlePaint = Paint()
      ..color = color.withValues(alpha: Curves.easeIn.transform(circleProgress))
      ..style = PaintingStyle.fill;

    final double circleRadius = 8 * Curves.elasticOut.transform(circleProgress);
    final firstPoint = routePoints[0].point;
    canvas.drawCircle(
      Offset(firstPoint.x, firstPoint.y),
      circleRadius,
      circlePaint,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (routePoints.length < 2) {
      _drawInitialCircle(canvas);
      return;
    }

    final paint = getBasePaint();
    _drawInitialCircle(canvas);

    final Path fullPath = Path();
    final firstPoint = routePoints[0].point;
    fullPath.moveTo(firstPoint.x, firstPoint.y);

    for (int i = 0; i < routePoints.length - 1; i++) {
      final CmlPoint p0 = i > 0
          ? routePoints[i - 1].point
          : routePoints[i].point;
      final CmlPoint p1 = routePoints[i].point;
      final CmlPoint p2 = routePoints[i + 1].point;
      final CmlPoint p3 = i + 2 < routePoints.length
          ? routePoints[i + 2].point
          : p2;

      const double t = 0.2;
      final controlPoint1 = Offset(
        p1.x + (p2.x - p0.x) * t,
        p1.y + (p2.y - p0.y) * t,
      );
      final controlPoint2 = Offset(
        p2.x - (p3.x - p1.x) * t,
        p2.y - (p3.y - p1.y) * t,
      );

      fullPath.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p2.x,
        p2.y,
      );
    }
    final ui.PathMetric pathMetric = fullPath.computeMetrics().first;
    final double progress = Curves.easeInOut.transform(animationValue);
    final Path animatedPath = pathMetric.extractPath(
      0,
      pathMetric.length * progress,
    );
    canvas.drawPath(animatedPath, paint);
  }
}
