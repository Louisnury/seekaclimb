import 'package:flutter/material.dart';
import 'package:seekaclimb/abstract/cal_editor_element.dart';
import 'package:seekaclimb/models/cml_point.dart';

class CmlRoutePoint extends CalEditorElement {
  CmlPoint secondPoint;
  Color lineColor;
  double lineWidth;

  CmlRoutePoint({
    required CmlPoint point,
    required this.secondPoint,
    this.lineColor = Colors.red,
    this.lineWidth = 2.0,
    VoidCallback? onElementTaped,
    VoidCallback? onElementChanged,
  }) : super() {
    this.point = point;
    size = 0;
    this.onElementTaped = onElementTaped;
    this.onElementChanged = onElementChanged;
  }

  void updateLineColor(Color color) {
    lineColor = color;
    onElementChanged?.call();
  }

  void updateLineWidth(double width) {
    lineWidth = width;
    onElementChanged?.call();
  }

  @override
  Map<String, dynamic> toMap() => {
    'type': 'route_point',
    'lineColor': lineColor,
    'lineWidth': lineWidth,
  };

  @override
  Widget toWidget() {
    return GestureDetector(
      onTap: onElementTaped,
      child: CustomPaint(
        painter: RouteLinePainter(
          startPoint: point,
          endPoint: secondPoint,
          color: lineColor,
          width: lineWidth,
        ),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
        ),
      ),
    );
  }

  @override
  void updateScale(double scale) {}
}

class RouteLinePainter extends CustomPainter {
  final CmlPoint startPoint;
  final CmlPoint endPoint;
  final Color color;
  final double width;

  RouteLinePainter({
    required this.startPoint,
    required this.endPoint,
    this.color = Colors.red,
    this.width = 2.0,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;

    // Dessiner la ligne entre les deux points
    canvas.drawLine(
      Offset(startPoint.x, startPoint.y),
      Offset(endPoint.x, endPoint.y),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    if (oldDelegate is RouteLinePainter) {
      return oldDelegate.startPoint.x != startPoint.x ||
          oldDelegate.startPoint.y != startPoint.y ||
          oldDelegate.endPoint.x != endPoint.x ||
          oldDelegate.endPoint.y != endPoint.y ||
          oldDelegate.color != color ||
          oldDelegate.width != width;
    }
    return true;
  }
}
