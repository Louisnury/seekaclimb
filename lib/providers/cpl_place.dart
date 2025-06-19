import 'package:commun/commun.dart';
import 'package:seekaclimb/models/cml_place.dart';

class CplPlace extends Provider<CmlPlace> {
  CplPlace({
    super.baseUrl = 'http://192.168.1.194:5000',
    super.tableName = 'places',
  }) : super(route: '/places', fromMapFunction: CmlPlace.fromMap);

  @override
  List<String> getSearchableFields() {
    return ['name'];
  }
}
