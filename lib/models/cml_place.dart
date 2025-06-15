import 'dart:convert';
import 'package:commun/commun.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

  static final _secureStorage = const FlutterSecureStorage();

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
  static CmlPlace fromMap(Map<String, dynamic> map) {
    return CmlPlace(
      id: map['id'] as int,
      name: map['name'] as String,
      location: LatLng(map['lat'] as double, map['long'] as double),
      parkingLocation: _parseLatLngList(map['parking_locations']),
      accesPath: _parseAccesPath(map['acces_path']),
      description: map['description'] as String?,
      addresse: map['addresse'] as String?,
      isIndoor: map['isIndoor'] as bool? ?? false,
    );
  }

  /// Parse une liste de coordonnées depuis la réponse API
  static List<LatLng> _parseLatLngList(dynamic data) {
    if (data == null) return [];

    if (data is List) {
      return data
          .map((item) {
            if (item is Map<String, dynamic>) {
              return LatLng(item['lat'] as double, item['long'] as double);
            }
            return null;
          })
          .where((item) => item != null)
          .cast<LatLng>()
          .toList();
    }

    return [];
  }

  /// Parse les chemins d'accès depuis la réponse API
  static Map<String, List<LatLng>> _parseAccesPath(dynamic data) {
    if (data == null) return {};

    if (data is Map<String, dynamic>) {
      final Map<String, List<LatLng>> result = {};

      data.forEach((key, value) {
        result[key] = _parseLatLngList(value);
      });

      return result;
    }

    return {};
  }

  static Future<CmlPlace?> get() async {
    final placeData = await _secureStorage.read(key: 'current_place');
    if (placeData != null) {
      return CmlPlace.fromMap(jsonDecode(placeData));
    }

    return null;
  }

  static Future<bool> save(CmlPlace place) async {
    try {
      final placeJson = jsonEncode(place.toMap());
      await _secureStorage.write(key: 'current_place', value: placeJson);

      return true;
    } catch (e) {
      return false;
    }
  }
}
