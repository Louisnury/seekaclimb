import 'package:commun/commun.dart';
import 'package:seekaclimb/abstract/cal_editor_element.dart';

class CmlRoute extends Serializable {
  String name;
  int wallId;
  String? description;
  List<CalEditorElement> elements;

  CmlRoute({
    required this.name,
    required this.wallId,
    description,
    List<CalEditorElement>? elements,
  }) : elements = elements ?? [];

  @override
  Map<String, dynamic> toMap() => {
    'name': name,
    'wallId': wallId,
    'description': description,
    'elements': elements.map((e) => e.toMap()).toList(),
  };

  static CmlRoute fromMap(Map<String, dynamic> map) {
    return CmlRoute(
      name: map['name'] as String,
      wallId: map['wallId'] as int,
      description: map['description'] as String?,
      elements: (map['elements'] as List<dynamic>)
          .map(
            (element) =>
                CalEditorElement.fromMap(element as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
