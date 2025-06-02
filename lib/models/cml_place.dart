import 'package:commun/commun.dart';
import 'package:latlong2/latlong.dart';

class CmlPlace extends Serializable {
  final int id;
  final String name;
  final LatLng location;
  final List<LatLng> parkingLocation;
  final Map<String, List<LatLng>> accesPath;
  final String? description;
  final String? addresse;
  final bool isIndoor;

  CmlPlace({
    required this.id,
    required this.name,
    required this.location,
    this.parkingLocation = const [],
    this.accesPath = const {},
    this.description,
    this.addresse,
    this.isIndoor = false,
  });

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'lat': location.latitude,
    'long': location.longitude,
    'description': description,
    'addresse': addresse,
    'isIndoor': isIndoor,
  };

  CmlPlace fromMap(Map<String, dynamic> map) {
    return CmlPlace(
      id: map['id'] as int,
      name: map['name'] as String,
      location: LatLng(map['lat'] as double, map['long'] as double),
      description: map['description'] as String?,
      addresse: map['addresse'] as String?,
      isIndoor: map['isIndoor'] as bool? ?? false,
    );
  }
}
