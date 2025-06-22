import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Marker déplaçable pour la carte
class DraggableMapMarker extends StatefulWidget {
  final LatLng initialPosition;
  final Widget child;
  final Function(LatLng) onDragEnd;
  final Function(LatLng)? onDragUpdate;
  final MapController mapController;
  final double width;
  final double height;
  final bool isDraggable;

  const DraggableMapMarker({
    super.key,
    required this.initialPosition,
    required this.child,
    required this.onDragEnd,
    required this.mapController,
    this.onDragUpdate,
    this.width = 40.0,
    this.height = 40.0,
    this.isDraggable = true,
  });

  @override
  State<DraggableMapMarker> createState() => _DraggableMapMarkerState();
}

class _DraggableMapMarkerState extends State<DraggableMapMarker> {
  late LatLng _currentPosition;
  bool _isDragging = false;
  Offset? _lastPanPosition;

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.initialPosition;
  }

  @override
  void didUpdateWidget(DraggableMapMarker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPosition != oldWidget.initialPosition) {
      _currentPosition = widget.initialPosition;
    }
  }

  LatLng _screenPointToLatLng(Offset screenPoint) {
    // Convertir les coordonnées d'écran en coordonnées géographiques
    // Utiliser la méthode intégrée de flutter_map pour une conversion précise
    final camera = widget.mapController.camera;
    final bounds = camera.visibleBounds;
    final size = context.size!;

    // Calcul proportionnel basé sur les limites visibles
    final double latProgress = screenPoint.dy / size.height;
    final double lngProgress = screenPoint.dx / size.width;

    final double lat =
        bounds.north - latProgress * (bounds.north - bounds.south);
    final double lng = bounds.west + lngProgress * (bounds.east - bounds.west);

    return LatLng(lat, lng);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: widget.isDraggable
          ? (details) {
              setState(() {
                _isDragging = true;
                _lastPanPosition = details.localPosition;
              });
            }
          : null,
      onPanUpdate: widget.isDraggable
          ? (details) {
              if (_lastPanPosition != null) {
                final newPosition = _screenPointToLatLng(details.localPosition);
                setState(() {
                  _currentPosition = newPosition;
                });
                widget.onDragUpdate?.call(newPosition);
                _lastPanPosition = details.localPosition;
              }
            }
          : null,
      onPanEnd: widget.isDraggable
          ? (details) {
              setState(() {
                _isDragging = false;
                _lastPanPosition = null;
              });
              widget.onDragEnd(_currentPosition);
            }
          : null,
      child: AnimatedScale(
        scale: _isDragging ? 1.2 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: widget.child,
      ),
    );
  }
}

/// Extension pour créer des markers déplaçables facilement
extension MarkerExtensions on Marker {
  static Marker draggable({
    required LatLng point,
    required Widget child,
    required Function(LatLng) onDragEnd,
    required MapController mapController,
    Function(LatLng)? onDragUpdate,
    double width = 80.0,
    double height = 80.0,
    Alignment alignment = Alignment.center,
  }) {
    return Marker(
      point: point,
      width: width,
      height: height,
      alignment: alignment,
      child: DraggableMapMarker(
        initialPosition: point,
        onDragEnd: onDragEnd,
        onDragUpdate: onDragUpdate,
        mapController: mapController,
        width: width,
        height: height,
        child: child,
      ),
    );
  }
}
