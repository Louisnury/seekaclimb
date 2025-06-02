import 'package:flutter/material.dart';
import 'package:seekaclimb/abstract/cal_editor_element.dart';
import 'package:seekaclimb/models/cml_point.dart';

class CmlRoutePoint extends CalEditorElement {
  CmlPoint secondPoint;

  CmlRoutePoint({
    required CmlPoint point,
    required this.secondPoint,
    VoidCallback? onElementTaped,
    VoidCallback? onElementChanged,
  }) : super() {
    this.point = point;
    size = 0;
    this.onElementTaped = onElementTaped;
    this.onElementChanged = onElementChanged;
  }

  @override
  Map<String, dynamic> toMap() => {'type': 'route_point'};

  @override
  Widget toWidget() {
    return GestureDetector(
      onTap: onElementTaped,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  void updateScale(double scale) {}
}
