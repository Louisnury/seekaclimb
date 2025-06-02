import 'package:commun/commun.dart';
import 'package:flutter/material.dart';
import 'package:seekaclimb/models/cml_point.dart';

abstract class CalEditorElement extends Serializable {
  /// Coordonées de l'élément dans l'éditeur
  late CmlPoint point;

  /// Taille de l'élément
  late double size;

  /// CallBack pour gérer les interactions avec l'élément
  VoidCallback? onElementTaped;
  VoidCallback? onElementChanged;

  final ValueNotifier<bool> isSelectedNotifier = ValueNotifier<bool>(
    false,
  );

  bool get isSelected => isSelectedNotifier.value;
  set isSelected(bool value) => isSelectedNotifier.value = value;
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
