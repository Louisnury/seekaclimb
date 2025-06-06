import 'package:commun/commun.dart';
import 'package:flutter/material.dart';
import 'package:seekaclimb/abstract/cal_editor_element.dart';
import 'package:seekaclimb/enums/e_hold_type.dart';
import 'package:seekaclimb/models/cml_circle.dart';
import 'package:seekaclimb/models/cml_point.dart';
import 'package:seekaclimb/models/cml_route.dart';
import 'package:seekaclimb/models/cml_route_point.dart';
import 'package:seekaclimb/widgets/cw_back_button.dart';
import 'package:seekaclimb/widgets/cw_delete_button.dart';
import 'package:seekaclimb/widgets/cw_hold_type_toolbar.dart';
import 'package:seekaclimb/widgets/cw_route_point_toolbar.dart';
import 'package:seekaclimb/widgets/cw_validate_button.dart';

enum RouteEditorMode { circle, point }

class CvlRouteEditor extends StatefulWidget {
  const CvlRouteEditor({super.key});

  @override
  CvlRouteEditorState createState() => CvlRouteEditorState();
}

class CvlRouteEditorState extends State<CvlRouteEditor> {
  int _selectedElementIndex = -1;
  double _initialElementSize = 0.0;
  Offset? _tapPosition;
  Offset? _previousTapPosition;
  final TransformationController _transformationController =
      TransformationController();

  RouteEditorMode _mode = RouteEditorMode.circle;

  // Variables globales pour les propriétés des route points
  Color _globalRoutePointColor = Colors.red;
  double _globalRoutePointWidth = 2.0;

  CmlRoute route = CmlRoute(
    name: 'Example Route',
    wallId: 1,
    description: 'This is an example route for the route editor.',
  );

  void _selectElement(int index) {
    // Désélectionner tous les éléments d'abord
    for (int i = 0; i < route.elements.length; i++) {
      route.elements[i].isSelected =
          (i == index && _selectedElementIndex != index);
    }

    setState(() {
      _selectedElementIndex = (index == _selectedElementIndex) ? -1 : index;
    });
  }

  void _deselectAll() {
    for (CalEditorElement element in route.elements) {
      element.isSelected = false;
    }

    setState(() {
      _selectedElementIndex = -1;
    });
  }

  List<EHoldType> _getSelectedHoldTypes() {
    if (_selectedElementIndex == -1 ||
        _selectedElementIndex >= route.elements.length) {
      return [];
    }
    final element = route.elements[_selectedElementIndex];

    if (element is CmlCircle) {
      return element.holdTypes;
    }

    return [];
  }

  bool _isSelectedElementCircle() {
    if (_selectedElementIndex == -1 ||
        _selectedElementIndex >= route.elements.length) {
      return false;
    }
    return route.elements[_selectedElementIndex] is CmlCircle;
  }

  void _deleteSelectedElement() {
    if (_selectedElementIndex != -1 &&
        _selectedElementIndex < route.elements.length) {
      setState(() {
        route.elements[_selectedElementIndex].dispose();
        route.elements.removeAt(_selectedElementIndex);
        _selectedElementIndex = -1;
      });
    }
  }

  CmlPoint _convertTapPositionToPoint(Offset tapPosition) {
    final Matrix4 matrix = _transformationController.value;
    final Matrix4 invertedMatrix = Matrix4.inverted(matrix);

    return CmlPoint.fromOffset(
      offset: MatrixUtils.transformPoint(invertedMatrix, tapPosition),
    );
  }

  void _createElement() {
    if (_tapPosition case final Offset position) {
      CmlPoint point = _convertTapPositionToPoint(position);

      final newElementIndex = route.elements.length;
      CalEditorElement? newElement;

      switch (_mode) {
        case RouteEditorMode.circle:
          newElement = CmlCircle(
            size: 30 / _transformationController.value.getMaxScaleOnAxis(),
            point: point,
            holdTypes: [],
            onElementTaped: () {
              _selectElement(newElementIndex);
            },
          );

          _selectedElementIndex = newElementIndex;
          newElement.isSelected = true;

          break;
        case RouteEditorMode.point:
          if (_previousTapPosition case final Offset previousPosition) {
            newElement = CmlRoutePoint(
              point: point,
              secondPoint: _convertTapPositionToPoint(previousPosition),
              lineColor: _globalRoutePointColor,
              lineWidth: _globalRoutePointWidth,
              onElementTaped: () {
                _selectElement(newElementIndex);
              },
              onElementChanged: () {
                setState(() {});
              },
            );
          }
          break;
      }

      if (newElement != null) {
        setState(() {
          route.elements.add(newElement!);
        });
      }
    }
  }

  void _onHoldTypeToggled(EHoldType holdType) {
    if (_selectedElementIndex == -1 ||
        _selectedElementIndex >= route.elements.length) {
      return;
    }

    final element = route.elements[_selectedElementIndex];
    if (element is CmlCircle) {
      final currentTypes = List<EHoldType>.from(element.holdTypes);

      if (currentTypes.contains(holdType)) {
        currentTypes.remove(holdType);
      } else {
        currentTypes.add(holdType);
      }

      element.updateHoldTypes(currentTypes);
      setState(() {});
    }
  }

  void _onRoutePointColorChanged(Color color) {
    _globalRoutePointColor = color;

    // Mettre à jour tous les route points existants
    for (CalEditorElement element in route.elements) {
      if (element is CmlRoutePoint) {
        element.updateLineColor(color);
      }
    }

    setState(() {});
  }

  void _onRoutePointWidthChanged(double width) {
    _globalRoutePointWidth = width;

    // Mettre à jour tous les route points existants
    for (CalEditorElement element in route.elements) {
      if (element is CmlRoutePoint) {
        element.updateLineWidth(width);
      }
    }

    setState(() {});
  }

  void _removeLastPoint() {
    List<CmlRoutePoint> routePointList = route.elements
        .whereType<CmlRoutePoint>()
        .toList();
    if (routePointList.isNotEmpty) {
      route.elements.remove(routePointList.last);

      List<CmlRoutePoint> remainingRoutePoints = route.elements
          .whereType<CmlRoutePoint>()
          .toList();

      if (remainingRoutePoints.isNotEmpty) {
        _tapPosition = remainingRoutePoints.last.point.toOffset();
      } else {
        _previousTapPosition = null;
        _tapPosition = null;
      }
    }

    setState(() {});
  }

  @override
  void dispose() {
    for (CalEditorElement element in route.elements) {
      element.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTapDown: (TapDownDetails details) {
              if (_tapPosition == null) {
                _tapPosition = details.localPosition;
              } else {
                if (_mode == RouteEditorMode.point) {
                  _previousTapPosition = _tapPosition;
                }

                _tapPosition = details.localPosition;
              }
            },
            onTap: () {
              if (_selectedElementIndex != -1) {
                _deselectAll();
              } else {
                _createElement();
              }
            },
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 1,
              maxScale: 8,
              // Désactiver le déplacement si un élément est sélectionné
              panEnabled: _selectedElementIndex == -1,
              // Désactiver le zoom si un élément est sélectionné
              scaleEnabled: _selectedElementIndex == -1,
              onInteractionStart: (details) {
                if (_selectedElementIndex != -1) {
                  _initialElementSize =
                      route.elements[_selectedElementIndex].size;
                }
              },
              onInteractionUpdate: (details) {
                if (_selectedElementIndex != -1) {
                  route.elements[_selectedElementIndex].updateScale(
                    _initialElementSize * details.scale * 1.1,
                  );
                }
              },
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: [
                    Center(
                      child: CachedImage(
                        imageUrl:
                            'https://lh3.googleusercontent.com/gps-cs-s/AC9h4nryR3KLfENZzSCkSmzxgkm5YbCejf85PJnVHe9QNF53PT9P84_IxdRfsCbYFwu9WlAASrA3yAmizlNTx0ok8ALshgU-aHF_3At9nk4RoO0C71c0t2RDBq3itC0dBbUm7cL4QjA0=s1360-w1360-h1020',
                      ),
                    ),
                    ...route.elements.map((element) => element.toWidget()),
                  ],
                ),
              ),
            ),
          ),

          const CwBackButton(),
          CwAnimatedPositionedWidget(
            isVisible: true,
            bottom: _selectedElementIndex != -1 ? 113.0 : 25.0,
            right: _selectedElementIndex != -1 ? 75.0 : 12.0,
            emptyKey: const ValueKey('empty-delete'),
            child: CwValidateButton(
              key: const ValueKey('delete'),
              onPressed: _deleteSelectedElement,
            ),
          ),

          CwAnimatedPositionedWidget(
            isVisible: _selectedElementIndex != -1,
            bottom: 113.0,
            right: 12.0,
            slideBeginOffset: Offset(1.0, 1.5),
            emptyKey: const ValueKey('empty-delete-2'),
            child: CwDeleteButton(
              key: const ValueKey('delete-2'),
              onPressed: _deleteSelectedElement,
            ),
          ),

          CwAnimatedPositionedWidget(
            isVisible: _mode == RouteEditorMode.point,
            bottom: 145.0,
            right: 12.0,
            slideBeginOffset: Offset(1.0, 1.5),
            emptyKey: const ValueKey('empty-delete-2'),
            child: CwDeleteButton(
              key: const ValueKey('delete-2'),
              onPressed: _removeLastPoint,
            ),
          ),

          Positioned(
            right: 20,
            top: 29,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _tapPosition = null;
                  _previousTapPosition = null;
                  _mode = _mode == RouteEditorMode.circle
                      ? RouteEditorMode.point
                      : RouteEditorMode.circle;
                });
              },
              child: Text("data"),
            ),
          ),

          // Barre d'outils flottante en bas pour les cercles
          CwAnimatedPositionedWidget(
            isVisible:
                _selectedElementIndex != -1 && _isSelectedElementCircle(),
            bottom: 0,
            left: 0,
            right: 0,
            slideBeginOffset: const Offset(0.0, 1.0),
            emptyKey: const ValueKey('empty-toolbar'),
            child: CwHoldTypeToolbar(
              key: const ValueKey('toolbar'),
              selectedHoldTypes: _getSelectedHoldTypes(),
              onHoldTypeToggled: _onHoldTypeToggled,
            ),
          ),

          // Barre d'outils flottante en bas pour les route points
          CwAnimatedPositionedWidget(
            isVisible: _mode == RouteEditorMode.point,
            bottom: 0,
            left: 0,
            right: 0,
            slideBeginOffset: const Offset(0.0, 1.0),
            emptyKey: const ValueKey('empty-route-toolbar'),
            child: CwRoutePointToolbar(
              key: const ValueKey('route-toolbar'),
              selectedColor: _globalRoutePointColor,
              selectedWidth: _globalRoutePointWidth,
              onColorChanged: _onRoutePointColorChanged,
              onWidthChanged: _onRoutePointWidthChanged,
            ),
          ),
        ],
      ),
    );
  }
}
