import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:seekaclimb/abstract/cal_editor_element.dart';
import 'package:seekaclimb/models/cml_point.dart';

class CmlGeoRoutePoint extends CalEditorElement {
  CmlGeoRoutePoint({
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
    'type': 'geo_route_point',
    'point': point.toMap(),
  };
  static CmlGeoRoutePoint fromMap(Map<String, dynamic> map) {
    return CmlGeoRoutePoint(point: CmlPoint.fromMap(map['point']));
  }

  Marker createMarker({
    Function(LatLng)? onDragEnd,
    Function(LatLng)? onDragUpdate,
    required double markerSize,
    required MapController mapController,
  }) {
    return AnimatedMarker(geoPoint: this, markerSize: markerSize);
  }

  @override
  Widget toWidget() {
    return const SizedBox.shrink();
  }

  @override
  void updateScale(double scale) {
    return;
  }
}

class AnimatedMarker extends Marker {
  final CmlGeoRoutePoint geoPoint;

  AnimatedMarker({required this.geoPoint, required double markerSize})
    : super(
        point: geoPoint.point.toLatLng(),
        width: markerSize,
        height: markerSize,
        alignment: Alignment.center,
        child: ValueListenableBuilder<CmlPoint>(
          valueListenable: geoPoint.pointNotifier,
          builder: (context, currentPoint, child) {
            return ValueListenableBuilder<bool>(
              valueListenable: geoPoint.isSelectedNotifier,
              builder: (context, isSelected, child) {
                return GestureDetector(
                  onTap: geoPoint.isInteractive
                      ? geoPoint.onElementTaped
                      : null,
                  child: Container(
                    width: markerSize,
                    height: markerSize,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Colors.white
                            : Colors.black.withValues(alpha: 0.3),
                        width: isSelected ? 2.0 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.open_with,
                            color: Colors.white,
                            size: 12,
                          )
                        : null
                  ),
                );
              },
            );
          },
        ),
      );

  @override
  LatLng get point => geoPoint.point.toLatLng();
}