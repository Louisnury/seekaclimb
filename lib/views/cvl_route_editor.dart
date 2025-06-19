import 'package:commun/commun.dart';
import 'package:flutter/material.dart';
import 'package:seekaclimb/abstract/cal_editor_element.dart';
import 'package:seekaclimb/enums/e_hold_type.dart';
import 'package:seekaclimb/models/cml_circle.dart';
import 'package:seekaclimb/models/cml_point.dart';
import 'package:seekaclimb/models/cml_route.dart';
import 'package:seekaclimb/models/cml_route_point.dart';
import 'package:seekaclimb/widgets/cw_back_button.dart';
import 'package:seekaclimb/widgets/cw_floating_button.dart';
import 'package:seekaclimb/widgets/cw_hold_type_toolbar.dart';
import 'package:seekaclimb/widgets/cw_route_point_toolbar.dart';
import 'package:seekaclimb/widgets/painters/route_point_painters.dart';

enum RouteEditorMode { circle, point, view }

class CvlRouteEditor extends StatefulWidget {
  final CmlRoute? route;
  const CvlRouteEditor({super.key, this.route});

  @override
  CvlRouteEditorState createState() => CvlRouteEditorState();
}

class CvlRouteEditorState extends State<CvlRouteEditor> {
  int _selectedElementIndex = -1;
  double _initialElementSize = 0.0;
  Offset? _tapPosition;
  final TransformationController _transformationController =
      TransformationController();

  RouteEditorMode _mode = RouteEditorMode.circle;

  // Variables globales pour les propriétés des route points
  Color _globalRoutePointColor = Colors.red;
  double _globalRoutePointWidth = 2.0;

  late final CmlRoute route;
  @override
  void initState() {
    super.initState();
    if (widget.route case final CmlRoute widgetRoute) {
      route = widgetRoute;
      _mode = RouteEditorMode.view;
      _switchInteractivity();
    } else {
      route = CmlRoute(name: '', wallId: 1, description: '', elements: []);
    }
  }

  void _switchInteractivity() {
    final bool isInteractive = _mode != RouteEditorMode.view;

    for (final CalEditorElement element in route.elements) {
      element.isInteractive = isInteractive;
      element.onElementTaped = isInteractive
          ? () => _selectElement(element)
          : null;
    }
  }

  void _selectElement(CalEditorElement element) {
    final int index = route.elements.indexOf(element);
    if (index == -1) return;

    // Optimisation: éviter les boucles inutiles
    final bool shouldSelect = index != _selectedElementIndex;

    for (int i = 0; i < route.elements.length; i++) {
      route.elements[i].isSelected = (i == index && shouldSelect);
    }

    setState(() {
      _selectedElementIndex = shouldSelect ? index : -1;
    });
  }

  void _deselectAll() {
    if (_selectedElementIndex == -1) return; // Éviter setState inutile

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
    return element is CmlCircle ? element.holdTypes : [];
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
      final CmlPoint point = _convertTapPositionToPoint(position);

      final CalEditorElement? newElement = switch (_mode) {
        RouteEditorMode.circle => CmlCircle(
          size: 30 / _transformationController.value.getMaxScaleOnAxis(),
          point: point,
          holdTypes: [],
        ),
        RouteEditorMode.point => CmlRoutePoint(
          point: point,
          lineColor: _globalRoutePointColor,
          lineWidth: _globalRoutePointWidth,
        ),
        RouteEditorMode.view => null,
      };

      if (newElement != null) {
        newElement.onElementTaped = () => _selectElement(newElement);

        setState(() {
          route.elements.add(newElement);

          // Sélectionner automatiquement les cercles
          if (newElement is CmlCircle) {
            final newElementIndex = route.elements.length - 1;
            _selectedElementIndex = newElementIndex;
            newElement.isSelected = true;
          }
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

      element.holdTypes = currentTypes;
      setState(() {});
    }
  }

  void _onRoutePointColorChanged(Color color) {
    _globalRoutePointColor = color;

    // Mettre à jour tous les route points existants
    for (final CalEditorElement element in route.elements) {
      if (element is CmlRoutePoint) {
        element.updateLineColor(color);
      }
    }

    setState(() {});
  }

  void _onRoutePointWidthChanged(double width) {
    _globalRoutePointWidth = width;

    // Mettre à jour tous les route points existants
    for (final CalEditorElement element in route.elements) {
      if (element is CmlRoutePoint) {
        element.updateLineWidth(width);
      }
    }

    setState(() {});
  }

  void _removeLastPoint() {
    _selectedElementIndex = -1;
    final routePointList = route.elements.whereType<CmlRoutePoint>().toList();

    if (routePointList.isNotEmpty) {
      route.elements.remove(routePointList.last);

      final remainingRoutePoints = route.elements
          .whereType<CmlRoutePoint>()
          .toList();

      _tapPosition = remainingRoutePoints.isNotEmpty
          ? remainingRoutePoints.last.point.toOffset()
          : null;
    }

    setState(() {});
  }

  void _switchMode() {
    setState(() {
      _mode = _mode == RouteEditorMode.circle
          ? RouteEditorMode.point
          : RouteEditorMode.circle;

      _tapPosition = _mode == RouteEditorMode.circle
          ? null
          : route.elements
                .whereType<CmlRoutePoint>()
                .lastOrNull
                ?.point
                .toOffset();

      _deselectAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTapDown: _mode == RouteEditorMode.view
                ? null
                : (TapDownDetails details) {
                    _tapPosition = details.localPosition;
                  },
            onTap: _mode == RouteEditorMode.view
                ? null
                : () {
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
              panEnabled: _selectedElementIndex == -1,
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
                    // Affichage des route points en premier (arrière-plan) avec CustomPainter
                    Builder(
                      builder: (context) {
                        final routePoints = route.elements
                            .whereType<CmlRoutePoint>()
                            .toList();
                        if (routePoints.isEmpty) return const SizedBox.shrink();

                        return CustomPaint(
                          painter: CwlFullRoutePointPainter(
                            routePoints: routePoints,
                            color: _globalRoutePointColor,
                            animationValue: 1.0,
                            lineWidth: _globalRoutePointWidth,
                          ),
                          child: const SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        );
                      },
                    ),

                    // Affichage des autres éléments
                    ...route.elements.map((element) => element.toWidget()),
                  ],
                ),
              ),
            ),
          ),

          const CwBackButton(),

          if (_mode != RouteEditorMode.view) ...[
            CwAnimatedPositionedWidget(
              isVisible: true,
              bottom: _selectedElementIndex != -1 ? 113.0 : 25.0,
              right: _selectedElementIndex != -1 ? 75.0 : 12.0,
              emptyKey: const ValueKey('empty-validate'),
              child: CwFloatingButton(
                backgroundColor: Colors.black,
                icon: Icons.check_rounded,
                iconColor: Colors.green.shade500,
                key: const ValueKey('validate'),
                onPressed: () {
                  // TODO: Logique de validation/sauvegarde
                },
              ),
            ),

            if (_selectedElementIndex != -1)
              CwAnimatedPositionedWidget(
                isVisible: true,
                bottom: 113.0,
                right: 12.0,
                slideBeginOffset: const Offset(1.0, 1.5),
                emptyKey: const ValueKey('empty-delete'),
                child: CwFloatingButton(
                  backgroundColor: const Color(0xFFEF4444),
                  icon: Icons.delete_outline_rounded,
                  key: const ValueKey('delete'),
                  onPressed: _deleteSelectedElement,
                ),
              ),

            if (_mode == RouteEditorMode.point)
              CwAnimatedPositionedWidget(
                isVisible: true,
                bottom: 145.0,
                right: 12.0,
                slideBeginOffset: const Offset(1.0, 1.5),
                emptyKey: const ValueKey('empty-undo'),
                child: CwFloatingButton(
                  backgroundColor: Colors.black,
                  icon: Icons.undo_rounded,
                  key: const ValueKey('undo'),
                  onPressed: _removeLastPoint,
                ),
              ),
          ],

          if (_mode != RouteEditorMode.view)
            Positioned(
              right: 20,
              top: 29,
              child: ElevatedButton(
                onPressed: _switchMode,
                child: Text(
                  _mode == RouteEditorMode.circle ? "Circle" : "Point",
                ),
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
