import 'dart:ui';
import 'package:commun/commun.dart';

class CmlPoint extends Serializable {
  double x;
  double y;

  CmlPoint({required this.x, required this.y});

  CmlPoint.fromOffset({required Offset offset}) : x = offset.dx, y = offset.dy;

  @override
  Map<String, dynamic> toMap() => {'x': x, 'y': y};

  static CmlPoint fromMap(Map<String, dynamic> map) =>
      CmlPoint(x: map['x'] as double, y: map['y'] as double);

  Offset toOffset() => Offset(x, y);
}
