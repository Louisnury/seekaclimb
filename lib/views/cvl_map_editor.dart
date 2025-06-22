import 'dart:math' as math;
import 'package:commun/commun.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:seekaclimb/models/cml_point.dart';
import 'package:seekaclimb/models/cml_geo_route_point.dart';
import 'package:seekaclimb/widgets/cw_editor.dart';
import 'package:seekaclimb/controllers/editor_controller.dart';

class CvlMapEditor extends StatefulWidget {
  const CvlMapEditor({super.key});

  @override
  CvlMapEditorState createState() => CvlMapEditorState();
}

class CvlMapEditorState extends State<CvlMapEditor> {
  late final EditorController _controller;
  final CwMapController _mapController = CwMapController();
  int mode = 0;
  final List<Marker> _routeMarkers = [];
  final List<Polyline> _routePolylines = [];
  @override
  void initState() {
    super.initState();
    _controller = EditorController(mode: EditorMode.edit);
    _controller.panAllowed = false;
    _controller.scaleAllowed = false;

    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {});
  }

  void _onMapTap(LatLng position) {
    if (_controller.hasSelectedElement) {
      _controller.deselectAll();
    } else {
      final geoPoint = CmlGeoRoutePoint(point: CmlPoint.fromLatLng(position));
      _controller.addElement(geoPoint, select: false);

      _addMarker(geoPoint);
      setState(() {});
    }
  }

  LatLng _screenToLatLng(Offset screenPoint) {
    final mapController = _mapController.getMapController();
    if (mapController == null) return const LatLng(0, 0);

    final camera = mapController.camera;

    final point = camera.pointToLatLng(
      math.Point(screenPoint.dx, screenPoint.dy),
    );

    return point;
  }

  void _addMarker(CmlGeoRoutePoint geoPoint) {
    final mapController = _mapController.getMapController();
    if (mapController == null) return;

    final marker = geoPoint.createMarker(
      markerSize: 30.0,
      mapController: mapController,
      onDragUpdate: (newPosition) {
        geoPoint.point = CmlPoint.fromLatLng(newPosition);
      },
    );
    _routeMarkers.add(marker);
    _updatePolylines();
  }

  void _updatePolylines() {
    _routePolylines.clear();

    if (_controller.elements.length >= 2) {
      final List<LatLng> points = _controller.elements
          .cast<CmlGeoRoutePoint>()
          .map((geoPoint) => geoPoint.point.toLatLng())
          .toList();
      _routePolylines.add(
        Polyline(
          points: points,
          strokeWidth: 3.0,
          color: Colors.blue,
          pattern: StrokePattern.dashed(segments: const [5, 5]),
        ),
      );
    }
  }

  void _removeMarker(int elementIndex) {
    if (elementIndex >= 0 && elementIndex < _routeMarkers.length) {
      _routeMarkers.removeAt(elementIndex);
      _updatePolylines();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Listener(
            onPointerMove: (PointerMoveEvent event) {
              if (_controller.selectedElement is CmlGeoRoutePoint) {
                final newLatLng = _screenToLatLng(event.localPosition);

                _controller.selectedElement?.point = CmlPoint.fromLatLng(
                  newLatLng,
                );
                _updatePolylines();

                setState(() {});
              }
            },
            child: CwMap(
              controller: _mapController,
              markers: _routeMarkers,
              polylines: _routePolylines,
              onTap: _onMapTap,
              interactiveFlags: !_controller.hasSelectedElement,
            ),
          ),
          if (_controller.hasSelectedElement)
            Positioned(
              top: 50,
              right: 20,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.red,
                onPressed: () {
                  if (_controller.selectedElement is CmlGeoRoutePoint) {
                    final selectedIndex = _controller.selectedElementIndex;
                    _controller.removeSelectedElement();

                    _removeMarker(selectedIndex);
                    setState(() {});
                  }
                },
                child: const Icon(Icons.delete, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
