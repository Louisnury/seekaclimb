import 'package:flutter/material.dart';
import 'package:seekaclimb/abstract/cal_editor_element.dart';
import 'package:seekaclimb/enums/e_hold_type.dart';
import 'package:seekaclimb/models/cml_point.dart';
import 'package:seekaclimb/widgets/painters/circle_painters.dart';

class CmlCircle extends CalEditorElement {
  /// Types de la prise
  final ValueNotifier<List<EHoldType>> holdTypesNotifier =
      ValueNotifier<List<EHoldType>>([]);

  set holdTypes(List<EHoldType> value) {
    holdTypesNotifier.value = value;
  }

  List<EHoldType> get holdTypes => holdTypesNotifier.value;
  CmlCircle({
    required CmlPoint point,
    List<EHoldType> holdTypes = const [],
    double size = 30.0,
    VoidCallback? onElementTaped,
    VoidCallback? onElementChanged,
  }) {
    this.point = point;
    this.size = size;
    this.onElementTaped = onElementTaped;
    this.onElementChanged = onElementChanged;
    if (holdTypes.isNotEmpty) this.holdTypes = holdTypes;
  }

  @override
  Widget toWidget() {
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
                final double totalSize = (size * 2) + (extraMargin * 2);

                return Positioned(
                  left: point.x - size - extraMargin,
                  top: point.y - size - extraMargin,
                  width: totalSize,
                  height: totalSize,
                  child: GestureDetector(
                    onTap: isInteractive ? onElementTaped : null,
                    onPanUpdate: (isSelected && isInteractive)
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
                              painter: StartDiagonalLinesPainter(radius: size),
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