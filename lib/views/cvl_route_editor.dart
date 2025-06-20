import 'package:commun/commun.dart';
import 'package:flutter/material.dart';
import 'package:seekaclimb/abstract/cal_editor_element.dart';
import 'package:seekaclimb/enums/e_hold_type.dart';
import 'package:seekaclimb/models/cml_circle.dart';
import 'package:seekaclimb/models/cml_route.dart';
import 'package:seekaclimb/models/cml_route_point.dart';
import 'package:seekaclimb/models/cml_wall.dart';
import 'package:seekaclimb/widgets/cw_editor.dart';
import 'package:seekaclimb/controllers/editor_controller.dart';
import 'package:seekaclimb/widgets/cw_floating_button.dart';
import 'package:seekaclimb/widgets/cw_hold_type_toolbar.dart';
import 'package:seekaclimb/widgets/cw_route_point_toolbar.dart';
import 'package:seekaclimb/widgets/painters/route_point_painters.dart';

class CvlRouteEditor extends StatefulWidget {
  final CmlWall wall;
  final CmlRoute? route;

  const CvlRouteEditor({super.key, required this.wall, this.route});

  @override
  CvlRouteEditorState createState() => CvlRouteEditorState();
}

class CvlRouteEditorState extends State<CvlRouteEditor> {
  late final EditorController _controller;
  int mode = 0;

  @override
  void initState() {
    super.initState();
    if (widget.route case final CmlRoute route) {
      _controller = EditorController(
        mode: EditorMode.view,
        elements: route.elements,
      );
    } else {
      _controller = EditorController(mode: EditorMode.edit);
    }

    // Pour rafraîchir l'interface et afficher les boutons
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void onWidthChanged(double width) {
    CmlRoutePoint.lineWidth = width;
    setState(() {});
  }

  List<EHoldType> _getSelectedHoldTypes() {
    if (_controller.selectedElement case final CmlCircle circle) {
      return circle.holdTypes;
    }

    return [];
  }

  void _onHoldTypeToggled(EHoldType holdType) {
    if (_controller.selectedElement case final CmlCircle circle) {
      if (circle.holdTypes.contains(holdType)) {
        circle.holdTypes.remove(holdType);
      } else {
        circle.holdTypes.add(holdType);
      }
    }
  }

  void _removeLast() {
    _controller.removeElementAt(_controller.elements.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Editor(
            controller: _controller,
            createElementCallback: (position) {
              final CalEditorElement newElement = mode == 0
                  ? CmlCircle(point: position)
                  : CmlRoutePoint(point: position);
              newElement.isSelected = true;
              return newElement;
            },
            backgroundWidget: widget.wall.imageUrl != null
                ? CachedImage(imageUrl: widget.wall.imageUrl!)
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_outlined,
                          size: 64,
                          color: Colors.black,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Aucune image disponible pour ce mur',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),

            paintersBuilder: () => [
              CwlFullRoutePointPainter(
                routePoints: _controller.elements
                    .whereType<CmlRoutePoint>()
                    .toList(),
                color: Colors.black,
                animationValue: 1.0,
                lineWidth: CmlRoutePoint.lineWidth,
              ),
            ],
          ),

          if (_controller.mode != EditorMode.view) ...[
            CwAnimatedPositionedWidget(
              isVisible: true,
              bottom: _controller.hasSelectedElement ? 113.0 : 25.0,
              right: _controller.hasSelectedElement ? 75.0 : 12.0,
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

            if (_controller.hasSelectedElement)
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
                  onPressed: _controller.removeSelectedElement,
                ),
              ),

            if (mode == 1)
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
                  onPressed: _removeLast,
                ),
              ),
          ],

          if (_controller.mode != EditorMode.view)
            Positioned(
              right: 20,
              top: 29,
              child: ElevatedButton(
                onPressed: () {
                  mode = (mode + 1) % 2;
                  _controller.deselectAll();
                  setState(() {});
                },
                child: Text(mode == 0 ? "Circle" : "Point"),
              ),
            ),

          // Barre d'outils flottante en bas pour les cercles
          CwAnimatedPositionedWidget(
            isVisible:
                _controller.hasSelectedElement &&
                _controller.selectedElement is CmlCircle,
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
            isVisible: mode == 1,
            bottom: 0,
            left: 0,
            right: 0,
            slideBeginOffset: const Offset(0.0, 1.0),
            emptyKey: const ValueKey('empty-route-toolbar'),
            child: CwRoutePointToolbar(
              key: const ValueKey('route-toolbar'),
              onWidthChanged: onWidthChanged,
            ),
          ),
        ],
      ),
    );
  }
}
