import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:seekaclimb/enums/e_hold_type.dart';

class CirclePainter extends CustomPainter {
  final double radius;
  final List<EHoldType> holdTypes;
  final bool isSelected;

  CirclePainter({
    required this.radius,
    required this.holdTypes,
    required this.isSelected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = isSelected ? Colors.green : Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Si c'est une prise de pied, dessiner en pointillés
    if (holdTypes.contains(EHoldType.foot)) {
      paint.strokeWidth = 2.0;
      _drawDashedCircle(canvas, Offset(radius, radius), radius, paint);
    } else {
      // Dessiner un cercle normal
      canvas.drawCircle(Offset(radius, radius), radius, paint);
    }
  }

  void _drawDashedCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
  ) {
    // Adapter la taille des pointillés selon le rayon pour éviter qu'ils deviennent invisibles
    final double minDashLength = 2.0;
    final double maxDashLength = 8.0;
    final double dashLength = (radius * 0.15).clamp(
      minDashLength,
      maxDashLength,
    );
    final double gapLength = dashLength * 0.6;

    const double fullCircle = 2 * math.pi;
    final double dashAngle = dashLength / radius;
    final double gapAngle = gapLength / radius;
    final double totalAngle = dashAngle + gapAngle;

    // Calculer le nombre de segments pour faire un cercle complet
    final int segmentCount = (fullCircle / totalAngle).floor();
    final double adjustedTotalAngle = fullCircle / segmentCount;
    final double adjustedDashAngle =
        adjustedTotalAngle * (dashAngle / totalAngle);

    for (int i = 0; i < segmentCount; i++) {
      final double startAngle = i * adjustedTotalAngle;

      final Path path = Path();
      path.addArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        adjustedDashAngle,
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) {
    return oldDelegate.isSelected != isSelected ||
        oldDelegate.radius != radius ||
        oldDelegate.holdTypes != holdTypes;
  }
}

class StartDiagonalLinesPainter extends CustomPainter {
  final double radius;

  StartDiagonalLinesPainter({required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    // Adapter l'épaisseur de la ligne selon la taille du cercle
    final double minStrokeWidth = 2.0;
    final double maxStrokeWidth = 4.0;
    final double strokeWidth = (radius * 0.15).clamp(
      minStrokeWidth,
      maxStrokeWidth,
    );

    final Paint paint = Paint()
      ..color = Colors.red
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    final Offset center = Offset(radius, radius);

    // Ligne diagonale en haut à droite (collée au cercle)
    final double baseLineLength = radius * 0.8;
    final double minVisibleLength = 4.0;
    final double maxAllowedLength = radius * 1.2;

    final double lineLength = math.max(
      math.min(baseLineLength, maxAllowedLength),
      minVisibleLength,
    );

    // Angle à 45° (pi/4 radians) pour la direction haut-droite
    const double angle = -math.pi / 4; // -45° en radians

    // Calculer le point de départ exactement sur le bord du cercle
    final Offset startPoint = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );

    // Calculer le point d'arrivée en prolongeant la ligne vers le haut à droite
    final Offset endPoint = Offset(
      startPoint.dx + lineLength * math.cos(angle),
      startPoint.dy + lineLength * math.sin(angle),
    );

    // S'assurer que la ligne reste dans les limites du canvas
    final double canvasSize = size.width;
    if (endPoint.dx >= 0 &&
        endPoint.dx <= canvasSize &&
        endPoint.dy >= 0 &&
        endPoint.dy <= canvasSize) {
      canvas.drawLine(startPoint, endPoint, paint);
    } else {
      // Si la ligne sort des limites, dessiner une ligne plus courte mais visible
      final double adjustedLength = math.min(lineLength, radius * 0.6);
      final Offset adjustedEndPoint = Offset(
        startPoint.dx + adjustedLength * math.cos(angle),
        startPoint.dy + adjustedLength * math.sin(angle),
      );
      canvas.drawLine(startPoint, adjustedEndPoint, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
