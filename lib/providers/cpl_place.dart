import 'package:commun/commun.dart';
import 'package:seekaclimb/models/cml_place.dart';

class CplPlace extends Provider<CmlPlace> {
  CplPlace({
    String? placeName,
    super.baseUrl = 'https://api.seekaclimb.com',
    super.tableName = 'places',
  }) : super(
         route: placeName != null
             ? '/api/places?name=$placeName'
             : '/api/places',
         fromMapFunction: CmlPlace.fromMap,
       );

  /// Recherche des lieux par nom
  Future<void> searchPlaces(String query) async {
    await loadData(queryParams: {'search': query});
  }

  /// Recherche des lieux dans un rayon donné
  Future<void> searchPlacesInRadius({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    await loadData(
      queryParams: {
        'lat': latitude.toString(),
        'long': longitude.toString(),
        'radius': radiusKm.toString(),
      },
    );
  }

  /// Filtre les lieux par type (indoor/outdoor)
  Future<void> filterByType({required bool isIndoor}) async {
    await loadData(queryParams: {'is_indoor': isIndoor.toString()});
  }

  /// Obtient un lieu spécifique par son ID
  Future<CmlPlace?> getPlaceById(int id) async {
    try {
      final place = items.firstWhere((place) => place.id == id);
      return place;
    } catch (e) {
      // Si le lieu n'est pas dans la liste locale, essayer de le charger depuis l'API
      await loadData(queryParams: {'id': id.toString()});
      try {
        return items.firstWhere((place) => place.id == id);
      } catch (e) {
        return null;
      }
    }
  }
}
