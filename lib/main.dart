import 'package:commun/commun.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:seekaclimb/models/cml_place.dart';
import 'package:seekaclimb/models/cml_user.dart';
import 'package:seekaclimb/views/cvl_home.dart';
import 'package:seekaclimb/views/cvl_places.dart';
import 'package:seekaclimb/views/cvl_route_editor.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    try {
      await FMTCObjectBoxBackend().initialise();
      await FMTCStore('mapStore').manage.create();
    } catch (e) {
      debugPrint('Erreur d\'initialisation FMTC: $e');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AppInitializer(
        config: AppInitializerConfig(
          appName: 'SeekAClimb',
          appDescription: 'Jsp',
          appIcon: Icons.landscape_rounded,
          primaryColor: Colors.blue[600],
          initFunction: _initializeAppData,
          appBuilder: (data) => _buildMainApp(data),
        ),
      ),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }

  Future<Map<String, dynamic>> _initializeAppData() async {
    // Initialiser le DatabaseManager en premier
    await DatabaseManager.instance.initialize();

    final results = await Future.wait([CmlUser.get(), CmlPlace.get()]);

    return {
      'user': results[0] as CmlUser?,
      'currentPlace': results[1] as CmlPlace?,
    };
  }

  Widget _buildMainApp(Map<String, dynamic> data) {
    CmlUser? user = data['user'];
    CmlPlace? currentPlace = data['currentPlace'];

    return ModelBox(
      models: {"user": user, "currentPlace": currentPlace, "currentWall": null},
      child: NavigatorWidget(
        initialPage: const CvlHome(),
        config: const NavigatorConfig(),
        routes: {
          '/home': (context) => const CvlHome(),
          '/place': (context) => const CvlPlaces(),
          '/editor': (context) => const CvlRouteEditor(),
        },
        bottomNavigationItems: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_rounded),
            label: 'Carte',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_rounded),
            label: 'Places',
          ),
        ],
        bottomNavigationRoutes: const ['/editor', '/home', '/place'],
        initialBottomNavIndex: 1,
        showBottomNavigation: true,
      ),
    );
  }
}
