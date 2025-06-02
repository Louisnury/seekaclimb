import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:seekaclimb/abstract/cal_editor_element.dart';
import 'package:seekaclimb/enums/e_hold_type.dart';
import 'package:seekaclimb/models/cml_point.dart';

class CmlCircle extends CalEditorElement {
  /// Types de la prise
  List<EHoldType> holdTypes;

  final ValueNotifier<double> sizeNotifier = ValueNotifier<double>(30.0);
  final ValueNotifier<CmlPoint> pointNotifier = ValueNotifier<CmlPoint>(
    CmlPoint(x: 0, y: 0),
  );
  final ValueNotifier<List<EHoldType>> holdTypesNotifier =
      ValueNotifier<List<EHoldType>>([]);

  CmlCircle({
    required CmlPoint point,
    required this.holdTypes,
    double size = 30.0,
    VoidCallback? onElementTaped,
    VoidCallback? onElementChanged,
    bool inSelected = false,
  }) {
    this.point = point;
    this.size = size;
    this.onElementTaped = onElementTaped;
    this.onElementChanged = onElementChanged;
    holdTypes = holdTypes;
    isSelected = inSelected;

    pointNotifier.value = point;
    sizeNotifier.value = size;
    holdTypesNotifier.value = List.from(holdTypes);
  }

  @override
  set size(double value) {
    super.size = value;
    sizeNotifier.value = value;
  }

  @override
  set point(CmlPoint value) {
    super.point = value;
    pointNotifier.value = CmlPoint(x: value.x, y: value.y);
  }

  void updateHoldTypes(List<EHoldType> newHoldTypes) {
    holdTypes = List.from(newHoldTypes);
    holdTypesNotifier.value = List.from(newHoldTypes);
  }

  @override
  Widget toWidget() {
    return ValueListenableBuilder<bool>(
      valueListenable: isSelectedNotifier,
      builder: (context, isSelected, child) {
        return ValueListenableBuilder<double>(
          valueListenable: sizeNotifier,
          builder: (context, size, child) {
            return ValueListenableBuilder<CmlPoint>(
              valueListenable: pointNotifier,
              builder: (context, point, child) {
                return ValueListenableBuilder<List<EHoldType>>(
                  valueListenable: holdTypesNotifier,
                  builder: (context, holdTypes, child) {
                    // Calculer la marge nécessaire pour les éléments qui dépassent
                    final double extraMargin = size * 0.5;
                    final double totalSize =
                        (size * 2) + (extraMargin * 2);

                    return Positioned(
                      left: point.x - size - extraMargin,
                      top: point.y - size - extraMargin,
                      width: totalSize,
                      height: totalSize,
                      child: GestureDetector(
                        onTap: () {
                          isSelectedNotifier.value =
                              !isSelectedNotifier.value;
                          onElementTaped?.call();
                        },
                        onPanUpdate: isSelected
                            ? (details) {
                                final newPoint = CmlPoint(
                                  x: point.x + details.delta.dx * 2,
                                  y: point.y + details.delta.dy * 2,
                                );
                                this.point = newPoint;
                              }
                            : null,
                        child: Stack(
                          children: [
                            // Cercle principal
                            Positioned(
                              left: extraMargin,
                              top: extraMargin,
                              child: CustomPaint(
                                size: Size(size * 2, size * 2),
                                painter: CirclePainter(
                                  radius: size,
                                  holdTypes: holdTypes,
                                  isSelected: isSelected,
                                ),
                              ),
                            ),

                            // Lignes diagonales pour prise de départ
                            if (holdTypes.contains(EHoldType.start))
                              Positioned(
                                left: extraMargin,
                                top: extraMargin,
                                child: CustomPaint(
                                  size: Size(size * 2, size * 2),
                                  painter: StartDiagonalLinesPainter(
                                    radius: size,
                                  ),
                                ),
                              ), // Icône drapeau pour prise de fin (en haut à droite)
                            if (holdTypes.contains(EHoldType.end))
                              Positioned(
                                left: extraMargin + size + (size * 0.8),
                                top: extraMargin + size - (size * 1.2),
                                child: Icon(
                                  Icons.flag_rounded,
                                  color: Colors.red,
                                  size: size * 0.7,
                                ),
                              ),

                            // Icône étoile pour prise crux (passage difficile)
                            if (holdTypes.contains(EHoldType.crux))
                              Positioned(
                                left: extraMargin + size - (size * 1.5),
                                top: extraMargin + size - (size * 1.2),
                                child: Icon(
                                  Icons.star_rounded,
                                  color: Colors.orange,
                                  size: size * 0.7,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Map<String, dynamic> toMap() => {
    'holdTypes': holdTypes.map((type) => type.index).toList(),
    'point': point.toMap(),
    'radius': size,
  };

  static CmlCircle fromMap(Map<String, dynamic> map) => CmlCircle(
    holdTypes: (map['holdTypes'] as List<int>)
        .map((index) => EHoldTypeExtension.eHoldTypeFromKey(index))
        .toList(),
    size: map['radius'] as double,
    point: CmlPoint.fromMap(map['point'] as Map<String, dynamic>),
  );

  @override
  void updateScale(double newScale) {
    final clampedScale = newScale.clamp(5.0, 80.0);
    size = clampedScale;
  }

  @override
  void dispose() {
    super.dispose();
    sizeNotifier.dispose();
    pointNotifier.dispose();
    holdTypesNotifier.dispose();
  }
}


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
