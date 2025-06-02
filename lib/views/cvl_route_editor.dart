import 'package:commun/commun.dart';
import 'package:flutter/material.dart';
import 'package:seekaclimb/abstract/cal_editor_element.dart';
import 'package:seekaclimb/enums/e_hold_type.dart';
import 'package:seekaclimb/models/cml_circle.dart';
import 'package:seekaclimb/models/cml_point.dart';
import 'package:seekaclimb/models/cml_route.dart';
import 'package:seekaclimb/widgets/cw_back_button.dart';
import 'package:seekaclimb/widgets/cw_delete_button.dart';
import 'package:seekaclimb/widgets/cw_hold_type_toolbar.dart';
import 'package:seekaclimb/widgets/cw_validate_button.dart';

class CvlRouteEditor extends StatefulWidget {
  const CvlRouteEditor({super.key});

  @override
  CvlRouteEditorState createState() => CvlRouteEditorState();
}

class CvlRouteEditorState extends State<CvlRouteEditor> {
  int _selectedElementIndex = -1;
  double _initialElementSize = 0.0;
  Offset? _tapPosition;
  final TransformationController _transformationController =
      TransformationController();

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
      _selectedElementIndex = (index == _selectedElementIndex)
          ? -1
          : index;
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

  void _createCircle() {
    final Matrix4 matrix = _transformationController.value;
    final Offset globalPosition = _tapPosition!;
    final Matrix4 invertedMatrix = Matrix4.inverted(matrix);
    final Offset localPosition = MatrixUtils.transformPoint(
      invertedMatrix,
      globalPosition,
    );

    final newElementIndex = route.elements.length;
    final newCircle = CmlCircle(
      size: 30 / _transformationController.value.getMaxScaleOnAxis(),
      point: CmlPoint(x: localPosition.dx, y: localPosition.dy),
      holdTypes: [],
      onElementTaped: () {
        _selectElement(newElementIndex);
      },
    );

    setState(() {
      _selectedElementIndex = newElementIndex;
      route.elements.add(newCircle);
      newCircle.isSelected = true;
    });
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
              _tapPosition = details.localPosition;
            },
            onTap: () {
              if (_selectedElementIndex != -1) {
                _deselectAll();
              } else if (_tapPosition != null) {
                _createCircle();
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

          // Barre d'outils flottante en bas
          CwAnimatedPositionedWidget(
            isVisible: _selectedElementIndex != -1,
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
        ],
      ),
    );
  }
}
