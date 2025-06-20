import 'package:flutter/material.dart';
import 'package:seekaclimb/abstract/cal_editor_element.dart';
import 'package:seekaclimb/models/cml_point.dart';

class CmlRoutePoint extends CalEditorElement {
  CmlRoutePoint({
    required CmlPoint point,
    VoidCallback? onElementTaped,
    VoidCallback? onElementChanged,
  }) : super() {
    this.point = point;
    this.onElementTaped = onElementTaped;
    this.onElementChanged = onElementChanged;
  }
  static double lineWidth = 2.0;

  @override
  Map<String, dynamic> toMap() => {
    'type': 'route_point',
    'point': point.toMap(),
  };

  static CmlRoutePoint fromMap(Map<String, dynamic> map) {
    return CmlRoutePoint(
      point: CmlPoint.fromMap(map['point'] as Map<String, dynamic>),
    );
  }

  @override
  Widget toWidget() {
    return ValueListenableBuilder<CmlPoint>(
      valueListenable: pointNotifier,
      builder: (context, point, child) {
        return Positioned(
          left: point.x,
          top: point.y,
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
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.black,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Colors.white
                      : Colors.black.withValues(alpha: 0.3),
                  width: isSelected ? 2.0 : 1.0,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void updateScale(double scale) {
    return;
  }
}
