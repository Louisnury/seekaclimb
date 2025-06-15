import 'package:commun/commun.dart';
import 'package:flutter/material.dart';
import 'package:seekaclimb/models/cml_point.dart';

abstract class CalEditorElement extends Serializable {
  /// Coordonées de l'élément dans l'éditeur
  final ValueNotifier<CmlPoint> pointNotifier = ValueNotifier<CmlPoint>(
    CmlPoint(x: 0, y: 0),
  );

  /// Taille de l'élément
  final ValueNotifier<double> sizeNotifier = ValueNotifier<double>(30.0);

  /// CallBack pour gérer les interactions avec l'élément
  VoidCallback? onElementTaped;
  VoidCallback? onElementChanged;

  /// Indique si l'élément est interactif (peut être tapé et déplacé)
  bool isInteractive = true;

  final ValueNotifier<bool> isSelectedNotifier = ValueNotifier<bool>(false);

  bool get isSelected => isSelectedNotifier.value;
  set isSelected(bool value) => isSelectedNotifier.value = value;

  set point(CmlPoint value) {
    pointNotifier.value = value;
  }

  CmlPoint get point => pointNotifier.value;

  set size(double value) {
    sizeNotifier.value = value;
  }

  double get size => sizeNotifier.value;

  Widget toWidget();

  /// Méthode de désérialisation à implémenter par les classes concrètes
  static CalEditorElement fromMap(Map<String, dynamic> map) {
    throw UnimplementedError(
      'La méthode fromMap doit être implémentée par chaque classe concrète.',
    );
  }

  void updateScale(double scale);

  // Dispose du ValueNotifier pour éviter les fuites mémoire
  void dispose() {
    isSelectedNotifier.dispose();
  }
}
