import 'package:commun/commun.dart';
import 'package:seekaclimb/models/cml_route.dart';

class CplRoute extends Provider<CmlRoute> {
  final int? placeId;

  CplRoute({
    this.placeId,
    super.baseUrl = 'https://api.seekaclimb.com',
    super.tableName = 'routes',
  }) : super(
         fromMapFunction: CmlRoute.fromMap,
         route: placeId == null
             ? '/api/routes'
             : '/api/routes?place_id=$placeId',
       );
}
