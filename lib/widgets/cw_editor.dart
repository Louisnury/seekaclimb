import 'package:flutter/material.dart';
import 'package:seekaclimb/abstract/cal_editor_element.dart';
import 'package:seekaclimb/models/cml_point.dart';
import 'package:seekaclimb/controllers/editor_controller.dart';

enum EditorMode { edit, view }

class CwEditor extends StatefulWidget {
  final EditorController? controller;
  final CalEditorElement Function(CmlPoint point) createElementCallback;
  final List<CustomPainter> Function()? paintersBuilder;
  final Widget backgroundWidget;

  const CwEditor({
    super.key,
    this.controller,
    required this.createElementCallback,
    this.paintersBuilder,
    required this.backgroundWidget,
  });

  @override
  CwEditorState createState() => CwEditorState();
}

class CwEditorState extends State<CwEditor> {
  late final EditorController _controller;

  @override
  void initState() {
    super.initState();

    // Utiliser le contrôleur fourni ou en créer un nouveau
    _controller = widget.controller ?? EditorController();

    // Écouter les changements du contrôleur
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);

    // Ne dispose le contrôleur que si on l'a créé nous-mêmes
    if (widget.controller == null) {
      _controller.dispose();
    }

    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {
      // Le setState sera appelé quand le contrôleur notifie des changements
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapDown: _controller.isViewMode
                ? null
                : (TapDownDetails details) {
                    _controller.onTapDown(details);
                  },
            onTap: _controller.isViewMode
                ? null
                : () {
                    if (_controller.hasSelectedElement) {
                      _controller.deselectAll();
                    } else {
                      final CmlPoint tapPoint = _controller
                          .convertTapPositionToPoint(_controller.tapPosition!);
                      final CalEditorElement newElement = widget
                          .createElementCallback(tapPoint);
                      _controller.addElement(newElement);
                    }
                  },
            child: InteractiveViewer(
              transformationController: _controller.transformationController,
              minScale: 1,
              maxScale: 8,
              panEnabled: _controller.panAllowed,
              scaleEnabled: _controller.scaleAllowed,
              onInteractionStart: _controller.onInteractionStart,
              onInteractionUpdate: _controller.onInteractionUpdate,
              onInteractionEnd: _controller.onInteractionEnd,
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: [
                    // Element de fond
                    Center(child: widget.backgroundWidget),

                    // Painters customisés
                    if (widget.paintersBuilder != null)
                      ...widget.paintersBuilder!().map(
                        (painter) => CustomPaint(painter: painter),
                      ),

                    // Affichage des éléments
                    ..._controller.elements.map(
                      (element) => element.toWidget(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
