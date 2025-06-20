import 'package:flutter/material.dart';

enum EGrade { jaune, orange, bleue, rouge, noire, blanche, verte }

extension EGradeExtension on EGrade {
  static EGrade eHoldTypeFromKey(int index) {
    return switch (index) {
      0 => EGrade.jaune,
      1 => EGrade.orange,
      2 => EGrade.bleue,
      3 => EGrade.rouge,
      4 => EGrade.noire,
      5 => EGrade.blanche,
      6 => EGrade.verte,
      _ => throw ArgumentError('Index $index invalide pour EHoldType'),
    };
  }

  Color getColor() {
    return switch (this) {
      EGrade.jaune => Colors.yellow,
      EGrade.orange => Colors.orange,
      EGrade.bleue => Colors.blue,
      EGrade.rouge => Colors.red,
      EGrade.noire => Colors.black,
      EGrade.blanche => Colors.white,
      EGrade.verte => Colors.green,
    };
  }

  String get label {
    return switch (this) {
      EGrade.jaune => 'Jaune',
      EGrade.orange => 'Orange',
      EGrade.bleue => 'Bleue',
      EGrade.rouge => 'Rouge',
      EGrade.noire => 'Noire',
      EGrade.blanche => 'Blanche',
      EGrade.verte => 'Verte',
    };
  }

}
