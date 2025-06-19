import 'package:commun/commun.dart';
import 'package:seekaclimb/models/cml_route.dart';

class CplRoute extends Provider<CmlRoute> {
  CplRoute({
    super.baseUrl = 'http://192.168.1.194:5000',
    super.tableName = 'routes',
  }) : super(route: '/routes', fromMapFunction: CmlRoute.fromMap);
}
