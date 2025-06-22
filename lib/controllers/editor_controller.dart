import 'package:flutter/material.dart';
import 'package:seekaclimb/abstract/cal_editor_element.dart';
import 'package:seekaclimb/models/cml_point.dart';
import 'package:seekaclimb/widgets/cw_editor.dart';

/// Contrôleur pour gérer l'éditeur de route
class EditorController extends ChangeNotifier {
  List<CalEditorElement> _elements;
  int _selectedElementIndex = -1;
  double initialElementSize = 0.0;
  Offset? tapPosition;
  EditorMode _mode = EditorMode.edit;
  bool _panAllowed = true;
  bool _scaleAllowed = true;

  final TransformationController _transformationController =
      TransformationController();

  EditorController({
    List<CalEditorElement>? elements,
    EditorMode mode = EditorMode.edit,
  }) : _elements = elements ?? [],
       _mode = mode {
    _configureElementCallbacks();
    _updateElementsInteractivity();
  }

  // Getters
  List<CalEditorElement> get elements => _elements;
  int get selectedElementIndex => _selectedElementIndex;
  CalEditorElement? get selectedElement =>
      _selectedElementIndex >= 0 && _selectedElementIndex < elements.length
      ? elements[_selectedElementIndex]
      : null;
  EditorMode get mode => _mode;
  bool get panAllowed => _panAllowed && _selectedElementIndex == -1;
  bool get scaleAllowed => _scaleAllowed && _selectedElementIndex == -1;
  bool get isEditMode => _mode == EditorMode.edit;
  bool get isViewMode => _mode == EditorMode.view;
  TransformationController get transformationController =>
      _transformationController;

  // Setters
  set elements(List<CalEditorElement> elements) {
    _elements = elements;
    _selectedElementIndex = -1;
    _configureElementCallbacks();
    _updateElementsInteractivity();
    notifyListeners();
  }

  set mode(EditorMode newMode) {
    if (_mode != newMode) {
      _mode = newMode;
      deselectAll();
      _updateElementsInteractivity();
      notifyListeners();
    }
  }

  set panAllowed(bool allowed) {
    if (_panAllowed != allowed) {
      _panAllowed = allowed;
      notifyListeners();
    }
  }

  set scaleAllowed(bool allowed) {
    if (_scaleAllowed != allowed) {
      _scaleAllowed = allowed;
      notifyListeners();
    }
  }

  /// Ajoute un élément à la route
  void addElement(CalEditorElement element, {bool select = true}) {
    _elements.add(element);
    final int newElementIndex = _elements.length - 1;

    // Configurer le callback pour le nouvel élément
    element.onElementTaped = () => selectElement(newElementIndex);

    // Désélectionner tous les autres éléments et sélectionner le nouveau
    _deselectAllSilent();
    if (select) {
      _selectedElementIndex = newElementIndex;
      element.isSelected = true;
    }

    notifyListeners();
  }

  /// Supprime l'élément sélectionné
  void removeSelectedElement() {
    if (_selectedElementIndex >= 0 && _selectedElementIndex < elements.length) {
      elements[_selectedElementIndex].dispose();
      elements.removeAt(_selectedElementIndex);
      _selectedElementIndex = -1;

      // Reconfigurer tous les callbacks après suppression
      _configureElementCallbacks();
      notifyListeners();
    }
  }

  /// Supprime un élément par son index
  void removeElementAt(int index) {
    if (index >= 0 && index < elements.length) {
      elements[index].dispose();
      elements.removeAt(index);

      // Ajuster l'index de sélection si nécessaire
      if (_selectedElementIndex == index) {
        _selectedElementIndex = -1;
      } else if (_selectedElementIndex > index) {
        _selectedElementIndex--;
      }

      // Reconfigurer tous les callbacks après suppression
      _configureElementCallbacks();
      notifyListeners();
    }
  }

  /// Sélectionne un élément par son index
  void selectElement(int index) {
    if (_mode == EditorMode.view) return;

    if (_selectedElementIndex == index) {
      // Si l'élément est déjà sélectionné, le désélectionner
      deselectAll();
      return;
    }

    // Désélectionner tous les éléments
    _deselectAllSilent();

    // Sélectionner l'élément spécifié
    if (index >= 0 && index < elements.length) {
      elements[index].isSelected = true;
      _selectedElementIndex = index;
    }

    notifyListeners();
  }

  /// Désélectionne tous les éléments
  void deselectAll() {
    if (_selectedElementIndex == -1) return;

    _deselectAllSilent();
    notifyListeners();
  }

  /// Désélectionne tous les éléments sans notifier
  void _deselectAllSilent() {
    for (CalEditorElement element in elements) {
      element.isSelected = false;
    }
    _selectedElementIndex = -1;
  }

  /// Convertit une position de tap en point dans l'éditeur
  CmlPoint convertTapPositionToPoint(Offset tapPosition) {
    final Matrix4 matrix = _transformationController.value;
    final Matrix4 invertedMatrix = Matrix4.inverted(matrix);

    return CmlPoint.fromOffset(
      offset: MatrixUtils.transformPoint(invertedMatrix, tapPosition),
    );
  }

  /// Configure les callbacks pour tous les éléments
  void _configureElementCallbacks() {
    for (int i = 0; i < elements.length; i++) {
      final int index = i;
      elements[i].onElementTaped = () => selectElement(index);
    }
  }

  /// Met à jour l'interactivité des éléments selon le mode
  void _updateElementsInteractivity() {
    final bool isInteractive = _mode == EditorMode.edit;
    for (final CalEditorElement element in elements) {
      element.isInteractive = isInteractive;
    }
  }

  /// Gère l'interaction de début (début du geste)
  void onInteractionStart(ScaleStartDetails details) {
    if (_selectedElementIndex != -1) {
      initialElementSize = elements[_selectedElementIndex].size;
    }
  }

  /// Gère la mise à jour de l'interaction (pendant le geste)
  void onInteractionUpdate(ScaleUpdateDetails details) {
    if (_selectedElementIndex != -1) {
      elements[_selectedElementIndex].updateScale(
        initialElementSize * details.scale * 1.1,
      );
      notifyListeners();
    }
  }

  /// Gère la fin de l'interaction
  void onInteractionEnd(ScaleEndDetails details) {}

  /// Gère le tap sur l'éditeur
  void onEditorTap() {
    if (_mode == EditorMode.view) return;

    if (_selectedElementIndex != -1) {
      deselectAll();
    }
  }

  /// Gère le tap down sur l'éditeur
  void onTapDown(TapDownDetails details) {
    if (_mode == EditorMode.view) return;
    tapPosition = details.localPosition;
  }

  /// Retourne le nombre d'éléments
  int get elementCount => elements.length;

  /// Vérifie si la route a des éléments
  bool get hasElements => elements.isNotEmpty;

  /// Vérifie si un élément est sélectionné
  bool get hasSelectedElement => _selectedElementIndex != -1;

  @override
  void dispose() {
    for (final element in elements) {
      element.dispose();
    }
    _transformationController.dispose();
    super.dispose();
  }
}
