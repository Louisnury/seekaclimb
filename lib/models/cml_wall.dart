import 'package:commun/commun.dart';

class CmlWall extends Serializable {
  /// Nom du mur
  final String name;

  /// Id du mur
  final int id;

  /// Url de la photo du mur
  String? imageUrl;

  String? thumbnailUrl;

  CmlWall({
    required this.id,
    required this.name,
    this.imageUrl,
    this.thumbnailUrl,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  static CmlWall fromMap(Map<String, dynamic> map) {
    return CmlWall(
      id: map['id'],
      name: map['name'] as String,
      imageUrl: map['imageUrl'] as String?,
      thumbnailUrl: map['thumbnailUrl'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is CmlWall) {
      return id == other.id;
    }

    return false;
  }

  @override
  int get hashCode => id.hashCode;
}
