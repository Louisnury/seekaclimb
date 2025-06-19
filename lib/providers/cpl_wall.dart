import 'package:commun/commun.dart';
import 'package:seekaclimb/models/cml_wall.dart';

class CplWall extends Provider<CmlWall> {
  CplWall({
    super.baseUrl = 'http://192.168.1.194:5000',
    super.tableName = 'walls',
  }) : super(route: '/walls', fromMapFunction: CmlWall.fromMap);
}
